# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Hub Site Integration', type: :integration do
  let(:hub_fixture_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'hub') }
  let(:project_fixture_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'project') }

  describe 'hub site functionality' do
    let(:site) { build_site(hub_fixture_path) }

    it 'identifies itself as a hub site' do
      prexian_config = site.config['prexian'] || {}
      expect(prexian_config['site_type']).to eq('hub')
    end

    it 'processes project repositories' do
      # Create a real git service with a temporary cache directory
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        hub_reader = Prexian::HubSiteReader.new(site, git_service: git_service)

        # This should process the projects defined in our fixture
        expect { hub_reader.read_projects }.not_to raise_error

        # Verify that projects collection exists
        expect(site.collections['projects']).to be_a(Jekyll::Collection)
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'aggregates content from multiple projects' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        hub_reader = Prexian::HubSiteReader.new(site, git_service: git_service)

        # Process projects
        hub_reader.read_projects

        # Check that we have the expected collections
        expect(site.collections.keys).to include('projects', 'software', 'specs', 'posts')
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'handles project repository failures gracefully' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        # Create a site with invalid project repository URLs
        invalid_config = site.config.dup
        invalid_config['collections'] = {
          'projects' => { 'output' => true }
        }

        invalid_site = Jekyll::Site.new(Jekyll::Configuration.from(invalid_config))
        invalid_site.collections['projects'] = Jekyll::Collection.new(invalid_site, 'projects')

        # Add a project with invalid repo URL
        project_doc = Jekyll::Document.new(
          File.join(hub_fixture_path, '_projects', 'invalid.md'),
          site: invalid_site,
          collection: invalid_site.collections['projects']
        )
        project_doc.data['site'] = {
          'git_repo_url' => 'https://invalid-repo-url-that-does-not-exist.com/repo.git',
          'git_repo_branch' => 'main'
        }
        invalid_site.collections['projects'].docs << project_doc

        hub_reader = Prexian::HubSiteReader.new(invalid_site, git_service: git_service)

        # Should not raise error even with invalid repositories
        expect { hub_reader.read_projects }.not_to raise_error
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'processes software entries from projects' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        hub_reader = Prexian::HubSiteReader.new(site, git_service: git_service)

        # Process projects - this will attempt to read from our local project fixture
        hub_reader.read_projects

        # Verify software collection exists
        expect(site.collections['software']).to be_a(Jekyll::Collection)
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end

    it 'processes spec entries from projects' do
      cache_dir = Dir.mktmpdir('prexian_test_cache')
      git_service = Prexian::GitService.new(cache_dir: cache_dir)

      begin
        hub_reader = Prexian::HubSiteReader.new(site, git_service: git_service)

        # Process projects
        hub_reader.read_projects

        # Verify specs collection exists
        expect(site.collections['specs']).to be_a(Jekyll::Collection)
      ensure
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
      end
    end
  end

  describe 'configuration validation' do
    let(:site) { build_site(hub_fixture_path) }

    it 'validates hub site configuration' do
      prexian_config = site.config['prexian'] || {}

      expect(prexian_config['site_type']).to eq('hub')
      expect(prexian_config['parent_hub']).to be_nil
      expect(prexian_config['tag_namespaces']).to be_a(Hash)
      expect(prexian_config['landing_priority']).to be_an(Array)
    end

    it 'processes tag namespaces correctly' do
      prexian_config = site.config['prexian'] || {}
      expect(prexian_config['tag_namespaces'].keys).to include('software', 'specs')
    end

    it 'handles landing priority configuration' do
      prexian_config = site.config['prexian'] || {}
      expect(prexian_config['landing_priority']).to eq(%w[software specs blog])
    end
  end
end
