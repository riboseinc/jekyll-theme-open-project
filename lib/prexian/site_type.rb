# frozen_string_literal: true

module Prexian
  #
  # Infers from available content whether the site is a hub
  # or individual project site, and adds site-wide config variable
  # accessible as {{ site.is_hub }} in Liquid.
  #
  class SiteTypeVariableGenerator < Jekyll::Generator
    def generate(site)
      prexian_config = site.config['prexian'] || {}
      prexian_config['is_hub'] = hub_site?(site)
    end

    private

    # If there’re projects defined, we assume it is indeed
    # a Jekyll Open Project hub site.
    def hub_site?(site)
      projects = site.collections['projects']
      projects&.docs&.any?
    end
  end
end
