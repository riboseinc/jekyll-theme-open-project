# frozen_string_literal: true

require_relative 'lib/prexian/version'

Gem::Specification.new do |spec|
  spec.name     = 'prexian'
  spec.version  = Prexian::VERSION
  spec.authors  = ['Ribose Inc.']
  spec.email    = ['open.source@ribose.com']

  spec.summary  = 'A Jekyll theme to manage a nexus of project sites.'
  spec.homepage = 'https://github.com/riboseinc/prexian/'
  spec.license  = 'MIT'

  spec.metadata['plugin_type'] = 'theme'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(assets|exe|lib|_(includes|layouts|sass|data|pages)/|_config.yml|(LICENSE|README)((\.txt|\.md|\.markdown|\.adoc)|$))}i)
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Core Jekyll dependencies
  spec.add_runtime_dependency 'jekyll', '~> 4.4'
  spec.add_runtime_dependency 'jekyll-seo-tag', '~> 2.1'
  spec.add_runtime_dependency 'jekyll-sitemap', '~> 1.0'

  # Prexian-specific dependencies
  spec.add_runtime_dependency 'fastimage', '~> 2.0'
  spec.add_runtime_dependency 'git', '~> 1.0'
  spec.add_runtime_dependency 'jekyll-asciidoc', '~> 3.0'
  spec.add_runtime_dependency 'jekyll-data', '~> 1.0'
  spec.add_runtime_dependency 'jekyll-redirect-from', '~> 0.16'
  spec.add_runtime_dependency 'kramdown-parser-gfm', '~> 1.0'
  spec.add_runtime_dependency 'kramdown-syntax-coderay', '~> 1.0'
  spec.add_runtime_dependency 'thor', '~> 1.0'

  # Development dependencies
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
end
