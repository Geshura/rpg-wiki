#!/usr/bin/env python3
"""Double leading-space indentation when file uses single-space indents.

Usage: python scripts/double_indent.py PATH
If PATH omitted, defaults to nav.yml in repo root.
The script overwrites the file in-place after a backup (`.bak`).
"""
from pathlib import Path
import sys


def detect_min_indent(lines):
    counts = []
    for ln in lines:
        if not ln.strip():
            continue
        # count leading spaces
        i = 0
        for ch in ln:
            if ch == ' ':
                i += 1
            else:
                break
        if i > 0:
            counts.append(i)
    return min(counts) if counts else 0


def transform(lines):
    min_indent = detect_min_indent(lines)
    if min_indent == 0:
        print("No indented lines found; nothing to do.")
        return None
    if min_indent != 1:
        print(f"Detected minimum indent = {min_indent}. Only transforms files using 1-space indents. No changes made.")
        return None

    out = []
    for ln in lines:
        # replace leading spaces: each leading space -> two spaces
        i = 0
        for ch in ln:
            if ch == ' ':
                i += 1
            else:
                break
        if i > 0:
            new_leading = ' ' * (i * 2)
            out.append(new_leading + ln[i:])
        else:
            out.append(ln)
    return out


def main():
    repo = Path(__file__).resolve().parents[1]
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else repo / 'nav.yml'
    if not path.exists():
        print(f"File not found: {path}")
        raise SystemExit(1)

    txt = path.read_text(encoding='utf-8').splitlines(keepends=True)
    out = transform(txt)
    if out is None:
        return

    bak = path.with_suffix(path.suffix + '.bak')
    path.replace(bak)
    path.write_text(''.join(out), encoding='utf-8')
    print(f"Updated {path} (backup -> {bak})")


if __name__ == '__main__':
    main()
