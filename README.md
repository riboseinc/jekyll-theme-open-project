# The Prexian Jekyll theme (previously the "Ribose Open Project theme")

## Purpose

Prexian provides a Jekyll theme (with accompanying plugin code) aiming to help
organizations and individuals present open-source software and specifications in
a navigable and elegant way.

The gem is released as `prexian`.

Prexian fits two types of sites:

* "project site": a site that describes one individual project;
* "hub site": a site that combine multiple project sites into an open hub site.

NOTE: A deployment using the theme is available at
[Ribose](https://www.ribose.com/) project sites -- for example,
[Metanorma](https://www.metanorma.com),
[RNP](https://www.rnpgp.com),
[Cryptode](https://www.cryptode.com),
[Relaton](https://www.relaton.com).

NOTE: This theme was previously named `jekyll-theme-open-project` with a helper
gem `jekyll-theme-open-project-helpers`.


## Site configuration

Every Prexian site is a Jekyll site, and as such, it has a `_config.yml` file
that contains site-wide configuration options.

Prexian adds the following configuration options to the Jekyll site under the `prexian` namespace:

```yaml
prexian:
  # Hub site marker
  is_hub: true | false

  # Parent hub configuration (for project sites)
  parent_hub:
    git_repo_url: "<URL to the parent hub repository (HTTPS)>"
    git_repo_branch: "<branch name in the parent hub repository>"
```

This is a basic Prexian project site configuration:

```yaml
# Prexian site configuration
prexian:
  title: RNP
  description: Secure email with unrivaled performance. LibrePGP and RFC&nbsp;4880 compliant.
  # The above two are used by jekyll-seo-tag for things such as
  # `<title>` and `<meta>` tags, as well as elsewhere by the theme.

  permalink: /blog/:year-:month-:day-:title/

  algolia_search:
    api_key: '0193b06d928ee52f653c6e5ea95d9f97'
    index_name: 'rnpgp'

  tagline: >-
    Powering end-to-end email encryption in Mozilla Thunderbird. LibrePGP secure.

  landing_priority:
    - software
    - custom_intro
    - specs
    - blog
    - advisories
    - man_pages

  pitch: >-
    <a href="https://www.librepgp.org"><img title="LibrePGP" src="/assets/librepgp-button.svg"/></a>
    Secure email with unrivaled performance.
    <a href="https://www.librepgp.org">LibrePGP</a> and RFC&nbsp;4880 compliant.

  author: "Ribose Inc."

  authors:
    - name: Ribose Inc.
      email: open.source@ribose.com
  contact_email: open.source@ribose.com

  # Project sites do not set parent_hub
  parent_hub:
    git_repo_url: https://github.com/riboseinc/open.ribose.com
    home_url: https://open.ribose.com/

  social:
    links:
      - {social link 1 URL}
      - {social link 2 URL}

  legal:
    name: {Full Organization Name}
    tos_link: {URL to terms of service, without trailing slash}
    privacy_policy_link: {URL to privacy policy, without trailing slash}

  home_calls_to_action:
    - { url: "/{target URL path on this site}", title: "{title1}" }
    - { url: "/{target URL path on this site}", title: "{title2}" }

  github_repo_url: {link to GitHub repository URL, without trailing slash}

tag_namespaces:
  software:
    writtenin: "Written in"
    bindingsfor: "Bindings for"
    user: "Target user"
    interface: "Interface"
  specs:
    audience: "Audience"
    completion_status: "Status"


# Jekyll configuration
includes_dir: '.'

# Must be set for Prexian
collections:
  projects:
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

# Must be set for Prexian
defaults:
  # Theme defaults.
  # MUST be duplicated from theme’s _config.yml
  # (does not get inherited, unlike the collections hash)
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

# Must be set for Prexian
plugins:
  - prexian

url: {link to production site URL, without trailing slash}

exclude:
  - .git
  - _software/**/.git
  - parent-hub/.git
  - Gemfile*
  - README.adoc
  - vendor # for deployment
```


## Site components

### General

A Prexian site can have the following components:

* pages
* blog posts
* projects
* software
* specifications

### Pages

A page is a static page that can be used to present information.

The page is a Markdown or AsciiDoc file in the `_pages` directory, with
frontmatter specifying the title, permalink, layout, and other metadata.

* `_pages/{name}.{md|adoc}` The main page file, with frontmatter containing the
  page title, description, and other metadata.

e.g.

```adoc
---
title: About RNP
description: What is RNP?
permalink: /about/
layout: docs-base
html-class: docs-page
---

= About RNP

== General

RNP is a powerful open-source software library for working with LibrePGP and
OpenPGP messages.
...
```

NOTE: `docs-base` here is defined in the Prexian theme as a layout.


### Blog posts

Blog posts are authored as per usual Jekyll setup, with the following files:

* `_posts/{year}-{month}-{day}-{slug}.{md|adoc}` The blog post file, with frontmatter
  containing the post title, author, and other metadata.


The format is as follows:

```markdown
---
layout: post
title:  {title of the post}
date:   {2025-08-20 20:37:38 +0700}
categories: {category1, category2}
authors:
  - name: {author's full name}
    email: {author's email}
    social_links:
      - {author's one or more social links}
excerpt: >-
  {excerpt of the post goes here, and supports inline HTML formatting only.}
redirect_from:
  - {if you want to redirect from another URL, specify it here}
---

{# content}
```

### Projects

A project points to a Prexian project site.

For each project, the following files are needed:

* `_projects/{name}.{md|adoc}` The main project description file, with
  frontmatter containing the project name, description, and other metadata.
* `_projects/{name}/assets/symbol.svg` The project logo file, in SVG
  format, if any.

The main project description file is expected to have the following
frontmatter:

```markdown
---
title: {name of the project}
description: {description of the project}
featured: {true|false}
home_url: {URL to the project home page}
tags: [{tags for the project in comma-separated format}]
site:
  git_repo_url: {URL to the Prexian project site repository (HTTPS)}
  git_repo_branch: {branch name in the Prexian project site repository}
---

{# content of the project description, in Markdown or AsciiDoc format
}
```


### Software components

For each software component, the following files are needed:

* `_software/{name}.{md|adoc}` The main software description file, with
  frontmatter containing the software name, description, and other metadata.

* `_software/{name}/assets/symbol.svg` The software logo file, in SVG
  format, if any.

The main software description file is expected to have the following
frontmatter:

```markdown
---
title: {name of the component}
repo_url: {URL to the component repository (HTTPS)}
external_links:
  - url: {URL to the component repository (HTTPS)}
description: {description of the component}
tags: [{tags for the component}]
---

{# content of the component description, in Markdown or AsciiDoc format
}

```

### Specifications

Specifications are similar to software components, but with a different
file structure and frontmatter.

For each Specification, the following file are needed:

* `_specs/{name}.{md|adoc}` The main spec description file, with
  frontmatter containing the spec name, description, and other metadata.

```markdown
---
title: {name of the specification}
description: {description of the specification}
feature_with_priority: {priority of the feature in number}

external_links:
  - url: {URL to the specification repository or published document, one or more}
  # ...

tags: [{tags for the specification}]
---

{# content of the specification description, in Markdown or AsciiDoc format
}
```


## Site types

A Prexian site can be either a "project site" or a "hub site".

### Project site

A Prexian project site is a site that describes one individual project and can
have any of the site components. A project site does not have its own
`_projects` collection (as configured in `_config.yml`).


### Hub site

A Prexian hub site is a site that aggregates multiple project sites. The hub site
itself is also a project site, except that its `_projects` collection exists. A
hub site can also have its own software and specifications.



## Fetching the hub site content in the project site

The parent hub site content is fetched into the project site
into the `_parent-hub` directory, which will contain a `parent-hub`
(i.e. `_parent-hub/parent-hub`) directory with the hub site content
which is cloned from the hub repository.

This directory is added to the `include` path, so that the project site can
use the hub site content in its own pages and posts through the `include` command such
as `{% include parent-hub/title.html %}` or `{% include parent-hub/assets/symbol.svg %}`.

If the configuration is not given for `parent_hub`, the project site will not
fetch the hub site content, and the `_parent-hub` directory will not be created.



## Internal architecture

The gem provides the following Ruby components:

- **`Prexian::Configuration`**: Centralized configuration management with validation
- **`Prexian::GitService`**: Repository operations, caching, and cleanup
- **`Prexian::HubSiteReader`**: Hub site content aggregation and processing
- **`Prexian::ProjectSiteReader`**: Project site functionality and parent hub integration
- **`Prexian::CLI`**: Command-line interface for cache management
- **`Prexian::Metanorma`**: Metanorma integration utilities

## Migrating from `jekyll-theme-open-project` to the new `prexian`

Follow these steps:

1. Update your Open Project Gemfile to remove all previously used dependencies
from `jekyll-theme-open-project` (including `git`), and replace it like this:
```ruby
group :jekyll_plugins do
  gem "prexian"
end
```

2. Update your `_config.yml` file to remove all previously used plugins from `jekyll-theme-open-project` and only use `prexian`, so it becomes:
```yaml
plugins:
  - prexian
```

3. Replace in SCSS files all mention of import files with their renamed counterparts:
  * `@import 'jekyll-theme-open-project'` => ``@import 'prexian'`
  * `'open-project-mixins'` => remove because it was already included.

4. If you use the `png_diagrams` feature in any page layout, replace as follows:
```diff
-engine: png_diagrams
+engine: png_diagram_page
```

## Contents

* Creating a site: [how to](#starting-a-site-with-this-theme)

  * [General site setup](#general-setup)
  * [Hub site setup](#hub-site)
  * [Project site setup](#project-site) and describing your software and specs

* Customizing site looks:

  * [Style customization](#style-customization)
  * [SVG guidelines](#svg-guidelines)
  * [Content guidelines](#content-guidelines)

* [Authoring content](#authoring-content)

* References:

  * [Layouts](#theme-layouts)
  * [Includes](#theme-includes)

## Getting started

### Set up Ruby and Jekyll

The currently recommended Ruby version is 3.3.

NOTE: In case you don't use Ruby often, the easiest way to install one may be
with RVM.

The currently recommended Jekyll version is 3 or newer
(read about [Jekyll installation](https://jekyllrb.com/docs/#instructions)).

NOTE: This theme is known to not work with Ruby older than 2.3.
It has not been tested on newer versions.

### Start a new Jekyll site

```sh
jekyll new my-open-site
```

If you use Git for site source version management,
see the "Extra .gitignore rules" section below
for additional lines you should add to your `.gitignore`.

### Install Open Site theme into the Jekyll site

Add this line to your Jekyll site's `Gemfile`,
replacing default theme requirement:

```ruby
gem "prexian"
```

(Jekyll's default theme was "minima" at the time of this writing.)

Also in the `Gemfile`, add two important plugins to the `:jekyll_plugins` group.
(The SEO tag plugin is not mandatory, but these docs assume you use it.)

```ruby
group :jekyll_plugins do
  gem "prexian"

  # The following gems are automatically included by prexian
  # gem "jekyll-seo-tag"
  # gem "jekyll-sitemap"
  # gem "jekyll-data"
  # gem "jekyll-asciidoc"
  # gem "jekyll-external-links"

  # ...other plugins, if you use any
end
```

Execute the following to install dependencies:

```sh
$ bundle
```

### Configure your Open Site for the first time

Edit `_config.yml` to add necessary site-wide configuration options,
and add files and folders to site contents. This step depends
on the type of site you're creating: hub or individual project site.

Further sections explain core concepts of open project and hub, and go
into detail about how to configure a project or hub site.

Before building the first time you must do this:

1. Configure [common settings](#common-settings)
2. Add your logo(s) according to [logo](#logo)

Please see the [configuration section](#configuration) for more details.

NOTE: It may be required to copy the following properties from
this theme's `_config.yaml` to your site's: `collections`, `includes_dir`.

This is likely caused by changed behavior of jekyll-data gem in recent versions,
which is responsible for "inheritance" of `_config.yaml` between theme and site.

You can add any custom collections for your site
after collections copied from theme's config.

### Building site

Execute to build the site locally and watch for changes:

    $ bundle exec jekyll serve --host mysite.local --port 4000

This assumes you have mysite.local mapped in your hosts file,
otherwise omit --host and it'll use "localhost" as domain name.

## Configuration

There are 3 areas to configure when you first create an Open Site, namely:

* [Common setup](#common-setup), settings that apply to both Hub and Project sites;
* [Hub site](#hub-site);
* [Project site](#project-site)

## Common setup

### Git repository branch behavior

You'll see many instances of document frontmatter
referencing Git repository URLs.

Note that, wherever a `[*_]repo_url` property is encountered,
a sibling property `[*_]repo_branch` is supported.
(This is new in 2.1.17, until that version branch "master" was used for all repositories.)

If you reference repositories that don't use branch name "main",
you must either:

- use a sibling `[*_]repo_branch` property to specify your custom branch name
  (you can search for `git_repo_branch`, `repo_branch`, `github_repo_branch`
  in this document for examples), or

- specify `default_repo_branch` property in `config.yml`

  (in this case, in scenarios with project sites being used in conjunction
  with a hub site, `default_repo_branch` must be the same
  across all project sites' and their hub site's `config.yml`—otherwise you're advised
  to use the previous option to avoid site build failure).

Note that, when a referenced Git repository doesn't contain the necessary branch
(either explicitly specified custom branch, or `default_repo_branch`, or branch called "main"),
this will cause build failure of that project site, or a hub site using that project site.

### Repository Caching & Performance

The theme includes intelligent repository caching to improve build performance:

- **Automatic Caching**: Git repositories are cached locally to speed up subsequent builds
- **Shallow Clones**: Only necessary files are downloaded using Git's shallow clone feature
- **Sparse Checkout**: Only specified subdirectories are checked out when needed
- **Cache Management**: Use the CLI tools to monitor and clean cache as needed

### Refresh Control

Control when remote repository data is refreshed:

```yaml
# In _config.yml
refresh_remote_data: always | never | daily | weekly
# Default: daily
```

- `always`: Fetch fresh data on every build (slower but always current)
- `never`: Use cached data only (fastest, but may be stale)
- `daily`: Refresh once per day
- `weekly`: Refresh once per week

### Common settings

(mandatory)

These settings apply to both site types (hub and project).

- You may want to remove the default `about.{md|adoc}` page added by Jekyll,
  as this theme does not account for its existence.

- Add `hero_include: home-hero.html` to YAML frontmatter
  in your main `index.{md|adoc}`.

- Add following items to site's `_config.yml`
  (and don't forget to remove default theme requirement there):

  ```yaml
  url: https://example.com
  # Site's URL with protocol, without optional www. prefix
  # and without trailing slash.
  # Used e.g. for marking external links in docs and blog posts.

  github_repo_url: https://github.com/example-org/example.com
  # URL to GitHub repo for the site.
  # Using GitHub & specifying this setting is currently required
  # for "suggest edits" buttons to show on documentation pages.
  github_repo_branch: main
  # Optional, default is `main`.

  title: Example
  description: The example of examples
  # The above two are used by jekyll-seo-tag for things such as
  # `<title>` and `<meta>` tags, as well as elsewhere by the theme.

  default_repo_branch: main
  # Optional, default is `main`.
  # Whenever branch name isn't specified for some repository
  # (such as project docs or specs), this name will be used
  # during site's build.
  # (See branch behavior section for details.)

  tagline: Because examples are very important
  # Used in hero unit on main page.

  social:
    links:
      - https://twitter.com/<orgname>
      - https://github.com/<orgname>

  legal:
    name: Full Organization Name
    tos_link: https://www.example.com/tos
    privacy_policy_link: https://www.example.com/privacy

  # no_auto_fontawesome: yes
  # Specify this only if you want to disable free Font Awesome CDN.
  # IMPORTANT: In this case your site MUST specify include head.html with appropriate scripts.
  # Theme design relies on Font Awesome "solid" and "brands" icon styles
  # and expects them to be included in SVG mode.
  # Without this setting, one-file FA distribution, all.js, is included from free FA CDN.

  theme: prexian

  permalink: /blog/:month-:day-:year-:title/
  # It's important that dash-separated permalink is used for blog posts.
  # There're no daily or monthly blog archive pages generated.
  # Hub sites reference posts using that method, and it's currently non-customizable.
  # With `collections` configuration, specify permalink for posts
  # correctly as well (for an example, see https://github.com/metanorma/metanorma.org/blob/d2b15f6d8c4cea73d45ad899374845ec38348ff1/_config.yml#L60).

  refresh_remote_data: daily
  # Optional. Controls when to refresh remote repository data.
  # Options: always, never, daily, weekly
  # Default: daily
  ```

### Logo

(mandatory)

By "logo" is meant the combination of site symbol as a graphic
and name as word(s).

- **Symbol** is basically an icon for the site.
  Should look OK in dimensions of 30x30px, and fit inside a square.
  Should be in SVG format (see also the SVG guidelines section).

  - Provide your site-wide symbol in <site root>/assets/symbol.svg.

  - Provide the symbol as PNG renders as `favicon.png` and `favicon-192x192.png`
    under `<site root>/assets/`; use transparent background.

- **Site name** displayed to the right of the symbol.
  Limit the name to 1-3 words.

  Drop a file called `title.html` in the root of your site.
  In its contents you can go as simple as `{{ site.name }}`
  and as complex as a custom SVG shape.

  Note that it must look good when placed inside ~30px tall container.
  In case of SVG, SVG guidelines apply.

If you want to style SVG with CSS specifying rules for .site-logo descendants:
take care, as this may cause issues when hub site's logo is used in context
of a project site. (You can use inline styling within the SVG.)

### Blog

Project sites and hub site can have a blog.

In case of the hub, blog index will show combined timeline
from hub blog and projects' blogs.

#### Index

Create blog index page as _pages/blog.html, with nothing but frontmatter.
Use layout called "blog-index", pass `hero_include: index-page-hero.html`,
and set `title` and `description` as appropriate for blog index page.

Example:

```yaml
---
title: Blog
description: >-
  Get the latest announcements and technical how-to's
  about our software and projects.
layout: blog-index
hero_include: index-page-hero.html
---
```

#### Posts

In general, posts are authored as per usual Jekyll setup.

It is recommended that you provide explicit hand-crafted post excerpts,
as automatically-generated excerpts may break the post card layout.

Theme also anticipates author information within frontmatter.
Together with excerpts, here's how post frontmatter (in addition to anything
already required by Jekyll) looks like:

```yaml
---
# Required
authors:
  - email: <author's email, required>
    use_picture: <`gravatar` (default), `assets`, an image path relative to assets/, or `no`>
    name: <author's full name>
    social_links:
      - https://twitter.com/username
      - https://facebook.com/username
      - https://linkedin.com/in/username

# Recommended
excerpt: >-
  Post excerpt goes here, and supports inline HTML formatting only.

# Optional. Cover image. Would normally refer to an illustration from within the post.
# First post, if it has card_image specified, will be displayed with bigger layout
# featuring the image.
card_image: <path, starting with /assets/>
---
```

For hub-wide posts, put posts under _posts/ in site root and name files e.g.
`2018-04-20-welcome-to-jekyll.markdown` (no change from the usual Jekyll setup).

If ``use_picture`` is set to "assets", author photo would be expected to
reside under `assets/blog/authors/<author email>.jpg`.

For project posts, see below the project site section.

## Hub site

The hub represents your company or department, links to all projects
and offers a software and specification index.

Note that a hub site is expected to have at least one document
in the `projects` collection (see below).

Additional items allowed/expected in _config.yml:

```yaml
# Mark this as a hub site
is_hub: true

# Since a hub would typically represent an organization as opposed
# to individual, this would make sense:
seo:
  type: Organization

tag_namespaces:
  software:
    namespace_id: "Human-readable namespace name"
    # E.g.:
    # writtenin: "Written in"
  specs:
    namespace_id: "Human-readable namespace name"

# Projects collection configuration
collections:
  projects:
    output: false
    permalink: /:collection/:name/
```

### Project, spec and software data

Each project subdirectory
must contain a file "index.{md|adoc}" with frontmatter like this:

```yaml
title: Sample Awesome Project
description: A sentence or two about what the project is for.
tagline: Because awesomeness is underrated

# Whether the project is included in featured three projects on hub home page
featured: true | false

site:
  git_repo_url: <Git URL to standalone project site source repo>
  git_repo_branch: <branch name in the above repo>

home_url: <URL to standalone project site>

tags: [some, tags]
```

### Project index page

Create software index in _pages/projects.html, with nothing but frontmatter.
Use layout called "project-index", pass `hero_include: index-page-hero.html`,
and set `title` and `description` as appropriate.

Example:

```yaml
---
title: Open projects
description: Projecting goodness into the world!
layout: project-index
hero_include: index-page-hero.html
---
```

### Software index page

Create software index in _pages/software.html, with nothing but frontmatter.
Use layout called "software-index", pass `hero_include: index-page-hero.html`,
and set `title` and `description` as appropriate.

Example:

```yaml
---
title: Software
description: Open-source software developed with MyCompany's cooperation.
layout: software-index
hero_include: index-page-hero.html
---
```

### Specification index page

Create spec index in _pages/specs.html, with nothing but frontmatter.
Use layout called "spec-index", pass `hero_include: index-page-hero.html`,
and set `title` and `description` as appropriate.

Example:

```yaml
---
title: Specifications
description: Because specifications are cool!
layout: spec-index
hero_include: index-page-hero.html
---
```

## Project site

For standalone sites of each of your projects, _config.yml should include
site-wide `title` that is the same as project name.

Additional items allowed/expected in _config.yml:

```yaml
authors:
  - name: Your Name
    email: your-email@example.com

author: "Company or Individual Name Goes Here"

# Any given open project site is assumed to be part of a hub,
# and hub details in this format are required to let project site
# reference the hub.
parent_hub:
  git_repo_url: git@example.com:path/to-repo.git
  git_repo_branch: somebranchname
  home_url: https://www.example.com/

algolia_search:
  api_key: '<your Algolia API key>'
  index_name: '<your Algolia index name>'

# Only add this if you want to use Algolia's search on your project site.

tag_namespaces:
  software:
    namespace_id: "Human-readable namespace name"
    # E.g.:
    # writtenin: "Written in"
  specs:
    namespace_id: "Human-readable namespace name"
# NOTE: Tag namespaces must match corresponding hub site's configuration entry.

landing_priority: [custom_intro, blog, specs, software]
# Which order should sections be displayed on landing.
#
# Default order: [software, specs, blog]
# Depending on your project's focus & pace of development you may want to change that.
# Supported sections: featured_posts, featured_software, featured_specs, custom_intro.
#
# If you use custom_intro, project site must define an include "custom-intro.html".
# The contents of that include will be wrapper in section.custom-intro tag.
# Inside the include you'd likely want to have introductory summary wrapped
# in section.summary, and possibly custom call-to-action buttons
# (see Metanorma.com site for an example).
```

### File structure

Each project is expected to have a machine-readable and unique name, a title,
a description, a symbol, one or more software products and/or specs.
Blog, docs, and other pages are optional.

Following data structure is used for project sites:

    - <project-name>/    # Jekyll site root containing _config.yml
      - assets/
        - symbol.svg     # Required — project logo
      - _software/
        - <name>.adoc
        - <name>/
          - assets/
            - symbol.svg
      - _specs/
        - <name>.adoc
      - _pages/
        - blog.html
        - software.html  # Software index
        - specs.html     # Spec index
        - docs.html
      - docs/            # Project-wide documentation
        - getting-started.adoc
        - <some-page>.adoc
      - _posts/          # Blog
        - 2038-02-31-blog-post-title.markdown
      - _layouts/
        - docs.html

### Blog

Author project site blog posts as described in the general site setup section.

### Project docs

Two kinds of docs can coexist on a given open project site:

- Project-wide documentation. It's well-suited for describing the idea behind the project,
  the "whys", for tutorials and similar.
- Documentation specific to a piece of software (of which there can be more than one
  for any given open project). This may go in detail about that piece of software,
  and things like implementation specifics, extended installation instructions,
  development guidelines may go here.

This section is about project-wide docs, for software docs see software and specs section.

The suggested convention is to create
_pages/docs.adoc for the main documentation page, put other pages under docs/,
and create custom layout `docs.html` that inherits from `docs-base`, specifies
`html-class: docs-page` and provides `navigation` structure linking to all docs pages
in a hierarchy.

Example _layouts/docs.html:

```
---
layout: docs-base
html-class: docs-page
docs_title: <Project name>
navigation:
  items:
  - title: Introduction
    items:
      - title: "Overview"
        path: /docs/
      - title: "Get started"
        path: /docs/getting-started/
---

{{ content }}
```

Example _pages/docs.adoc:

```
---
layout: docs
title: Overview
html-class: >-
  overview
  # ^^ classes you can use to style the page in your custom CSS rules
---
:page-liquid:

Your main docs page goes here.
```

### Software and specs

An open project serves as an umbrella for related
software products and/or specifications.

Each product or spec is described by its own <name>.adoc file with frontmatter,
placed under _software/ or _specs/ subdirectory (respectively)
of your open project's Jekyll site.

A software product additionally is required to have a symbol in SVG format,
placed in <name>/assets/symbol.svg within _software/ directory.

YAML frontmatter that is expected with both software and specs:

```yaml
title: A Few Words
# Shown to the user
# and used for HTML metadata if jekyll-seo-tag is enabled

description: A sentence.
# Not necessarily shown to the user,
# but used for HTML metadata if jekyll-seo-tag is enabled

tags: [Ruby, Python, RFC, "<some_namespace_id>:<appropriate_tag>"]
# NOTE: Avoid whitespaces and other characters that may make Jekyll
# percent-encode the tag in URLs. Replace " " (a regular space)
# with "_" (underline); underlines will be rewritten as spaces when tags
# are presented to site users.
# Tag can be prepended with a namespace to signify the type,
# e.g. chosen programming language or target viewer audience
# (see hub site configuration for tag namespace setup).
# Avoid long namespace/tag combos as they can overflow item's card widget.

external_links:
  - url: https://github.com/metanorma/metanorma
  - url: https://docs.rs/proj/ver/…/
  - { url: https://example.com/, title: "Custom title" }
# External links.
# For software, typically points to docs sites or source code repository.
# For specs, this usually contains RFC, IETF links, spec source code.
# * Link label can be specified with the title key.
#   Select URLs are recognized and an appropriate label
#   (possibly icon) is shown by default,
#   otherwise you **should** specify the title.
#   Currently, recognized URLs include
#   GitHub, Docs.rs, RubyDoc,
#   ietf.org/html/rfcN, datatracker.ietf.org/doc/…
# * Order links according to importance for project site visitors.
#   The first link will be highlighted as primary.

feature_with_priority: 1
# With this key, software or spec will be featured on home
# page of project site. Lower number means higher priority
# (as in, priority no. 1 means topmost item on home page,
# as long as there aren't others with the same value).
# If no documents in the collection have this key,
# items on home will be ordered according to Jekyll's
# default behavior.
```

### Software product

YAML frontmatter required for software:

```yaml
repo_url: https://github.com/riboseinc/asciidoctor-rfc
# Required.
# Used for things like showing how long ago
# the was project updated last.

repo_branch: main

docs_source:
  git_repo_url: git@example.com:path/to-repo.git
  git_repo_subtree: docs
  git_repo_branch: main
# Documentation, the contents of which will be made part of the project site.
# See the nearby section about documentation.
```

#### Displaying software docs

Inside the repository and optionally subtree specified under `docs`
in above sample, place a file called `navigation.adoc` (or `navigation.{md|adoc}`) containing
only frontmatter, following this sample:

```yaml
---
items:
- title: Introduction
  path: intro/
  items:
    - { title: Overview, path: intro/overview/ }
    - { title: Installation, path: intro/installation/ }
- { title: Usage, path: usage/ }
---

= Navigation
```

In the same directory, place the required document pages—in this case, `overview.adoc`,
`installation.adoc`, and `basic-usage.adoc`. Each file must contain
standard YAML frontmatter with at least `title` specified.

During project site build, Jekyll pulls docs for software that's part of the
site and builds them, converting pages from Markdown/AsciiDoc to HTML and adding
the navigation.

### Specification

YAML frontmatter specific to specs:

```yaml
spec_source:
  git_repo_url: https://github.com/<user>/<repo>
  git_repo_subtree: images
  git_repo_branch: main
  build:
    engine: png_diagram_page
# See below about building the spec from its source
# to be displayed on the site.

navigation:
  sections:
  - name: Model diagrams
    items:
    - title: "CSAND Normal Document"
      path: "Csand_NormalDocument"
      description: ""
      ignore_missing: yes
```

#### Displaying specification contents

While software doc pages are currently simply generated using standard
Jekyll means from Markdown/AsciiDoc into HTML,
building specs is handled in a more flexible way,
delegating the source -> Open Project site-compatible HTML conversion
to an engine.

For specs to be built, provide build config and navigation
in the YAML frontmatter of corresponding `_specs/<specname>.adoc` file
as described in spec YAML frontmatter sample.

For now, only the `png_diagram_page` engine is supported, with Metanorma-based
project build engine to come.

During project site build, Jekyll pulls spec sources that's part of the
site and builds them, converting pages from source markup to HTML using
the engine specified, and adding the navigation.

### Symbol

Should look OK in dimensions of about 30x30, 60x60px. Must fit in a square.
Should be in SVG format (see also the SVG guidelines section).
Place the symbol in assets/symbol.svg within project directory.

## SVG guidelines

- Ensure SVG markup does not use IDs. It may appear multiple times
  on the page hence IDs would fail markup validation.
- Ensure root `<svg>` element specifies the `viewBox` attribute,
  and no `width` or `height` attributes.
- You can style SVG shapes by adding custom rules to site's assets/css/style.scss.
- Project symbols only: the same SVG is used both in hub site's project list
  (where it appears on white, and is expected to be colored)
  and in project site's top header
  (where it appears on colored background, and is expected to be white).
  It is recommended to use a normal color SVG, and style it in project site's
  custom CSS. The SVG must be created in a way that allows this to happen.

## Content guidelines

- Project, software, spec title: 1-3 words, capital case
- Project, software, spec description: about 12 words, no markup
- Project description (featured): about 20-24 words, no markup
- Blog post title: 3–7 words
- Blog post excerpt: about 20–24 words, no markup

## Authoring content

Content is expected to be authored in AsciiDoc.
Some features, such as in-page navigation in software/project documentation
and code listing copy buttons,
require HTML structure to match the one generated from AsciiDoc by jekyll-asciidoc
and won't work with content is authored in Markdown, for example.

### Disabling copy button on code listings

By default, each code listing widget, like below, will have a copy button
next to the `<pre>` element.

```
[source,sh]
----
docker pull ribose/metanorma
----
```

To disable that button for a particular listing, add `.nocopy` class to it:

```
[.nocopy]
[source,sh]
----
docker pull ribose/metanorma
----
```

## Theme includes

Commonly used overridable includes are (paths relative to your site root):

- title.html: Site name in case you want to provide custom typography,
  possibly as SVG.

- project-nav.html (currently project sites only): Additional
  links in project site's top navigation, if needed.

- assets/symbol.svg: Site-wide symbol is used as an include
  to facilitate path fill color overrides via CSS rules.

### Include location gotcha

Theme configuration adds `includes_dir: .` to your site.
This means when Jekyll encounters `{% include <include_name> %}`
in a template, it looks first in `<site root>/<include_name>`,
and then in `<theme root>/_includes/<include_name>`. Consequently,
you put your include overrides directly in site root, **not** inside
`_includes/` directory of your site.

## Theme layouts

Normally you don't need to specify layouts manually, except where
instructed in site setup sections of this document.

Commonly used layouts are:

- blog-index: Blog index page. Pages using this layout are recommended
  to supply hero_include.

- post: Blog post.

- project-index: Open project index page (hub site only).
  Suggested to supply hero_include.
  Will show a list of open projects across the hub.

- software-index: Software index page (hub site only).
  Suggested to supply hero_include.
  Will show a list of software across projects within the hub.

- spec-index: Specification index page (hub site only).
  Suggested to supply hero_include.
  Will show a list of specs across projects within the hub.

- product: Software product (project site only).

- spec: Open specification (project site only).

- default: Main layout; among other things adds `html-class` specified in frontmatter
  of last inheriting layout and the concrete page frontmatter to the `<body>` element.

### Page frontmatter

Typical expected page frontmatter is `title` and `description`. Those are
also used by jekyll-seo-tag plugin to add the appropriate meta tags.

Commonly supported in page frontmatter is the hero_include option,
which would show hero unit underneath top header.
Currently, theme
