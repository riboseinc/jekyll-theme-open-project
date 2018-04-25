# Open Project theme by Ribose

Open Project is a theme for Jekyll oriented towards presenting open efforts
such as open-source software and specifications in a navigable and elegant way.

Open Project fits two types of sites:
that describe one individual project, and that combine projects into a hub.


## Starting a site based on gem-based theme

### Getting started with Ruby

If you aren’t using Ruby often, the recommended way to install it is with RVM.
Refer to RVM docs and use it to install a reasonably fresh Ruby version,
let’s say 2.4.4.

### Start new Jekyll site

jekyll new my-open-hub

### Installing theme

Add this line to your Jekyll site's `Gemfile`,
replacing default theme requirement:

```ruby
gem 'jekyll-theme-open-hub'
```

Add this line to your Jekyll site's `_config.yml`,
replacing default theme requirement:

```yaml
theme: jekyll-theme-open-hub
```

(Default theme is “minima” at the time of this writing.)

Execute to install dependencies:

    $ bundle

### Setting up pages

You may want to remove the default about.md page (theme does not account
for its existence).

Create _pages directory and put in there pages for blog, software
index, and specification index. Layouts to use are correspondingly
`blog-index`, `software-index`, and `spec-index`.

Example page frontmatter:

```yaml
---
title: Software
description: Open-source software developed with our company’s cooperation.
layout: software-index
hero_include: index-page-hero.html
---
```

### Configuring site

Depending on the type of site, copy _config-hub.yml or _config-project.yml
into main _config.yml of Jekyll installation. Edit that file to add necessary
site-wide configuration options, and add necessary files and folders to site contents.

Below sections explain core concepts of open project and hub, and go
into detail about how to configure a project or hub site.

### Building site

Execute to build the site:

    $ bundle exec jekyll serve --host mysite.local --port 4000


## Describing a project: shared data structure

Each project is expected to have a machine-readable and unique name, a title,
a description, a symbol, and one or more software products and/or specs.

Following data structure is shared and used to describe projects,
whether on hub home site or each individual project site:

    - <project-name>/
      - _includes/
        - symbol.svg
      - _software/
        - <name>.md
      - _specs/
        - <name>.md

### Software and specs

An open project serves as an umbrella for related
software products and/or specifications.

Each product or spec is described by its own <name>.md file with frontmatter,
placed under _software/ or _specs/ subdirectory, respectively,
of your open project’s Jekyll site.

Note: even though they’re in different subdirectories, all software products and specs
within one project share URL namespace and hence must have unique names.

### Software product

YAML frontmatter specific to software:

```yaml
version: v1.2.3
docs_url: https://foobar.readthedocs.io/en/latest
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
```

Specs that are not hosted elsewhere (such as ietf.org for RFCs)
are expected to contain the actual specification content after frontmatter.
Start with second-level header (##).

### Symbol

Symbol should be in SVG format, have equal height and width,
and look OK with height under 30px.
Place the symbol in _includes/symbol.svg within project directory.


## Generic site

### Blog

Both project site and hub site have blogs. Place posts under _posts
and named files e.g. `2018-04-20-welcome-to-jekyll.markdown`.

### Logo

Logo consists of a symbol and site name.

Both should look OK when placed in a 30px container.

Symbol: should have equal height and width. Should look OK with height under 30px.
Should be in SVG format. Place the symbol in _includes/symbol.svg.
See also SVG guidelines.

Site name: 1-3 words displayed to the right of the symbol.
By default, the title you define in site config is used.
Alternatively, you can place site name in _includes/title.html with custom HTML
or even SVG (same SVG guidelines apply).

### Legal small text

You may want to supply _includes/legal.html with content like this:

```html
<span class="copyright">Copyright © 2018 Example. All rights reserved.</span>
<nav>
  <a href="https://www.example.com/tos">Terms</a>
  <a href="https://www.example.com/privacy">Privacy</a>
</nav>
```


## Hub site

The hub represents your company or department.

### Projects, software and specs

See above section about project data structure.

When used within hub site, each project is expected to contain directly inside
project directory a file index.md with following frontmatter:

```yaml
title: Sample Awesome Project

description: >-
  A sentence or two go here.

# Whether the project is included in the three projects on hub home page
featured: true | false

home_url: <URL to standalone project site>
```


## Project site

When project is set up as a standalone site, _config.yml should include
"title" and "description", corresponding to project’s information.

Otherwise file layout is the same as described in the section
about shared project data structure.


## SVG format guidelines

- Ensure SVG markup does not use IDs. It may appear multiple times
on the page hence IDs would fail markup validation.

- Ensure root <svg> element specifies its viewBox,
but no width or height attributes.

- You can style SVG shapes using in site’s assets/css/style.scss.


## Content guidelines

- Project title: 1-3 words, capital case
- Project feature description: about 20-24 words, no markup
- Project, software, spec regular description: about 12 words, no markup
- Post title: 3–7 words
- Post excerpt: about 20–24 words, no markup


## TODO: Note on shared data

In the long run it is recommended to avoid maintaining two separate copies
of data (e.g., same project data for project site, and one for parent hub site,
or reposting posts from project site blogs into hub blog).

Ideally, during static site build the automation would pull relevant data
from a centralized or distributed source and place it as needed
inside Jekyll site structure before executing `jekyll build`.


## Contributing

Bug reports and pull requests are welcome on GitHub
at https://github.com/riboseinc/openproject-theme.

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## Theme development

This directory is setup just like a Jekyll site.

To set up your environment to develop this theme, run `bundle install`.

To experiment with this code, add some sample content
and run `bundle exec jekyll serve`.

This starts a Jekyll server using your theme at `http://localhost:4000`. 

Put your layouts in `_layouts`, your includes in `_includes`,
your sass files in `_sass` and any other assets in `assets`.

Add pages, documents, data, etc. like normal to test your theme's contents.

As you make modifications to your theme and to your content, your site will
regenerate and you should see the changes in the browser after a refresh,
like normal.

When your theme is released, only the files in `_layouts`, `_includes`,
`_sass` and `assets` tracked with Git will be bundled.
To add a custom directory to your theme-gem, please edit the regexp in
`openhub.gemspec` accordingly.


## License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
