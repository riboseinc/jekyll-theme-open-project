# frozen_string_literal: true

require_relative 'content_entry'
require_relative 'git_service'
require_relative 'collection_doc_reader'

module Prexian
  # Generic processor for git-based content entries
  class GitContentProcessor
    def initialize(site, git_service: nil, collection_reader: nil, site_loader: nil)
      @site = site
      @git_service = git_service || GitService.new
      @collection_reader = collection_reader || CollectionDocReader.new(@site)
      @site_loader = site_loader
    end

    # Process a collection using the specified entry class
    def process_collection(collection_name, entry_class, refresh_condition: 'last-resort')
      return unless @site.collections.key?(collection_name)

      Jekyll.logger.debug("Prexian GitContentProcessor: Processing #{collection_name} collection with #{entry_class}")

      entry_points = find_entry_points(collection_name, entry_class)

      if entry_points.empty?
        Jekyll.logger.info("Prexian GitContentProcessor: No entry points found in #{collection_name} for #{entry_class}")
        return
      end

      entry_points.each do |index_doc|
        entry = entry_class.new(index_doc, collection_name, @site)
        process_entry(entry, refresh_condition: refresh_condition)
      end
    end

    private

    def find_entry_points(collection_name, entry_class)
      # Create a temporary entry instance to get the filter field
      temp_doc = @site.collections[collection_name].docs.first
      return [] unless temp_doc

      temp_entry = entry_class.new(temp_doc, collection_name, @site)
      filter_field = temp_entry.filter_field

      # Filter documents based on the entry type's filter field
      @site.collections[collection_name].docs.select do |doc|
        case filter_field
        when 'site'
          # Special case for ProjectEntry - check nested field
          doc.data['site'] && doc.data['site']['git_repo_url']
        else
          doc.data[filter_field]
        end
      end
    end

    def process_entry(entry, refresh_condition: 'last-resort')
      Jekyll.logger.debug("Prexian GitContentProcessor: Processing entry #{entry.index_doc.id}")

      config = entry.extract_config
      destination = entry.checkout_destination

      begin
        # Use GitService to handle checkout and copy
        checkout_result = @git_service.checkout_and_copy_content(
          config,
          destination,
          subtrees: config[:subtree] ? [config[:subtree]] : [],
          refresh_condition: refresh_condition
        )

        # Read the copied content into collections
        @collection_reader.read(destination, @site.collections[entry.collection_name])

        # Update document metadata
        entry.index_doc.merge_data!({ 'last_update' => checkout_result[:modified_at] })

        # Perform any post-processing (e.g., asset copying for projects)
        entry.post_process(checkout_result)

        # Handle build step if needed
        if entry.needs_build?
          entry.perform_build(config)
        end

      rescue Prexian::GitService::GitError => e
        handle_git_error(entry, e)
      end
    end

    def handle_git_error(entry, error)
      Jekyll.logger.warn("Prexian GitContentProcessor: Git error for #{entry.index_doc.id}: #{error.message}")

      # For software entries, try fallback to main repository for timestamp
      if entry.is_a?(SoftwareEntry)
        handle_software_fallback(entry)
      end
    end

    def handle_software_fallback(entry)
      Jekyll.logger.warn("Prexian GitContentProcessor: Trying main repo fallback for #{entry.index_doc.id}")

      main_repo_config = {
        repo_url: entry.index_doc.data['repo_url'],
        branch: entry.index_doc.data['repo_branch'] || 'main'
      }

      begin
        checkout_result = @git_service.shallow_checkout(
          main_repo_config[:repo_url],
          branch: main_repo_config[:branch],
          refresh_condition: 'last-resort'
        )
        entry.index_doc.merge_data!({ 'last_update' => checkout_result[:modified_at] })
      rescue Prexian::GitService::GitError => fallback_error
        Jekyll.logger.error("Prexian GitContentProcessor: Fallback also failed for #{entry.index_doc.id}: #{fallback_error.message}")
      end
    end
  end
end
