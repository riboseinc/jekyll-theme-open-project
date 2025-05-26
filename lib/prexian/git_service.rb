# frozen_string_literal: true

require 'fileutils'
require 'git'
require 'digest'
require 'jekyll'

module Prexian
  # Service class for handling Git operations with external caching
  class GitService
    DEFAULT_REPO_REMOTE_NAME = 'origin'
    DEFAULT_REPO_BRANCH = 'main'
    DEFAULT_CACHE_DIR = File.expand_path('~/.prexian/cache/repos')

    class GitError < StandardError; end
    class SparseCheckoutError < GitError; end

    def initialize(cache_dir: nil, logger: nil)
      @cache_dir = cache_dir || ENV['ROP_CACHE_DIR'] || DEFAULT_CACHE_DIR
      @logger = logger || default_logger
      ensure_cache_dir_exists
    end

    # Shallow clone or update a repository with optional sparse checkout
    # Returns hash with success status, timestamp, and local path
    def shallow_checkout(repo_url, sparse_subtrees: [], branch: nil, refresh_condition: 'last-resort')
      # Check if repo_url is a file path
      return handle_file_path_checkout(repo_url) if File.exist?(repo_url) && File.directory?(repo_url)

      repo_hash = generate_repo_hash(repo_url)
      branch_name = branch || DEFAULT_REPO_BRANCH
      repo_path = File.join(@cache_dir, repo_hash, branch_name)

      @logger.debug("Prexian GitService: Checking out #{repo_url} (#{branch_name}) to #{repo_path}")

      result = perform_checkout(repo_path, repo_url, sparse_subtrees, branch_name, refresh_condition)
      result[:local_path] = repo_path
      result
    rescue StandardError => e
      @logger.error("Prexian GitService: Failed to checkout #{repo_url}: #{e.message}")
      raise GitError, "Git checkout failed for #{repo_url}: #{e.message}"
    end

    # Copy files from cached repository to destination
    def copy_cached_content(cached_repo_path, destination_path, subtrees: [])
      return false unless File.exist?(cached_repo_path)

      FileUtils.mkdir_p(destination_path)

      if subtrees.empty?
        # Copy entire repository content (excluding .git)
        Dir.glob(File.join(cached_repo_path, '*')).each do |item|
          next if File.basename(item) == '.git'

          FileUtils.cp_r(item, destination_path)
        end
      else
        # Copy only specified subtrees
        subtrees.each do |subtree|
          source_path = File.join(cached_repo_path, subtree)
          next unless File.exist?(source_path)

          dest_subtree_path = File.join(destination_path, subtree)
          FileUtils.mkdir_p(File.dirname(dest_subtree_path))
          FileUtils.cp_r(source_path, dest_subtree_path)
        end
      end

      true
    rescue StandardError => e
      @logger.error("Prexian GitService: Failed to copy content: #{e.message}")
      false
    end

    # Clean up cached repositories
    def cleanup_cache(repo_url: nil)
      if repo_url
        repo_hash = generate_repo_hash(repo_url)
        repo_cache_path = File.join(@cache_dir, repo_hash)
        FileUtils.rm_rf(repo_cache_path) if File.exist?(repo_cache_path)
        @logger.info("Prexian GitService: Cleaned cache for #{repo_url}")
      else
        FileUtils.rm_rf(@cache_dir) if File.exist?(@cache_dir)
        @logger.info('Prexian GitService: Cleaned entire cache directory')
      end
    end

    # Get cache statistics
    def cache_stats
      return { total_repos: 0, total_size: 0 } unless File.exist?(@cache_dir)

      total_size = 0
      repo_count = 0

      Dir.glob(File.join(@cache_dir, '*')).each do |repo_dir|
        next unless File.directory?(repo_dir)

        repo_count += 1
        total_size += directory_size(repo_dir)
      end

      {
        total_repos: repo_count,
        total_size: total_size,
        cache_dir: @cache_dir
      }
    end

    private

    def default_logger
      # Try to use Jekyll logger if available, otherwise create a simple logger
      if defined?(Jekyll)
        Jekyll.logger
      else
        require 'logger'
        Logger.new($stdout).tap do |logger|
          logger.level = Logger::INFO
        end
      end
    end

    def handle_file_path_checkout(file_path)
      # For file paths, we pretend it's a successful checkout
      # and return the path as-is with current timestamp
      {
        success: true,
        newly_initialized: false,
        modified_at: File.mtime(file_path),
        local_path: file_path
      }
    end

    def ensure_cache_dir_exists
      FileUtils.mkdir_p(@cache_dir) unless File.exist?(@cache_dir)
    end

    def generate_repo_hash(repo_url)
      # Create a hash from the repository URL for consistent directory naming
      Digest::SHA256.hexdigest(repo_url)[0..15]
    end

    def perform_checkout(repo_path, remote_url, sparse_subtrees, branch_name, refresh_condition)
      newly_initialized = false
      repo = nil

      git_dir = File.join(repo_path, '.git')

      if File.exist?(git_dir)
        repo = Git.open(repo_path)
      else
        newly_initialized = true
        repo = initialize_new_repo(repo_path, remote_url, sparse_subtrees)
      end

      handle_refresh_condition(repo, branch_name, refresh_condition, sparse_subtrees)

      latest_commit = repo.gcommit('HEAD')

      {
        success: true,
        newly_initialized: newly_initialized,
        modified_at: latest_commit.date
      }
    end

    def initialize_new_repo(repo_path, remote_url, sparse_subtrees)
      FileUtils.mkdir_p(repo_path)
      repo = Git.init(repo_path)

      repo.config('core.sshCommand', 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no')
      repo.add_remote(DEFAULT_REPO_REMOTE_NAME, remote_url)

      setup_sparse_checkout(repo, repo_path, sparse_subtrees) if sparse_subtrees.any?

      repo
    end

    def setup_sparse_checkout(repo, repo_path, sparse_subtrees)
      repo.config('core.sparseCheckout', true)

      git_info_dir = File.join(repo_path, '.git', 'info')
      FileUtils.mkdir_p(git_info_dir)

      sparse_checkout_file = File.join(git_info_dir, 'sparse-checkout')
      File.open(sparse_checkout_file, 'w') do |f|
        sparse_subtrees.each { |path| f.puts(path) }
      end
    end

    def handle_refresh_condition(repo, branch_name, refresh_condition, sparse_subtrees)
      case refresh_condition
      when 'always'
        fetch_and_checkout(repo, branch_name)
      when 'last-resort'
        handle_last_resort_refresh(repo, branch_name, sparse_subtrees)
      when 'skip'
        # Do nothing - use existing checkout
      else
        raise GitError, "Invalid refresh_remote_data value: #{refresh_condition}"
      end
    end

    def fetch_and_checkout(repo, branch_name)
      repo.fetch(DEFAULT_REPO_REMOTE_NAME, { depth: 1 })
      repo.reset_hard
      repo.checkout("#{DEFAULT_REPO_REMOTE_NAME}/#{branch_name}", { f: true })
    end

    def handle_last_resort_refresh(repo, branch_name, sparse_subtrees)
      repo.checkout("#{DEFAULT_REPO_REMOTE_NAME}/#{branch_name}", { f: true })
    rescue StandardError => e
      if sparse_checkout_error?(e, sparse_subtrees)
        raise SparseCheckoutError, "Sparse checkout failed for subtrees: #{sparse_subtrees.join(', ')}"
      end

      @logger.debug("Prexian GitService: Checkout failed, fetching: #{e.message}")
      fetch_and_checkout(repo, branch_name)
    end

    def sparse_checkout_error?(error, subtrees)
      error.message.include?('Sparse checkout leaves no entry on working directory') && subtrees.any?
    end

    def directory_size(path)
      total_size = 0
      Dir.glob(File.join(path, '**', '*'), File::FNM_DOTMATCH).each do |file|
        total_size += File.size(file) if File.file?(file)
      end
      total_size
    end
  end
end
