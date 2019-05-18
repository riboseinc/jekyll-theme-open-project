(function () {

  const listings = document.querySelectorAll('main .listingblock pre');
  const buttonHint = 'Copy code to clipboard';

  for (let el of listings) {
    let copyBtn = document.createElement('button');
    copyBtn.innerHTML = '<i class="fas fa-copy"></i>';
    copyBtn.setAttribute('aria-label', buttonHint);
    copyBtn.setAttribute('title', buttonHint);
    copyBtn.classList.add('listing-clipboard-button');
    el.parentNode.insertBefore(copyBtn, el);
  }

  new ClipboardJS(document.querySelectorAll('button.listing-clipboard-button'), {
    target: function (triggerEl) { return triggerEl.nextElementSibling; },
  });

}());
