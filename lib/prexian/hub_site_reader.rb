# frozen_string_literal: true

require_relative 'site_reader'

module Prexian
  # Handles reading and aggregating content for hub sites
  # Inherits all base site functionality from SiteReader
  class HubSiteReader < SiteReader
    def read_content
      # Hub sites get all project site functionality
      super

      # Plus hub-specific project aggregation
      read_projects
    end

    def read_projects
      return unless is_hub?

      puts 'Prexian HubSiteReader: Starting to read projects for hub site'

      project_indexes = find_project_indexes
      puts "Prexian HubSiteReader: Found #{project_indexes.size} project indexes"

      project_indexes.each do |project|
        puts "Prexian HubSiteReader: Processing project: #{project.id}"
        process_project(project)
      end
    end

    private

    def find_project_indexes
      # Find all project documents that have site configuration
      @site.collections['projects'].docs.select do |doc|
        doc.data['site'] && doc.data['site']['git_repo_url']
      end
    end

    def process_project(project)
      # Extract project name from the project document path
      project_name = File.basename(project.path, '.md')

      # Use a separate directory for cloned project sites to avoid conflicts
      project_site_path = File.join(@site.source, '_project-sites', project_name)

      Jekyll.logger.debug("Prexian HubSiteReader: Processing project #{project_name} -> #{project_site_path}")

      # Fallback: try to copy directly from local path if it's a file:// URL or local path
      local_path = nil
      if project['site']['git_repo_url'].start_with?('file://')
        local_path = project['site']['git_repo_url'].sub('file://', '')
      elsif project['site']['git_repo_url'].start_with?('/')
        local_path = project['site']['git_repo_url']
      end

      if local_path && Dir.exist?(local_path)
        Jekyll.logger.debug("Prexian HubSiteReader: Attempting direct copy from #{local_path}")
        copy_local_project_content(local_path, project_site_path)
        copy_project_assets_to_site(local_path, project_name)
        @collection_reader.read(project_site_path, @site.collections['projects'])
      else
        begin
          # Full clone, no subtree filtering
          checkout_result = @git_service.shallow_checkout(
            project['site']['git_repo_url'],
            branch: project['site']['git_repo_branch'] || default_repo_branch,
            refresh_condition: refresh_condition
          )

          Jekyll.logger.debug("Prexian HubSiteReader: Checkout result for #{project['site']['git_repo_url']}: #{checkout_result[:success]}")

          if checkout_result[:success]
            # Copy content from cache to project site directory
            @git_service.copy_cached_content(
              checkout_result[:local_path],
              project_site_path
            )

            # Copy project assets to the site's assets directory for serving
            copy_project_assets_to_site(checkout_result[:local_path], project_name)

            # Read the copied content into collections
            @collection_reader.read(project_site_path, @site.collections['projects'])
          else
            Jekyll.logger.warn("Prexian HubSiteReader: Failed to checkout project repository #{project['site']['git_repo_url']}")
          end
        rescue Prexian::GitService::GitError => e
          Jekyll.logger.warn("Prexian HubSiteReader: Git error processing project #{project_name}: #{e.message}")
        end
      end

      # Process software and specs for this project using inherited methods
      fetch_and_read_software('projects')
      fetch_and_read_specs('projects', build_pages: true)
    end

    def copy_local_project_content(source_path, destination_path)
      require 'fileutils'

      Jekyll.logger.debug("Prexian HubSiteReader: Copying local project content from #{source_path} to #{destination_path}")

      # Ensure destination directory exists
      FileUtils.mkdir_p(destination_path)

      # Copy the entire folder from source_path to destination_path
      Jekyll.logger.debug("Prexian HubSiteReader: Copying full content from #{source_path} to #{destination_path}")
      FileUtils.cp_r(Dir.glob(File.join(source_path, '*')), destination_path)
    end

    def copy_project_assets_to_site(source_path, project_name)
      require 'fileutils'

      source_assets = File.join(source_path, 'assets')
      return unless Dir.exist?(source_assets)

      # Create the projects directory in the site's assets
      site_projects_assets = File.join(@site.source, 'assets', 'projects', project_name)
      FileUtils.mkdir_p(site_projects_assets)

      Jekyll.logger.debug("Prexian HubSiteReader: Copying project assets from #{source_assets} to #{site_projects_assets}")

      # Copy all assets from the project to the site's assets/projects/[project_name] directory
      Dir.glob(File.join(source_assets, '*')).each do |asset_file|
        if File.file?(asset_file)
          FileUtils.cp(asset_file, site_projects_assets)
          Jekyll.logger.debug("Prexian HubSiteReader: Copied asset #{File.basename(asset_file)} to #{site_projects_assets}")
        end
      end
    end
  end
end
