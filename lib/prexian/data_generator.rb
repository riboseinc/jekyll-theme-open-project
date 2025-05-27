# frozen_string_literal: true

require_relative 'index_generator'

module Prexian
  # Generator that populates site.prexian.* data for use in templates
  class DataGenerator < Jekyll::Generator
    include ConfigurationHelper

    safe true
    priority :low

    def generate(site)
      @site = site

      # Initialize prexian data namespace
      site.config['prexian'] ||= {}
      prexian_data = site.config['prexian']

      # Process projects for hub sites
      if is_hub?
        process_projects(site, prexian_data)
      end

      # Process software and specs for all sites
      process_software(site, prexian_data)
      process_specs(site, prexian_data)
      process_posts(site, prexian_data)
    end

    private

    def process_projects(site, prexian_data)
      return unless site.collections['projects']

      projects = get_projects(site)

      # Set basic project data
      prexian_data['projects'] = projects
      prexian_data['num_projects'] = projects.size

      # Categorize featured vs non-featured projects
      featured_projects = projects.select { |p| p.data['featured'] }
      prexian_data['featured_projects'] = featured_projects
      prexian_data['num_featured_projects'] = featured_projects.size

      non_featured_projects = projects.reject { |p| p.data['featured'] }
      prexian_data['non_featured_projects'] = non_featured_projects
      prexian_data['num_non_featured_projects'] = non_featured_projects.size
    end

    def process_software(site, prexian_data)
      return unless site.collections['software']

      software_items = site.collections['software'].docs.select do |item|
        item.path.include?('/_software') && !item.path.include?('/docs')
      end

      sort_items_by_date(software_items)
      add_project_data_to_items(site, software_items) if is_hub?

      set_index_config(software_items, 'software')
      categorize_items(software_items, 'software')

      # Copy to prexian namespace
      prexian_data['all_software'] = software_items
      prexian_data['num_all_software'] = software_items.size
      prexian_data['featured_software'] = prexian_data['featured_software'] || []
      prexian_data['num_featured_software'] = prexian_data['featured_software'].size
      prexian_data['non_featured_software'] = prexian_data['non_featured_software'] || []
      prexian_data['num_non_featured_software'] = prexian_data['non_featured_software'].size
      prexian_data['one_software'] = software_items.size == 1
    end

    def process_specs(site, prexian_data)
      return unless site.collections['specs']

      spec_items = site.collections['specs'].docs.select do |item|
        item.path.include?('/_specs') && !item.path.include?('/docs')
      end

      sort_items_by_date(spec_items)
      add_project_data_to_items(site, spec_items) if is_hub?

      set_index_config(spec_items, 'specs')
      categorize_items(spec_items, 'specs')

      # Copy to prexian namespace
      prexian_data['all_specs'] = spec_items
      prexian_data['num_all_specs'] = spec_items.size
      prexian_data['featured_specs'] = prexian_data['featured_specs'] || []
      prexian_data['num_featured_specs'] = prexian_data['featured_specs'].size
      prexian_data['non_featured_specs'] = prexian_data['non_featured_specs'] || []
      prexian_data['num_non_featured_specs'] = prexian_data['non_featured_specs'].size
    end

    def process_posts(site, prexian_data)
      return unless site.collections['posts']

      posts = site.collections['posts'].docs
      sort_items_by_date(posts, 'date')

      # For hub sites, combine posts from all projects
      if is_hub?
        combined_posts = posts.dup

        # Add posts from project sites if they exist
        site.collections['projects']&.docs&.each do |project|
          project_name = project.data['name'] || project.url.split('/')[2]
          project_posts_path = File.join(site.source, '_project-sites', project_name, '_posts')

          if Dir.exist?(project_posts_path)
            Dir.glob(File.join(project_posts_path, '*.md')).each do |post_file|
              # Create document for project post
              project_post = Jekyll::Document.new(
                post_file,
                site: site,
                collection: site.collections['posts']
              )
              project_post.read
              project_post.data['project_name'] = project_name
              combined_posts << project_post
            end
          end
        end

        sort_items_by_date(combined_posts, 'date')
        prexian_data['posts_combined'] = combined_posts
        prexian_data['num_posts_combined'] = combined_posts.size
      end

      prexian_data['posts'] = posts
      prexian_data['num_posts'] = posts.size
    end

    def set_index_config(items, index_name)
      prexian_data = @site.config['prexian']
      prexian_data["one_#{index_name}"] = items.size == 1 ? items[0] : nil
      prexian_data["all_#{index_name}"] = items
      prexian_data["num_all_#{index_name}"] = items.size
    end

    def categorize_items(items, index_name)
      prexian_data = @site.config['prexian']

      featured_items = items.select { |item| item.data['featured'] }
      prexian_data["featured_#{index_name}"] = featured_items
      prexian_data["num_featured_#{index_name}"] = featured_items.size

      non_featured_items = items.reject { |item| item.data['featured'] }
      prexian_data["non_featured_#{index_name}"] = non_featured_items
      prexian_data["num_non_featured_#{index_name}"] = non_featured_items.size
    end

    def sort_items_by_date(items, date_field = 'last_update')
      items.sort! do |i1, i2|
        val1 = i1.data.fetch(date_field, default_time) || default_time
        val2 = i2.data.fetch(date_field, default_time) || default_time
        (val2 <=> val1) || 0
      end
    end

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

    def default_time
      Time.new(1970, 1, 1)
    end
  end
end
