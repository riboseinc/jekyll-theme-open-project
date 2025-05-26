# Prexian

*A Jekyll theme for open-source software and specification projects*

[![Gem Version](https://badge.fury.io/rb/prexian.svg)](https://badge.fury.io/rb/prexian)
[![Build Status](https://github.com/riboseinc/prexian/workflows/test/badge.svg)](https://github.com/riboseinc/prexian/actions)

Prexian is a powerful Jekyll theme designed to help organizations and individuals present open-source software and specifications in a navigable and elegant way. It supports both individual project sites and hub sites that aggregate multiple projects.

## ✨ Features

- **Two Site Types**: Create individual project sites or hub sites that aggregate multiple projects
- **Smart Content Management**: Automatically fetch and display software documentation, specifications, and project metadata from Git repositories
- **Performance Optimized**: Intelligent caching system with shallow clones and sparse checkout
- **Modern Design**: Clean, responsive design with customizable styling
- **SEO Ready**: Built-in SEO optimization with jekyll-seo-tag integration
- **Blog Support**: Full-featured blogging with author profiles and social links
- **Search Integration**: Optional Algolia search support
- **AsciiDoc Support**: First-class support for AsciiDoc content authoring

## 🚀 Quick Start

### Installation

Add this line to your Jekyll site's `Gemfile`:

```ruby
gem "prexian"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install prexian
```

### Basic Setup

1. **Create a new Jekyll site**:
   ```bash
   jekyll new my-project-site
   cd my-project-site
   ```

2. **Add Prexian to your Gemfile**:
   ```ruby
   gem "prexian"
   ```

3. **Configure your site** in `_config.yml`:
   ```yaml
   theme: prexian

   plugins:
     - prexian

   prexian:
     title: My Project
     description: An awesome open-source project
     tagline: Making the world a better place
     site_type: project  # or 'hub'
   ```

4. **Build and serve**:
   ```bash
   bundle exec jekyll serve
   ```

## 📋 Minimum Requirements

### Required Configuration

Every Prexian site must have these minimum configuration settings in `_config.yml`:

```yaml
# Basic Jekyll configuration
title: Your Site Title
description: Your site description

# Theme configuration
theme: prexian
plugins:
  - prexian

# Prexian configuration (required)
prexian:
  site_type: project  # or 'hub' - REQUIRED
  title: Your Project Title
  description: Your project description

# Collections (required for content types you want to use)
collections:
  software:
    output: true
    permalink: /software/:path/
  specs:
    output: true
    permalink: /specs/:path/
  posts:
    output: true
    permalink: /blog/:year-:month-:day-:title/
  # For hub sites only:
  projects:
    output: false

# Defaults (required)
defaults:
  - scope:
      path: ""
    values:
      layout: default
  - scope:
      path: _posts
      type: posts
    values:
      layout: post
  - scope:
      path: _software
      type: software
    values:
      layout: product
  - scope:
      path: _specs
      type: specs
    values:
      layout: spec
```

### Required Files

#### For All Sites

- **`_config.yml`** - Site configuration (see above)
- **`index.md`** - Homepage content:
  ```yaml
  ---
  layout: home
  ---

  Your homepage content here...
  ```

#### For Project Sites

If your project site has a parent hub, add this to `_config.yml`:

```yaml
prexian:
  parent_hub:
    git_repo_url: https://github.com/your-org/hub-site
    git_repo_branch: main  # optional, defaults to 'main'
    home_url: https://your-hub-site.com/
```

#### For Hub Sites

Create a `_projects` directory with project definitions:

```yaml
# _projects/my-project.md
---
title: My Project
description: Brief project description
site:
  git_repo_url: https://github.com/your-org/my-project-site
  git_repo_branch: main
home_url: https://your-org.github.io/my-project/
---

Detailed project description...
```

### Optional Files

#### Site Logo/Symbol

- **`assets/symbol.svg`** - Your site's logo (SVG format recommended)
- **`assets/favicon.png`** - Site favicon

#### Custom Styling

- **`assets/css/style.scss`** - Custom styles:
  ```scss
  ---
  ---

  ...
  @import "prexian";
  @import "prexian/custom-styles";

  // Your custom styles here
  ```

#### Content Pages

- **`_pages/`** - Static pages (about, contact, etc.)
- **`_posts/`** - Blog posts
- **`_software/`** - Software components
- **`_specs/`** - Specifications

### Directory Structure Example

```
my-project-site/
├── _config.yml           # Required: Site configuration
├── index.md              # Required: Homepage
├── Gemfile               # Required: Dependencies
├── assets/
│   ├── symbol.svg        # Optional: Site logo
│   └── css/
│       └── style.scss    # Optional: Custom styles
├── _pages/               # Optional: Static pages
│   ├── about.md
│   └── contact.md
├── _posts/               # Optional: Blog posts
│   └── 2024-01-01-welcome.md
├── _software/            # Optional: Software components
│   └── my-tool.md
└── _specs/               # Optional: Specifications
    └── my-spec.md
```

This is the absolute minimum needed to get a Prexian site running. You can then add content and customize as needed.

## 📖 Site Types

Prexian supports two distinct types of sites, each with specific purposes and capabilities:

### Project Site

A **project site** describes one individual project and can contain:

- **Software components**: Individual software products with their documentation
- **Specifications**: Technical specifications and standards
- **Blog posts**: Project-specific announcements and articles
- **Documentation**: Project-wide documentation and guides
- **Pages**: Static pages for additional content

Project sites are designed to be comprehensive resources for a single project, providing everything users need to understand, use, and contribute to the project.

```yaml
# _config.yml for project site
prexian:
  site_type: project
  parent_hub:
    git_repo_url: https://github.com/your-org/hub-site
    git_repo_branch: main
    home_url: https://your-org.github.io/
```

### Hub Site

A **hub site** aggregates multiple project sites into a unified portal. Hub sites can contain:

- **Projects collection**: Links to individual project sites
- **Aggregated software**: Software from all projects in the hub
- **Aggregated specifications**: Specifications from all projects
- **Hub-wide blog**: Organization-level announcements and articles
- **All project site components**: Hub sites can also have their own software, specs, and content

Hub sites serve as the central entry point for organizations with multiple related projects, providing a unified view of all activities and resources.

```yaml
# _config.yml for hub site
prexian:
  site_type: hub

collections:
  projects:
    output: false
```

## 🏗️ Building Project and Hub Sites

### Adding Projects (Hub Sites Only)

Projects are defined in the `_projects` collection. Each project points to a separate Prexian project site:

```yaml
# _projects/my-project.md
---
title: My Awesome Project
description: A sentence or two about what the project is for.
tagline: Because awesomeness is underrated
featured: true  # Include in featured projects on hub home page

site:
  git_repo_url: https://github.com/your-org/my-project-site
  git_repo_branch: main

home_url: https://your-org.github.io/my-project/
tags: [awesome, project, open-source]
---

Detailed description of the project goes here...
```

### Adding Software

Software components are defined in the `_software` collection:

```yaml
# _software/my-tool.md
---
title: My Development Tool
description: A powerful tool for developers
repo_url: https://github.com/your-org/my-tool
repo_branch: main  # Optional, defaults to site's default_repo_branch

# Optional: Separate documentation repository
docs:
  git_repo_url: https://github.com/your-org/my-tool-docs
  git_repo_subtree: docs
  git_repo_branch: main

tags: [Ruby, CLI, Developer Tools]
external_links:
  - url: https://github.com/your-org/my-tool
  - url: https://rubydoc.info/gems/my-tool
    title: "API Documentation"

feature_with_priority: 1  # Featured on home page
---

Your software description goes here...
```

**Software Logo**: Place an SVG logo at `_software/my-tool/assets/symbol.svg`

### Adding Specifications

Specifications are defined in the `_specs` collection:

```yaml
# _specs/my-spec.md
---
title: My Technical Specification
description: A comprehensive specification for X protocol
tags: [RFC, Standard, Protocol]

external_links:
  - url: https://tools.ietf.org/html/rfc1234
    title: "RFC 1234"

# Optional: Build specification from source
spec_source:
  git_repo_url: https://github.com/your-org/spec-repo
  git_repo_subtree: specification
  git_repo_branch: main
  build:
    engine: png_diagram_page
    options:
      format: png

# Optional: Custom navigation for built specs
navigation:
  sections:
    - name: "Diagrams"
      items:
        - title: "Overview Diagram"
          path: "overview"
          description: "System overview"
---

Your specification description goes here...
```

### Adding Custom Content Types (e.g., Advisories)

You can extend Prexian with custom collections:

1. **Define the collection** in `_config.yml`:
   ```yaml
   collections:
     advisories:
       output: true
       permalink: /advisories/:path/

   defaults:
     - scope:
         path: _advisories
         type: advisories
       values:
         layout: advisory  # Create this layout
   ```

2. **Create content** in `_advisories/`:
   ```yaml
   # _advisories/security-advisory-001.md
   ---
   title: Security Advisory 001
   severity: high
   date: 2024-01-15
   affected_versions: ["< 2.1.0"]
   tags: [security, vulnerability]
   ---

   Description of the security issue...
   ```

3. **Create an index page** in `_pages/advisories.html`:
   ```yaml
   ---
   title: Security Advisories
   layout: advisory-index  # Create this layout
   hero_include: index-page-hero.html
   ---
   ```

### Hero Sections and Custom Introductions

#### Adding a Hero Section

Add a hero section to any page by specifying `hero_include` in the frontmatter:

```yaml
---
title: My Page
hero_include: index-page-hero.html
---
```

#### Custom Introduction Section

For project sites, you can add a custom introduction section:

1. **Enable it** in `_config.yml`:
   ```yaml
   prexian:
     landing_priority:
       - custom_intro
       - software
       - specs
       - blog
   ```

2. **Create the include** file `custom-intro.html`:
   ```html
   <section class="custom-intro">
     <div class="summary">
       <h2>Welcome to {{ site.title }}</h2>
       <p>{{ site.description }}</p>
     </div>

     <div class="call-to-action">
       <a href="/getting-started" class="btn btn-primary">Get Started</a>
       <a href="/documentation" class="btn btn-secondary">Documentation</a>
     </div>
   </section>
   ```

### Tag Namespaces

Tag namespaces help organize and categorize content with semantic meaning:

```yaml
# _config.yml
tag_namespaces:
  software:
    writtenin: "Written in"        # Programming languages
    bindingsfor: "Bindings for"    # Language bindings
    user: "Target user"            # Target audience
    interface: "Interface"         # UI type (CLI, GUI, API)
  specs:
    audience: "Audience"           # Who the spec is for
    completion_status: "Status"    # Draft, Final, etc.
    domain: "Domain"               # Technical domain
```

Use namespaced tags in your content:

```yaml
tags: [writtenin:Ruby, user:Developer, interface:CLI, audience:Technical]
```

### Collections Configuration

Collections define the types of content your site can contain:

```yaml
# _config.yml
collections:
  # Core Prexian collections
  software:
    output: true
    permalink: /software/:path/
  specs:
    output: true
    permalink: /specs/:path/
  posts:
    output: true
    permalink: /blog/:year-:month-:day-:title/

  # Hub sites only
  projects:
    output: false

  # Custom collections
  advisories:
    output: true
    permalink: /advisories/:path/
  tutorials:
    output: true
    permalink: /tutorials/:path/
```

### Data Collections

Prexian supports Jekyll's data collections for structured content. Create YAML files in `_data/`:

```yaml
# _data/team.yml
- name: John Doe
  role: Lead Developer
  github: johndoe

- name: Jane Smith
  role: Technical Writer
  github: janesmith
```

Use in templates:
```liquid
{% for member in site.data.team %}
  <div class="team-member">
    <h3>{{ member.name }}</h3>
    <p>{{ member.role }}</p>
  </div>
{% endfor %}
```

## 🔧 Configuration

### Essential Configuration

```yaml
# _config.yml
title: Your Project Name
description: A brief description of your project
url: https://your-project.github.io

prexian:
  title: Your Project Name
  description: A brief description of your project
  tagline: Your project's tagline
  site_type: project  # 'project' or 'hub'

  author: "Your Organization"
  authors:
    - name: Your Name
      email: your.email@example.com

  social:
    links:
      - https://github.com/your-org
      - https://twitter.com/your-org

  github_repo_url: https://github.com/your-org/your-project
  default_repo_branch: main  # Default branch for all repositories
```

### Git Repository Configuration

All Git repository references support branch/version specification:

```yaml
# For parent hub
prexian:
  parent_hub:
    git_repo_url: https://github.com/your-org/hub-site
    git_repo_branch: main  # or version tag like 'v1.2.3'

# For software documentation
# _software/my-tool.md
docs:
  git_repo_url: https://github.com/your-org/my-tool-docs
  git_repo_branch: main  # or 'develop', 'v2.0', etc.

# For specifications
# _specs/my-spec.md
spec_source:
  git_repo_url: https://github.com/your-org/spec-repo
  git_repo_branch: main  # or 'draft', 'v1.0', etc.
```

## 🏗️ Internal Architecture

### Developer Services

Prexian provides several internal services for developers:

#### `Prexian::Configuration`
Centralized configuration management with validation:
```ruby
config = Prexian::Configuration.new(site.config)
config.site_type        # => 'project' or 'hub'
config.hub_site?        # => true/false
config.default_repo_branch  # => 'main'
```

#### `Prexian::GitService`
Repository operations with caching:
```ruby
git_service = Prexian::GitService.new
result = git_service.shallow_checkout(repo_url, branch: 'main')
git_service.copy_cached_content(result[:local_path], destination)
```

#### `Prexian::HubSiteLoader`
Aggregates content from multiple project repositories for hub sites.

#### `Prexian::ProjectSiteLoader`
Handles individual project site content and parent hub integration.

### The `_parent-hub` Directory

For project sites with a parent hub, Prexian automatically:

1. **Fetches hub content** from the parent hub repository
2. **Copies it** to `_parent-hub/parent-hub/` in your project site
3. **Adds it to include paths** so you can reference hub assets

This allows project sites to:
- Use the hub's logo: `{% include parent-hub/assets/symbol.svg %}`
- Reference hub branding: `{% include parent-hub/title.html %}`
- Maintain consistent styling with the hub

The `_parent-hub` directory structure:
```
_parent-hub/
└── parent-hub/
    ├── assets/
    │   └── symbol.svg
    ├── title.html
    └── other-hub-includes.html
```

## 🎨 Customization

### Styling

Create custom styles in `assets/css/style.scss`:

```scss
---
---

@import "prexian/custom-variables";
@import "prexian";
@import "prexian/custom-styles";

// Your custom styles here
.custom-class {
  color: #your-color;
}
```

### Layouts and Includes

Override theme layouts by creating files in `_layouts/` and includes in your site root (not `_includes/`):

- `title.html` - Custom site title/logo
- `custom-intro.html` - Custom introduction section
- `project-nav.html` - Additional navigation links

### Logo and Symbol Guidelines

#### Site Symbol
- **Format**: SVG
- **Size**: Should look good at 30x30px and 60x60px
- **Location**: `assets/symbol.svg`
- **Requirements**:
  - No IDs in SVG markup (appears multiple times on page)
  - Root `<svg>` element must have `viewBox` attribute
  - No `width` or `height` attributes on root element

#### Favicon
Provide PNG renders as:
- `assets/favicon.png`
- `assets/favicon-192x192.png`

Use transparent background for PNG files.

## 🔧 CLI Tools

Prexian includes command-line tools for cache management:

```bash
# Check version
bundle exec prexian version

# Clear cache
bundle exec prexian cache clear

# Show cache status
bundle exec prexian cache status
```

## 🛠️ Theme Development

### Building the Theme

When developing the Prexian theme itself, you cannot use the standard `_config.yml` file because it gets inherited by user gems. Instead, use one of these methods:

#### Method 1: Use the Theme Development Configuration

```bash
# Build with theme development config
bundle exec jekyll build --config _config_theme-dev.yml

# Serve with theme development config
bundle exec jekyll serve --config _config_theme-dev.yml
```

#### Method 2: Use the Build Script

```bash
# Build the example site
script/build

# Serve the example site
script/server
```

The `_config_theme-dev.yml` file contains the proper configuration for testing the theme with example content, while `_config.yml` is kept minimal for gem users.

### Configuration Files

- **`_config.yml`**: Minimal configuration inherited by gem users
- **`_config_theme-dev.yml`**: Full development configuration with example content
- **`script/build`**: Convenience script that uses the theme development config
- **`script/server`**: Development server script

### Testing Changes

After making changes to the theme:

1. **Test the build**:
   ```bash
   script/build
   ```

2. **Test the CLI tools**:
   ```bash
   bundle exec prexian version
   bundle exec prexian cache status
   ```

3. **Run the test suite**:
   ```bash
   bundle exec rspec
   ```

4. **Serve locally to verify**:
   ```bash
   script/server
   ```

## � Content Authoring

### AsciiDoc Support

Content is expected to be authored in AsciiDoc for full feature support:

```adoc
---
title: My Documentation Page
layout: docs-base
---
:page-liquid:

= My Documentation

== Introduction

This is an AsciiDoc document with full Prexian support.

[source,ruby]
----
puts "Hello, World!"
----
```

### Disabling Copy Buttons

By default, code listings have copy buttons. To disable for a specific listing:

```adoc
[.nocopy]
[source,sh]
----
some command
----
```

### Blog Posts

```yaml
---
layout: post
title: "Announcing Version 2.0"
date: 2024-01-15
authors:
  - name: John Doe
    email: john@example.com
    use_picture: gravatar  # 'gravatar', 'assets', 'no', or path
    social_links:
      - https://github.com/johndoe
      - https://twitter.com/johndoe
excerpt: >-
  We're excited to announce the release of version 2.0 with many new features.
card_image: /assets/blog/v2-announcement.png  # Optional cover image
---

Your blog post content goes here...
```

## 🔄 Migration from jekyll-theme-open-project

If you're migrating from the old `jekyll-theme-open-project`:

1. **Update Gemfile**:
   ```ruby
   # Remove old gems
   # gem "jekyll-theme-open-project"
   # gem "jekyll-theme-open-project-helpers"

   # Add new gem
   gem "prexian"
   ```

2. **Update _config.yml**:
   ```yaml
   # Remove old plugins
   plugins:
     - prexian  # Replace all old plugins with this

   # Update site type configuration
   prexian:
     site_type: hub  # instead of is_hub: true
   ```

3. **Update SCSS imports**:
   ```scss
   // Old
   @import 'jekyll-theme-open-project';

   // New
   @import 'prexian';
   ```

4. **Update engine references**:
   ```yaml
   # Old
   engine: png_diagrams

   # New
   engine: png_diagram_page
   ```

## 🌟 Examples

See Prexian in action:

- [Metanorma](https://www.metanorma.org) - Standards authoring platform
- [RNP](https://www.rnpgp.org) - OpenPGP implementation
- [Relaton](https://www.relaton.org) - Bibliographic data toolkit

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/riboseinc/prexian.

## 📄 License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🆘 Support

- **Documentation**: Full documentation available in this README
- **Issues**: Report bugs and request features on [GitHub Issues](https://github.com/riboseinc/prexian/issues)
- **Discussions**: Join the conversation on [GitHub Discussions](https://github.com/riboseinc/prexian/discussions)

---

## Detailed Configuration Reference

<details>
<summary>Click to expand complete configuration options</summary>

### Complete Configuration Example

```yaml
# _config.yml
title: Your Project
description: Project description
url: https://your-project.github.io

prexian:
  title: Your Project
  description: Project description
  tagline: Your project tagline

  # Site type (required)
  site_type: project  # 'project' or 'hub'

  # Repository settings
  default_repo_branch: main
  github_repo_url: https://github.com/your-org/your-project
  github_repo_branch: main

  # Author information
  author: "Your Organization"
  authors:
    - name: Your Name
      email: your.email@example.com
  contact_email: your.email@example.com

  # Parent hub (for project sites)
  parent_hub:
    git_repo_url: https://github.com/your-org/hub-site
    git_repo_branch: main
    home_url: https://your-org.github.io/

  # Social links
  social:
    links:
      - https://github.com/your-org
      - https://twitter.com/your-org

  # Legal information
  legal:
    name: Your Organization
    tos_link: https://your-org.com/terms
    privacy_policy_link: https://your-org.com/privacy

  # Search (optional)
  algolia_search:
    api_key: 'your-api-key'
    index_name: 'your-index'

  # Landing page sections order
  landing_priority:
    - software
    - specs
    - blog
    - custom_intro

  # Call-to-action buttons
  home_calls_to_action:
    - url: "/getting-started"
      title: "Get Started"
    - url: "/documentation"
      title: "Documentation"

# Tag namespaces
tag_namespaces:
  software:
    writtenin: "Written in"
    user: "Target user"
    interface: "Interface"
  specs:
    audience: "Audience"
    completion_status: "Status"

# Jekyll collections (required)
collections:
  projects:    # Only for hub sites
    output: false
  software:
    output: true
    permalink: /software/:path/
  specs:
    output: true
    permalink: /specs/:path/
  posts:
    output: true
    permalink: /blog/:year-:month-:day-:title/
  pages:
    output: true
    permalink: /:name/

# Jekyll defaults (required)
defaults:
  - scope:
      path: ""
    values:
      layout: default
  - scope:
      path: _posts
      type: posts
    values:
      layout: post
  - scope:
      path: _software
      type: software
    values:
      layout: product
  - scope:
      path: _specs
      type: specs
    values:
      layout: spec

# Plugins
plugins:
  - prexian

# Exclude files
exclude:
  - .git
  - Gemfile*
  - README.*
  - vendor
  - script
```

### Theme Layouts

Available layouts:

- **`default`**: Main layout with `html-class` support
- **`home`**: Homepage layout
- **`post`**: Blog post layout
- **`product`**: Software product layout
- **`spec`**: Specification layout
- **`blog-index`**: Blog index page
- **`software-index`**: Software index page (hub sites)
- **`spec-index`**: Specification index page (hub sites)
- **`project-index`**: Project index page (hub sites)
- **`docs-base`**: Documentation base layout
- **`page`**: Generic page layout

### Theme Includes

Commonly overridden includes:

- **`title.html`**: Site name/logo
- **`custom-intro.html`**: Custom introduction section
- **`project-nav.html`**: Additional navigation links
- **`assets/symbol.svg`**: Site symbol
- **`head.html`**: Custom head content
- **`scripts.html`**: Custom JavaScript

### Content Guidelines

- **Project/Software/Spec titles**: 1-3 words, title case
- **Descriptions**: ~12 words, no markup
- **Featured descriptions**: ~20-24 words, no markup
- **Blog post titles**: 3-7 words
- **Blog post excerpts**: ~20-24 words, no markup
- **Taglines**: Short, memorable phrases

</details>
