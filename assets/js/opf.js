(function () {
  'use strict';

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
      }
    };
  };

  // Topmost hamburger menu
  var hamburgerMenu = initCollapsibleMenu(
    document.getElementById('hamburgerButton'),
    document.getElementById('hamburgerMenu'));

  // Collapsible header

  var initCollapsibleHeader = function(headerEl, hamburgerMenu) {
    var body = document.querySelector('body');
    var headerElH = headerEl.offsetHeight;
    var headroom = new Headroom(headerEl, {
      onUnpin: function() {
        if (hamburgerMenu.hasOpened()) {
          this.pin();
        }
      }
    });

    headroom.init();

    body.classList.add('with-headroom');
    body.style.paddingTop = '' + headerElH + 'px';
  };

  var body = document.querySelector('body');
  if (body.classList.contains('layout--product')) {
    initCollapsibleHeader(
      document.querySelector('.underlay.header'),
      hamburgerMenu);
  }
}());
