# frozen_string_literal: true

require_relative 'site_loader'

module Prexian
  # Handles reading and aggregating content for hub sites
  # Inherits all base site functionality from SiteLoader
  class HubSiteLoader < SiteLoader
    def read_content
      # Hub sites get all project site functionality
      super

      # Plus hub-specific project aggregation
      return unless is_hub?

      puts 'Prexian HubSiteLoader: Starting to read projects for hub site'
      @content_processor.process_collection('projects', ProjectEntry, refresh_condition: refresh_condition)

      # Process software and specs for projects using inherited methods
      @content_processor.process_collection('projects', SoftwareEntry, refresh_condition: refresh_condition)
      @content_processor.process_collection('projects', SpecificationEntry, refresh_condition: refresh_condition)
    end
  end
end
