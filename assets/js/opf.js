(function () {
  'use strict';


  var body = document.querySelector('body');



  /* Topmost hamburger menu */

  var initCollapsibleMenu = function(triggerEl, menuEl) {
    var hasOpened = false;

    if (triggerEl != null && menuEl != null) {
      triggerEl.addEventListener('click', function (evt) {
        hasOpened = menuEl.classList.toggle('expanded');
        if (hasOpened) {
          triggerEl.setAttribute('aria-expanded', true);
          menuEl.setAttribute('aria-hidden', false);
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

    article.style.paddingTop = '2em';

    docsNav.classList.add('top-expandable');
    docsNav.style.zIndex = '4';
    docsNav.style.top = '' + topHeaderHeight + 'px';

    docsNavHeader.innerHTML = docsNavHeader.innerHTML + ' ▼';

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
      console.debug(docsNav.style.bottom);

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



  // Initializing stuff
  var hamburgerMenu = initCollapsibleMenu(
    document.getElementById('hamburgerButton'),
    document.getElementById('hamburgerMenu'));

  var collapsibleHeader;

  if (document.querySelector('body.layout--product .documentation:not(.docs-landing)') != null) {
    collapsibleHeader = initCollapsibleHeader(
      document.querySelector('.underlay.header'),
      hamburgerMenu);
  }

  var docsRoot = body.querySelector('body.layout--product .documentation:not(.docs-landing)');
  var collapsibleDocsNav;

  if (docsRoot !== null) {
    collapsibleDocsNav = initCollapsibleDocsNav(docsRoot, collapsibleHeader);
    collapsibleHeader.assignCollapsibleDocsNav(collapsibleDocsNav);
  }

  var docArticleSelectorPrefix = 'body.layout--product .documentation:not(.docs-landing) > article ';
  var docArticleHeaderNavToggle = document.querySelector(docArticleSelectorPrefix + '> header > nav > button.docs-nav-toggle');
  var docArticleFooterNavToggle = document.querySelector(docArticleSelectorPrefix + '> footer > nav > button.docs-nav-toggle');
  for (var el of [docArticleFooterNavToggle, docArticleHeaderNavToggle]) {
    if (el) { i.addEventListener('click', collapsibleDocsNav.toggle); }
  }

}());
