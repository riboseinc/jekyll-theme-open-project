# frozen_string_literal: true

require_relative 'site_loader'

module Prexian
  # Handles reading content for individual project sites
  # Inherits all base site functionality from SiteLoader
  class ProjectSiteLoader < SiteLoader
    # Add methods expected by tests for backward compatibility
    def fetch_and_read_software(collection_name)
      @content_processor.process_collection(collection_name, SoftwareEntry, refresh_condition: refresh_condition)
    end

    def fetch_and_read_specs(collection_name, build_pages: false)
      @content_processor.process_collection(collection_name, SpecificationEntry, refresh_condition: refresh_condition)
    end
  end
end
