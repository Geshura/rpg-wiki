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
