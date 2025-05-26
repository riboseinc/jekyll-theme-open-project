# frozen_string_literal: true

require_relative 'git_service'
require_relative 'project_reader'

module Prexian
  # Handles reading and aggregating content for hub sites
  class HubSiteReader
    def initialize(site, git_service: nil)
      @site = site
      @git_service = git_service || GitService.new
      @collection_reader = CollectionDocReader.new(@site)
    end

    def read_projects
      prexian_config = @site.config['prexian'] || {}
      return unless prexian_config['site_type'] == 'hub'

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

      prexian_config = @site.config['prexian'] || {}
      default_branch = prexian_config['default_repo_branch'] || 'main'
      refresh_condition = prexian_config['refresh_remote_data'] || 'last-resort'

      begin
        # Checkout project repository to cache
        checkout_result = @git_service.shallow_checkout(
          project['site']['git_repo_url'],
          sparse_subtrees: %w[assets _posts _software _specs],
          branch: project['site']['git_repo_branch'] || default_branch,
          refresh_condition: refresh_condition
        )

        Jekyll.logger.debug("Prexian HubSiteReader: Checkout result for #{project['site']['git_repo_url']}: #{checkout_result[:success]}")

        if checkout_result[:success]
          # Copy content from cache to project site directory
          @git_service.copy_cached_content(
            checkout_result[:local_path],
            project_site_path,
            subtrees: %w[assets _posts _software _specs]
          )

          # Read the copied content into collections
          @collection_reader.read(project_site_path, @site.collections['projects'])
        else
          Jekyll.logger.warn("Prexian HubSiteReader: Failed to checkout project repository #{project['site']['git_repo_url']}")
        end
      rescue Prexian::GitService::GitError => e
        Jekyll.logger.warn("Prexian HubSiteReader: Git error processing project #{project_name}: #{e.message}")

        # Fallback: try to copy directly from local path if it's a file:// URL
        if project['site']['git_repo_url'].start_with?('file://')
          local_path = project['site']['git_repo_url'].sub('file://', '')
          Jekyll.logger.debug("Prexian HubSiteReader: Attempting direct copy from #{local_path}")

          if Dir.exist?(local_path)
            copy_local_project_content(local_path, project_site_path)
            @collection_reader.read(project_site_path, @site.collections['projects'])
          end
        end
      end

      # Process software and specs for this project
      fetch_and_read_software('projects')
      fetch_and_read_specs('projects')
    end

    def fetch_and_read_software(collection_name)
      return unless @site.collections.key?(collection_name)

      entry_points = @site.collections[collection_name].docs.select do |doc|
        doc.data['repo_url']
      end

      entry_points.each do |index_doc|
        process_software_entry(index_doc, collection_name)
      end
    end

    def process_software_entry(index_doc, collection_name)
      item_name = index_doc.id.split('/')[-1]

      docs_config = extract_docs_config(index_doc)
      docs_path = "#{index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"

      # Checkout documentation repository
      docs_checkout = @git_service.shallow_checkout(
        docs_config[:repo_url],
        sparse_subtrees: [docs_config[:subtree]],
        branch: docs_config[:branch],
        refresh_condition: refresh_condition
      )

      if docs_checkout[:success]
        @git_service.copy_cached_content(
          docs_checkout[:local_path],
          docs_path,
          subtrees: [docs_config[:subtree]]
        )
        @collection_reader.read(docs_path, @site.collections[collection_name])
        index_doc.merge_data!({ 'last_update' => docs_checkout[:modified_at] })
      else
        # Fallback: get timestamp from main repository
        prexian_config = @site.config['prexian'] || {}
        default_branch = prexian_config['default_repo_branch'] || 'main'
        refresh_condition = prexian_config['refresh_remote_data'] || 'last-resort'

        main_checkout = @git_service.shallow_checkout(
          index_doc.data['repo_url'],
          branch: index_doc.data['repo_branch'] || default_branch,
          refresh_condition: refresh_condition
        )
        index_doc.merge_data!({ 'last_update' => main_checkout[:modified_at] }) if main_checkout[:success]
      end
    end

    def fetch_and_read_specs(collection_name)
      return unless @site.collections.key?(collection_name)

      entry_points = @site.collections[collection_name].docs.select do |doc|
        doc.data['spec_source']
      end

      entry_points.each do |index_doc|
        process_spec_entry(index_doc, collection_name)
      end
    end

    def process_spec_entry(index_doc, collection_name)
      spec_config = extract_spec_config(index_doc)

      prexian_config = @site.config['prexian'] || {}
      refresh_condition = prexian_config['refresh_remote_data'] || 'last-resort'

      checkout_result = @git_service.shallow_checkout(
        spec_config[:repo_url],
        sparse_subtrees: [spec_config[:repo_subtree]].compact,
        branch: spec_config[:repo_branch],
        refresh_condition: refresh_condition
      )

      return unless checkout_result[:success]

      @git_service.copy_cached_content(
        checkout_result[:local_path],
        spec_config[:checkout_path],
        subtrees: [spec_config[:repo_subtree]].compact
      )

      @collection_reader.read(spec_config[:checkout_path], @site.collections[collection_name])
      index_doc.merge_data!({ 'last_update' => checkout_result[:modified_at] })
    end

    def extract_docs_config(index_doc)
      docs = index_doc.data['docs']
      main_repo = index_doc.data['repo_url']
      prexian_config = @site.config['prexian'] || {}
      default_branch = prexian_config['default_repo_branch'] || 'main'
      main_repo_branch = index_doc.data['repo_branch'] || default_branch

      {
        repo_url: (docs && docs['git_repo_url']) || main_repo,
        subtree: (docs && docs['git_repo_subtree']) || 'docs',
        branch: (docs && docs['git_repo_branch']) || main_repo_branch
      }
    end

    def extract_spec_config(index_doc)
      item_name = index_doc.id.split('/')[-1]
      src = index_doc.data['spec_source']
      prexian_config = @site.config['prexian'] || {}
      default_branch = prexian_config['default_repo_branch'] || 'main'

      {
        item_name: item_name,
        repo_url: src['git_repo_url'],
        repo_subtree: src['git_repo_subtree'],
        repo_branch: src['git_repo_branch'] || default_branch,
        checkout_path: "#{index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"
      }
    end

    def copy_local_project_content(source_path, destination_path)
      require 'fileutils'

      Jekyll.logger.debug("Prexian HubSiteReader: Copying local project content from #{source_path} to #{destination_path}")

      # Ensure destination directory exists
      FileUtils.mkdir_p(destination_path)

      # Copy each subtree that we're interested in
      %w[assets _posts _software _specs].each do |subtree|
        source_subtree = File.join(source_path, subtree)
        destination_subtree = File.join(destination_path, subtree)

        if Dir.exist?(source_subtree)
          Jekyll.logger.debug("Prexian HubSiteReader: Copying #{subtree} from #{source_subtree} to #{destination_subtree}")
          FileUtils.cp_r(source_subtree, destination_subtree)
        else
          Jekyll.logger.debug("Prexian HubSiteReader: Subtree #{subtree} not found in #{source_path}")
        end
      end
    end
  end
end
