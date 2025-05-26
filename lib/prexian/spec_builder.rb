# frozen_string_literal: true

require 'forwardable'
require 'fastimage'
require_relative 'png_diagram_page'

module Prexian
  class SpecBuilder
    attr_reader :built_pages

    def initialize(site, spec_index_doc, spec_source_base, spec_out_base, engine, opts)
      require_relative engine

      @site = site
      @spec_index_doc = spec_index_doc
      @spec_source_base = spec_source_base
      @spec_out_base = spec_out_base
      @opts = opts

      @built_pages = []
    end

    def build
      @built_pages = build_spec_pages(
        @site,
        @spec_index_doc,
        @spec_source_base,
        @spec_out_base,
        @opts
      )
    end

    def build_spec_pages(site, spec_info, source, dest, _opts)
      nav_items = get_nav_items_with_path(
        spec_info.data['navigation']['items']
      )

      pages, not_found_items = process_spec_images(site, source, nav_items,
                                                   dest, spec_info)

      not_found_items.each do |item|
        warn "SPECIFIED PNG NOT FOUND: #{item['title']}.png not found " \
            "at source as specified at (#{dest})."
      end

      pages
    end

    # Recursively go through given list of nav_items, including any nested items,
    # and return a flat array containing navigation items with path specified.
    def get_nav_items_with_path(nav_items)
      items_with_path = []

      nav_items.each do |item|
        items_with_path.push(item) if item['path']

        items_with_path.concat(get_nav_items_with_path(item['items'])) if item['items']
      end

      items_with_path
    end

    def process_spec_images(site, source, nav_items, dest, spec_info)
      pages = []
      not_found_items = nav_items.dup

      Dir.glob("#{source}/*.png") do |pngfile|
        png_name = File.basename(pngfile)
        png_name_noext = File.basename(png_name, File.extname(png_name))

        nav_item = find_nav_items(nav_items, png_name_noext)[0].clone

        if nav_item.nil?
          warn "UNUSED PNG: #{File.basename(pngfile)} detected at source " \
              "without a corresponding navigation item at (#{dest})."
          next
        end

        not_found_items.delete_if { |item| item['title'] == nav_item['title'] }

        data = build_spec_page_data(pngfile, dest, png_name, nav_item,
                                    spec_info)

        pages << build_spec_page(site, dest, png_name_noext, data)
      end

      [pages, not_found_items]
    end

    def find_nav_items(diagram_nav_items, png_name_noext)
      diagram_nav_items.select do |item|
        item['path'].start_with?(png_name_noext)
      end
    end

    def build_spec_page(site, spec_root, png_name_noext, data)
      page = PngDiagramPage.new(
        site,
        site.source,
        File.join(spec_root, png_name_noext),
        data
      )

      stub_path = "#{File.dirname(__FILE__)}/png_diagram.html"
      page.content = File.read(stub_path)

      page
    end

    def build_spec_page_data(pngfile, spec_root, png_name, nav_item, spec_info)
      data = fill_image_data(pngfile, spec_info, spec_root, png_name)
             .merge(nav_item)

      data['title'] = "#{spec_info['title']}: #{nav_item['title']}"
      data['article_header_title'] = nav_item['title'].to_s

      data
    end

    def fill_image_data(pngfile, spec_info, spec_root, png_name)
      png_dimensions = FastImage.size(pngfile)
      data = spec_info.data.clone
      data['image_path'] = "/#{spec_root}/images/#{png_name}"
      data['image_width'] = png_dimensions[0]
      data['image_height'] = png_dimensions[1]
      data
    end
  end
end
