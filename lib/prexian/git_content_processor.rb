# frozen_string_literal: true

require_relative 'content_entry'
require_relative 'git_service'
require_relative 'collection_doc_reader'

# Load entry classes for type checking
module Prexian
  class ProjectEntry < ContentEntry; end
  class SoftwareEntry < ContentEntry; end
  class SpecificationEntry < ContentEntry; end
end

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
      puts "Prexian GitContentProcessor: About to call find_entry_points for #{entry_class}"

      # Special handling for SoftwareEntry and SpecificationEntry when processing projects
      if collection_name == 'projects' && (entry_class.name == 'Prexian::SoftwareEntry' || entry_class.name == 'Prexian::SpecificationEntry')
        process_project_content(entry_class, refresh_condition: refresh_condition)
        return
      end

      entry_points = find_entry_points(collection_name, entry_class)
      puts "Prexian GitContentProcessor: find_entry_points returned #{entry_points.length} entries"

      if entry_points.empty?
        Jekyll.logger.info("Prexian GitContentProcessor: No entry points found in #{collection_name} for #{entry_class}")
        return
      end

      entry_points.each do |index_doc|
        puts "Prexian GitContentProcessor: Creating #{entry_class} for doc #{index_doc.id}"
        begin
          entry = entry_class.new(index_doc, collection_name, @site)
          puts "Prexian GitContentProcessor: Successfully created entry, now processing..."
          process_entry(entry, refresh_condition: refresh_condition)
        rescue => e
          puts "Prexian GitContentProcessor: Error creating or processing entry: #{e.message}"
          puts "Prexian GitContentProcessor: Backtrace: #{e.backtrace.first(5).join("\n")}"
        end
      end
    end

    private

    def get_filter_field_for_class(entry_class)
      case entry_class.name
      when 'Prexian::SoftwareEntry'
        'repo_url'
      when 'Prexian::SpecificationEntry'
        'spec_source'
      when 'Prexian::ProjectEntry'
        'site'
      else
        # Fallback: create a temporary instance if needed
        require 'ostruct'
        temp_doc = OpenStruct.new(id: 'temp', data: {}, path: 'temp')
        temp_entry = entry_class.new(temp_doc, 'temp', @site)
        temp_entry.filter_field
      end
    end

    def find_entry_points(collection_name, entry_class)
      collection = @site.collections[collection_name]
      return [] unless collection && !collection.docs.empty?

      # Get the filter field from the entry class directly
      filter_field = get_filter_field_for_class(entry_class)

      Jekyll.logger.debug("Prexian GitContentProcessor: Looking for #{entry_class} in #{collection_name} collection with filter_field '#{filter_field}'")
      Jekyll.logger.debug("Prexian GitContentProcessor: Collection has #{@site.collections[collection_name].docs.length} documents")

      # Filter documents based on the entry type's filter field
      matching_docs = @site.collections[collection_name].docs.select do |doc|
        Jekyll.logger.debug("Prexian GitContentProcessor: Checking doc #{doc.id}, data keys: #{doc.data.keys}")
        case filter_field
        when 'site'
          # Special case for ProjectEntry - check for either git_repo_url or local_path
          has_site = doc.data['site'] && (doc.data['site']['git_repo_url'] || doc.data['site']['local_path'])
          Jekyll.logger.debug("Prexian GitContentProcessor: Doc #{doc.id} has site config: #{has_site}")
          has_site
        else
          has_field = doc.data[filter_field]
          Jekyll.logger.debug("Prexian GitContentProcessor: Doc #{doc.id} has #{filter_field}: #{has_field}")
          has_field
        end
      end

      Jekyll.logger.debug("Prexian GitContentProcessor: Found #{matching_docs.length} matching documents for #{entry_class}")
      matching_docs
    end

    def process_entry(entry, refresh_condition: 'last-resort')
      Jekyll.logger.debug("Prexian GitContentProcessor: Processing entry #{entry.index_doc.id}")
      puts "Prexian GitContentProcessor: Processing entry #{entry.index_doc.id}"

      config = entry.extract_config
      puts "Prexian GitContentProcessor: Extracted config: #{config.inspect}"

      destination = entry.checkout_destination
      puts "Prexian GitContentProcessor: Checkout destination: #{destination}"

      begin
        # Check if this is a local path (indicated by branch being nil and path being local)
        resolved_path = resolve_local_path(config[:repo_url])
        if config[:branch].nil? && resolved_path && File.directory?(resolved_path)
          puts "Prexian GitContentProcessor: Handling local path: #{config[:repo_url]} -> #{resolved_path}"
          checkout_result = handle_local_path(resolved_path, destination)
        else
          puts "Prexian GitContentProcessor: Handling git repository: #{config[:repo_url]}"
          # Use GitService to handle checkout and copy
          checkout_result = @git_service.checkout_and_copy_content(
            config,
            destination,
            subtrees: config[:subtree] ? [config[:subtree]] : [],
            refresh_condition: refresh_condition
          )
        end

        puts "Prexian GitContentProcessor: Checkout result: #{checkout_result.inspect}"

        # For ProjectEntry, we don't read content into collections - that's handled later
        # by SoftwareEntry and SpecificationEntry processing
        if entry.is_a?(ProjectEntry)
          puts "Prexian GitContentProcessor: Skipping collection read for ProjectEntry - content will be processed by subsequent SoftwareEntry/SpecificationEntry"
        else
          # Read the copied content into collections for other entry types
          puts "Prexian GitContentProcessor: Reading content from #{destination} into collection #{entry.collection_name}"
          puts "Prexian GitContentProcessor: Available collections: #{@site.collections.keys}"
          @collection_reader.read(destination, @site.collections[entry.collection_name])
        end

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
      rescue => e
        puts "Prexian GitContentProcessor: Error processing entry: #{e.message}"
        puts "Prexian GitContentProcessor: Backtrace: #{e.backtrace.first(5).join("\n")}"
      end
    end

    def handle_git_error(entry, error)
      Jekyll.logger.warn("Prexian GitContentProcessor: Git error for #{entry.index_doc.id}: #{error.message}")

      # For software entries, try fallback to main repository for timestamp
      if entry.is_a?(SoftwareEntry)
        handle_software_fallback(entry)
      end
    end

    def resolve_local_path(path)
      return nil if path.nil? || path.empty?

      # If it's already an absolute path, return it
      return path if File.absolute_path?(path)

      # For relative paths, resolve them relative to the site source directory
      resolved = File.expand_path(path, @site.source)
      puts "Prexian GitContentProcessor: Resolved relative path '#{path}' to '#{resolved}'"
      resolved
    end

    def handle_local_path(source_path, destination)
      require 'fileutils'

      puts "Prexian GitContentProcessor: Copying from #{source_path} to #{destination}"

      # Create destination directory if it doesn't exist
      FileUtils.mkdir_p(destination)

      # Copy all content from source to destination, but skip existing collection directories
      # to avoid nested _software/_software and _specs/_specs
      Dir.glob("#{source_path}/*", File::FNM_DOTMATCH).each do |item|
        next if File.basename(item) == '.' || File.basename(item) == '..'

        item_name = File.basename(item)
        dest_item = File.join(destination, item_name)

        # Skip if destination already has this directory (avoid duplicates)
        if File.directory?(item) && File.directory?(dest_item)
          puts "Prexian GitContentProcessor: Skipping existing directory: #{item_name}"
          next
        end

        if File.directory?(item)
          FileUtils.cp_r(item, dest_item)
        else
          FileUtils.cp(item, dest_item)
        end
      end

      # Get the modification time of the source directory
      modified_at = File.mtime(source_path)

      {
        local_path: destination,
        modified_at: modified_at
      }
    end

    def process_project_content(entry_class, refresh_condition: 'last-resort')
      puts "Prexian GitContentProcessor: Processing project content for #{entry_class}"

      # Determine target collection based on entry class
      target_collection_name = case entry_class.name
      when 'Prexian::SoftwareEntry'
        'software'
      when 'Prexian::SpecificationEntry'
        'specs'
      else
        puts "Prexian GitContentProcessor: Unknown entry class #{entry_class.name}"
        return
      end

      target_collection = @site.collections[target_collection_name]
      unless target_collection
        puts "Prexian GitContentProcessor: Target collection #{target_collection_name} not found"
        return
      end

      # Find project sites directory
      project_sites_dir = File.join(@site.source, '_project-sites')
      unless File.directory?(project_sites_dir)
        puts "Prexian GitContentProcessor: Project sites directory not found: #{project_sites_dir}"
        return
      end

      puts "Prexian GitContentProcessor: Scanning project sites in #{project_sites_dir}"

      # Scan each project directory
      Dir.glob("#{project_sites_dir}/*").each do |project_dir|
        next unless File.directory?(project_dir)

        project_name = File.basename(project_dir)
        puts "Prexian GitContentProcessor: Processing project #{project_name}"

        # Determine subdirectory to scan based on entry class
        subdir = case entry_class.name
        when 'Prexian::SoftwareEntry'
          File.join(project_dir, '_software')
        when 'Prexian::SpecificationEntry'
          File.join(project_dir, '_specs')
        end

        if File.directory?(subdir)
          puts "Prexian GitContentProcessor: Reading content from #{subdir} into #{target_collection_name} collection"
          @collection_reader.read(subdir, target_collection)
        else
          puts "Prexian GitContentProcessor: Subdirectory not found: #{subdir}"
        end
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
