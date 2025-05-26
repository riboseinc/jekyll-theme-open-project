# frozen_string_literal: true

module Prexian
  # On an open hub site, Jekyll Open Project theme assumes the existence of two types
  # of item indexes: software and specs, where items are gathered
  # from across open projects in the hub.
  #
  # The need for :item_test arises from our data structure (see Jekyll Open Project theme docs)
  # and the fact that Jekyll doesn’t intuitively handle nested collections.
  INDEXES = {
    'software' => {
      item_test: ->(item) { item.path.include? '/_software' and !item.path.include? '/docs' }
    },
    'specs' => {
      item_test: ->(item) { item.path.include? '/_specs' and !item.path.include? '/docs' }
    }
  }.freeze

  # Below passes the `items` variable to normal (unfiltered)
  # index page layout.

  class IndexPageGenerator < ::Jekyll::Generator
    safe true

    def generate(site)
      prexian_config = site.config['prexian'] || {}
      prexian_config['max_featured_software'] = 3
      prexian_config['max_featured_specs'] = 3
      prexian_config['max_featured_posts'] = 3

      INDEXES.each do |index_name, params|
        collection_name = if prexian_config['is_hub']
                            'projects'
                          else
                            index_name
                          end

        next unless site.collections.key? collection_name

        # Filters items from given collection_name through item_test function
        # and makes items available in templates via e.g. site.all_specs, site.all_software

        items = get_all_items(site, collection_name, params[:item_test])

        prexian_config["one_#{index_name}"] = items[0] if items.length == 1

        prexian_config["all_#{index_name}"] = items
        prexian_config["num_all_#{index_name}"] = items.size

        featured_items = items.reject { |item| item.data['feature_with_priority'].nil? }
        prexian_config["featured_#{index_name}"] = featured_items.sort_by { |item| item.data['feature_with_priority'] }
        prexian_config["num_featured_#{index_name}"] = featured_items.size

        non_featured_items = items.select { |item| item.data['feature_with_priority'].nil? }
        prexian_config["non_featured_#{index_name}"] = non_featured_items
        prexian_config["num_non_featured_#{index_name}"] = non_featured_items.size
      end
    end

    def get_all_items(site, collection_name, filter_func)
      # Fetches items of specified type, ordered and prepared for usage in index templates

      collection = site.collections[collection_name]

      raise "Collection does not exist: #{collection_name}" if collection.nil?

      items = collection.docs.select do |item|
        filter_func.call(item)
      end

      default_time = Time.new(1989, 12, 31, 0, 0, 0, '+00:00')

      items.sort! do |i1, i2|
        val1 = i1.data.fetch('last_update', default_time) || default_time
        val2 = i2.data.fetch('last_update', default_time) || default_time
        (val2 <=> val1) || 0
      end

      prexian_config = site.config['prexian'] || {}
      if prexian_config['is_hub']
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

      items
    end
  end
  # Each software or spec item can have its tags,
  # and the theme allows to filter each index by a tag.
  # The below generates an additional index page
  # for each tag in an index, like software/Ruby.
  #
  # Note: this expects "_pages/<index page>.html" to be present in site source,
  # so it would fail if theme setup instructions were not followed fully.

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

  class FilteredIndexPageGenerator < IndexPageGenerator
    safe true

    def generate(site)
      prexian_config = site.config['prexian'] || {}
      INDEXES.each do |index_name, params|
        collection_name = if prexian_config['is_hub']
                            'projects'
                          else
                            index_name
                          end

        items = get_all_items(site, collection_name, params[:item_test])

        # Creates a data structure like { tag1: [item1, item2], tag2: [item2, item3] }
        tags = {}
        items.each do |item|
          (item.data['tags'] or []).each do |tag|
            tags[tag] = [] unless tags.key? tag
            tags[tag].push(item)
          end
        end

        # Creates a filtered index page for each tag
        tags.each do |tag, tagged_items|
          site.pages << FilteredIndexPage.new(
            site,
            site.source,
            # The filtered page will be nested under /<index page>/<tag>.html
            File.join(index_name, tag),
            tag,
            tagged_items,
            index_name
          )
        end
      end
    end
  end
end
