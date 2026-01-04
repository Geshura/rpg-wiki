#!/usr/bin/env python3
import re
from pathlib import Path

def convert_links(text: str, repo: Path):
    # find markdown links like [text](some/path/)
    pattern = re.compile(r"\]\(([^)]+/)\)")
    count = 0

    def repl(m):
        nonlocal count
        path = m.group(1)
        # ignore absolute URLs
        if path.startswith('http://') or path.startswith('https://'):
            return m.group(0)
        candidate = repo / 'docs' / Path(path) / 'index.md'
        try:
            if candidate.exists():
                count += 1
                return f"]({path}index.md)"
        except Exception:
            pass
        return m.group(0)

    new_text = pattern.sub(repl, text)

    # also replace plain occurrences in mkdocs.yml or inline paths
    plain_pattern = re.compile(r"(?P<prefix>[\'\"]|\b)(?P<path>(?:[\w\-_/]+/))(?P<suffix>[\'\"]|\b)")
    def repl2(m):
        nonlocal count
        path = m.group('path')
        if path.startswith('http://') or path.startswith('https://'):
            return m.group(0)
        candidate = repo / 'docs' / Path(path) / 'index.md'
        try:
            if candidate.exists():
                count += 1
                return f"{m.group('prefix')}{path}index.md{m.group('suffix')}"
        except Exception:
            pass
        return m.group(0)

    new_text2 = plain_pattern.sub(repl2, new_text)
    return new_text2, count

def process_file(path: Path, repo: Path):
    text = path.read_text(encoding='utf-8')
    new_text, count = convert_links(text, repo)
    if count > 0 and new_text != text:
        path.write_text(new_text, encoding='utf-8')
    return count

def main():
    repo = Path.cwd()
    files = list(repo.glob('docs/**/*.md')) + [repo / 'mkdocs.yml']
    total = 0
    touched = 0
    for f in files:
        if not f.exists():
            continue
        c = process_file(f, repo)
        if c:
            touched += 1
            total += c
            print(f"Updated {f} ({c} replacements)")

    print(f"Done — modified {touched} files, {total} total replacements.")

if __name__ == '__main__':
    main()
