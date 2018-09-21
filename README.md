# Open Project theme by Ribose

Open Project is a theme for Jekyll oriented towards presenting open efforts
such as open-source software and specifications in a navigable and elegant way.

Open Project fits two types of sites:
that describe one individual project, and that combine projects into sort of an open hub.

See also: CI_OPS for how to set up automated build and deployment of the site
to AWS S3.


## Contents

* Creating a site: [how to](#starting-a-site-with-this-theme)

  * [General site setup](#general-setup)
  * [Hub site setup](#hub-site)
  * [Project site setup](#project-site)

* Describing open projects:
  [Project data structure](#describing-a-project-shared-data-structure)

* Customizing site looks:

  * [Style customization](#style-customization)
  * [SVG guidelines](#svg-guidelines)
  * [Content guidelines](#content-guidelines)

* [Layouts](#theme-layouts)
* [Includes](#theme-includes)


## Starting a site with this theme

### Getting started with Ruby

If you aren’t using Ruby often, the recommended way to install it is with RVM.
Refer to RVM docs and use it to install a fresh Ruby version.

The currently recommended version is 2.4.4, it’s known to not work under 2.3
and it hasn’t been tested on newer versions.

### Start new Jekyll site

    jekyll new my-open-site

### Installing theme

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
  gem "jekyll-data"
  gem "jekyll-theme-open-project-helpers"
  # ...other plugins, if you use any
end
```

Execute the following to install dependencies:

    $ bundle

### Configuring site

Edit _config.yml to add necessary site-wide configuration options,
and add files and folders to site contents. This step depends
on the type of site you’re creating: hub or individual project site.

Further sections explain core concepts of open project and hub, and go
into detail about how to configure a project or hub site.

### Building site

Execute to build the site locally and watch for changes:

    $ bundle exec jekyll serve --host mysite.local --port 4000

This assumes you have mysite.local mapped in your hosts file,
otherwise omit --host and it’ll use “localhost” as domain name.


## General setup

These settings apply to both site types (hub and project).

- You may want to remove the default about.md page added by Jekyll,
  as this theme does not account for its existence.

- Add `hero_include: home-hero.html` to YAML frontmatter
  in your main `index.md`.

- Add following items to site’s _config.yml
  (and don’t forget to remove default theme requirement there):

  ```yaml
  title: Site title
  description: Site description
  # The above two are used by jekyll-seo-tag for things such as
  # `<title>` and `<meta>` tags, as well as elsewhere by the theme.

  tagline: Site tagline
  pitch: Site pitch
  # The above two are used on home hero unit.

  social:
    links:
      - https://twitter.com/<orgname>
      - https://github.com/<orgname>

  legal:
    name: Full Organization Name
    tos_link: https://www.example.com/tos
    privacy_policy_link: https://www.example.com/privacy

  # These are required for the theme to work:

  theme: jekyll-theme-open-project
  permalink: /blog/:month-:day-:year/:title/
  ```

### Logo

By “logo” is meant the combination of site symbol as a graphic
and name as word(s).

- **Symbol** is basically an icon for the site.
  Should look OK in dimensions of 30x30px, and fit inside a square.
  Should be in SVG format (see also the SVG guidelines section).

  Drop your site-wide symbol in <site root>/assets/symbol.svg.

- **Site name** displayed to the right of the symbol.
  Limit the name to 1-3 words.

  Drop a file called `title.html` in the root of your site.
  In its contents you can go as simple as `{{ site.name }}`
  and as complex as a custom SVG shape.
  
  Note that it must look good when placed inside ~30px tall container.
  In case of SVG, SVG guidelines apply.
  
Do not create custom CSS rules for .site-logo descendants:
this may cause issues when one site’s logo is used in context of another site
of the same hub. You can use inline styling, though.

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
as automatically-generated excerpts may break post card markup.

Theme also anticipates author information within frontmatter.
Together with excerpts, here’s how post frontmatter (in addition to anything
already required by Jekyll) looks like:

```yaml
---
excerpt: >-
  Post excerpt goes here, and supports inline formatting only.

author:
  email: <author’s email; associated Gravatar will be shown>
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
is_hub: true

# Since a hub would typically represent an organization as opposed
# to individual, this would make sense:
seo:
  type: Organization
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

site:
  git_repo_url: <Git URL to standalone project site source repo>
home_url: <URL to standalone project site>

# Note: Avoid whitespaces and other characters that may make Jekyll
# percent-encode the tag in URLs. Replace " " (a regular space)
# with "_" (underline); underlines will be rewritten as spaces when tags
# are presented to site users.
tags: [Ruby, Python, RFC]
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

# Any given open project site is assumed to be part of a hub,
# and hub details in this format are required to let project site
# reference the hub.
parent_hub:
  git_repo_url: git@example.com:path/to-repo.git
  home_url: https://www.example.com/
```

File layout is the same as described in the section
about shared project data structure, with _software, _specs, _posts, assets
subdirectories found in the root of your Jekyll site.


## Describing a project: shared data structure

Each project is expected to have a machine-readable and unique name, a title,
a description, a symbol, and one or more software products and/or specs.

Following data structure is shared and used to describe projects,
whether on hub home site or each individual project site:

    - <project-name>/
      - _posts/
        - 2038-02-31-blog-post-title.markdown
      - assets/
        - symbol.svg
      - _software/
        - <name>.md
        - <name>/
          - assets/
            - symbol.svg
      - _specs/
        - <name>.md

### Blog

Author project site blog posts as described in the general site setup section.

### Software and specs

An open project serves as an umbrella for related
software products and/or specifications.

Each product or spec is described by its own <name>.md file with frontmatter,
placed under _software/ or _specs/ subdirectory, respectively,
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

tags: [Python, Ruby]

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

docs:
  git_repo_url: git@example.com:path/to-repo.git
  git_repo_subtree: docs
```

About the `docs` key in this frontmatter, see nearby section
about documentation.

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
# Required.
```

### Documentation for specs and software

Documentation contents for software should be kept in software
package’s own repository, under a directory such as `docs/`.
Inside that directory, place a file called `navigation.md` containing
only frontmatter, in format like this:

```yaml
sections:
- name: Introduction
  items:
    - overview
    - installation
- name: Usage
  items:
    - basic
```

In the same directory, place the required document pages—in this case, overview.md,
installation.md, and basic.md. Each document page is required to contain
standard YAML frontmatter with at least `title` specified.

During project site build, Jekyll will pull docs for software products
that are hosted under that project site.

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
`_includes/` directory of your side.

## Theme layouts

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

Following are the variables along with their defaults:

```scss
$font-family: Helvetica, Arial, sans-serif !default;

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

# This is for the big big hero unit on home page.
$superhero-background: $primary-dark-color !default;

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

1. First, update version number in .gemspec within this repo’s root.

2. Then, execute `./develop/release`. This does the following:

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
