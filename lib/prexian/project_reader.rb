# frozen_string_literal: true

require 'jekyll'
require_relative 'site_loader'
require_relative 'hub_site_loader'
require_relative 'project_site_loader'

module Prexian
  # Main entry point for reading project data
  class ProjectReader < ::Jekyll::Reader
    def initialize(site)
      super
      @config = @site.config
    end

    def read
      super

      prexian_config = @config['prexian'] || { 'site_type' => 'project' }

      @loader = case prexian_config['site_type']
      when 'hub'
        puts 'Prexian ProjectReader: Creating HubSiteLoader'
        HubSiteLoader.new(@site)
      when 'project'
        puts 'Prexian ProjectReader: Creating ProjectSiteLoader'
        ProjectSiteLoader.new(@site)
      end

      @loader.read_content
    end
  end

end
