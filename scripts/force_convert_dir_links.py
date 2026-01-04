#!/usr/bin/env python3
import re
from pathlib import Path

PAT = re.compile(r"\]\(([^)]+/)\)")

def main():
    repo = Path.cwd()
    files = list(repo.glob('docs/**/*.md'))
    total = 0
    touched = 0
    for f in files:
        s = f.read_text(encoding='utf-8')
        new, n = PAT.subn(r'](\1index.md)', s)
        if n > 0 and new != s:
            f.write_text(new, encoding='utf-8')
            print(f'Updated {f} ({n} replacements)')
            touched += 1
            total += n
    print(f'Done — modified {touched} files, {total} total replacements.')

if __name__ == '__main__':
    main()
