# frozen_string_literal: true

require_relative 'index_generator'

module Prexian
  # On an open hub site, Jekyll Open Project theme assumes the existence of two types
  # of item indexes: software and specs, where items are gathered
  # from across open projects in the hub.
  #
  # The need for :item_test arises from our data structure (see Jekyll Open Project theme docs)
  # and the fact that Jekyll doesn't intuitively handle nested collections.

  # Below passes the `items` variable to normal (unfiltered)
  # index page layout.

  class IndexPageGenerator < BaseIndexGenerator
    def generate(site)
      @site = site
      prexian_config['max_featured_software'] = max_featured_items
      prexian_config['max_featured_specs'] = max_featured_items
      prexian_config['max_featured_posts'] = max_featured_items

      IndexConfig.all_indexes.each do |index_name, params|
        collection_name = collection_name_for(index_name)

        next unless site.collections.key? collection_name

        # Filters items from given collection_name through item_test function
        # and makes items available in templates via e.g. site.all_specs, site.all_software

        items = get_all_items(site, collection_name, params[:item_test])

        set_index_config(items, index_name)
        categorize_items(items, index_name)
      end
    end

    def get_all_items(site, collection_name, filter_func)
      # Fetches items of specified type, ordered and prepared for usage in index templates

      collection = site.collections[collection_name]

      raise "Collection does not exist: #{collection_name}" if collection.nil?

      items = collection.docs.select do |item|
        filter_func.call(item)
      end

      sort_items_by_date(items)
      add_project_data_to_items(site, items)
    end
  end

  # Each software or spec item can have its tags,
  # and the theme allows to filter each index by a tag.
  # The below generates an additional index page
  # for each tag in an index, like software/Ruby.
  #
  # Note: this expects "_pages/<index page>.html" to be present in site source,
  # so it would fail if theme setup instructions were not followed fully.

  class FilteredIndexPageGenerator < IndexPageGenerator
    def generate(site)
      @site = site
      IndexConfig.all_indexes.each do |index_name, params|
        collection_name = collection_name_for(index_name)

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
