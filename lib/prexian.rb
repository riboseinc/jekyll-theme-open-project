# frozen_string_literal: true

puts '[prexian] Loading.'

require 'jekyll'

require_relative 'prexian/version'
require_relative 'prexian/git_service'
require_relative 'prexian/cli'

require_relative 'prexian/configuration_helper'
require_relative 'prexian/collection_doc_reader'
require_relative 'prexian/site_loader'
require_relative 'prexian/project_reader'
require_relative 'prexian/hub_site_loader'
require_relative 'prexian/project_site_loader'
require_relative 'prexian/filterable_index'
require_relative 'prexian/blog_index'
require_relative 'prexian/spec_builder'

Jekyll::Hooks.register :site, :after_init do |site|
  puts "[prexian] Registering ProjectReader, theme: #{site.theme&.name || 'none'}"
  site.reader = Prexian::ProjectReader.new(site)
end

# This is a fix for static files
require 'fileutils'
Jekyll::Hooks.register :pages, :post_write do |page|
  if (page.path == 'robots.txt') || (page.path == 'sitemap.xml')
    File.write(page.site.in_dest_dir(page.path), page.content, mode: 'wb')
  end
end

puts '[prexian] Loaded.'
