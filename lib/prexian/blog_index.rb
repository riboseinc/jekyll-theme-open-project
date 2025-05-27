# frozen_string_literal: true

require 'digest/md5'
require_relative 'index_generator'

module Prexian
  #
  # Adds a variable holding the array of posts of open hub blog
  # and from each individual project blog, combined and sorted by date.
  #
  # It also does some processing on the posts
  # as required by the Open Project theme.
  #
  class CombinedPostArrayGenerator < Jekyll::Generator
    include ConfigurationHelper

    safe true

    def generate(site)
      @site = site
      site_posts = site.posts.docs

      posts_combined = if is_hub?
        project_posts = get_project_posts(site)
        (project_posts + site_posts)
      else
        site_posts
      end

      # On each post, replace authors' emails with corresponding md5 hashes
      # suitable for hotlinking authors' Gravatar profile pictures.
      posts_combined = posts_combined.sort_by(&:date).reverse.map do |post|
        process_author(post.data['author']) if post.data.key? 'author'

        if post.data.key? 'authors'
          post.data['authors'].map do |author|
            process_author(author)
          end
        end

        post
      end

      # Make combined blog post array available site-wide
      prexian_config['posts_combined'] = posts_combined
      prexian_config['num_posts_combined'] = posts_combined.size
    end

    private

    def get_project_posts(site)
      projects = get_projects(site)

      # Get documents representing posts from each project's blog
      project_posts = site.collections['projects'].docs.select { |item| item.url.include? '_posts' }

      # Add parent project's data hash onto each
      project_posts.map do |post|
        project_name = post.url.split('/')[2]
        post.data['parent_project'] = projects.detect { |p| p.data['name'] == project_name }
        post.content = ''
        post
      end
    end

    def process_author(author)
      # Handle string authors (just return as-is)
      return author unless author.is_a?(Hash)

      # Handle hash authors with email processing
      email = author['email']
      return author if email.nil? || email.empty?

      hash = Digest::MD5.hexdigest(email)
      author['email'] = hash
      author['plaintext_email'] = email
      author
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
  end
end
