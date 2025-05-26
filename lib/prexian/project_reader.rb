# frozen_string_literal: true

require 'jekyll'
require_relative 'configuration'
require_relative 'hub_site_reader'
require_relative 'project_site_reader'

module Prexian
  # Main entry point for reading project data
  class ProjectReader < ::Jekyll::Reader
    def initialize(site)
      super
      @config = @site.config
    end

    def read
      super

      puts "Prexian ProjectReader: Starting read, hub_site? = #{@config['prexian']['is_hub']}"

      if @config['prexian']['is_hub']
        puts 'Prexian ProjectReader: Creating HubSiteReader'
        hub_reader = HubSiteReader.new(@site)
        hub_reader.read_projects
      else
        puts 'Prexian ProjectReader: Creating ProjectSiteReader'
        project_reader = ProjectSiteReader.new(@site)
        project_reader.read_content
      end
    end
  end

  # Non-liquid document class for performance
  class NonLiquidDocument < ::Jekyll::Document
    def render_with_liquid?
      false
    end
  end

  # Reads collection documents from a directory
  class CollectionDocReader < ::Jekyll::DataReader
    def read(dir, collection)
      read_project_subdir(dir, collection)
    end

    def read_project_subdir(dir, collection, nested: false)
      return unless File.directory?(dir) && !@entry_filter.symlink?(dir)

      entries = Dir.chdir(dir) do
        Dir['*.{adoc,md,markdown,html,svg,png}'] + Dir['*'].select { |fn| File.directory?(fn) }
      end

      entries.each do |entry|
        path = File.join(dir, entry)

        Jekyll.logger.debug('Prexian CollectionDocReader:', "Reading entry #{path}")

        if File.directory?(path)
          read_project_subdir(path, collection, nested: true)
        elsif nested || (File.basename(entry, '.*') != 'index')
          process_file_entry(path, collection)
        end
      end
    end

    private

    def process_file_entry(path, collection)
      ext = File.extname(path)

      if ['.adoc', '.md', '.markdown'].include?(ext)
        process_document(path, collection)
      else
        process_static_file(path, collection)
      end
    end

    def process_document(path, collection)
      doc = NonLiquidDocument.new(path, site: @site, collection: collection)
      doc.read

      # Add document to Jekyll document database if it refers to software or spec
      doc_url_parts = doc.url.split('/')
      Jekyll.logger.debug('Prexian CollectionDocReader:',
                          "Reading document in collection #{collection.label} with URL #{doc.url} (#{doc_url_parts.size} parts)")

      if should_add_document?(collection, doc_url_parts)
        Jekyll.logger.debug('Prexian CollectionDocReader:', "Adding document with URL: #{doc.url}")
        collection.docs << doc
      else
        Jekyll.logger.debug('Prexian CollectionDocReader:',
                            "Did NOT add document with URL (possibly nesting level doesn't match): #{doc.url}")
      end
    end

    def process_static_file(path, collection)
      Jekyll.logger.debug('Prexian CollectionDocReader:', "Adding static file: #{path}")
      collection.files << ::Jekyll::StaticFile.new(
        @site,
        @site.source,
        Pathname.new(File.dirname(path)).relative_path_from(Pathname.new(@site.source)).to_s,
        File.basename(path),
        collection
      )
    end

    def should_add_document?(collection, doc_url_parts)
      (collection.label != 'projects') || (doc_url_parts.size == 5)
    end
  end
end
