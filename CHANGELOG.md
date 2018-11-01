# Changelog

## 1.1.22

- Started marking external links within main site contents

## 1.1.21

- Better support for AsciiDoc-rendered HTML in site contents

- Added tag-based filtering for software & spec indexes on project sites

- Fixed an issue where ordering of software by last modification timestamp
  was messed up when timestamp was not present on some packages

## 1.1.20

- Fixed a regression introduced in previous version
  that caused cards from hub site software & spec indexes to not link
  to their pages on corresponding project sites, 404’ing instead.

## 1.1.19

Improved software and spec indexes on both hub and project sites:

- Order software and specs by last update timestamp, descending

- Highlight featured software and specs

- Show featured software/specs first in corresponding index listing on project sites

## 1.1.18

Updated layout of landing pages for both project and hub sites.

- Fixed issues with inelegant whitespace

- Hero unit look updated overall, is now more compact

- Now showing featured items as a grid

## 1.1.17

Fixed an issue with code listings not always being horizontally scrollable,
in those cases causing layout of documentation pages to exceed screen width.

Added favicon to base page meta (sites are expected to provide
`/assets/favicon.png` and `/assets/webclip.png` now).

Made top header collapse on scroll for better readability on smaller screens.
Made documentation ToC collapsible as well.

**BREAKING**: Navigation block on documentation pages has changed its
selector from .nav-sidebar to .docs-nav; sites customizing that have to
update the selector in HTML/CSS.


## 1.1.16

Improved formatting of code snippets, lists, tables and admonition blocks.

## 1.1.14-15

Incremental improvements to content presentation & formatting:

- More consistent formatting of code snippets in docs and elsewhere on the site

- Nicer styling of tables in article bodies

- Whitespace consistency here and there

- Better formatting of TBD labels

## 1.1.13

- More consistent formatting of code snippets in docs and elsewhere on the site

- Fixed a problem with fetched software documentation not always being rendered
  as part of project site

## 1.1.12

- Some changes in SASS structure aimed to improve customizability
  of Open Project framework-based site UIs

## 1.1.11

- Even faster processing when `refresh_remote_data` is set to 'skip'

- More flexible customization means for sites using the OP framework

- Layout improvements across screen widths

- Minor documentation page layout & content formatting improvements

## 1.1.10

### Synchronized versions & centralized change log

- Each theme version will require (in its gemspec) the exact helpers library version

- Theme’s CHANGELOG will reflect the development of Open Project framework
  regardless of whether the actual changes belong to theme or helpers gem

### Fixes to multi-site data integration

- A few issues in data-fetching logic were fixed, now certain edge cases (such as missing
  software docs) are handled better and (re)generation of sites,
  especially for projects with many software packages and for project hubs,
  should be faster on average.

- Site’s `_config.yml` now supports optional string flag `refresh_remote_data`
  with three possible values: 'always', 'last-resort' (default), and 'skip'.

  - The default 'last-resort' choice means site build will attempt to fetch remote data
    (such as last software update timestamp, software docs, hub logos, etc.)
    when there is no local copy.
  
  - 'always' may be helpful during development if you have a local copy from previous build,
    but the remote data has changed and you want your local sites to reflect that.
  
  - 'skip' will always leave local data intact and not attempt to contact remote repositories,
    which would speed up regeneration during debugging or development
    where you know you have a local copy alreay fetched as needed
    (otherwise it’s likely going to break your build).

## 1.1.9

Build-related fix:

- Correct ``exclude`` to ensure hub site doesn’t try to build software docs

Software documentation improvements:

- Fixes to hosted (‘internal’) documentation page layout

- Slightly more expressive formatting on documentation pages (highlighting “tip” blocks)

- Improvements to how external documentation links are shown

Various fixes and improvements:

- Make hamburger menu script external to facilitate CSP policy implementation

- Minor changes to layout & default copy

- Remove redundant ARIA role definition from presentational divs

## 1.1.8

- Minor improvements to layout & default copy phrasing here and there

- Correct ``excludes`` in default ``_config.yml`` definition in the theme
  to prevent Jekyll from trying to build what shouldn’t be built

## 1.1.7

Improved documentation layout:

- Show external link markers

- Fix an issue with “Documentation” header shown on item docs landing
  even if no documentation pages exist

Bugfixes:

- Show tags in human-readable form (with underscores replaced to spaces)
  on software & spec cards


## 1.1.6

Much improved documentation layout:

- Docs landing page features commonly used external links
  (external API reference docs, repository, IETF datatracker, etc.)
  more prominently

- Fixed how code samples are shown in documentation pages

- Fixed documentation page layout issues on narrower screens

## 1.1.5

A couple of layout tweaks:

- Preserve clickability of active item in top menu
- Make software documentation/spec page layout fit narrow screens

## 1.1.4

- A few improvements to sites’ layout on narrow screens

## 1.1.3

- A few appearance updates, including more elegant layout
  and hamburger menu on narrower screens.

## 1.1.2

- Fixed an issue preventing hub site build if child project sites’
  SCSS imported files from outside the assets directory

## 1.1.1

- Fixed an issue breaking Jekyll build on sites which do not have
  a scripts.html include

## 1.1.0

Minor features:

- Update default layout to allow sites plug custom JS via scripts.html include
- Add an ID to default `<link>` element (allows sites to change
  the stylesheet from a script for custom theming)

Other changes:

- Changed site type and layout classes added on `<body>` by the theme,
  aiming to make the selectors more explicit and clear.

  **BREAKING:** This breaks custom styling on sites where it relies
  on old-style `body.layout-layoutname`, `body.hub`, `body.project` selectors.

  Corresponding new selectors would be
  `body.layout--layoutname`, `body.site--hub`, `body.site--project`.

## 1.0.10

- Implemented optional key `feature_with_priority` for software and specs (#28)
- Added CHANGELOG
