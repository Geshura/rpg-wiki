#!/usr/bin/env python3
from pathlib import Path
import re

def fix_file(path: Path) -> int:
    text = path.read_text(encoding='utf-8')
    # replace href=".../index.md" -> href=".../"
    new = re.sub(r'href=("|\')(.*?/)?index\.md(\1)', lambda m: f'href={m.group(1)}{m.group(2) or ""}{m.group(1)}', text)
    # also replace occurrences in href like ../../pochodzenia/index.md -> ../../pochodzenia/
    if new != text:
        path.write_text(new, encoding='utf-8')
        return 1
    return 0

def main():
    site = Path.cwd() / 'site'
    if not site.exists():
        print('site/ not found; run mkdocs build first')
        return
    count = 0
    for p in site.rglob('*.html'):
        try:
            count += fix_file(p)
        except Exception as e:
            print('Failed', p, e)
    print(f'Postprocessed {count} html files')

if __name__ == '__main__':
    main()
