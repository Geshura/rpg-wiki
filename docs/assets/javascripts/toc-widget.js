document.addEventListener('DOMContentLoaded', function () {
  const container = document.createElement('div');
  container.id = 'toc-widget';
  container.innerHTML = `
    <button id="toc-toggle" aria-expanded="false">Spis</button>
    <div id="toc-content" hidden></div>
  `;
  document.body.appendChild(container);

  const contentDiv = document.getElementById('toc-content');
  const toggle = document.getElementById('toc-toggle');

  async function loadTOC() {
    try {
      let resp = await fetch('/spis_tresci/');
      if (!resp.ok) resp = await fetch('/spis_tresci.md');
      const text = await resp.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(text, 'text/html');
      const generated = doc.querySelector('#generated-toc') || doc.querySelector('body');
      contentDiv.innerHTML = generated ? generated.innerHTML : text;
      highlightCurrent(contentDiv);
      injectInlineSectionTOC(generated || doc.body);
    } catch (e) {
      contentDiv.innerHTML = '<p>Nie można załadować spisu treści.</p>';
    }
  }

  function normalizePath(p) {
    if (!p) return '';
    try { p = decodeURIComponent(p); } catch (e) {}
    p = p.split('#')[0].split('?')[0];
    p = p.replace(/^\//, '').replace(/\.html$/, '').replace(/\/$/, '');
    return p;
  }

  function highlightCurrent(root) {
    const links = root.querySelectorAll('a');
    const current = normalizePath(location.pathname);
    links.forEach(a => {
      let href = a.getAttribute('href') || '';
      if (href.startsWith('http') || href.startsWith('mailto:') || href.startsWith('#')) return;
      let h = href.replace(/^\.\//, '').replace(/^\//, '').split('#')[0].split('?')[0];
      h = h.replace(/\.html$/, '').replace(/\/$/, '');
      if (h === current || (h === 'index' && (current === '' || current === 'index'))) {
        a.classList.add('toc-active');
        let li = a.closest('li');
        while (li) {
          li.classList.add('toc-open');
          li = li.parentElement ? li.parentElement.closest('li') : null;
        }
      }
    });
    const active = root.querySelector('.toc-active');
    if (active) active.scrollIntoView({ block: 'center' });
  }

  // Inline section TOC: inject a compact TOC for the current top-level section
  function injectInlineSectionTOC(root) {
    try {
      const tocRoot = root.querySelector('ul') || root;
      const current = normalizePath(location.pathname);

      // find best matching top-level li that contains current page
      const topLis = Array.from((tocRoot.querySelectorAll(':scope > ul > li')) || []);
      let selectedLi = null;
      for (const li of topLis) {
        const anchors = li.querySelectorAll('a');
        for (const a of anchors) {
          const href = a.getAttribute('href') || '';
          const norm = normalizePath(href.replace(/^\.\//, ''));
          if (!norm) continue;
          if (current === norm || current.startsWith(norm + '/')) {
            selectedLi = li; break;
          }
        }
        if (selectedLi) break;
      }

      // fallback: pick first top-level
      if (!selectedLi && topLis.length) selectedLi = topLis[0];
      if (!selectedLi) return;

      // clone selected subtree and render into page
      const clone = selectedLi.cloneNode(true);
      // create container
      const inline = document.createElement('aside');
      inline.id = 'inline-toc';
      inline.setAttribute('aria-label', 'Spis treści sekcji');
      const title = clone.querySelector('a') ? clone.querySelector('a').textContent : 'Spis';
      inline.innerHTML = `<div class="inline-toc-title">${title}</div>`;
      const list = document.createElement('div');
      list.className = 'inline-toc-list';
      // remove top-level link from clone (we'll keep children)
      const topLink = clone.querySelector('a');
      if (topLink) topLink.remove();
      list.appendChild(clone.querySelector('ul') || clone);
      inline.appendChild(list);

      // highlight current within inline
      highlightCurrent(inline);

      // insert after page title if possible
      const article = document.querySelector('main, .md-content, .md-main__inner, #main');
      if (article) {
        const firstH = article.querySelector('h1, h2');
        if (firstH && firstH.parentElement) {
          firstH.parentElement.insertBefore(inline, firstH.nextSibling);
        } else {
          article.insertBefore(inline, article.firstChild);
        }
      }
    } catch (e) {
      // fail silently
      console.warn('inline TOC error', e);
    }
  }

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
