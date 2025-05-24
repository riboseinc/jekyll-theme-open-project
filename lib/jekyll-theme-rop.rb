# frozen_string_literal: true

module Jekyll
  module Theme
    module Rop
    end
  end
end

puts '[jekyll-theme-rop] Loaded.'

require 'jekyll'
require_relative 'rop'

Jekyll::Hooks.register :site, :after_init do |site|
  site.reader = Rop::ProjectReader.new(site) if site.theme # TODO: Check theme name
end

# This is a fix for static files
require 'fileutils'
Jekyll::Hooks.register :pages, :post_write do |page|
  if (page.path == 'robots.txt') || (page.path == 'sitemap.xml')
    File.write(page.site.in_dest_dir(page.path), page.content,
               mode: 'wb')
  end
end
