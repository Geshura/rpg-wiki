// Wikipedia-like in-page TOC: build from headings on the current page and add scrollspy
document.addEventListener('DOMContentLoaded', function () {
  const container = document.createElement('aside');
  container.id = 'inline-toc';
  container.setAttribute('aria-label', 'Spis treści');

  const article = document.querySelector('main, .md-content, .md-main__inner, #main');
  if (!article) return; // no content area found

  // collect headings (exclude h1)
  const headings = Array.from(article.querySelectorAll('h2, h3, h4'));
  if (headings.length === 0) return; // nothing to show

  function slugify(text) {
    return text.toLowerCase().trim().replace(/[^a-z0-9ąćęłńóśżź]+/g, '-').replace(/^-+|-+$/g, '');
  }

  // ensure ids
  headings.forEach(h => {
    if (!h.id) h.id = slugify(h.textContent || 'section');
  });

  // build nested list
  const rootUl = document.createElement('ul');
  rootUl.className = 'inline-toc-root';
  let stack = [{level: 2, ul: rootUl}];

  headings.forEach(h => {
    const level = parseInt(h.tagName.substring(1), 10);
    const li = document.createElement('li');
    const a = document.createElement('a');
    a.href = '#' + h.id;
    a.textContent = h.textContent;
    a.className = 'inline-toc-link';
    li.appendChild(a);

    let last = stack[stack.length - 1];
    if (level > last.level) {
      // create nested ul
      const newUl = document.createElement('ul');
      last.ul.lastElementChild && last.ul.lastElementChild.appendChild(newUl);
      stack.push({level: level, ul: newUl});
      newUl.appendChild(li);
    } else {
      while (stack.length && level < stack[stack.length - 1].level) stack.pop();
      if (level !== stack[stack.length - 1].level) {
        stack.push({level: level, ul: stack[stack.length - 1].ul});
      }
      stack[stack.length - 1].ul.appendChild(li);
    }
  });

  // title and insert
  const title = document.createElement('div');
  title.className = 'inline-toc-title';
  title.textContent = 'Spis treści';
  container.appendChild(title);
  container.appendChild(rootUl);

  // insert after first h1 or at top of article
  const firstH1 = article.querySelector('h1');
  if (firstH1 && firstH1.parentElement) firstH1.parentElement.insertBefore(container, firstH1.nextSibling);
  else article.insertBefore(container, article.firstChild);

  // scrollspy: highlight link for current section
  const links = Array.from(container.querySelectorAll('a.inline-toc-link'));
  const headingTops = headings.map(h => ({id: h.id, top: h.getBoundingClientRect().top + window.scrollY}));

  function onScroll() {
    const scrollPos = window.scrollY + 10; // small offset
    let currentId = headingTops[0].id;
    for (let i = 0; i < headingTops.length; i++) {
      if (scrollPos >= headingTops[i].top) currentId = headingTops[i].id;
      else break;
    }
    links.forEach(a => a.classList.toggle('toc-active', a.hash === '#' + currentId));
  }

  window.addEventListener('scroll', onScroll, {passive: true});
  window.addEventListener('resize', () => {
    headingTops.forEach(ht => {
      const el = document.getElementById(ht.id);
      ht.top = el.getBoundingClientRect().top + window.scrollY;
    });
    onScroll();
  });

  // initial highlight
  onScroll();

  // smooth behavior for anchor clicks
  container.addEventListener('click', function (e) {
    if (e.target.tagName === 'A') {
      e.preventDefault();
      const id = e.target.getAttribute('href').substring(1);
      const el = document.getElementById(id);
      if (el) el.scrollIntoView({behavior: 'smooth', block: 'start'});
      history.replaceState(null, '', '#' + id);
    }
  });
});

  toggle.addEventListener('click', function () {
    const hidden = contentDiv.hasAttribute('hidden');
    if (hidden) {
      contentDiv.removeAttribute('hidden');
      toggle.setAttribute('aria-expanded', 'true');
      if (!contentDiv.innerHTML.trim()) loadTOC();
    } else {
      contentDiv.setAttribute('hidden', '');
      toggle.setAttribute('aria-expanded', 'false');
    }
  });

  // Load small TOC on first open; optionally preload after short delay
  setTimeout(() => { if (!contentDiv.innerHTML.trim()) loadTOC(); }, 500);
});
