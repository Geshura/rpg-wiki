#!/usr/bin/env python3
import re
from pathlib import Path

MD_GLOB = ['docs/**/*.md', '*.md']

def fix_links(text: str) -> (str, int):
    # Replace markdown links like [text](path/to/index.md) -> [text](path/to/)
    pattern = re.compile(r"\]\(([^)\s]*?)index\.md\)")
    count = 0

    def repl(m):
        nonlocal count
        prefix = m.group(1)
        if prefix == '' or prefix is None:
            new = './'
        else:
            new = prefix
        count += 1
        return f"]({new})"

    new_text = pattern.sub(repl, text)

    # Also fix plain occurrences in mkdocs.yml or other files like: path/to/index.md -> path/to/
    # Only replace when followed/preceded by whitespace or quotes or colon to avoid accidental replacements
    plain_pattern = re.compile(r"(?P<prefix>[\'\"\(\[]|^)(?P<path>(?:[\w\-_/]+/)?)index\.md(?P<suffix>[\'\"\)\],\s]|$)")
    def repl2(m):
        nonlocal count
        prefix = m.group('prefix')
        path = m.group('path')
        suffix = m.group('suffix')
        count += 1
        return f"{prefix}{path}{suffix}"

    new_text2 = plain_pattern.sub(repl2, new_text)
    return new_text2, count

def process_file(path: Path) -> int:
    text = path.read_text(encoding='utf-8')
    new_text, count = fix_links(text)
    if count > 0 and new_text != text:
        path.write_text(new_text, encoding='utf-8')
    return count

def main():
    repo = Path.cwd()
    files = list(repo.glob('docs/**/*.md')) + list(repo.glob('*.md')) + [repo / 'mkdocs.yml']
    total = 0
    touched = 0
    for f in files:
        if not f.exists():
            continue
        c = process_file(f)
        if c:
            touched += 1
            total += c
            print(f"Updated {f} ({c} replacements)")

    print(f"Done — modified {touched} files, {total} total replacements.")

if __name__ == '__main__':
    main()
