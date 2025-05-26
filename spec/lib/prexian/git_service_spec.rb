# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe Prexian::GitService do
  let(:temp_cache_dir) { Dir.mktmpdir('prexian_test_cache') }
  let(:temp_dest_dir) { Dir.mktmpdir('prexian_test_dest') }

  after do
    FileUtils.rm_rf(temp_cache_dir) if Dir.exist?(temp_cache_dir)
    FileUtils.rm_rf(temp_dest_dir) if Dir.exist?(temp_dest_dir)
  end

  describe '#initialize' do
    it 'creates cache directory if it does not exist' do
      non_existent_dir = File.join(temp_cache_dir, 'non_existent')
      described_class.new(cache_dir: non_existent_dir)

      expect(Dir.exist?(non_existent_dir)).to be true
    end

    it 'uses default cache directory when none provided' do
      service = described_class.new
      expected_default = File.expand_path('~/.prexian/cache/repos')

      expect(service.instance_variable_get(:@cache_dir)).to eq(expected_default)
    end

    it 'uses environment variable for cache directory' do
      ENV['ROP_CACHE_DIR'] = temp_cache_dir
      service = described_class.new

      expect(service.instance_variable_get(:@cache_dir)).to eq(temp_cache_dir)
    ensure
      ENV.delete('ROP_CACHE_DIR')
    end
  end

  describe '#shallow_checkout' do
    let(:service) { described_class.new(cache_dir: temp_cache_dir) }
    let(:repo_url) { 'https://github.com/octocat/Hello-World' }

    it 'uses specified branch' do
      branch = 'master'
      result = service.shallow_checkout(repo_url, branch: branch)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:success)
      expect(result).to have_key(:local_path)
      expect(result[:local_path]).to include(branch) if result[:success]
    end

    it 'handles sparse checkout subtrees' do
      subtrees = %w[docs _posts]
      branch = 'master'
      result = service.shallow_checkout(repo_url, branch: branch, sparse_subtrees: subtrees)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:success)
      expect(result).to have_key(:local_path)
    end

    it 'handles git errors gracefully' do
      invalid_repo_url = 'https://invalid-domain-that-does-not-exist.com/repo.git'
      expect {
        service.shallow_checkout(invalid_repo_url)
      }.to raise_error(Prexian::GitService::GitError)
    end
  end

  describe '#copy_cached_content' do
    let(:service) { described_class.new(cache_dir: temp_cache_dir) }
    let(:source_dir) { File.join(temp_cache_dir, 'test_source') }

    before do
      FileUtils.mkdir_p(source_dir)
      FileUtils.mkdir_p(File.join(source_dir, 'docs'))
      FileUtils.mkdir_p(File.join(source_dir, '_posts'))
      File.write(File.join(source_dir, 'README.md'), 'Test content')
      File.write(File.join(source_dir, 'docs', 'guide.md'), 'Guide content')
      File.write(File.join(source_dir, '_posts', '2023-01-01-test.md'), 'Post content')
    end

    it 'copies entire directory when no subtrees specified' do
      result = service.copy_cached_content(source_dir, temp_dest_dir)

      expect(result).to be true
      expect(File.exist?(File.join(temp_dest_dir, 'README.md'))).to be true
      expect(File.exist?(File.join(temp_dest_dir, 'docs', 'guide.md'))).to be true
    end

    it 'copies only specified subtrees' do
      subtrees = ['docs']
      result = service.copy_cached_content(source_dir, temp_dest_dir, subtrees: subtrees)

      expect(result).to be true
      expect(File.exist?(File.join(temp_dest_dir, 'docs', 'guide.md'))).to be true
      expect(File.exist?(File.join(temp_dest_dir, '_posts', '2023-01-01-test.md'))).to be false
      expect(File.exist?(File.join(temp_dest_dir, 'README.md'))).to be false
    end

    it 'returns false for non-existent source' do
      non_existent_source = File.join(temp_cache_dir, 'non_existent')
      result = service.copy_cached_content(non_existent_source, temp_dest_dir)

      expect(result).to be false
    end
  end

  describe '#cleanup_cache' do
    let(:service) { described_class.new(cache_dir: temp_cache_dir) }

    before do
      FileUtils.mkdir_p(File.join(temp_cache_dir, 'repo1'))
      FileUtils.mkdir_p(File.join(temp_cache_dir, 'repo2'))
      File.write(File.join(temp_cache_dir, 'repo1', 'file.txt'), 'content')
    end

    it 'cleans entire cache when no repo specified' do
      service.cleanup_cache

      expect(Dir.exist?(temp_cache_dir)).to be false
    end

    it 'cleans specific repository cache' do
      repo_url = 'https://github.com/example/repo1.git'
      # Generate the actual hash that would be used
      repo_hash = service.send(:generate_repo_hash, repo_url)

      # Create a directory with the actual hash name
      actual_repo_dir = File.join(temp_cache_dir, repo_hash)
      FileUtils.mkdir_p(actual_repo_dir)
      File.write(File.join(actual_repo_dir, 'file.txt'), 'content')

      service.cleanup_cache(repo_url: repo_url)

      expect(Dir.exist?(actual_repo_dir)).to be false
      expect(Dir.exist?(File.join(temp_cache_dir, 'repo2'))).to be true
    end
  end

  describe '#cache_stats' do
    let(:service) { described_class.new(cache_dir: temp_cache_dir) }

    it 'returns zero stats for empty cache' do
      stats = service.cache_stats

      expect(stats[:total_repos]).to eq(0)
      expect(stats[:total_size]).to eq(0)
    end

    it 'calculates stats for populated cache' do
      repo_dir = File.join(temp_cache_dir, 'test_repo')
      FileUtils.mkdir_p(repo_dir)
      File.write(File.join(repo_dir, 'test.txt'), 'x' * 1024) # 1KB file

      stats = service.cache_stats

      expect(stats[:total_repos]).to eq(1)
      expect(stats[:total_size]).to be > 0
      expect(stats[:cache_dir]).to eq(temp_cache_dir)
    end
  end

  describe 'private methods' do
    let(:service) { described_class.new(cache_dir: temp_cache_dir) }

    describe '#generate_repo_hash' do
      it 'generates consistent hash for same URL' do
        url = 'https://github.com/example/repo.git'
        hash1 = service.send(:generate_repo_hash, url)
        hash2 = service.send(:generate_repo_hash, url)

        expect(hash1).to eq(hash2)
        expect(hash1).to be_a(String)
        expect(hash1.length).to eq(16)
      end

      it 'generates different hashes for different URLs' do
        url1 = 'https://github.com/example/repo1.git'
        url2 = 'https://github.com/example/repo2.git'
        hash1 = service.send(:generate_repo_hash, url1)
        hash2 = service.send(:generate_repo_hash, url2)

        expect(hash1).not_to eq(hash2)
      end
    end
  end
end
