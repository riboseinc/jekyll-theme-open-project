# frozen_string_literal: true

require_relative 'git_service'
require_relative 'project_reader'
require_relative 'spec_builder'

module Prexian
  # Handles reading content for individual project sites
  class ProjectSiteReader
    def initialize(site, git_service: nil)
      @site = site
      @config = @site.config
      @git_service = git_service || GitService.new
      @collection_reader = CollectionDocReader.new(@site)
    end

    def read_content
      return if @config['prexian']['is_hub'] == true

      fetch_hub_logo
      fetch_and_read_software('software')
      fetch_and_read_specs('specs', build_pages: true)
    end

    private

    def fetch_hub_logo
      puts 'Prexian ProjectSiteReader: Fetching hub logo'
      Jekyll.logger.debug('Prexian ProjectSiteReader: Fetching hub logo')

      # Check if parent_hub configuration exists
      parent_hub_config = @config.dig('prexian', 'parent_hub')
      unless parent_hub_config
        Jekyll.logger.warn('[WARNING] prexian.parent_hub is required but not set, skipping hub logo fetch')
        return
      end

      parent_hub_repo_url = parent_hub_config['git_repo_url']
      unless parent_hub_repo_url
        Jekyll.logger.warn('[WARNING] prexian.parent_hub.git_repo_url is required but not set, skipping hub logo fetch')
        return
      end

      parent_hub_repo_branch = @config['prexian']['parent_hub']['git_repo_branch'] || @config['prexian']['default_repo_branch']

      refresh_condition = @config['prexian']['refresh_remote_data'] || 'last-resort'
      puts "Prexian ProjectSiteReader: Parent hub repository branch: #{parent_hub_repo_branch}"
      Jekyll.logger.debug("Prexian ProjectSiteReader: Parent hub repository branch: #{parent_hub_repo_branch}")

      begin
        checkout_result = @git_service.shallow_checkout(
          parent_hub_repo_url,
          branch: parent_hub_repo_branch,
          refresh_condition: refresh_condition
        )
        puts "Prexian ProjectSiteReader: Checkout result: #{checkout_result.inspect}"

        # Copy entire hub site to _parent-hub directory
        hub_destination = File.join(@site.source, '_parent-hub')
        parent_hub_includes = File.join(hub_destination, 'parent-hub')
        @git_service.copy_cached_content(
          checkout_result[:local_path],
          parent_hub_includes
        )
        return unless File.directory?(parent_hub_includes)

        puts "Prexian ProjectSiteReader: Hub site copied to #{parent_hub_includes}"

        # puts @site.includes_load_paths.inspect

        @site.includes_load_paths << hub_destination unless @site.includes_load_paths.include?(hub_destination)
      rescue Prexian::GitService::GitError => e
        Jekyll.logger.warn("Prexian ProjectSiteReader: Failed to fetch hub logo: #{e.message}")
      end
    end

    def fetch_and_read_software(collection_name)
      return unless @site.collections.key?(collection_name)

      Jekyll.logger.debug("Prexian ProjectSiteReader: Fetching software for collection #{collection_name}")

      entry_points = @site.collections[collection_name].docs.select do |doc|
        doc.data['repo_url']
      end

      if entry_points.empty?
        Jekyll.logger.info("Prexian ProjectSiteReader: No software entry points found in #{collection_name}")
        return
      end

      entry_points.each do |index_doc|
        process_software_entry(index_doc, collection_name)
      end
    end

    def process_software_entry(index_doc, collection_name)
      item_name = index_doc.id.split('/')[-1]
      Jekyll.logger.debug("Prexian ProjectSiteReader: Processing software entry #{index_doc.id}")

      docs_config = extract_docs_config(index_doc)
      docs_path = "#{index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"

      # Checkout documentation repository
      docs_checkout = @git_service.shallow_checkout(
        docs_config[:repo_url],
        sparse_subtrees: [docs_config[:subtree]],
        branch: docs_config[:branch],
        refresh_condition: @config['prexian']['refresh_remote_data']
      )

      @git_service.copy_cached_content(
        docs_checkout[:local_path],
        docs_path,
        subtrees: [docs_config[:subtree]]
      )
      @collection_reader.read(docs_path, @site.collections[collection_name])
      index_doc.merge_data!({ 'last_update' => docs_checkout[:modified_at] })
    rescue Prexian::GitService::GitError => e
      # Fallback: get timestamp from main repository if docs checkout failed
      Jekyll.logger.warn("Prexian ProjectSiteReader: Docs checkout failed for #{index_doc.id}, trying main repo: #{e.message}")
      main_checkout = @git_service.shallow_checkout(
        index_doc.data['repo_url'],
        branch: index_doc.data['repo_branch'] || @config['prexian']['default_repo_branch'],
        refresh_condition: @config['prexian']['refresh_remote_data']
      )
      index_doc.merge_data!({ 'last_update' => main_checkout[:modified_at] })
    end

    def fetch_and_read_specs(collection_name, build_pages: false)
      return unless @site.collections.key?(collection_name)

      Jekyll.logger.debug("Prexian ProjectSiteReader: Fetching specs for collection #{collection_name}")

      entry_points = @site.collections[collection_name].docs.select do |doc|
        doc.data['spec_source']
      end

      if entry_points.empty?
        Jekyll.logger.info("Prexian ProjectSiteReader: No spec entry points found in #{collection_name}")
        return
      end

      entry_points.each do |index_doc|
        process_spec_entry(index_doc, collection_name, build_pages: build_pages)
      end
    end

    def process_spec_entry(index_doc, collection_name, build_pages: false)
      Jekyll.logger.debug("Prexian ProjectSiteReader: Processing spec entry #{index_doc.id}")

      spec_config = extract_spec_config(index_doc)

      checkout_result = @git_service.shallow_checkout(
        spec_config[:repo_url],
        sparse_subtrees: [spec_config[:repo_subtree]].compact,
        branch: spec_config[:repo_branch],
        refresh_condition: @config['prexian']['refresh_remote_data']
      )

      @git_service.copy_cached_content(
        checkout_result[:local_path],
        spec_config[:checkout_path],
        subtrees: [spec_config[:repo_subtree]].compact
      )

      build_spec_pages(index_doc, spec_config) if build_pages

      @collection_reader.read(spec_config[:checkout_path], @site.collections[collection_name])
      index_doc.merge_data!({ 'last_update' => checkout_result[:modified_at] })
    end

    def build_spec_pages(index_doc, spec_config)
      return unless spec_config[:engine] && spec_config[:spec_root]

      builder = SpecBuilder.new(
        @site,
        index_doc,
        spec_config[:spec_root],
        "specs/#{spec_config[:item_name]}",
        spec_config[:engine],
        spec_config[:engine_opts]
      )

      builder.build
      builder.built_pages.each do |page|
        @site.pages << page
      end
    rescue StandardError => e
      Jekyll.logger.error("Prexian ProjectSiteReader: Failed to build spec pages for #{index_doc.id}: #{e.message}")
    end

    def extract_docs_config(index_doc)
      docs = index_doc.data['docs']
      main_repo = index_doc.data['repo_url']
      prexian_config = @config['prexian'] || {}
      default_branch = prexian_config['default_repo_branch'] || 'main'
      main_repo_branch = index_doc.data['repo_branch'] || default_branch

      {
        repo_url: (docs && docs['git_repo_url']) || main_repo,
        subtree: (docs && docs['git_repo_subtree']) || 'docs',
        branch: (docs && docs['git_repo_branch']) || main_repo_branch
      }
    end

    def extract_spec_config(index_doc)
      item_name = index_doc.id.split('/')[-1]
      src = index_doc.data['spec_source']
      build = src['build'] || {}

      spec_checkout_path = "#{index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"
      spec_root = src['git_repo_subtree'] ? "#{spec_checkout_path}/#{src['git_repo_subtree']}" : spec_checkout_path

      {
        item_name: item_name,
        repo_url: src['git_repo_url'],
        repo_subtree: src['git_repo_subtree'],
        repo_branch: src['git_repo_branch'] || @config['prexian']['default_repo_branch'],
        engine: build['engine'],
        engine_opts: build['options'] || {},
        checkout_path: spec_checkout_path,
        spec_root: spec_root
      }
    end
  end
end
