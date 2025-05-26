# frozen_string_literal: true

require_relative 'lib/prexian/version'

Gem::Specification.new do |spec|
  spec.name          = 'prexian'
  spec.version       = Prexian::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['open.source@ribose.com']

  spec.summary       = 'Prexian Jekyll theme'
  spec.homepage      = 'https://github.com/riboseinc/prexian/'
  spec.license       = 'MIT'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__,
                                             err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        !f.match(%r{^((lib|_data|_includes|_layouts|_sass|assets|_pages|_plugins)/|(_config.yml|LICENSE|README|Rakefile)((\.(txt|md|markdown)|$)))}i)
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'fastimage'
  spec.add_dependency 'git'
  spec.add_dependency 'html-proofer'
  spec.add_dependency 'jekyll', '~> 4.3'
  spec.add_dependency 'jekyll-asciidoc'
  spec.add_dependency 'jekyll-data'
  spec.add_dependency 'jekyll-redirect-from'
  spec.add_dependency 'jekyll-seo-tag'
  spec.add_dependency 'jekyll-sitemap'
  spec.add_dependency 'kramdown-parser-gfm'
  spec.add_dependency 'kramdown-syntax-coderay'

  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'w3c_validators'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
