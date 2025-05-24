# frozen_string_literal: true

require 'fileutils'
require 'git'
require 'jekyll-data/reader'

module Rop
  DEFAULT_DOCS_SUBTREE = 'docs'
  DEFAULT_REPO_REMOTE_NAME = 'origin'
  DEFAULT_REPO_BRANCH = 'main'
  # Can be overridden by default_repo_branch in site config.
  # Used by shallow_git_checkout.

  class NonLiquidDocument < ::Jekyll::Document
    def render_with_liquid?
      false
    end
  end

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

        Jekyll.logger.debug('OPF:', "Reading entry #{path}")

        if File.directory?(path)
          read_project_subdir(path, collection, nested: true)

        elsif nested || (File.basename(entry, '.*') != 'index')
          ext = File.extname(path)
          if ['.adoc', '.md', '.markdown'].include? ext
            doc = NonLiquidDocument.new(path, site: @site, collection: collection)
            doc.read

            # Add document to Jekyll document database if it refers to software or spec
            # (as opposed to be some random nested document within repository source, like a README)
            doc_url_parts = doc.url.split('/')
            Jekyll.logger.debug('OPF:',
                                "Reading document in collection #{collection.label} with URL #{doc.url} (#{doc_url_parts.size} parts)")
            if (collection.label != 'projects') || (doc_url_parts.size == 5)
              Jekyll.logger.debug('OPF:', "Adding document with URL: #{doc.url}")
              collection.docs << doc
            else
              Jekyll.logger.debug('OPF:',
                                  "Did NOT add document with URL (possibly nesting level doesn’t match): #{doc.url}")
            end
          else
            Jekyll.logger.debug('OPF:', "Adding static file: #{path}")
            collection.files << ::Jekyll::StaticFile.new(
              @site,
              @site.source,
              Pathname.new(File.dirname(path)).relative_path_from(Pathname.new(@site.source)).to_s,
              File.basename(path),
              collection
            )
          end
        end
      end
    end
  end

  #
  # Below deals with fetching each open project’s data from its site’s repo
  # (such as posts, template includes, software and specs)
  # and reading it into 'projects' collection docs.
  #

  class ProjectReader < ::JekyllData::Reader
    # TODO: Switch to @site.config?
    @@siteconfig = Jekyll.configuration({})

    def read
      super
      if @site.config['is_hub']
        fetch_and_read_projects
      else
        fetch_and_read_software('software')
        fetch_and_read_specs('specs', build_pages: true)
        fetch_hub_logo
      end
    end

    private

    def fetch_hub_logo
      return unless @site.config.key?('parent_hub') && @site.config['parent_hub'].key?('git_repo_url')

      git_shallow_checkout(
        File.join(@site.source, 'parent-hub'),
        @site.config['parent_hub']['git_repo_url'],
        ['assets', 'title.html'],
        @site.config['parent_hub']['git_repo_branch']
      )
    end

    def fetch_and_read_projects
      project_indexes = @site.collections['projects'].docs.select do |doc|
        pieces = doc.id.split('/')
        pieces.length == 4 and pieces[1] == 'projects' and pieces[3] == 'index'
      end
      project_indexes.each do |project|
        project_path = project.path.split('/')[0..-2].join('/')

        git_shallow_checkout(
          project_path,
          project['site']['git_repo_url'],
          %w[assets _posts _software _specs],
          project['site']['git_repo_branch']
        )

        Jekyll.logger.debug('OPF:', "Reading files in project #{project_path}")

        CollectionDocReader.new(site).read(
          project_path,
          @site.collections['projects']
        )

        fetch_and_read_software('projects')
        fetch_and_read_specs('projects')
      end
    end

    def build_and_read_spec_pages(collection_name, index_doc, build_pages: false)
      spec_config = extract_spec_config(index_doc)
      repo_checkout = git_shallow_checkout(
        spec_config[:checkout_path],
        spec_config[:repo_url],
        [spec_config[:repo_subtree]],
        spec_config[:repo_branch]
      )

      return unless repo_checkout[:success]

      build_spec_pages(collection_name, index_doc, spec_config) if build_pages

      index_doc.merge_data!({ 'last_update' => repo_checkout[:modified_at] })
    end

    def extract_spec_config(index_doc)
      item_name = index_doc.id.split('/')[-1]
      src = index_doc.data['spec_source']
      build = src['build']

      spec_checkout_path = "#{index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"
      spec_root = src['git_repo_subtree'] ? "#{spec_checkout_path}/#{src['git_repo_subtree']}" : spec_checkout_path

      {
        item_name: item_name,
        repo_url: src['git_repo_url'],
        repo_subtree: src['git_repo_subtree'],
        repo_branch: src['git_repo_branch'],
        engine: build['engine'],
        engine_opts: build['options'] || {},
        checkout_path: spec_checkout_path,
        spec_root: spec_root
      }
    end

    def build_spec_pages(collection_name, index_doc, spec_config)
      builder = Rop::SpecBuilder.new(
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

      CollectionDocReader.new(site).read(
        spec_config[:checkout_path],
        @site.collections[collection_name]
      )
    end

    def fetch_and_read_specs(collection_name, build_pages: false)
      # collection_name would be either specs or (for hub site) projects

      Jekyll.logger.debug('OPF:', "Fetching specs for items in collection #{collection_name} (if it exists)")

      return unless @site.collections.key?(collection_name)

      Jekyll.logger.debug('OPF:', "Fetching specs for items in collection #{collection_name}")

      # Get spec entry points
      entry_points = @site.collections[collection_name].docs.select do |doc|
        doc.data['spec_source']
      end

      if entry_points.empty?
        Jekyll.logger.info('OPF:',
                           "Fetching specs for items in collection #{collection_name}: No entry points")
      end

      entry_points.each do |index_doc|
        Jekyll.logger.debug('OPF:', "Fetching specs: entry point #{index_doc.id} in collection #{collection_name}")
        build_and_read_spec_pages(collection_name, index_doc, build_pages: build_pages)
      end
    end

    def fetch_and_read_software(collection_name)
      # collection_name would be either software or (for hub site) projects

      Jekyll.logger.debug('OPF:', "Fetching software for items in collection #{collection_name} (if it exists)")

      return unless @site.collections.key?(collection_name)

      Jekyll.logger.debug('OPF:', "Fetching software for items in collection #{collection_name}")

      entry_points = @site.collections[collection_name].docs.select do |doc|
        doc.data['repo_url']
      end

      if entry_points.empty?
        Jekyll.logger.info('OPF:',
                           "Fetching software for items in collection #{collection_name}: No entry points")
      end

      entry_points.each do |index_doc|
        item_name = index_doc.id.split('/')[-1]
        Jekyll.logger.debug('OPF:', "Fetching software: entry point #{index_doc.id} in collection #{collection_name}")

        docs = index_doc.data['docs']
        main_repo = index_doc.data['repo_url']
        main_repo_branch = index_doc.data['repo_branch']

        sw_docs_repo = (docs['git_repo_url'] if docs) || main_repo
        sw_docs_subtree = (docs['git_repo_subtree'] if docs) || DEFAULT_DOCS_SUBTREE
        sw_docs_branch = (docs['git_repo_branch'] if docs) || main_repo_branch

        docs_path = "#{index_doc.path.split('/')[0..-2].join('/')}/#{item_name}"

        sw_docs_checkout = git_shallow_checkout(docs_path, sw_docs_repo, [sw_docs_subtree], sw_docs_branch)

        if sw_docs_checkout[:success]
          CollectionDocReader.new(site).read(
            docs_path,
            @site.collections[collection_name]
          )
        end

        # Get last repository modification timestamp.
        # Fetch the repository for that purpose,
        # unless it’s the same as the repo where docs are.
        if !sw_docs_checkout[:success] || (sw_docs_repo != main_repo)
          repo_path = "#{index_doc.path.split('/')[0..-2].join('/')}/_#{item_name}_repo"
          repo_checkout = git_shallow_checkout(repo_path, main_repo, [], main_repo_branch)
          index_doc.merge_data!({ 'last_update' => repo_checkout[:modified_at] })
        else
          index_doc.merge_data!({ 'last_update' => sw_docs_checkout[:modified_at] })
        end
      end
    end

    def git_shallow_checkout(repo_path, remote_url, sparse_subtrees, branch_name)
      # Returns hash with timestamp of latest repo commit
      # and boolean signifying whether new repo has been initialized
      # in the process of pulling the data.

      newly_initialized = false
      repo = nil

      git_dir = File.join(repo_path, '.git')
      git_info_dir = File.join(git_dir, 'info')
      git_sparse_checkout_file = File.join(git_dir, 'info', 'sparse-checkout')
      if File.exist? git_dir
        repo = Git.open(repo_path)

      else
        newly_initialized = true

        repo = Git.init(repo_path)

        repo.config(
          'core.sshCommand',
          'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
        )

        repo.add_remote(DEFAULT_REPO_REMOTE_NAME, remote_url)

        if sparse_subtrees.size.positive?
          repo.config('core.sparseCheckout', true)

          FileUtils.mkdir_p git_info_dir
          File.open(git_sparse_checkout_file, 'a') do |f|
            sparse_subtrees.each { |path| f << "#{path}\n" }
          end
        end

      end

      refresh_condition = @@siteconfig['refresh_remote_data'] || 'last-resort'
      repo_branch = branch_name || @@siteconfig['default_repo_branch'] || DEFAULT_REPO_BRANCH

      raise 'Invalid refresh_remote_data value in site’s _config.yml!' unless %w[always last-resort
                                                                                 skip].include?(refresh_condition)

      if refresh_condition == 'always'
        repo.fetch(DEFAULT_REPO_REMOTE_NAME, { depth: 1 })
        repo.reset_hard
        repo.checkout("#{DEFAULT_REPO_REMOTE_NAME}/#{repo_branch}", { f: true })

      elsif refresh_condition == 'last-resort'
        # This is the default case.

        begin
          # Let’s try in case this repo has been fetched before (this would never be the case on CI though)
          repo.checkout("#{DEFAULT_REPO_REMOTE_NAME}/#{repo_branch}", { f: true })
        rescue StandardError => e
          if is_sparse_checkout_error(e, sparse_subtrees)
            # Silence errors caused by nonexistent sparse checkout directories
            return {
              success: false,
              newly_initialized: nil,
              modified_at: nil
            }
          else
            # In case of any other error, presume repo has not been fetched and do that now.
            Jekyll.logger.debug('OPF:', "Fetching & checking out #{remote_url} for #{repo_path}")
            repo.fetch(DEFAULT_REPO_REMOTE_NAME, { depth: 1 })
            begin
              # Try checkout again
              repo.checkout("#{DEFAULT_REPO_REMOTE_NAME}/#{repo_branch}", { f: true })
            rescue StandardError => e
              raise e unless is_sparse_checkout_error(e, sparse_subtrees)

              # Again, silence an error caused by nonexistent sparse checkout directories…
              return {
                success: false,
                newly_initialized: nil,
                modified_at: nil
              }

              # but this time throw any other error.
            end
          end
        end
      end

      latest_commit = repo.gcommit('HEAD')

      {
        success: true,
        newly_initialized: newly_initialized,
        modified_at: latest_commit.date
      }
    end

    def is_sparse_checkout_error(err, subtrees)
      if err.message.include? 'Sparse checkout leaves no entry on working directory'
        Jekyll.logger.debug('OPF: It looks like sparse checkout of these directories failed:', subtrees.to_s)
        true
      else
        false
      end
    end
  end
end
