# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = 'jekyll-theme-open-project'
  s.version       = '2.0.21'
  s.authors       = ['Ribose Inc.']
  s.email         = ['open.source@ribose.com']

  s.summary       = 'Open Project Jekyll theme'
  s.homepage      = 'https://github.com/riboseinc/jekyll-theme-open-project/'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^((_data|_includes|_layouts|_sass|assets|_pages)/|(_config.yml|LICENSE|README)((\.(txt|md|markdown)|$)))}i) }

  s.add_runtime_dependency 'jekyll', '~> 3.8'
  s.add_runtime_dependency 'jekyll-seo-tag', '~> 2.0'
  s.add_runtime_dependency 'jekyll-data', '~> 1.0'
  s.add_runtime_dependency 'git', '~> 1.4'
  s.add_runtime_dependency 'jekyll-theme-open-project-helpers', '= 2.0.21'

  s.add_development_dependency 'bundler', '~> 2.0'
  s.add_development_dependency 'rake', '~> 12.0'

  s.add_development_dependency 'html-proofer', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.50'
  s.add_development_dependency 'w3c_validators', '~> 1.3'
end
