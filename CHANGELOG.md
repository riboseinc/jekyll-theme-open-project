# Changelog

## 1.1.3

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
