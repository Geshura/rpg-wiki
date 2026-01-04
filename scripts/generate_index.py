#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path('docs') / 'cwd'

def title_from_file(path: Path) -> str:
    text = path.read_text(encoding='utf-8')
    m = re.search(r'^#\s+(.+)$', text, flags=re.MULTILINE)
    if m:
        return m.group(1).strip()
    name = path.stem
    name = name.replace('-', ' ').replace('_', ' ')
    return name.title()

def generate():
    if not ROOT.exists():
        print('docs/cwd not found')
        return

    # read existing index.md tail (after the first '---' separator) to preserve contribution/license sections
    index_path = ROOT / 'index.md'
    tail = ''
    if index_path.exists():
        content = index_path.read_text(encoding='utf-8')
        parts = content.split('\n---\n', 1)
        if len(parts) == 2:
            tail = '\n---\n' + parts[1].strip() + '\n'
        else:
            # fallback: preserve section starting with 'Jak pomagać'
            idx = content.find('\nJak pomagać')
            if idx != -1:
                tail = '\n' + content[idx:]

    header = (
        '# Cień Władcy Demonów - Kompendium\n\n'
        'Rozszerzone kompendium dla systemu Shadow of the Demon Lord / Cień Władcy Demonów.\n\n'
        '## Struktura\n\n'
    )

    body_lines = [header]

    # iterate subfolders sorted
    for sub in sorted([p for p in ROOT.iterdir() if p.is_dir()] , key=lambda p: p.name):
        # skip assets folder
        if sub.name.lower() in ('assets', 'images'):
            continue
        section_title = sub.name.replace('_', ' ').title()
        body_lines.append(f'### [{section_title}]({sub.name}/)\n')
        # list files
        files = sorted([f for f in sub.glob('*.md') if f.name.lower() != 'index.md'])
        if files:
            for f in files:
                rel = f.relative_to(ROOT)
                title = title_from_file(f)
                body_lines.append(f'- [{title}]({rel.as_posix()})')
        else:
            body_lines.append('*Brak stron (w trakcie dodawania)*')
        body_lines.append('')

    # assemble and write
    new_content = '\n'.join(body_lines).rstrip() + '\n' + tail
    index_path.write_text(new_content, encoding='utf-8')
    print('Wygenerowano', index_path)

if __name__ == '__main__':
    generate()
