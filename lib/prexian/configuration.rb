# frozen_string_literal: true

module Prexian
  # Configuration management for Prexian theme
  class Configuration
    DEFAULT_DOCS_SUBTREE = 'docs'
    DEFAULT_REPO_BRANCH = 'main'
    DEFAULT_REFRESH_CONDITION = 'last-resort'

    VALID_REFRESH_CONDITIONS = %w[always last-resort skip].freeze

    attr_reader :site_config

    def initialize(site_config)
      @site_config = site_config
      validate_config
      validate_refresh_condition(prexian_config['refresh_remote_data']) if prexian_config['refresh_remote_data']
    end

    def hub_site?
      prexian_config['is_hub'] == true
    end

    def project_site?
      !hub_site?
    end

    def default_repo_branch
      prexian_config['default_repo_branch'] || DEFAULT_REPO_BRANCH
    end

    def refresh_remote_data
      condition = prexian_config['refresh_remote_data'] || DEFAULT_REFRESH_CONDITION
      validate_refresh_condition(condition)
      condition
    end

    def parent_hub_config
      prexian_config['parent_hub'] || {}
    end

    def parent_hub_repo_url
      parent_hub_config['git_repo_url']
    end

    def parent_hub_repo_branch
      parent_hub_config['git_repo_branch'] || default_repo_branch
    end

    def parent_hub_home_url
      parent_hub_config['home_url']
    end

    def has_parent_hub?
      !parent_hub_repo_url.nil?
    end

    def tag_namespaces
      prexian_config['tag_namespaces'] || {}
    end

    def algolia_search_config
      prexian_config['algolia_search'] || {}
    end

    def landing_priority
      prexian_config['landing_priority'] || %w[software specs blog]
    end

    private

    def prexian_config
      @prexian_config ||= @site_config['rop'] || {}
    end

    def validate_config
      # Basic validation of required configuration
      Jekyll.logger.warn('Prexian Config: Hub site detected but no projects collection found') if hub_site? && !has_projects_collection?

      # Check for project site with parent_hub config but missing git_repo_url
      return unless project_site? && !parent_hub_config.empty? && parent_hub_repo_url.nil?

      Jekyll.logger.warn('Prexian Config: Project site with parent_hub config but no git_repo_url specified')
    end

    def validate_refresh_condition(condition)
      return if VALID_REFRESH_CONDITIONS.include?(condition)

      raise ArgumentError, "Invalid refresh_remote_data value '#{condition}'. " \
                          "Valid values are: #{VALID_REFRESH_CONDITIONS.join(', ')}"
    end

    def has_projects_collection?
      collections = @site_config['collections'] || {}
      projects = collections['projects']
      projects && !projects.empty?
    end
  end
end
