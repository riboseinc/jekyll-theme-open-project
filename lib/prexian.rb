# frozen_string_literal: true

puts '[prexian] Loading.'

require 'jekyll'

require_relative 'prexian/version'
require_relative 'prexian/git_service'
require_relative 'prexian/cli'

# Only require Jekyll-dependent modules if Jekyll is available
if defined?(Jekyll)
  require_relative 'prexian/site_type'
  require_relative 'prexian/project_reader'
  require_relative 'prexian/hub_site_reader'
  require_relative 'prexian/project_site_reader'
  require_relative 'prexian/filterable_index'
  require_relative 'prexian/blog_index'
  require_relative 'prexian/spec_builder'
end

Jekyll::Hooks.register :site, :after_init do |site|
  puts "[prexian] Registering ProjectReader, theme: #{site.theme&.name || 'none'}"
  site.reader = Prexian::ProjectReader.new(site)
end

# This is a fix for static files
require 'fileutils'
Jekyll::Hooks.register :pages, :post_write do |page|
  if (page.path == 'robots.txt') || (page.path == 'sitemap.xml')
    File.write(page.site.in_dest_dir(page.path), page.content,
               mode: 'wb')
  end
end

puts '[prexian] Loaded.'
