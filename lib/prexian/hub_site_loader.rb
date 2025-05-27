# frozen_string_literal: true

require_relative 'site_loader'
require_relative 'content_entry'

module Prexian
  # Handles reading and aggregating content for hub sites
  # Inherits all base site functionality from SiteLoader
  class HubSiteLoader < SiteLoader
    def read_content
      # Hub sites get all project site functionality
      super

      # Plus hub-specific project aggregation
      read_projects
    end

    def read_projects
      return unless is_hub?

      puts 'Prexian HubSiteLoader: Starting to read projects for hub site'
      puts "Prexian HubSiteLoader: Projects collection exists: #{@site.collections.key?('projects')}"
      if @site.collections.key?('projects')
        puts "Prexian HubSiteLoader: Projects collection has #{@site.collections['projects'].docs.length} documents"
        @site.collections['projects'].docs.each do |doc|
          puts "Prexian HubSiteLoader: Project doc: #{doc.id}, data keys: #{doc.data.keys}"
        end
      end

      puts 'Prexian HubSiteLoader: Processing ProjectEntry...'
      @content_processor.process_collection('projects', ProjectEntry, refresh_condition: refresh_condition)

      # Process software and specs for projects using inherited methods
      puts 'Prexian HubSiteLoader: Processing SoftwareEntry for projects...'
      @content_processor.process_collection('projects', SoftwareEntry, refresh_condition: refresh_condition)
      puts 'Prexian HubSiteLoader: Processing SpecificationEntry for projects...'
      @content_processor.process_collection('projects', SpecificationEntry, refresh_condition: refresh_condition)
    end
  end
end
