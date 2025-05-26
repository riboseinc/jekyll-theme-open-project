# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

require 'bundler/setup'
require 'jekyll'
require 'rspec'

# Require the gem
require 'prexian'

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  # Include GitTestHelper for integration tests
  config.include GitTestHelper, type: :integration

  # Helper methods
  config.include(Module.new do
    def fixture_site(name)
      File.join(File.dirname(__FILE__), 'fixtures', name)
    end

    def build_site(source_dir, config_overrides = {})
      config = Jekyll.configuration(
        'source' => source_dir,
        'destination' => File.join(source_dir, '_site'),
        'quiet' => true,
        'safe' => false
      ).merge(config_overrides)

      Jekyll::Site.new(config)
    end

    def with_temp_cache_dir
      require 'tmpdir'
      Dir.mktmpdir('prexian_test_cache') do |cache_dir|
        original_cache = ENV['ROP_CACHE_DIR']
        ENV['ROP_CACHE_DIR'] = cache_dir
        yield cache_dir
      ensure
        ENV['ROP_CACHE_DIR'] = original_cache
      end
    end
  end)
end
