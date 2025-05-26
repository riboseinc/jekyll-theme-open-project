# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prexian::Configuration do
  let(:mock_logger) { double('Logger') }

  before do
    allow(mock_logger).to receive(:warn)
    # Mock Jekyll.logger if Jekyll is available
    if defined?(Jekyll)
      allow(Jekyll).to receive(:logger).and_return(mock_logger)
    else
      # Create a simple logger mock for non-Jekyll environments
      stub_const('Jekyll', Class.new)
      allow(Jekyll).to receive(:logger).and_return(mock_logger)
    end
  end

  describe '#initialize' do
    context 'with hub site configuration' do
      let(:hub_config) do
        {
          'rop' => {
            'is_hub' => true
          },
          'collections' => {
            'projects' => { 'output' => true }
          }
        }
      end

      it 'initializes without warnings for valid hub config' do
        config = described_class.new(hub_config)

        expect(config.hub_site?).to be true
        expect(config.project_site?).to be false
        expect(mock_logger).not_to have_received(:warn)
      end
    end

    context 'with project site configuration' do
      let(:project_config) do
        {
          'rop' => {
            'is_hub' => false,
            'parent_hub' => {
              'git_repo_url' => 'https://github.com/hub/repo.git',
              'git_repo_branch' => 'main',
              'home_url' => 'https://hub.example.com'
            }
          }
        }
      end

      it 'initializes project site configuration' do
        config = described_class.new(project_config)

        expect(config.project_site?).to be true
        expect(config.hub_site?).to be false
        expect(config.has_parent_hub?).to be true
      end
    end

    context 'with invalid configurations' do
      it 'warns for hub site without projects collection' do
        invalid_hub_config = { 'rop' => { 'is_hub' => true } }

        described_class.new(invalid_hub_config)

        expect(mock_logger).to have_received(:warn)
          .with('Prexian Config: Hub site detected but no projects collection found')
      end

      it 'warns for project site with incomplete parent_hub config' do
        invalid_project_config = {
          'rop' => {
            'is_hub' => false,
            'parent_hub' => { 'home_url' => 'https://example.com' }
          }
        }

        described_class.new(invalid_project_config)

        expect(mock_logger).to have_received(:warn)
          .with('Prexian Config: Project site with parent_hub config but no git_repo_url specified')
      end
    end
  end

  describe '#hub_site?' do
    it 'returns true when is_hub is true' do
      config = described_class.new({ 'rop' => { 'is_hub' => true } })
      expect(config.hub_site?).to be true
    end

    it 'returns false when is_hub is false' do
      config = described_class.new({ 'rop' => { 'is_hub' => false } })
      expect(config.hub_site?).to be false
    end

    it 'returns false when is_hub is not set' do
      config = described_class.new({})
      expect(config.hub_site?).to be false
    end
  end

  describe '#project_site?' do
    it 'returns false for hub sites' do
      config = described_class.new({ 'rop' => { 'is_hub' => true } })
      expect(config.project_site?).to be false
    end

    it 'returns true for non-hub sites' do
      config = described_class.new({ 'rop' => { 'is_hub' => false } })
      expect(config.project_site?).to be true
    end
  end

  describe '#default_repo_branch' do
    it 'returns configured branch when set' do
      config = described_class.new({ 'rop' => { 'default_repo_branch' => 'develop' } })
      expect(config.default_repo_branch).to eq('develop')
    end

    it 'returns default branch when not configured' do
      config = described_class.new({})
      expect(config.default_repo_branch).to eq('main')
    end
  end

  describe '#refresh_remote_data' do
    it 'returns configured refresh condition' do
      config = described_class.new({ 'rop' => { 'refresh_remote_data' => 'always' } })
      expect(config.refresh_remote_data).to eq('always')
    end

    it 'returns default refresh condition when not configured' do
      config = described_class.new({})
      expect(config.refresh_remote_data).to eq('last-resort')
    end

    it 'validates refresh condition values' do
      expect do
        described_class.new({ 'rop' => { 'refresh_remote_data' => 'invalid' } })
      end.to raise_error(ArgumentError, /Invalid refresh_remote_data value/)
    end

    it 'accepts valid refresh conditions' do
      %w[always last-resort skip].each do |condition|
        config = described_class.new({ 'rop' => { 'refresh_remote_data' => condition } })
        expect(config.refresh_remote_data).to eq(condition)
      end
    end
  end

  describe '#parent_hub_config' do
    it 'returns parent hub configuration when present' do
      parent_hub = {
        'git_repo_url' => 'https://github.com/hub/repo.git',
        'git_repo_branch' => 'main'
      }
      config = described_class.new({ 'rop' => { 'parent_hub' => parent_hub } })

      expect(config.parent_hub_config).to eq(parent_hub)
    end

    it 'returns empty hash when not configured' do
      config = described_class.new({})
      expect(config.parent_hub_config).to eq({})
    end
  end

  describe '#parent_hub_repo_url' do
    it 'returns parent hub repository URL' do
      config = described_class.new({
                                     'rop' => {
                                       'parent_hub' => { 'git_repo_url' => 'https://github.com/hub/repo.git' }
                                     }
                                   })

      expect(config.parent_hub_repo_url).to eq('https://github.com/hub/repo.git')
    end

    it 'returns nil when not configured' do
      config = described_class.new({})
      expect(config.parent_hub_repo_url).to be_nil
    end
  end

  describe '#parent_hub_repo_branch' do
    it 'returns configured parent hub branch' do
      config = described_class.new({
                                     'rop' => {
                                       'parent_hub' => { 'git_repo_branch' => 'develop' }
                                     }
                                   })

      expect(config.parent_hub_repo_branch).to eq('develop')
    end

    it 'returns default branch when parent hub branch not configured' do
      config = described_class.new({
                                     'rop' => {
                                       'default_repo_branch' => 'custom-main',
                                       'parent_hub' => { 'git_repo_url' => 'https://example.com' }
                                     }
                                   })

      expect(config.parent_hub_repo_branch).to eq('custom-main')
    end
  end

  describe '#parent_hub_home_url' do
    it 'returns parent hub home URL' do
      config = described_class.new({
                                     'rop' => {
                                       'parent_hub' => { 'home_url' => 'https://hub.example.com' }
                                     }
                                   })

      expect(config.parent_hub_home_url).to eq('https://hub.example.com')
    end

    it 'returns nil when not configured' do
      config = described_class.new({})
      expect(config.parent_hub_home_url).to be_nil
    end
  end

  describe '#has_parent_hub?' do
    it 'returns true when parent hub repo URL is configured' do
      config = described_class.new({
                                     'rop' => {
                                       'parent_hub' => { 'git_repo_url' => 'https://github.com/hub/repo.git' }
                                     }
                                   })

      expect(config.has_parent_hub?).to be true
    end

    it 'returns false when parent hub repo URL is not configured' do
      config = described_class.new({
                                     'rop' => {
                                       'parent_hub' => { 'home_url' => 'https://example.com' }
                                     }
                                   })

      expect(config.has_parent_hub?).to be false
    end

    it 'returns false when parent_hub is not configured' do
      config = described_class.new({})
      expect(config.has_parent_hub?).to be false
    end
  end

  describe '#tag_namespaces' do
    it 'returns configured tag namespaces' do
      tag_namespaces = {
        'software' => { 'writtenin' => 'Written in' },
        'specs' => { 'audience' => 'Audience' }
      }
      config = described_class.new({ 'rop' => { 'tag_namespaces' => tag_namespaces } })

      expect(config.tag_namespaces).to eq(tag_namespaces)
    end

    it 'returns empty hash when not configured' do
      config = described_class.new({})
      expect(config.tag_namespaces).to eq({})
    end
  end

  describe '#algolia_search_config' do
    it 'returns configured Algolia search settings' do
      algolia_config = {
        'api_key' => 'test_key',
        'index_name' => 'test_index'
      }
      config = described_class.new({ 'rop' => { 'algolia_search' => algolia_config } })

      expect(config.algolia_search_config).to eq(algolia_config)
    end

    it 'returns empty hash when not configured' do
      config = described_class.new({})
      expect(config.algolia_search_config).to eq({})
    end
  end

  describe '#landing_priority' do
    it 'returns configured landing priority' do
      priority = %w[blog software specs]
      config = described_class.new({ 'rop' => { 'landing_priority' => priority } })

      expect(config.landing_priority).to eq(priority)
    end

    it 'returns default landing priority when not configured' do
      config = described_class.new({})
      expect(config.landing_priority).to eq(%w[software specs blog])
    end
  end
end
