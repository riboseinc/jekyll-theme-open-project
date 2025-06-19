# frozen_string_literal: true

require_relative 'configuration_helper'

module Prexian
  # Base class for all index generators that provides common functionality
  # for processing collections and generating index pages
  class BaseIndexGenerator
    include ConfigurationHelper

    protected

    # Common method to sort items by date (last_update or date field)
    def sort_items_by_date(items, date_field = 'last_update')
      items.sort! do |i1, i2|
        val1 = i1.data.fetch(date_field, default_time) || default_time
        val2 = i2.data.fetch(date_field, default_time) || default_time
        (val2 <=> val1) || 0
      end
    end

    # Common method to add project data to items in hub sites
    def add_project_data_to_items(site, items)
      return items unless is_hub?

      items.map! do |item|
        project_name = item.url.split('/')[2]
        project_path = "_projects/#{project_name}/index.md"

        item.data['project_name'] = project_name
        item.data['project_data'] = site.collections['projects'].docs.select do |proj|
          proj.path.end_with? project_path
        end [0]

        item
      end
    end

    # Common method to categorize items into featured and non-featured
    def categorize_items(items, index_name)
      featured_items = items.reject { |item| item.data['feature_with_priority'].nil? }
      prexian_config["featured_#{index_name}"] = featured_items.sort_by { |item| item.data['feature_with_priority'] }
      prexian_config["num_featured_#{index_name}"] = featured_items.size

      non_featured_items = items.select { |item| item.data['feature_with_priority'].nil? }
      prexian_config["non_featured_#{index_name}"] = non_featured_items
      prexian_config["num_non_featured_#{index_name}"] = non_featured_items.size
    end

    # Common method to set configuration values for an index
    def set_index_config(items, index_name)
      prexian_config["one_#{index_name}"] = items[0] if items.length == 1
      prexian_config["all_#{index_name}"] = items
      prexian_config["num_all_#{index_name}"] = items.size
    end

    # Common method to get projects from a site
    def get_projects(site)
      projects = site.collections['projects'].docs.select do |item|
        pieces = item.url.split('/')
        pieces.length == 4 && pieces[-1] == 'index' && pieces[1] == 'projects'
      end

      # Add project name (matches directory name, may differ from title)
      projects.map do |project|
        project.data['name'] = project.url.split('/')[2]
        project
      end
    end
  end

  # Configuration for different types of filterable indexes
  class IndexConfig
    INDEXES = {
      'software' => {
        item_test: ->(item) { item.path.include? '/_software' and !item.path.include? '/docs' }
      },
      'specs' => {
        item_test: ->(item) { item.path.include? '/_specs' and !item.path.include? '/docs' }
      }
    }.freeze

    def self.get_config(index_name)
      INDEXES[index_name]
    end

    def self.all_indexes
      INDEXES
    end
  end

  # Filtered index page for tag-based filtering
  class FilteredIndexPage < ::Jekyll::Page
    def initialize(site, base, dir, tag, items, index_page)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_pages'), "#{index_page}.html")
      data['tag'] = tag
      data['items'] = items
    end
  end
end
