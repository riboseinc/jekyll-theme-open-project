# frozen_string_literal: true

require_relative 'spec_builder'

module Prexian
  # Abstract base class for different types of content entries
  class ContentEntry
    attr_reader :index_doc, :collection_name, :site

    def initialize(index_doc, collection_name, site)
      @index_doc = index_doc
      @collection_name = collection_name
      @site = site
    end

    # Abstract methods that subclasses must implement
    def filter_field
      raise NotImplementedError, "Subclasses must implement filter_field"
    end

    def extract_config
      raise NotImplementedError, "Subclasses must implement extract_config"
    end

    def checkout_destination
      raise NotImplementedError, "Subclasses must implement checkout_destination"
    end

    # Default implementations that can be overridden
    def needs_build?
      false
    end

    def perform_build(config)
      # Default: no build step
    end

    def post_process(checkout_result)
      # Default: no post-processing
    end

    protected

    def item_name
      @item_name ||= @index_doc.id.split('/')[-1]
    end

    def default_repo_branch
      'main'
    end
  end

  # Software entry processor
  class SoftwareEntry < ContentEntry
    def filter_field
      'repo_url'
    end

    def extract_config
      docs = @index_doc.data['docs']
      main_repo = @index_doc.data['repo_url']
      main_repo_branch = @index_doc.data['repo_branch'] || default_repo_branch

      {
        repo_url: (docs && docs['git_repo_url']) || main_repo,
        branch: (docs && docs['git_repo_branch']) || main_repo_branch,
        subtree: (docs && docs['git_repo_subtree']) || 'docs'
      }
    end

    def checkout_destination
      "#{@index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"
    end
  end

  # Specification entry processor
  class SpecificationEntry < ContentEntry
    def filter_field
      'spec_source'
    end

    def extract_config
      src = @index_doc.data['spec_source']
      build = src['build'] || {}

      spec_checkout_path = checkout_destination
      spec_root = src['git_repo_subtree'] ? "#{spec_checkout_path}/#{src['git_repo_subtree']}" : spec_checkout_path

      config = {
        repo_url: src['git_repo_url'],
        branch: src['git_repo_branch'] || default_repo_branch,
        subtree: src['git_repo_subtree'],
        spec_root: spec_root
      }

      if !build['engine'].nil? && !build['engine'].empty?
        unless SpecBuilder.valid_engine?(build['engine'])
          raise ArgumentError, "Invalid engine specified: #{build['engine']}"
        end

        config.merge!(
          engine: build['engine'],
          engine_opts: build['engine_opts'] || {}
        )
      end

      config
    end

    def checkout_destination
      "#{@index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"
    end

    def needs_build?
      config = extract_config
      config[:engine] && config[:spec_root]
    end

    def perform_build(config)
      return unless needs_build?

      builder = SpecBuilder.new(
        @site,
        @index_doc,
        config[:spec_root],
        "specs/#{item_name}",
        config[:engine],
        config[:engine_opts]
      )

      builder.build
      builder.built_pages.each do |page|
        @site.pages << page
      end
    rescue StandardError => e
      Jekyll.logger.error("Prexian ContentEntry: Failed to build spec pages for #{@index_doc.id}: #{e.message}")
    end
  end

  # Project entry processor (for hub sites)
  class ProjectEntry < ContentEntry
    def filter_field
      'site'
    end

    def extract_config
      site_config = @index_doc.data['site']

      # Support both git_repo_url (for Git repositories) and local_path (for local directories)
      if site_config['local_path']
        {
          repo_url: site_config['local_path'],
          branch: nil  # Not applicable for local paths
        }
      else
        {
          repo_url: site_config['git_repo_url'],
          branch: site_config['git_repo_branch'] || default_repo_branch
        }
      end
    end

    def checkout_destination
      File.join(@site.source, '_project-sites', item_name)
    end

    def post_process(checkout_result)
      add_to_includes_load_paths(checkout_result[:local_path])
    end

    private

    def add_to_includes_load_paths(project_path)
      return unless File.directory?(project_path)

      project_sites_dir = File.join(@site.source, '_project-sites')

      # Add _project-sites directory to Jekyll's includes_load_paths
      Jekyll.logger.debug("Prexian ProjectEntry: Adding #{project_sites_dir} to includes_load_paths")
      @site.config['includes_load_paths'] ||= []
      unless @site.config['includes_load_paths'].include?(project_sites_dir)
        @site.config['includes_load_paths'] << project_sites_dir
      end
    end
  end
end
