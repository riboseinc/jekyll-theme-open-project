# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

module GitTestHelper
  def setup_test_repositories
    @test_dir = Dir.mktmpdir('prexian-test')
    @hub_repo_path = File.join(@test_dir, 'hub-site')
    @project_repo_path = File.join(@test_dir, 'project-site')

    create_hub_repository
    create_project_repository

    {
      hub_repo_path: @hub_repo_path,
      project_repo_path: @project_repo_path,
      hub_repo_url: "file://#{@hub_repo_path}",
      project_repo_url: "file://#{@project_repo_path}"
    }
  end

  def cleanup_test_repositories
    FileUtils.rm_rf(@test_dir) if @test_dir && Dir.exist?(@test_dir)
  end

  private

  def create_hub_repository
    FileUtils.mkdir_p(@hub_repo_path)
    Dir.chdir(@hub_repo_path) do
      # Initialize git repository
      system('git init --quiet')
      system('git config user.email "test@example.com"')
      system('git config user.name "Test User"')

      # Create hub site structure
      create_hub_site_files

      # Add and commit files
      system('git add .')
      system('git commit -m "Initial hub site commit" --quiet')
    end
  end

  def create_project_repository
    FileUtils.mkdir_p(@project_repo_path)
    Dir.chdir(@project_repo_path) do
      # Initialize git repository
      system('git init --quiet')
      system('git config user.email "test@example.com"')
      system('git config user.name "Test User"')

      # Create project site structure
      create_project_site_files

      # Add and commit files
      system('git add .')
      system('git commit -m "Initial project site commit" --quiet')
    end
  end

  def create_hub_site_files
    # _config.yml for hub site
    File.write('_config.yml', <<~YAML)
      title: "Test Hub Site"
      description: "A test hub site for integration testing"
      url: "https://test-hub.example.com"

      # Collections configuration
      collections:
        projects:
          output: true
          permalink: /:collection/:name/
        software:
          output: true
          permalink: /:collection/:name/
        specs:
          output: true
          permalink: /:collection/:name/
        posts:
          output: true
          permalink: /blog/:year/:month/:day/:title/

      # Theme configuration
      theme: prexian

      # ROP-specific configuration
      prexian:
        # Hub site marker
        is_hub: true

        # Git repository settings
        default_repo_branch: main
        refresh_remote_data: last-resort

        # Tag namespaces for categorization
        tag_namespaces:
          software:
            writtenin: "Written in"
            audience: "Audience"
          specs:
            audience: "Audience"
            status: "Status"

        # Landing page priority
        landing_priority:
          - software
          - specs
          - blog

      # Build settings
      markdown: kramdown
      highlighter: rouge

      # Plugins
      plugins:
        - jekyll-feed
    YAML

    # Create Gemfile
    File.write('Gemfile', <<~RUBY)
      source 'https://rubygems.org'

      gem 'jekyll', '~> 4.0'
      gem 'prexian', path: '#{Dir.pwd.gsub(@test_dir, '..')}'
      gem 'jekyll-feed'
    RUBY

    # Create index page
    File.write('index.md', <<~MARKDOWN)
      ---
      layout: home
      title: Test Hub Site
      ---

      This is a test hub site for integration testing.
    MARKDOWN

    # Create a sample project entry
    FileUtils.mkdir_p('_projects')
    File.write('_projects/test-project.md', <<~MARKDOWN)
      ---
      title: Test Project
      description: A test project for integration testing
      site:
        git_repo_url: "file://#{@project_repo_path}"
        git_repo_branch: main
      ---

      This is a test project entry.
    MARKDOWN

    # Create sample blog post
    FileUtils.mkdir_p('_posts')
    File.write('_posts/2024-01-01-test-post.md', <<~MARKDOWN)
      ---
      title: Test Hub Post
      date: 2024-01-01
      author: Test Author
      ---

      This is a test blog post from the hub site.
    MARKDOWN
  end

  def create_project_site_files
    # _config.yml for project site
    File.write('_config.yml', <<~YAML)
      title: "Test Project Site"
      description: "A test project site for integration testing"
      url: "https://test-project.example.com"

      # Collections configuration
      collections:
        software:
          output: true
          permalink: /:collection/:name/
        specs:
          output: true
          permalink: /:collection/:name/
        posts:
          output: true
          permalink: /blog/:year/:month/:day/:title/

      # Theme configuration
      theme: prexian

      # ROP-specific configuration
      prexian:
        # Project site marker (not a hub)
        is_hub: false

        # Parent hub configuration
        parent_hub:
          git_repo_url: "file://#{@hub_repo_path}"
          git_repo_branch: main
          home_url: "https://test-hub.example.com/"

        # Git repository settings
        default_repo_branch: main
        refresh_remote_data: last-resort

        # Tag namespaces for categorization
        tag_namespaces:
          software:
            writtenin: "Written in"
            audience: "Audience"
          specs:
            audience: "Audience"
            status: "Status"

        # Landing page priority
        landing_priority:
          - software
          - specs
          - blog

      # Build settings
      markdown: kramdown
      highlighter: rouge

      # Plugins
      plugins:
        - jekyll-feed
    YAML

    # Create Gemfile
    File.write('Gemfile', <<~RUBY)
      source 'https://rubygems.org'

      gem 'jekyll', '~> 4.0'
      gem 'prexian', path: '#{Dir.pwd.gsub(@test_dir, '..')}'
      gem 'jekyll-feed'
    RUBY

    # Create index page
    File.write('index.md', <<~MARKDOWN)
      ---
      layout: home
      title: Test Project Site
      ---

      This is a test project site for integration testing.
    MARKDOWN

    # Create sample software entry
    FileUtils.mkdir_p('_software')
    File.write('_software/test-software.md', <<~MARKDOWN)
      ---
      title: Test Software
      description: A test software package
      repo_url: https://github.com/test/software
      repo_branch: main
      tags:
        writtenin: [Ruby]
        audience: [Developers]
      ---

      This is a test software entry from the project site.
    MARKDOWN

    # Create sample specification
    FileUtils.mkdir_p('_specs')
    File.write('_specs/test-spec.md', <<~MARKDOWN)
      ---
      title: Test Specification
      description: A test specification document
      tags:
        audience: [Developers]
        status: [Draft]
      ---

      This is a test specification from the project site.
    MARKDOWN

    # Create sample blog post
    FileUtils.mkdir_p('_posts')
    File.write('_posts/2024-01-02-project-post.md', <<~MARKDOWN)
      ---
      title: Test Project Post
      date: 2024-01-02
      author: Project Author
      ---

      This is a test blog post from the project site.
    MARKDOWN

    # Create logo file for hub to fetch
    FileUtils.mkdir_p('assets')
    File.write('assets/logo.svg', <<~SVG)
      <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
        <circle cx="50" cy="50" r="40" fill="blue"/>
        <text x="50" y="55" text-anchor="middle" fill="white">LOGO</text>
      </svg>
    SVG
  end
end
