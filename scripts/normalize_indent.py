#!/usr/bin/env python3
"""Normalize indentation in a YAML-like file.

This script detects the smallest non-zero leading-space indent unit (gcd of counts)
and rewrites the file using a target indent width (default 2 spaces).

Usage:
  python scripts/normalize_indent.py [path] [-w WIDTH] [--annotate]

If --annotate is passed, the script appends a YAML comment with the detected
indent level for each non-empty line (useful for debugging nav generation).
"""
from pathlib import Path
import argparse
import sys
import math


def leading_spaces(s: str) -> int:
    i = 0
    for ch in s:
        if ch == ' ':
            i += 1
        else:
            break
    return i


def detect_unit(counts):
    counts = [c for c in counts if c > 0]
    if not counts:
        return 0
    g = counts[0]
    for c in counts[1:]:
        g = math.gcd(g, c)
    return g


def normalize_lines(lines, target_width=2, annotate=False):
    counts = [leading_spaces(ln) for ln in lines if ln.strip()]
    unit = detect_unit(counts)
    if unit <= 0:
        return None, unit

    out = []
    for ln in lines:
        if not ln.strip():
            out.append(ln)
            continue
        ls = leading_spaces(ln)
        level = ls // unit if unit else 0
        if ls % unit != 0:
            # approximate: use float ratio rounded
            level = round(ls / unit)
        new_lead = ' ' * (level * target_width)
        body = ln.lstrip(' ')
        line = new_lead + body
        if annotate and ln.strip():
            # append YAML comment with level
            if line.endswith('\n'):
                line = line[:-1] + f"  # lvl:{level}\n"
            else:
                line = line + f"  # lvl:{level}"
        out.append(line)
    return out, unit


def main():
    p = argparse.ArgumentParser()
    p.add_argument('path', nargs='?', default='nav.yml')
    p.add_argument('-w', '--width', type=int, default=2, help='target indent width')
    p.add_argument('--annotate', action='store_true', help='append comment with indent level')
    args = p.parse_args()

    path = Path(args.path)
    if not path.exists():
        print(f'File not found: {path}', file=sys.stderr)
        sys.exit(2)

    text = path.read_text(encoding='utf-8')
    lines = text.splitlines(keepends=True)
    new_lines, unit = normalize_lines(lines, target_width=args.width, annotate=args.annotate)
    if new_lines is None:
        print('No indented lines detected; nothing changed.')
        return

    bak = path.with_suffix(path.suffix + '.bak')
    path.replace(bak)
    path.write_text(''.join(new_lines), encoding='utf-8')
    print(f'Normalized {path} (unit={unit} -> width={args.width}). Backup: {bak}')


if __name__ == '__main__':
    main()
