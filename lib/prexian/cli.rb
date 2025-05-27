# frozen_string_literal: true

require 'thor'
require_relative 'git_service'

module Prexian
  # Command-line interface for Prexian theme management
  class CLI < Thor
    desc 'clean', 'Clean cached Git repositories and test fixtures'
    method_option :project, aliases: '-p', type: :string, desc: 'Clean cache for specific project repository URL'
    method_option :all, aliases: '-a', type: :boolean, desc: 'Clean entire cache directory'
    def clean
      git_service = GitService.new

      if options[:project]
        git_service.cleanup_cache(repo_url: options[:project])
        say "Cleaned cache for project: #{options[:project]}", :green
      elsif options[:all]
        git_service.cleanup_cache
        say 'Cleaned entire cache directory', :green
      else
        git_service.cleanup_cache
        say 'Cleaned entire cache directory', :green
      end

      # Clean test fixture directories
      cleanup_test_fixtures
    rescue StandardError => e
      say "Error cleaning cache: #{e.message}", :red
      exit 1
    end

    desc 'status', 'Show cache status and disk usage'
    def status
      git_service = GitService.new
      stats = git_service.cache_stats

      say "Cache Directory: #{stats[:cache_dir]}", :blue
      say "Total Repositories: #{stats[:total_repos]}", :blue
      say "Total Size: #{format_bytes(stats[:total_size])}", :blue

      if stats[:total_repos] > 0
        say "\nTo clean cache, run: prexian clean", :yellow
      else
        say "\nCache is empty", :green
      end
    rescue StandardError => e
      say "Error getting cache status: #{e.message}", :red
      exit 1
    end

    desc 'version', 'Show Prexian theme version'
    def version
      require_relative 'version'
      say "prexian version #{Prexian::VERSION}", :blue
    end

    private

    def cleanup_test_fixtures
      require 'fileutils'

      directories_to_clean = [
        'spec/fixtures/hub/_project-sites',
        'spec/fixtures/project/_parent-hub',
        Dir.glob('spec/fixtures/*/_site')
      ].flatten

      directories_to_clean.each do |dir|
        next unless Dir.exist?(dir)

        FileUtils.rm_rf(dir)
        say "Cleaned directory: #{dir}", :green
      end

      say 'Cleaned test fixture directories', :green if directories_to_clean.any? { |dir| Dir.exist?(dir) }
    end

    def format_bytes(bytes)
      units = %w[B KB MB GB TB]
      size = bytes.to_f
      unit_index = 0

      while size >= 1024 && unit_index < units.length - 1
        size /= 1024
        unit_index += 1
      end

      format('%.2f %s', size, units[unit_index])
    end
  end
end
