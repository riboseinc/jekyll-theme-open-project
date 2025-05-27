# frozen_string_literal: true

module Prexian
  class PngDiagramPage < ::Jekyll::Page
    EXTRA_STYLESHEETS = [{
      'href' => 'https://unpkg.com/leaflet@1.3.4/dist/leaflet.css',
      'integrity' => 'sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA==',
      'crossorigin' => ''
    }].freeze

    EXTRA_SCRIPTS = [{
      'src' => 'https://unpkg.com/leaflet@1.3.4/dist/leaflet.js',
      'integrity' => 'sha512-nMMmRyTVoLYqjP9hrbed9S+FzjZHW5gY1TWCHA5ckwXZBadntCNs8kEqAWdrb9O7rxbCaA4lKTIWjDXZxflOcA==',
      'crossorigin' => ''
    }].freeze

    def initialize(site, base, dir, data)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      self.data ||= data

      self.data['extra_stylesheets'] = EXTRA_STYLESHEETS
      self.data['extra_scripts'] = EXTRA_SCRIPTS
      self.data['layout'] = 'spec'
    end
  end
end
