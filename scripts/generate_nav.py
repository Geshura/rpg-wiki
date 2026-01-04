#!/usr/bin/env python3
from pathlib import Path
import re

DOCS_ROOT = Path('docs')

def read_title_from_md(path: Path):
    try:
        text = path.read_text(encoding='utf-8')
    except Exception:
        return None
    # find first level-1 or level-2 header
    m = re.search(r'^#\s+(.+)$', text, flags=re.M)
    if m:
        return m.group(1).strip()
    m2 = re.search(r'^##\s+(.+)$', text, flags=re.M)
    if m2:
        return m2.group(1).strip()
    return None

def humanize_name(name: str):
    name = name.replace('_', ' ').replace('-', ' ')
    # remove extension
    if name.endswith('.md'):
        name = name[:-3]
    return name.replace('%20', ' ')

def collect_nav_for_dir(dirpath: Path, relprefix: str = 'cwd'):
    entries = []
    seen = set()
    # if index.md exists, add it first as the section root
    index = dirpath / 'index.md'
    if index.exists():
        title = read_title_from_md(index) or humanize_name(dirpath.name)
        path = f"{relprefix}/index.md"
        entries.append((title, path))
        seen.add(path)
    # files next (sorted), excluding index.md
    files = sorted([p for p in dirpath.iterdir() if p.is_file() and p.suffix == '.md' and p.name.lower() != 'index.md'])
    for f in files:
        path = f"{relprefix}/{f.name}"
        if path in seen:
            continue
        title = read_title_from_md(f) or humanize_name(f.name)
        entries.append((title, path))
        seen.add(path)
    # then subdirectories
    dirs = sorted([p for p in dirpath.iterdir() if p.is_dir()])
    for d in dirs:
        # collect child files; child collector will include its own index.md as first child
        children = collect_nav_for_dir(d, relprefix=f"{relprefix}/{d.name}")
        # determine section title from children's first entry if present
        if children:
            first = children[0]
            if isinstance(first, tuple) and isinstance(first[1], str) and first[1].endswith('index.md'):
                section_title = first[0]
            else:
                section_title = humanize_name(d.name)
        else:
            section_title = humanize_name(d.name)
        entries.append((section_title, children))
    return entries

def render_nav(entries, indent=2):
    lines = []
    sp = ' ' * indent
    for title, target in entries:
        if isinstance(target, list):
            lines.append(f"{sp}- {title}:")
            # for children, render with increased indent
            lines.extend(render_nav(target, indent=indent+2))
        else:
            lines.append(f"{sp}- {title}: {target}")
    return lines

def main():
    cwd = DOCS_ROOT / 'cwd'
    if not cwd.exists():
        print('docs/cwd not found')
        return 1

    nav_entries = []
    # top-level home
    home = DOCS_ROOT / 'cwd' / 'index.md'
    if home.exists():
        title = read_title_from_md(home) or 'Home'
        nav_entries.append((title, 'cwd/index.md'))

    # scan top-level dirs
    for item in sorted(cwd.iterdir()):
        if item.is_dir():
            index = item / 'index.md'
            if index.exists():
                title = read_title_from_md(index) or humanize_name(item.name)
                children = collect_nav_for_dir(item, relprefix=f'cwd/{item.name}')
                nav_entries.append((title, children))
            else:
                # include as section with its children
                title = humanize_name(item.name)
                children = collect_nav_for_dir(item, relprefix=f'cwd/{item.name}')
                nav_entries.append((title, children))
        elif item.is_file() and item.suffix == '.md' and item.name.lower() != 'index.md':
            title = read_title_from_md(item) or humanize_name(item.name)
            nav_entries.append((title, f'cwd/{item.name}'))

    # render nav block
    nav_lines = ['nav:']
    nav_lines += render_nav(nav_entries, indent=2)
    nav_text = '\n'.join(nav_lines) + '\n'

    # inject into mkdocs.yml: replace existing nav: block if present
    mk = Path('mkdocs.yml')
    mk_text = mk.read_text(encoding='utf-8')
    if '\nnav:' in mk_text:
        new = mk_text.split('\nnav:')[0] + '\n' + nav_text
    elif mk_text.strip().endswith('nav:'):
        new = mk_text + '\n'.join(nav_lines[1:]) + '\n'
    else:
        # append
        if not mk_text.endswith('\n'):
            mk_text += '\n'
        new = mk_text + '\n' + nav_text

    mk.write_text(new, encoding='utf-8')
    print('Wygenerowano i zapisano nav w mkdocs.yml')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
