(function () {
  'use strict';

  var hamBtn = document.getElementById('hamburgerButton');
  var hamMnu = document.getElementById('hamburgerMenu');
  var hasOpened = false;

  hamBtn.addEventListener('click', function (evt) {
    hasOpened = hamMnu.classList.toggle('expanded');
    if (hasOpened) {
      hamBtn.setAttribute('aria-expanded', true);
      hamMnu.setAttribute('aria-hidden', false);
    }
  });
}());
