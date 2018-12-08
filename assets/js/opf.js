(function () {
  'use strict';


  var body = document.querySelector('body');

  // TODO: Best way (preferably w/o Node) to split these across files 
  // and concatenate/minify the result on Jekyll build?



  /* Search box in top bar */

  var initSearchWidget = function(containerEl, triggerEl, inputEl) {
    var showSearch = function() {
      containerEl.classList.add('with-expanded-search');
      inputEl.focus();
    };
    var hideSearch = function() {
      containerEl.classList.remove('with-expanded-search');
    };
    triggerEl.addEventListener('click', showSearch);

    window.initAlgolia();
  };



  var topMenuEl = body.querySelector('.top-menu');
  var triggerEl = topMenuEl.querySelector('.search');
  var inputEl = topMenuEl.querySelector('input[type=search]');



  /* Topmost hamburger menu */

  var initCollapsibleMenu = function(origNavEl, triggerEl, menuEl) {
    var hasOpened = false;
    var origNavNextSiblingEl = origNavEl.nextSibling;

    if (triggerEl != null && menuEl != null) {
      triggerEl.addEventListener('click', function (evt) {
        hasOpened = menuEl.classList.toggle('expanded');
        if (hasOpened) {
          triggerEl.setAttribute('aria-expanded', true);
          menuEl.setAttribute('aria-hidden', false);
          origNavEl.classList.remove('top-menu');
          origNavEl.remove();
          menuEl.insertBefore(origNavEl, menuEl.querySelector('.site-logo-container').nextSibling);
        } else {
          origNavEl.remove();
          origNavNextSiblingEl.parentNode.insertBefore(origNavEl, origNavNextSiblingEl);
          origNavEl.classList.add('top-menu');
        }
      });
    }

    return {
      hasOpened: function() {
        return hasOpened;
      },
    };
  };



  /* Collapsible header */

  var initCollapsibleHeader = function(headerEl, hamburgerMenu) {
    var collapsibleDocsMenu;
    var body = document.querySelector('body');
    var headerElH = headerEl.offsetHeight;
    var isPinned;

    body.style.paddingTop = '' + headerElH + 'px';

    var headroom = new Headroom(headerEl, {
      onUnpin: function() {
        if (hamburgerMenu.hasOpened() || (collapsibleDocsMenu && collapsibleDocsMenu.hasOpened())) {
          this.pin();
        } else {
          isPinned = false;
        }
      },
      onPin: function() {
        isPinned = true;
      },
    });

    headroom.init();

    body.style.paddingTop = '' + headerElH + 'px';
    body.classList.add('with-headroom');

    return {
      getHeaderHeight: function () {
        return headerElH;
      },
      assignCollapsibleDocsNav: function (nav) {
        collapsibleDocsMenu = nav;
      },
      isPinned: function () {
        return isPinned;
      },
    }
  };



  /* Collapsible docs nav */

  var initCollapsibleDocsNav = function(docsRoot, collapsibleHeader) {
    var article = docsRoot.querySelector('article');
    var articleHeader = article.querySelector('header:first-child');
    var docsNav = docsRoot.querySelector('.docs-nav');
    var docsNavHeader = docsNav.querySelector('.sidebar-header');
    var docsNavHeaderLink = docsNavHeader.querySelector('a');
    var docsNavHeaderH = docsNavHeader.offsetHeight + 20; // 20px is padding, below
    var docsNavH = docsNav.offsetHeight;
    var docsNavSections = docsNav.querySelectorAll('section');

    // Used to offset expandable documentation menu from the topmost edge of viewport
    // to account for top header height
    var topHeaderHeight = collapsibleHeader.getHeaderHeight();

    docsRoot.classList.add('with-expandable-toc');
    docsNav.classList.add('top-expandable');

    docsNav.style.top = '' + topHeaderHeight + 'px';
    docsNavSections.forEach(function (el) {
      el.style.transition = 'opacity .2s cubic-bezier(0.23, 1, 0.32, 1)';
    });

    // Triggering opening via header link itself

    var hasOpened = false;
    var closingTransition;

    var collapse = function (docsNav) {
      hasOpened = false;

      docsNav.classList.remove('expanded');

      docsNavSections.forEach(function (el) {
        el.style.opacity = '0';
      });

      closingTransition = window.setTimeout(function () {
        docsNav.style.height = '' + docsNavHeaderH + 'px';
        docsNav.style.bottom = 'unset';
        docsNav.scrollTop = 0;
      }, 2);
    };
    var open = function (docsNav) {
      hasOpened = true;
      window.clearTimeout(closingTransition);

      docsNav.classList.add('expanded');
      docsNav.style.height = 'auto';
      docsNav.style.bottom = '' + 100 + 'px';

      docsNavSections.forEach(function (el) {
        el.style.opacity = '1';
      });
    };
    var toggle = function () {
      if (hasOpened) { collapse(docsNav); }
      else { open(docsNav); }
    };
    docsNavHeader.addEventListener('click', toggle);

    collapse(docsNav);

    // Hiding docs nav

    // TODO: Replace with moving this to the top
    // in top header’s headroom hook?
    var headroom = new Headroom(docsNavHeader, {
      classes: {
        pinned: 'pinned',
        unpinned: 'unpinned',
      },
      onUnpin: function () {
        if (hasOpened) {
          this.pin();
        } else {
          docsNav.style.transform = 'translateY(-' + topHeaderHeight + 'px)';
        }
      },
      onPin: function () {
        docsNav.style.top = '' + topHeaderHeight + 'px';
        docsNav.style.transform = 'translateY(0)';
      },
    });

    headroom.init();

    return {
      hasOpened: function () {
        return hasOpened;
      },
      toggle: toggle,
    }
  };



  /* Software/spec index filter bar */

  var initIndexFilter = function(filterBar) {
    var namespaces = filterBar.querySelectorAll('.namespace');

    var updateScrolledStatus = function (evt) {
      if (!evt.target.classList) { return; }

      if (evt.target.scrollLeft > 0) {
        evt.target.classList.add('scrolled');
      } else {
        evt.target.classList.remove('scrolled');
      }
    };

    // Mark empty namespaces
    for (let nsEl of namespaces) {
      if (nsEl.querySelector('ul.tags > li') === null) {
        nsEl.classList.add('empty');
      }
    }

    // Update styling on tag bar on scroll
    for (let tags of filterBar.querySelectorAll('ul.tags')) {
      tags.addEventListener('scroll', updateScrolledStatus);
    }
  };



  // Initializing stuff
  var hamburgerMenu = initCollapsibleMenu(
    document.querySelector('header nav.top-menu'),
    document.getElementById('hamburgerButton'),
    document.getElementById('hamburgerMenu'));

  var collapsibleHeader;

  if (document.querySelector('body.layout--product .documentation:not(.docs-landing), body.layout--spec .documentation:not(.docs-landing)') != null) {
    collapsibleHeader = initCollapsibleHeader(
      document.querySelector('.underlay.header'),
      hamburgerMenu);
  }

  var docsRoot = body.querySelector('body.layout--product .documentation:not(.docs-landing), body.layout--spec .documentation:not(.docs-landing)');
  var collapsibleDocsNav;

  if (docsRoot !== null) {
    collapsibleDocsNav = initCollapsibleDocsNav(docsRoot, collapsibleHeader);
    collapsibleHeader.assignCollapsibleDocsNav(collapsibleDocsNav);
  }

  var docArticleSelectorPrefix = 'body.layout--product .documentation:not(.docs-landing) > article ';
  var docArticleHeaderNavToggle = document.querySelector(docArticleSelectorPrefix + '> header > nav > button.docs-nav-toggle');
  var docArticleFooterNavToggle = document.querySelector(docArticleSelectorPrefix + '> footer > nav > button.docs-nav-toggle');
  for (var el of [docArticleFooterNavToggle, docArticleHeaderNavToggle]) {
    if (el) { el.addEventListener('click', collapsibleDocsNav.toggle); }
  }

  if (triggerEl !== null && inputEl !== null && topMenuEl !== null) {
    initSearchWidget(topMenuEl, triggerEl, inputEl);
  }

  var indexFilterEl = document.querySelector('nav.item-filter');
  if (indexFilterEl !== null) {
    initIndexFilter(indexFilterEl);
  }

}());
