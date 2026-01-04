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

  // Sidebar tree TOC built from `docs/spis_tresci` (rendered HTML). If unavailable, fallback to per-page headings TOC.
  document.addEventListener('DOMContentLoaded', function () {
    const article = document.querySelector('main, .md-content, .md-main__inner, #main');

    function normalizePath(p) {
      if (!p) return '';
      try { p = decodeURIComponent(p); } catch (e) {}
      p = p.split('#')[0].split('?')[0];
      p = p.replace(/^\//, '').replace(/\.html$/, '').replace(/\/$/, '').replace(/^index$/,'');
      return p;
    }

    function highlightAndExpand(root) {
      const links = root.querySelectorAll('a');
      const current = normalizePath(location.pathname);
      let matched = null;
      links.forEach(a => {
        const href = (a.getAttribute('href')||'').replace(/^\.\//,'').replace(/^\//,'').split('#')[0];
        const norm = normalizePath(href);
        if (norm && (norm === current || current.startsWith(norm + '/'))) {
          a.classList.add('toc-active');
          // add mkdocs classes to li and link
          const li = a.closest('li');
          if (li) li.classList.add('md-nav__item--active');
          a.classList.add('md-nav__link--active');
          matched = a;
        } else {
          a.classList.remove('toc-active');
          const li = a.closest('li');
          if (li) li.classList.remove('md-nav__item--active');
          a.classList.remove('md-nav__link--active');
        }
      });
      if (matched) {
        let li = matched.closest('li');
        while (li) {
          li.classList.add('toc-open');
          li = li.parentElement ? li.parentElement.closest('li') : null;
        }
        matched.scrollIntoView({block:'center'});
      }
    }

    async function loadSiteTree() {
      try {
        // try overview in compendium first (Przegląd), then fall back to old spis_tresci
        const tryUrls = [
          '/compendium/shadow_demon_lord/index/',
          '/compendium/shadow_demon_lord/index.md',
          '/spis_tresci/',
          '/spis_tresci.md'
        ];
        let resp = null;
        for (let u of tryUrls) {
          try {
            const r = await fetch(u);
            if (r && r.ok) { resp = r; break; }
          } catch (e) {
            // ignore and try next
          }
        }
        if (!resp) throw new Error('no toc source');
        const text = await resp.text();
        const parser = new DOMParser();
        const doc = parser.parseFromString(text, 'text/html');
        const gen = doc.querySelector('#generated-toc') || doc.body;
        if (!gen) throw new Error('no toc');

        // create sidebar
        const sidebar = document.createElement('nav');
        sidebar.id = 'toc-widget';
        sidebar.className = 'toc-sidebar';
        sidebar.setAttribute('aria-label','Spis treści serwisu');
        // clone the generated structure
        const clone = gen.cloneNode(true);
        // normalize classes to match mkdocs-material
        (clone.querySelectorAll('ul') || []).forEach(ul => ul.classList.add('md-nav__list'));
        (clone.querySelectorAll('li') || []).forEach(li => {
          li.classList.add('md-nav__item');
          if (li.querySelector('ul')) li.classList.add('md-nav__item--section','md-nav__item--nested');
          const a = li.querySelector('a');
          if (a) a.classList.add('md-nav__link');
        });
        // ensure top-level lists also have md-nav classes
        const topLists = clone.querySelectorAll(':scope > ul');
        topLists.forEach(ul => ul.classList.add('md-nav__list'));

        sidebar.appendChild(clone);
        document.body.appendChild(sidebar);

        // click handlers: expand/collapse but we will keep tree expanded by default via CSS
        sidebar.addEventListener('click', function(e){
          const li = e.target.closest('li');
          if (!li) return;
          if (li.querySelector('ul')) li.classList.toggle('toc-open');
        });

        highlightAndExpand(sidebar);
        return true;
      } catch (e) {
        return false;
      }
    }

    function buildHeadingTOC() {
      if (!article) return;
      const headings = Array.from(article.querySelectorAll('h2, h3, h4'));
      if (!headings.length) return;
      function slugify(text) { return text.toLowerCase().trim().replace(/[^a-z0-9ąćęłńóśżź]+/g,'-').replace(/^-+|-+$/g,''); }
      headings.forEach(h => { if (!h.id) h.id = slugify(h.textContent||'section'); });
      const sidebar = document.createElement('aside');
      sidebar.id = 'toc-widget'; sidebar.className='toc-inline';
      const title = document.createElement('div'); title.className='inline-toc-title'; title.textContent='Spis treści'; sidebar.appendChild(title);
      const ul = document.createElement('ul');
      headings.forEach(h => { const li = document.createElement('li'); const a = document.createElement('a'); a.href='#'+h.id; a.textContent=h.textContent; a.className='inline-toc-link'; li.appendChild(a); ul.appendChild(li); });
      sidebar.appendChild(ul);
      const firstH1 = article.querySelector('h1');
      if (firstH1 && firstH1.parentElement) firstH1.parentElement.insertBefore(sidebar, firstH1.nextSibling);
      else article.insertBefore(sidebar, article.firstChild);

      // simple scrollspy
      const links = Array.from(sidebar.querySelectorAll('a'));
      function onScroll(){
        const scrollPos = window.scrollY + 10;
        let currentId = null;
        for (let h of headings) {
          if (h.getBoundingClientRect().top + window.scrollY <= scrollPos) currentId = h.id;
        }
        links.forEach(a => a.classList.toggle('toc-active', a.hash === ('#'+currentId)));
      }
      window.addEventListener('scroll', onScroll, {passive:true});
      onScroll();
    }

    // Try site-wide tree first, fallback to heading TOC
    loadSiteTree().then(ok => { if (!ok) buildHeadingTOC(); });
  });
});
