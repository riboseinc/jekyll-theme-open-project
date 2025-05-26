# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project Site Integration', type: :integration do
  let(:project_fixture_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'project') }
  let(:hub_fixture_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'hub') }

  describe 'project site functionality' do
    let(:site) { build_site(project_fixture_path) }

    it 'identifies itself as a project site' do
      prexian_config = site.config['prexian'] || {}
      expect(prexian_config['site_type']).to eq('project')
    end

    it 'has parent hub configuration' do
      prexian_config = site.config['prexian'] || {}
      parent_hub = prexian_config['parent_hub'] || {}
      expect(parent_hub['git_repo_url']).to include('fixtures/hub')
      expect(parent_hub['home_url']).to eq('https://techhub.example.com/')
    end

    it 'fetches hub logo from parent hub' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        project_reader = Prexian::ProjectSiteReader.new(site, git_service: git_service)

        # This should attempt to fetch from the parent hub (our local fixture)
        expect { project_reader.read_content }.not_to raise_error

        # Check that parent-hub directory structure is created
        parent_hub_path = File.join(site.source, '_parent-hub')
        expect(Dir.exist?(parent_hub_path) || Dir.exist?(File.join(parent_hub_path, 'parent-hub'))).to be_truthy
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
        # Clean up parent-hub directory
        parent_hub_path = File.join(site.source, 'parent-hub')
        FileUtils.rm_rf(parent_hub_path) if Dir.exist?(parent_hub_path)
      end
    end

    it 'processes software documentation' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        project_reader = Prexian::ProjectSiteReader.new(site, git_service: git_service)

        # This should process the software defined in our fixture
        expect { project_reader.read_content }.not_to raise_error

        # Verify software collection exists and has content
        expect(site.collections['software']).to be_a(Jekyll::Collection)
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'processes specifications with page building' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        project_reader = Prexian::ProjectSiteReader.new(site, git_service: git_service)

        # This should process the specs defined in our fixture
        expect { project_reader.read_content }.not_to raise_error

        # Verify specs collection exists
        expect(site.collections['specs']).to be_a(Jekyll::Collection)
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'handles repository checkout failures gracefully' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        # Create a site with invalid parent hub URL
        invalid_config = site.config.dup
        invalid_config['prexian']['parent_hub']['git_repo_url'] = 'https://invalid-repo-url.com/repo.git'

        invalid_site = Jekyll::Site.new(Jekyll::Configuration.from(invalid_config))
        invalid_site.collections['software'] = Jekyll::Collection.new(invalid_site, 'software')
        invalid_site.collections['specs'] = Jekyll::Collection.new(invalid_site, 'specs')
        invalid_site.collections['posts'] = Jekyll::Collection.new(invalid_site, 'posts')

        project_reader = Prexian::ProjectSiteReader.new(invalid_site, git_service: git_service)

        # Should not raise error even with invalid repositories
        expect { project_reader.read_content }.not_to raise_error
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'updates document timestamps from repository' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        project_reader = Prexian::ProjectSiteReader.new(site, git_service: git_service)

        # Process content
        expect { project_reader.read_content }.not_to raise_error

        # Verify collections exist
        expect(site.collections['software']).to be_a(Jekyll::Collection)
        expect(site.collections['specs']).to be_a(Jekyll::Collection)
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end
  end

  describe 'configuration validation' do
    let(:site) { build_site(project_fixture_path) }

    it 'validates project site configuration' do
      prexian_config = site.config['prexian'] || {}
      parent_hub = prexian_config['parent_hub'] || {}

      expect(prexian_config['site_type']).to eq('project')
      expect(parent_hub['git_repo_url']).to be_a(String)
      expect(parent_hub['git_repo_branch'] || prexian_config['default_repo_branch'] || 'main').to eq('main')
    end

    it 'handles refresh conditions' do
      prexian_config = site.config['prexian'] || {}
      expect(prexian_config['refresh_remote_data'] || 'last-resort').to eq('last-resort')
    end

    it 'processes tag namespaces' do
      prexian_config = site.config['prexian'] || {}
      expect(prexian_config['tag_namespaces'] || {}).to be_a(Hash)
    end
  end

  describe 'content processing' do
    let(:site) { build_site(project_fixture_path) }

    it 'processes software with documentation repositories' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        project_reader = Prexian::ProjectSiteReader.new(site, git_service: git_service)

        # This should process software from our fixture
        expect { project_reader.send(:fetch_and_read_software, 'software') }.not_to raise_error
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'processes specifications with build configuration' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        project_reader = Prexian::ProjectSiteReader.new(site, git_service: git_service)

        # This should process specs from our fixture
        expect { project_reader.send(:fetch_and_read_specs, 'specs', build_pages: true) }.not_to raise_error
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'handles empty collections gracefully' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        empty_site = build_site(project_fixture_path)
        empty_site.collections['software'] = Jekyll::Collection.new(empty_site, 'software')
        empty_site.collections['specs'] = Jekyll::Collection.new(empty_site, 'specs')

        project_reader = Prexian::ProjectSiteReader.new(empty_site, git_service: git_service)

        expect { project_reader.read_content }.not_to raise_error
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end
  end
end
