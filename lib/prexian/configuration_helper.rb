# frozen_string_literal: true

module Prexian
  # Provides centralized access to Prexian configuration patterns
  # that are repeated across multiple files
  module ConfigurationHelper
    def prexian_config
      @prexian_config ||= (@config || @site.config)['prexian'] || {}
    end

    def default_repo_branch
      prexian_config['default_repo_branch'] || 'main'
    end

    def refresh_condition
      prexian_config['refresh_remote_data'] || 'last-resort'
    end

    def site_type
      prexian_config['site_type'] || 'project'
    end

    def is_hub?
      site_type == 'hub'
    end

    def is_project?
      site_type == 'project'
    end

    def collection_name_for(index_name)
      is_hub? ? 'projects' : index_name
    end

    # Common configuration values used across generators
    def max_featured_items
      3
    end

    def default_time
      @default_time ||= Time.new(1989, 12, 31, 0, 0, 0, '+00:00')
    end
  end
end
