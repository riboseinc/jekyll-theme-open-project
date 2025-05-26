# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Prexian::CLI do
  let(:cli) { described_class.new }
  let(:cache_dir) { Dir.mktmpdir('prexian_cli_test') }

  after do
    FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
  end

  describe '#status' do
    it 'displays cache statistics' do
      # Set environment variable to use our test cache directory
      ENV['ROP_CACHE_DIR'] = cache_dir

      # Create some test cache content
      test_repo_dir = File.join(cache_dir, 'test_repo')
      FileUtils.mkdir_p(test_repo_dir)
      File.write(File.join(test_repo_dir, 'test_file.txt'), 'test content')

      expect { cli.status }.to output(/Cache Directory:/).to_stdout
      expect { cli.status }.to output(/Total Repositories:/).to_stdout
      expect { cli.status }.to output(/Total Size:/).to_stdout
    ensure
      ENV.delete('ROP_CACHE_DIR')
    end

    it 'shows empty cache message when no repositories' do
      # Set environment variable to use our test cache directory
      ENV['ROP_CACHE_DIR'] = cache_dir

      expect { cli.status }.to output(/Cache is empty/).to_stdout
    ensure
      ENV.delete('ROP_CACHE_DIR')
    end
  end

  describe '#clean' do
    context 'without specific repository' do
      it 'cleans entire cache' do
        # Set environment variable to use our test cache directory
        ENV['ROP_CACHE_DIR'] = cache_dir

        # Create some test cache content
        test_repo_dir = File.join(cache_dir, 'test_repo')
        FileUtils.mkdir_p(test_repo_dir)
        File.write(File.join(test_repo_dir, 'test_file.txt'), 'test content')

        expect { cli.clean }.to output(/Cleaned entire cache directory/).to_stdout
      ensure
        ENV.delete('ROP_CACHE_DIR')
      end
    end

    context 'with specific repository' do
      it 'cleans specific repository cache' do
        # Set environment variable to use our test cache directory
        ENV['ROP_CACHE_DIR'] = cache_dir

        repo_url = 'https://github.com/example/repo.git'
        allow(cli).to receive(:options).and_return({ project: repo_url })

        expect { cli.clean }.to output(/Cleaned cache for project: #{Regexp.escape(repo_url)}/).to_stdout
      ensure
        ENV.delete('ROP_CACHE_DIR')
      end
    end
  end

  describe '#version' do
    it 'displays version information' do
      expect { cli.version }.to output(/prexian version #{Prexian::VERSION}/).to_stdout
    end
  end

  describe 'private methods' do
    describe '#format_bytes' do
      it 'formats bytes correctly' do
        expect(cli.send(:format_bytes, 1024)).to eq('1.00 KB')
        expect(cli.send(:format_bytes, 1024 * 1024)).to eq('1.00 MB')
        expect(cli.send(:format_bytes, 1024 * 1024 * 1024)).to eq('1.00 GB')
        expect(cli.send(:format_bytes, 512)).to eq('512.00 B')
      end
    end
  end
end
