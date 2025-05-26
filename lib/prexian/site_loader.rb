# frozen_string_literal: true

require_relative 'git_service'
require_relative 'configuration_helper'
require_relative 'git_content_processor'
require_relative 'content_entry'

module Prexian
  # Base class for reading content for sites (both project and hub sites)
  class SiteLoader
    include ConfigurationHelper

    def initialize(site, git_service: nil)
      @site = site
      @config = @site.config
      @git_service = git_service || GitService.new
      @content_processor = GitContentProcessor.new(@site, git_service: @git_service, site_loader: self)
    end

    def read_content
      fetch_hub_logo if is_project?
      @content_processor.process_collection('software', SoftwareEntry, refresh_condition: refresh_condition)
      @content_processor.process_collection('specs', SpecificationEntry, refresh_condition: refresh_condition)
    end

    private

    def fetch_hub_logo
      puts 'Prexian SiteLoader: Fetching hub logo'
      Jekyll.logger.debug('Prexian SiteLoader: Fetching hub logo')

      # Check if parent_hub configuration exists
      parent_hub_config = prexian_config['parent_hub']
      unless parent_hub_config
        Jekyll.logger.warn('[WARNING] prexian.parent_hub is required but not set, skipping hub logo fetch')
        return
      end

      parent_hub_repo_url = parent_hub_config['git_repo_url']
      unless parent_hub_repo_url
        Jekyll.logger.warn('[WARNING] prexian.parent_hub.git_repo_url is required but not set, skipping hub logo fetch')
        return
      end

      parent_hub_repo_branch = prexian_config['parent_hub']['git_repo_branch'] || default_repo_branch

      puts "Prexian SiteLoader: Parent hub repository branch: #{parent_hub_repo_branch}"
      Jekyll.logger.debug("Prexian SiteLoader: Parent hub repository branch: #{parent_hub_repo_branch}")

      begin
        hub_config = {
          repo_url: parent_hub_repo_url,
          branch: parent_hub_repo_branch
        }

        hub_destination = File.join(@site.source, '_parent-hub')
        parent_hub_includes = File.join(hub_destination, 'parent-hub')

        checkout_result = @git_service.checkout_and_copy_content(
          hub_config,
          parent_hub_includes,
          refresh_condition: refresh_condition
        )

        puts "Prexian SiteLoader: Checkout result: #{checkout_result.inspect}"
        return unless File.directory?(parent_hub_includes)

        puts "Prexian SiteLoader: Hub site copied to #{parent_hub_includes}"

        add_to_includes_load_paths(hub_destination)
      rescue Prexian::GitService::GitError => e
        Jekyll.logger.warn("Prexian SiteLoader: Failed to fetch hub logo: #{e.message}")
      end
    end

    # Shared method to add directories to Jekyll's includes_load_paths
    def add_to_includes_load_paths(directory_path)
      return unless File.directory?(directory_path)

      Jekyll.logger.debug("Prexian SiteLoader: Adding #{directory_path} to includes_load_paths")

      # Add directory to Jekyll's includes_load_paths
      @site.config['includes_load_paths'] ||= []
      unless @site.config['includes_load_paths'].include?(directory_path)
        @site.config['includes_load_paths'] << directory_path
      end
    end
  end
end
