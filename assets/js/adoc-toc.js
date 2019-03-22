(function () {

  const HEADER_TAGS = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
  const IN_PAGE_NAV_HTML_CLASS = 'in-page-toc';
  const SCROLLABLE_NAV_CONTAINER_SELECTOR = 'ul.nav-items';

  /* Given a container of AsciiDoc .sectN elementss,
   * returns an object containing navigation structure like this:
   * { items: [ { title: "Some title", path: "./#some-title", items: [ ...subitems ] }, ... }
   * Works recursively through nested sections.
   */
  function getAdocTocItems(containerEl, sectLvl) {
    sectLvl = sectLvl || 1;
    var items = [];

    const topLevelSections = Array.from(containerEl.children).filter((el) => {
      return el.matches(`div.sect${sectLvl}`);
    });

    for (let sectionEl of topLevelSections) {
      const headerEl = Array.from(sectionEl.children).filter((el) => {
        for (let hTagName of HEADER_TAGS) {
          if (el.matches(hTagName)) { return true; }
        }
        return false;
      })[0];
      const headerId = headerEl.getAttribute('id');

      var subItems = [];
      const sectionBody = sectionEl.querySelector('div.sectionbody');
      if (sectionBody) {
        subItems = getAdocTocItems(sectionBody, sectLvl + 1);
      } else {
        subItems = getAdocTocItems(sectionEl, sectLvl + 1);
      }

      items.push({
        title: headerEl.innerText,
        description: headerEl.innerText,
        path: `./#${headerId}`,
        items: subItems,

        id: headerId,
      });
    }

    return items;
  }

  function highlightSelected(headerId, itemPath) {
    let selectedItemEl;

    for (const itemEl of document.querySelectorAll(`.${IN_PAGE_NAV_HTML_CLASS} li`)) {
      const link = (itemEl.firstChild || {}).firstChild;
      if (link && link.getAttribute('href') == itemPath) {
        itemEl.classList.add('highlighted');
        selectedItemEl = itemEl;
      } else {
        itemEl.classList.remove('highlighted');
      }
    }
    for (const hTag of HEADER_TAGS) {
      for (const headerEl of document.querySelectorAll(hTag)) {
        headerEl.classList.remove('highlighted');
      }
    }
    const selectedHeaderEl = document.getElementById(headerId);
    selectedHeaderEl.classList.add('highlighted');

    return selectedItemEl;
  }

  /* Given a list of navigation items, returns an <ul> containing items recursively
   * with CSS classes and layout consistent with docs navigation markup expected by the theme.
   */
  function formatSubItems(tocItems) {
    const subItemContainer = document.createElement('ul');

    subItemContainer.classList.add('nav-items');
    subItemContainer.classList.add('subitems');

    for (let item of tocItems) {
      let itemEl, itemTitleEl, itemLinkEl;

      itemEl = document.createElement('li');
      itemEl.classList.add('item');

      itemTitleEl = document.createElement('div');
      itemTitleEl.classList.add('item-title');

      itemLinkEl = document.createElement('a');
      itemLinkEl.setAttribute('href', item.path);
      itemLinkEl.setAttribute('title', item.title);
      itemLinkEl.innerText = item.title;

      itemTitleEl.appendChild(itemLinkEl);
      itemEl.appendChild(itemTitleEl);

      if (item.items.length > 0) {
        itemEl.appendChild(formatSubItems(item.items));
      }

      itemLinkEl.addEventListener('click', () => highlightSelected(item.id, item.path));

      subItemContainer.appendChild(itemEl);
    }

    return subItemContainer;
  }

  const articleBody = document.querySelector('main section article .body');
  const selectedItem = document.querySelector('main .docs-nav .nav-items li.selected');

  if (articleBody && selectedItem) {
    const items = getAdocTocItems(articleBody);

    if (items.length > 0) {
      const ulEl = formatSubItems(items);
      ulEl.classList.add(IN_PAGE_NAV_HTML_CLASS);

      const existingSubItems = selectedItem.querySelector('ul.nav-items');
      if (existingSubItems) {
        selectedItem.insertBefore(ulEl, existingSubItems);
      } else {
        selectedItem.appendChild(ulEl);
      }
    }
  }

  if (articleBody && window.location.hash) {
    // Do things that need to be done if the page was opened
    // with hash component in address bar.
    // - After initial scroll to anchor, scroll up a bit
    //   to ensure header is in view accounting for top bar.
    // - Select in-page doc nav item corresponding to the hash.

    const SCROLL_COMPENSATION_AMOUNT_PX = 0 - document.querySelector('body > .underlay.header > header').offsetHeight - 10;

    function _scrollUp(evt) {
      window.scrollBy(0, SCROLL_COMPENSATION_AMOUNT_PX);
      window.removeEventListener('scroll', _scrollUp);
    };

    function _selectInitialItem() {
      const hash = window.location.hash.substring(1);
      const anchorEl = document.getElementById(hash);

      var selectedLinkId;

      if (anchorEl.tagName === 'A') {
        // We were selected by <a> anchor, not by <hX[id]>.
        // We want to highlight selected item in the nav
        // according to the nearest header upwards from anchor.
        var curEl = anchorEl;
        while (true) {
          var curEl = curEl.parentNode;
          var nearestHeaderEl = curEl.querySelector('h2');
          if (nearestHeaderEl && nearestHeaderEl.hasAttribute('id')) {
            selectedLinkId = nearestHeaderEl.getAttribute('id');
            break;
          }
        }
      } else {
        selectedLinkId = hash;
      }

      const selectedItemEl = highlightSelected(selectedLinkId, `./#${selectedLinkId}`);
      window.setTimeout(function () { selectedItemEl.scrollIntoView(); }, 200);
    };

    _selectInitialItem();
    window.addEventListener('scroll', _scrollUp);
  }

}());
