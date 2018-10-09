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
  }

  // Topmost hamburger menu
  initCollapsibleMenu(
    document.getElementById('hamburgerButton'),
    document.getElementById('hamburgerMenu'));
}());
