# Open Project theme by Ribose

Open Project is a theme for Jekyll oriented towards presenting open efforts
such as open-source software and specifications in a navigable and elegant way.

Open Project fits two types of sites:
that describe one individual project, and that combine projects into sort of an open hub.

See also: CI_OPS for how to set up automated build and deployment of the site
to AWS S3.


## Contents

* Creating a site: [quick-start](#starting-a-site-with-this-theme)

  * [Universal site setup](#universal-setup)
  * [Hub site setup](#hub-site)
  * [Project site setup](#project-site)

* Describing open projects:
  [Project data structure](#describing-a-project-shared-data-structure)

* Customizing site looks without violating theme design constraints:

  * [Style customization](#style-customization)
  * [SVG guidelines](#svg-guidelines)
  * [Content guidelines](#content-guidelines)

* [Select layout reference](#select-layout-reference)


## Starting a site with this theme

### Getting started with Ruby

If you aren’t using Ruby often, the recommended way to install it is with RVM.
Refer to RVM docs and use it to install a reasonably fresh Ruby version,
let’s say 2.4.4.

### Start new Jekyll site

    jekyll new my-open-site

### Installing theme

Add this line to your Jekyll site's `Gemfile`,
replacing default theme requirement:

```ruby
gem 'jekyll-theme-open-project'
```

(Jekyll’s default theme was “minima” at the time of this writing.)

Also in the `Gemfile`, add two important plugins to the `:jekyll_plugins` group.
(The SEO tag plugin is not mandatory, but these docs assume you use it.)

```ruby
group :jekyll_plugins do
  gem "jekyll-seo-tag"
  gem "jekyll-theme-open-project-helpers"
  # ...other plugins, if you use any
end
```

Execute to install dependencies:

    $ bundle

### Configuring site

Edit _config.yml to add necessary site-wide configuration options,
and add necessary files and folders to site contents. This step depends
on the type of site you’re creating: open hub or individual open project site.

Below sections explain core concepts of open project and hub, and go
into detail about how to configure a project or hub site.

### Building site

Execute to build the site locally and watch for changes:

    $ bundle exec jekyll serve --host mysite.local --port 4000

This assumes you have mysite.local mapped, otherwise omit --host
and it’ll use localhost.


## Universal setup

These settings are required to both site types (hub and project).

- You may want to remove the default about.md page added by Jekyll,
  as this theme does not account for its existence.
- Add following items to _config.yml
  (don’t forget to remove default theme requirement):

  ```yaml
  title: Site title
  description: Site description
  # The above two are used by jekyll-seo-tag for things such as
  # `<title>` and `<meta>` tags, as well as elsewhere by the theme.

  tagline: Site tagline
  pitch: Site pitch
  # The above two are used on home hero unit.


  # Further settings are not expected to be changed,
  # unless you know what you’re doing:

  markdown: kramdown
  theme: jekyll-theme-open-project

  # Theme layouts can include from any directory, not just _includes.
  # There’s a quirk in Jekyll’s “safe” behavior around include and gem-based themes
  # which means include_relative wouldn’t cut it.
  includes_dir: .

  collections:
    posts:
      output: true
      permalink: /blog/:month-:day-:year/:title/
    pages:
      output: true
      permalink: /:name/

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
  ```

### Logo

Logo consists of a symbol and site name.

**Symbol** is basically an icon for the site.
Should look OK in dimensions of 30x30px, and fit inside a square.
Should be in SVG format (see also the SVG guidelines section).
Place the symbol in _includes/symbol.svg.

**Site name** displayed to the right of the symbol.
Limit the name to 1-3 words.
By default, the title you define in site config is used (for project site,
it is the name of the project).
Alternatively, you can place site name in _includes/title.html with custom HTML
or SVG. (In that case it must look good when placed in a 30px tall container,
and in case of SVG same SVG guidelines apply).

### Legal small text

You may want to supply _includes/legal.html with content like this:

```html
<span class="copyright">Copyright © 2018 MyCompany. All rights reserved.</span>
<nav>
  <a href="https://www.example.com/tos">Terms</a>
  <a href="https://www.example.com/privacy">Privacy</a>
</nav>
```

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

The following _additional_ data is expected within post document frontmatter:

```yaml
---
author:
  email: <author’s email>
  name: <author’s full name>
  social_links:
    - https://twitter.com/username
    - https://facebook.com/username
    - https://linkedin.com/in/username
---
```

For hub-wide posts, put posts under _posts/ in site root and name files e.g.
`2018-04-20-welcome-to-jekyll.markdown` (no change from the usual Jekyll setup).

For project posts, see below about shared project data structure.


## Hub site

The hub represents your company or department, links to all projects
and offers a software and specification index.

Additional items allowed/expected in _config.yml:

```yaml
social:
  links:
    - https://twitter.com/RiboseUS
    - https://github.com/riboseinc

# Since a hub would typically represent an organization as opposed
# to individual, this would make sense:
seo:
  type: Organization

collections:
  projects:
    output: false
  # ... (other collections)
```

### Project, spec and software data

See the section about project data structure.

_When used within hub site_ (only), each project subdirectory
must contain a file "index.md" with frontmatter like this:

```yaml
title: Sample Awesome Project

description: >-
  A sentence or two go here.

# Whether the project is included in featured three projects on hub home page
featured: true | false

home_url: <URL to standalone project site>
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

When project is set up as a standalone site, _config.yml should include
site-wide `title` that is the same as project name.

Additional items allowed/expected in _config.yml:

```yaml
authors:
  - name: Your Name
    email: your-email@example.com

author: "Company or Individual Name Goes Here"

collections:
  # ... (other collections)
  software:
    output: true
    permalink: /:name/
  specs:
    output: true
    permalink: /:name/

defaults:
  # ... (other defaults)
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

File layout is the same as described in the section
about shared project data structure, with _software, _specs, _posts directories
found in the root of your Jekyll site.


## Describing a project: shared data structure

Each project is expected to have a machine-readable and unique name, a title,
a description, a symbol, and one or more software products and/or specs.

Following data structure is shared and used to describe projects,
whether on hub home site or each individual project site:

    - <project-name>/
      - _posts/
        - 2038-02-31-blog-post-title.markdown
      - _includes/
        - symbol.svg
      - _software/
        - <name>.md
      - _specs/
        - <name>.md

### Blog

Project blog posts should be authored as described in the universal setup
section.

### Software and specs

An open project serves as an umbrella for related
software products and/or specifications.

Each product or spec is described by its own <name>.md file with frontmatter,
placed under _software/ or _specs/ subdirectory, respectively,
of your open project’s Jekyll site.

Note: even though they’re in different subdirectories, all software products and specs
within one project share URL namespace and hence must have unique names.

YAML frontmatter that can be used with both software and specs:

```yaml
title: A Few Words
# Shown to the user
# and used for HTML metadata if jekyll-seo-tag is enabled

description: A sentence.
# Not necessarily shown to the user,
# but used for HTML metadata if jekyll-seo-tag is enabled
```

### Software product

YAML frontmatter specific to software:

```yaml
version: v1.2.3
docs_url: https://foobar.readthedocs.io/en/latest
repo_url: https://github.com/…
stack: [Python, Django, AWS]
```

#### Documentation

**Recommended:** use a dedicated service supporting versioned and well-structured
multi-page docs, such as Read the Docs. You can link users to that documentation
using docs_url in software product’s frontmatter.

Otherwise, if this open project’s page will serve as the authoritative source
of documentation for the software product, documentation contents are expected
to follow frontmatter. 

Keep in mind that project name and description from before
will be displayed by the theme first. Start with second-level header (##),
with installation instructions or quick-start guide.

### Specification

YAML frontmatter specific to specs:

```yaml
rfc_id: XXXX
# IETF RFC URL would be in the form 
# http://ietf.org/html/rfc<id>

ietf_datatracker_id: some-string-identifier-here
ietf_datatracker_ver: "01"
# IETF datatracker URL would be in the form
# https://datatracker.ietf.org/doc/<id>[-<version>]

source_url: https://example.com/spec-source-markup
```

Specs that are not hosted elsewhere (such as ietf.org for RFCs)
are expected to contain the actual specification content after frontmatter.
Start with second-level header (##).

### Symbol

Should look OK in dimensions of 30x30px, and fit inside a square.
Should be in SVG format (see also the SVG guidelines section).
Place the symbol in _includes/symbol.svg within project directory.


## SVG guidelines

- Ensure SVG markup does not use IDs. It may appear multiple times
  on the page hence IDs would fail markup validation.
- Ensure root <svg> element specifies its viewBox,
  but no width or height attributes.
- You can style SVG shapes using in site’s assets/css/style.scss.


## Content guidelines

- Project, software, spec title: 1-3 words, capital case
- Project, software, spec description: about 12 words, no markup
- Project description (featured): about 20-24 words, no markup
- Blog post title: 3–7 words
- Blog post excerpt: about 20–24 words, no markup


## Select layout reference

Normally you don’t need to specify layouts manually, except where
instructed in site setup sections of this document.

Commonly used layouts are:

- blog-index: Blog index page. Pages using this layout are recommended
  to supply hero_include.

- post: Blog post

- project-index: Open project index page (hub site only).
  Suggested to supply hero_include.
  Will show a list of open projects across the hub.

- software-index: Software index page (hub site only).
  Suggested to supply hero_include.
  Will show a list of software across projects within the hub.

- spec-index: Specification index page (hub site only).
  Suggested to supply hero_include.
  Will show a list of specs across projects within the hub.

- product: Software product (project site only)

- spec: Open specification (project site only)

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

@import '{{ site.theme }}';
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

Following are the variables along with their defaults:

```scss
# Primary color—should be bright but dark enough to be readable,
# since some text elements are set using this color:
$primary-color: lightblue !default;

# Darker variation of primary color used for background on elements where
# text is set in white:
$primary-dark-color: navy !default;

# Bright color for accent elements, such as buttons (not yet in use).
# Text on those elements is set in bold and white, so this color
# should be dark enough:
$accent-color: red !default;

# Below are used for `background` CSS rule for top header, and for
# hero unit respectively. Gradients can be supplied.
$header-background: $primary-dark-color !default;
$hero-background: $primary-dark-color !default;

# Below customize colors for different sections of the site.
$hub-software--primary-color: lightsalmon !default;
$hub-software--primary-dark-color: tomato !default;
$hub-software--hero-background: $hub-software--primary-dark-color !default;

$hub-specs--primary-color: lightpink !default;
$hub-specs--primary-dark-color: palevioletred !default;
$hub-specs--hero-background: $hub-specs--primary-dark-color !default;
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

To check your theme, run:

    ./develop/build

It’ll build Jekyll site and run some checks, like HTML markup validation.

To build new gem and push it to rubygems.org, run:

    ./develop/release


## License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
