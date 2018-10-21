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

  var hamburgerMenu = initCollapsibleMenu(
    document.getElementById('hamburgerButton'),
    document.getElementById('hamburgerMenu'));



  /* Collapsible header */

  var initCollapsibleHeader = function(headerEl, hamburgerMenu) {
    var collapsibleDocsMenu;
    var body = document.querySelector('body');
    var headerElH = headerEl.offsetHeight;

    body.style.paddingTop = '' + headerElH + 'px';

    var headroom = new Headroom(headerEl, {
      onUnpin: function() {
        if (hamburgerMenu.hasOpened() || (collapsibleDocsMenu && collapsibleDocsMenu.hasOpened())) {
          this.pin();
        }
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
    }
  };

  var collapsibleHeader;

  if (document.querySelector('body.layout--product .documentation:not(.docs-landing)') != null) {
    collapsibleHeader = initCollapsibleHeader(
      document.querySelector('.underlay.header'),
      hamburgerMenu);
  }



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

    var offset = collapsibleHeader.getHeaderHeight();

    docsNav.style.zIndex = '4';
    docsNav.style.position = 'fixed';
    docsNav.style.top = '' + offset + 'px';
    docsNav.style.left = '0';
    docsNav.style.right = '0';
    docsNav.style.paddingTop = '0';
    docsNav.style.paddingLeft = '2em';
    docsNav.style.paddingRight = '2em';
    docsNav.style.transition = 'background .2s cubic-bezier(0.23, 1, 0.32, 1), top 200ms linear';
    docsNav.style.background = 'transparent';
    docsNav.style.overflow = 'hidden';
    docsNav.style.boxShadow = '0 0 10px 10px white';

    docsNavHeader.style.background = 'white';
    docsNavHeader.style.paddingTop = '10px';
    docsNavHeader.style.paddingBottom = '10px';

    docsNavSections.forEach(function (el) {
      el.style.transition = 'opacity .2s cubic-bezier(0.23, 1, 0.32, 1)';
    });

    // Triggering opening via header link itself

    var hasOpened = false;
    var closingTransition;

    var collapse = function (docsNav) {
      hasOpened = false;
      docsNav.style.background = 'transparent';
      docsNavSections.forEach(function (el) {
        el.style.opacity = '0';
      });

      closingTransition = window.setTimeout(function () {
        docsNav.style.overflowY = 'hidden';
        docsNav.style.height = '' + docsNavHeaderH + 'px';
        docsNav.style.bottom = 'unset';
        docsNav.scrollTop = 0;
      }, 200);
    };
    var open = function (docsNav) {
      hasOpened = true;
      window.clearTimeout(closingTransition);

      docsNav.style.overflowY = 'scroll';
      docsNav.style.height = 'auto';
      docsNav.style.bottom = '0';
      docsNav.style.background = 'white';
      docsNavSections.forEach(function (el) {
        el.style.opacity = '1';
      });
    };
    docsNavHeaderLink.addEventListener('click', function (e) {
      if (hasOpened) { collapse(docsNav); }
      else { open(docsNav); }
      e.preventDefault();
      return true;
    });

    collapse(docsNav);

    // Hiding docs nav

    // TODO: Replace with moving this to the top
    // in top header’s headroom hook
    var headroom = new Headroom(docsNavHeader, {
      onUnpin: function () {
        if (hasOpened) {
          this.pin();
        } else {
          docsNav.style.top = '0';
          docsNav.style.zIndex = '0';
        }
      },
      onPin: function () {
        console.debug('pin');
        docsNav.style.top = '' + offset + 'px';
        docsNav.style.zIndex = '4';
      },
      onTop: function () {
      },
    });

    headroom.init();

    return {
      hasOpened: function () {
        return hasOpened;
      },
    }
  };

  var docsRoot = body.querySelector('body.layout--product .documentation:not(.docs-landing)');
  var collapsibleDocsNav;

  if (docsRoot !== null) {
    collapsibleDocsNav = initCollapsibleDocsNav(docsRoot, collapsibleHeader);
    collapsibleHeader.assignCollapsibleDocsNav(collapsibleDocsNav);
  }


}());
