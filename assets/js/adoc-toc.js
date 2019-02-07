(function () {

  const HEADER_TAGS = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

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
          if (el.matches(hTagName)) {
            return true;
          }
        }
        return false;
      })[0];

      var subItems = [];
      const sectionBody = sectionEl.querySelector('div.sectionbody');
      if (sectionBody) {
        subItems = getAdocTocItems(sectionBody, sectLvl + 1);
      } else {
        subItems = getAdocTocItems(sectionEl, sectLvl + 1);
      }

      items.push({
        title: headerEl.innerText,
        path: `./#${headerEl.getAttribute('id')}`,
        items: subItems,
      });
    }

    return items;
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
      itemLinkEl.innerText = item.title;

      itemTitleEl.appendChild(itemLinkEl);
      itemEl.appendChild(itemTitleEl);

      if (item.items.length > 0) {
        itemEl.appendChild(formatSubItems(item.items));
      }

      subItemContainer.appendChild(itemEl);
    }

    return subItemContainer;
  }

  const articleBody = document.querySelector('main section article .body');
  const selectedItem = document.querySelector('main .docs-nav .nav-items .item.selected');

  if (articleBody && selectedItem) {
    const items = getAdocTocItems(articleBody);
    const ulEl = formatSubItems(items);
    ulEl.classList.add('in-page-toc');

    const existingSubItems = selectedItem.querySelector('ul.nav-items');
    if (existingSubItems) {
      selectedItem.insertBefore(ulEl, existingSubItems);
    } else {
      selectedItem.appendChild(ulEl);
    }
  }

}());
