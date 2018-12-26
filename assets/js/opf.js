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
        isPinned = false;
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

  var initCollapsibleDocsNav = function(mainRoot, collapsibleHeader) {
    var docsRoot = mainRoot.querySelector('section.documentation');
    var article = docsRoot.querySelector('article');
    var articleHeader = docsRoot.querySelector('header:first-child');
    var docsNav = docsRoot.querySelector('.docs-nav');

    if (!docsNav) { return; }  // Must be docs landing page

    var docsNavItemsContainer = docsNav.querySelector('.nav-items');
    var docsHeader = mainRoot.querySelector('header.documentation-header');

    var hasNav = docsHeader.classList.contains('has-nav');
    var docsHeaderH = docsHeader.offsetHeight - 1;   // 1px to compensate for border


    // Used to offset things from the topmost edge of viewport
    // to account for top header height
    var topHeaderHeight = collapsibleHeader.getHeaderHeight();

    docsRoot.classList.add('with-expandable-toc');
    docsNav.classList.add('top-expandable');

    docsHeader.style.top = '' + topHeaderHeight + 'px';

    docsNavItemsContainer.style.top = '' + (topHeaderHeight + docsHeaderH) + 'px';

    // Triggering opening via header link itself

    var hasOpened = false;

    var collapse = function (docsNav) {
      hasOpened = false;

      docsNav.classList.remove('expanded');
      docsHeader.classList.remove('nav-expanded');
      docsRoot.classList.add('with-collapsed-toc');
    };

    var open = function (docsNav) {
      hasOpened = true;

      docsNav.classList.add('expanded');
      docsHeader.classList.add('nav-expanded');
      docsRoot.classList.remove('with-collapsed-toc');
    };

    var toggle = function () {
      if (hasOpened) { collapse(docsNav); }
      else { open(docsNav); }
    };

    if (hasNav) {
      docsHeader.addEventListener('click', toggle);
      open(docsNav);
    } else {
      collapse(docsNav);
    }


    // Hiding docs nav

    // TODO: Replace with moving this to the top
    // in top header’s headroom hook?
    var headroom = new Headroom(docsHeader, {
      classes: {
        pinned: 'pinned',
        unpinned: 'unpinned',
      },
      onUnpin: function () {
        docsHeader.style.transform = 'translateY(-' + topHeaderHeight + 'px)';
        docsNavItemsContainer.style.top = '' + (docsHeaderH) + 'px';
      },
      onPin: function () {
        docsHeader.style.top = '' + topHeaderHeight + 'px';
        docsHeader.style.transform = 'translateY(0)';
        docsNavItemsContainer.style.top = '' + (topHeaderHeight + docsHeaderH) + 'px';
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

  if (document.querySelector('body.docs-page > main') != null) {
    collapsibleHeader = initCollapsibleHeader(
      document.querySelector('.underlay.header'),
      hamburgerMenu);
  }

  var docsRoot = body.querySelector('body.docs-page > main');
  var collapsibleDocsNav;

  if (docsRoot !== null) {
    collapsibleDocsNav = initCollapsibleDocsNav(docsRoot, collapsibleHeader);
    collapsibleHeader.assignCollapsibleDocsNav(collapsibleDocsNav);
  }

  var docArticleSelectorPrefixes = ['body.docs-page .documentation > article'];

  for (var prefix of docArticleSelectorPrefixes) {
    var docArticleHeaderNavToggle = document.querySelector(prefix + '> header > nav > button.docs-nav-toggle');
    var docArticleFooterNavToggle = document.querySelector(prefix + '> footer > nav > button.docs-nav-toggle');
    for (var el of [docArticleFooterNavToggle, docArticleHeaderNavToggle]) {
      if (el) { el.addEventListener('click', collapsibleDocsNav.toggle); }
    }
  }

  if (triggerEl !== null && inputEl !== null && topMenuEl !== null) {
    initSearchWidget(topMenuEl, triggerEl, inputEl);
  }

  var indexFilterEl = document.querySelector('nav.item-filter');
  if (indexFilterEl !== null) {
    initIndexFilter(indexFilterEl);
  }

}());
