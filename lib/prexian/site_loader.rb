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
      puts 'Prexian SiteLoader: Fetching hub data'
      Jekyll.logger.debug('Prexian SiteLoader: Fetching hub data')

      # Check if hub configuration exists
      hub_config = prexian_config['hub']
      unless hub_config
        Jekyll.logger.warn('[WARNING] prexian.hub is required but not set, skipping hub data fetch')
        return
      end

      hub_repo_url = hub_config['git_repo_url']
      unless hub_repo_url
        Jekyll.logger.warn('[WARNING] prexian.hub.git_repo_url is required but not set, skipping hub data fetch')
        return
      end

      hub_repo_branch = prexian_config['hub']['git_repo_branch'] || default_repo_branch

      puts "Prexian SiteLoader: Hub repository branch: #{hub_repo_branch}"
      Jekyll.logger.debug("Prexian SiteLoader: Hub repository branch: #{hub_repo_branch}")

      begin
        hub_git_config = {
          repo_url: hub_repo_url,
          branch: hub_repo_branch
        }

        hub_destination = File.join(@site.source, '_hub-site')
        hub_includes = File.join(hub_destination, 'hub')

        checkout_result = @git_service.checkout_and_copy_content(
          hub_git_config,
          hub_includes,
          refresh_condition: refresh_condition
        )

        puts "Prexian SiteLoader: Checkout result: #{checkout_result.inspect}"
        return unless File.directory?(hub_includes)

        puts "Prexian SiteLoader: Hub site copied to #{hub_includes}"

        add_to_includes_load_paths(hub_destination)
        extract_hub_data(hub_includes)
      rescue Prexian::GitService::GitError => e
        Jekyll.logger.warn("Prexian SiteLoader: Failed to fetch hub data: #{e.message}")
      end
    end

    def extract_hub_data(hub_path)
      hub_config_path = File.join(hub_path, '_config.yml')
      return unless File.exist?(hub_config_path)

      begin
        require 'yaml'
        hub_config = YAML.load_file(hub_config_path)

        # Extract hub data and make it available to Jekyll
        @site.data ||= {}
        @site.data['hub'] = {
          'title' => hub_config.dig('prexian', 'title') || hub_config['title'],
          'description' => hub_config.dig('prexian', 'description') || hub_config['description'],
          'url' => hub_config['url']
        }

        puts "Prexian SiteLoader: Extracted hub data: #{@site.data['hub'].inspect}"
        Jekyll.logger.debug("Prexian SiteLoader: Extracted hub data: #{@site.data['hub'].inspect}")
      rescue => e
        Jekyll.logger.warn("Prexian SiteLoader: Failed to extract hub data: #{e.message}")
      end
    end

    # Shared method to add directories to Jekyll's includes_load_paths
    def add_to_includes_load_paths(directory_path)
      return unless File.directory?(directory_path)

      Jekyll.logger.debug("Prexian SiteLoader: Adding #{directory_path} to includes_load_paths")

      # Add directory to Jekyll's includes_load_paths
      unless @site.includes_load_paths.include?(directory_path)

        @site.includes_load_paths << directory_path
      end
    end
  end
end
