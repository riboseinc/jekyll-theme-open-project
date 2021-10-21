# Open Project theme by Ribose

Open Project is a Jekyll theme (with the accompanying plugin)
aiming to help organizations and individuals present
open-source software and specifications in a navigable and elegant way.

Open Project fits two types of sites:

* a site that describes one individual project
* a site that combine projects into sort of an open hub.

**Demo**: See [Ribose Open](https://open.ribose.com/) project sites -- for example,
[Metanorma](https://www.metanorma.com),
[RNP](https://www.rnpgp.com),
[Cryptode](https://www.cryptode.com),
[Relaton](https://www.relaton.com).

See also: CI_OPS for how to set up automated build and deployment of sites
to AWS S3.

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

The currently recommended Ruby version is 2.6.
(In case you aren’t using Ruby often, the easiest way to install one may be with RVM.)

The currently recommended Jekyll version is 3 or newer
(read about [Jekyll installation](https://jekyllrb.com/docs/#instructions)).

NOTE: this theme is known to not work with Ruby older than 2.3,
and hasn’t been tested on newer versions.

### Start a new Jekyll site

    jekyll new my-open-site

If you use Git for site source version management,
see the “Extra .gitignore rules” section below
for additional lines you should add to your `.gitignore`.

### Install Open Site theme into the Jekyll site

Add this line to your Jekyll site's `Gemfile`,
replacing default theme requirement:

```ruby
gem "jekyll-theme-open-project"
```

(Jekyll’s default theme was “minima” at the time of this writing.)

Also in the `Gemfile`, add two important plugins to the `:jekyll_plugins` group.
(The SEO tag plugin is not mandatory, but these docs assume you use it.)

```ruby
group :jekyll_plugins do
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
  gem "jekyll-data"
  gem "jekyll-asciidoc"

  gem "jekyll-theme-open-project-helpers"
  gem "jekyll-external-links"

  # ...other plugins, if you use any
end
```

Execute the following to install dependencies:

    $ bundle

### Configure your Open Site for the first time

Edit `_config.yml` to add necessary site-wide configuration options,
and add files and folders to site contents. This step depends
on the type of site you’re creating: hub or individual project site.

Further sections explain core concepts of open project and hub, and go
into detail about how to configure a project or hub site.

Before building the first time you must do this:

1. Configure [common settings](#common-settings)
2. Add your logo(s) according to [logo](#logo)

Please see the [configuration section](#configuration) for more details.

NOTE: It may be required to copy the following properties from
this theme’s `_config.yaml` to your site’s: `collections`, `includes_dir`.

This is likely caused by changed behavior of jekyll-data gem in recent versions,
which is responsible for “inheritance” of `_config.yaml` between theme and site.

You can add any custom collections for your site
after collections copied from theme’s config.


### Building site

Execute to build the site locally and watch for changes:

    $ bundle exec jekyll serve --host mysite.local --port 4000

This assumes you have mysite.local mapped in your hosts file,
otherwise omit --host and it’ll use “localhost” as domain name.


## Configuration

There are 3 areas to configure when you first create an Open Site, namely:

* [Common setup](#common-setup), settings that apply to both Hub and Project sites;
* [Hub site](#hub-site);
* [Project site](#project-site)


## Common setup

### Git repository branch behavior

You’ll see many instances of document frontmatter
referencing Git repository URLs.

Note that, wherever a `[*_]repo_url` property is encountered,
a sibling property `[*_]repo_branch` is supported.

If you reference repositories that don’t use branch name `main`,
you must either:

- use a sibling `[*_]repo_branch` property to specify your custom branch name
  (you can search for `git_repo_branch`, `repo_branch`, `github_repo_branch`
  in this document for examples), or

- specify `default_repo_branch` property in `config.yml`

  (in this case, in scenarios with project sites being used in conjunction
  with a hub site, `default_repo_branch` must be the same
  across all project sites’ and their hub site’s `config.yml`—otherwise you’re advised
  to use the previous option to avoid site build failure).

Note that, when a referenced Git repository doesn’t contain the necessary branch
(either explicitly specified custom branch, or `default_repo_branch`, or branch called “main”),
this will cause build failure of that project site, or a hub site using that project site.

### Common settings

(mandatory)

These settings apply to both site types (hub and project).

- You may want to remove the default `about.md` page added by Jekyll,
  as this theme does not account for its existence.

- Add `hero_include: home-hero.html` to YAML frontmatter
  in your main `index.md`.

- Add following items to site’s `_config.yml`
  (and don’t forget to remove default theme requirement there):

  ```yaml
  url: https://example.com
  # Site’s URL with protocol, without optional www. prefix
  # and without trailing slash.
  # Used e.g. for marking external links in docs and blog posts.

  github_repo_url: https://github.com/example-org/example.com
  # URL to GitHub repo for the site.
  # Using GitHub & specifying this setting is currently required
  # for “suggest edits” buttons to show on documentation pages.
  github_repo_branch: main
  # Optional, default is `main`.

  title: Example
  description: The example of examples
  # The above two are used by jekyll-seo-tag for things such as
  # `<title>` and `<meta>` tags, as well as elsewhere by the theme.

  default_repo_branch: main
  # Optional, default is `main`.
  # Whenever branch name isn’t specified for some repository
  # (such as project docs or specs), this name will be used
  # during site’s build.
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
  # Theme design relies on Font Awesome “solid” and “brands” icon styles
  # and expects them to be included in SVG mode.
  # Without this setting, one-file FA distribution, all.js, is included from free FA CDN.

  theme: jekyll-theme-open-project
  permalink: /blog/:month-:day-:year/:title/
  ```

### Logo

(mandatory)

By “logo” is meant the combination of site symbol as a graphic
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
take care, as this may cause issues when hub site’s logo is used in context
of a project site. (You can use inline styling within the SVG.)

### Blog

Project sites and hub site can have a blog.

In case of the hub, blog index will show combined timeline
from hub blog and projects’ blogs.

#### Index

Create blog index page as _pages/blog.html, with nothing but frontmatter.
Use layout called "blog-index", pass `hero_include: index-page-hero.html`,
and set `title` and `description` as appropriate for blog index page.

Example:

```yaml
---
title: Blog
description: >-
  Get the latest announcements and technical how-to’s
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
Together with excerpts, here’s how post frontmatter (in addition to anything
already required by Jekyll) looks like:

```yaml
---
# Required
authors:
  - email: <author’s email, required>
    use_picture: <`gravatar` (default), `assets`, an image path relative to assets/, or `no`>
    name: <author’s full name>
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

Additional items allowed/expected in _config.yml:

```yaml
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
```

### Project, spec and software data

Each project subdirectory
must contain a file "index.md" with frontmatter like this:

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
description: Open-source software developed with MyCompany’s cooperation.
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

# Only add this if you want to use Algolia’s search on your project site.

tag_namespaces:
  software:
    namespace_id: "Human-readable namespace name"
    # E.g.:
    # writtenin: "Written in"
  specs:
    namespace_id: "Human-readable namespace name"
# NOTE: Tag namespaces must match corresponding hub site’s configuration entry.

landing_priority: [custom_intro, blog, specs, software]
# Which order should sections be displayed on landing.
#
# Default order: [software, specs, blog]
# Depending on your project’s focus & pace of development you may want to change that.
# Supported sections: featured_posts, featured_software, featured_specs, custom_intro.
#
# If you use custom_intro, project site must define an include "custom-intro.html".
# The contents of that include will be wrapper in section.custom-intro tag.
# Inside the include you’d likely want to have introductory summary wrapped
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

- Project-wide documentation. It’s well-suited for describing the idea behind the project,
  the “whys”, for tutorials and similar.
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
of your open project’s Jekyll site.

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
# Avoid long namespace/tag combos as they can overflow item’s card widget.

external_links:
  - url: https://github.com/riboseinc/asciidoctor-rfc
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
# as long as there aren’t others with the same value).
# If no documents in the collection have this key,
# items on home will be ordered according to Jekyll’s
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
in above sample, place a file `navigation.adoc` (or `navigation.md`) containing
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

During project site build, Jekyll pulls docs for software that’s part of the
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
    engine: png_diagrams
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

For now, only the `png_diagrams` engine is supported, with Metanorma-based
project build engine to come.

During project site build, Jekyll pulls spec sources that’s part of the
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
- You can style SVG shapes by adding custom rules to site’s assets/css/style.scss.
- Project symbols only: the same SVG is used both in hub site’s project list
  (where it appears on white, and is expected to be colored)
  and in project site’s top header
  (where it appears on colored background, and is expected to be white).
  It is recommended to use a normal color SVG, and style it in project site’s
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
and won’t work with content is authored in Markdown, for example.

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
  links in project site’s top navigation, if needed.

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

Normally you don’t need to specify layouts manually, except where
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
Currently, theme supports _includes/index-page-hero.html as the only value
you can pass for hero_include (or you can leave hero_include out altogether).


## Style customization

To customize site appearance, create a file in your Jekyll site
under assets/css/style.scss with following exact contents:

```
---
---
// Font imports can go here

// Variable redefinitions can go here

@import 'jekyll-theme-open-project';

// Custom rules can go here
```

There are two aspects to theme customization:

* Cutomize SASS variables before the import (such as colors)
* Define custom style rules after the import

### Custom rules

One suggested custom rule would be to change the fill color for SVG paths
used for your custom site symbol to white, unless it’s white by default.

The rule would look like this:

```scss
.site-logo svg path {
  fill: white;
}
```

### SASS variables

Following are principal variables that define the appearance of a site
built with this theme, along with their defaults.

For a project site, wisely choosing primary and accent colors should be enough
as a minimum.

```scss
$font-family: Helvetica, Arial, sans-serif !default;
$main-font-color: black !default;

# Primary color & accent colors are used throughout site’s UI.
# Make sure to use shades dark enough that white text is readable on top,
# especially with the primary color.
# Make sure these colors go well with each other.
$primary-color: lightblue !default;
$accent-color: red !default;

# These colors are used for warning/info blocks within body text.
$important-color: orange !default;
$warning-color: red !default;

# Background used on home page body & other pages’ hero unit backgrounds.
$main-background: linear-gradient(315deg, $accent-color 0%, $primary-color 74%) !default;

# This background defaults to $main-background value.
$header-background: $main-background !default;


# Below does not apply to project sites (only the hub site):

$hub-software--primary-color: lightsalmon !default;
$hub-software--primary-dark-color: tomato !default;
$hub-software--hero-background: $hub-software--primary-dark-color !default;

$hub-specs--primary-color: lightpink !default;
$hub-specs--primary-dark-color: palevioletred !default;
$hub-specs--hero-background: $hub-specs--primary-dark-color !default;
```

TIP: A good way to find a good match for primary-color and accent-color
may be the eggradients.com website. Find a suitable, dark enough gradient and pick
one color as primary, and the other as accent.


## Extra .gitignore rules

Add these lines to your .gitignore to prevent
theme-generated files and directories from adding chaos to your Git staging.

```
_software/*/.git
_software/*/docs
_software/_*_repo
_specs/*/
!_specs/*.*
parent-hub/*
```


## Contributing

Bug reports and pull requests are welcome on GitHub
at https://github.com/riboseinc/jekyll-theme-open-project.

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## Theme development

Generally, this directory is setup like a Jekyll site. To set it up,
run `bundle install`.

To experiment with this code, add content (projects, software, specs)
and run `bundle exec jekyll serve`. This starts a Jekyll server
using this theme at `http://localhost:4000`.

Put your layouts in `_layouts`, your includes in `_includes`,
your sass files in `_sass` and any other assets in `assets`.

Add pages, documents, data, etc. like normal to test your theme's contents.

As you make modifications to your theme and to your content, your site will
regenerate and you should see the changes in the browser after a refresh,
like normal.

When your theme is released, only files specified with gemspec file
will be included. If you modify theme to add more directories that
need to be included in the gem, edit regexp in the gemspec.

### Building and releasing

#### Manual test during development

When you’re working on visual aspects of the theme, it’s useful
to see how it would affect the end result (a site *built with* this theme).

Here’s how to develop the theme while simultaneously previewing the changes
on a site. The sequence would be as follows, assuming you have a local copy
of this repo and have a Jekyll site using this theme:

1. For the Jekyll site, change Gemfile to point to local copy
   of the theme (the root of this repo) and run `bundle`.

   For example, you’d change `gem "jekyll-theme-open-project", "~> 1.0.6"`
   to `gem "jekyll-theme-open-project", :path => "../jekyll-theme-open-project"`.
   The relative path assumes your site root and theme root are sibling directories.

2. Run `bundle exec jekyll serve` to start Jekyll’s development server.

3. Make changes to both theme and site directory contents.

4. If needed, kill with Ctrl+C then relaunch the serve command
   to apply the changes you made to the theme
   (it may not reload automatically if changes only affect the theme and not the site
   you’re serving).

4. Once you’re satisfied, release a new version of the theme — see below.

5. (To later bump the site to this latest version: revert the Gemfile change,
   update theme dependency version to the one you’ve just released,
   run `bundle --full-index` to update lockfile properly,
   and your site is ready to go.)

#### Releasing

Make sure theme works: build script is under construction,
so use good judgement and thorough manual testing.

1. Pick the next version number (think whether it’s a patch, minor or major increment).

2. Release the chosen version of `jekyll-theme-open-project-helpers` gem:
   see [https://github.com/riboseinc/jekyll-theme-open-project-helpers](gem’s docs).

   (Theme and plugin are coupled tightly at this time,
   and to simplify mental overhead of dependency management
   we go with one version number for the whole suite.)

3. Inside .gemspec within this repo’s root, update main gem version,
   and also the version for `jekyll-theme-open-project-helpers` runtime dependency,
   to the one we are releasing.

4. Run `bundle --full-index`, ensure it pulls the newly released plugin gem.
   (It may take a couple minutes after releasing helpers plugin for gem index to update.)

5. Make a commit for the new release (“chore: Release vX.X.X”).

6. Execute `./develop/release`. This does the following:

   * Builds new gem version
   * Pushes gem to rubygems.org
   * Creates new version tag in this repository
   * Pushes changes to GitHub

#### Testing with build script (TBD)

May not work at the moment — see #26. Please use the other test option.

To check your theme, run:

    ./develop/build

It’ll build Jekyll site and run some checks, like HTML markup validation.


## License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
