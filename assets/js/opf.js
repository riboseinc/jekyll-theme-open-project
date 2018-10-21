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
    var headroom = new Headroom(headerEl, {
      onUnpin: function() {
        if (hamburgerMenu.hasOpened() || (collapsibleDocsMenu && collapsibleDocsMenu.hasOpened())) {
          this.pin();
        } else {
          body.style.paddingTop = '0';
        }
      },
      onPin: function() {
        body.style.paddingTop = '' + headerElH + 'px';
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

    var offset = collapsibleHeader.getHeaderHeight();

    docsNav.style.zIndex = '4';
    docsNav.style.position = 'fixed';
    docsNav.style.top = '' + offset + 'px';
    docsNav.style.left = '0';
    docsNav.style.right = '0';
    docsNav.style.paddingTop = '0';
    docsNav.style.paddingLeft = '2em';
    docsNav.style.paddingRight = '2em';
    docsNav.style.transition = 'height .8s cubic-bezier(0.23, 1, 0.32, 1), top 200ms linear';

    docsNavHeader.style.background = 'white';
    docsNavHeader.style.paddingTop = '10px';
    docsNavHeader.style.paddingBottom = '10px';

    // Triggering opening via header link itself

    var hasOpened = false;

    var collapse = function (docsNav) {
      docsNav.style.overflow = 'hidden';
      docsNav.style.height = '' + docsNavHeaderH + 'px';
      docsNav.style.bottom = 'auto';
      hasOpened = false;
    };
    var open = function (docsNav) {
      docsNav.style.overflowY = 'scroll';
      docsNav.style.height = 'auto';
      docsNav.style.bottom = '0';
      docsNav.style.background = 'white';
      hasOpened = true;
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
