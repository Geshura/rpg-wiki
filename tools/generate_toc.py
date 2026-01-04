#!/usr/bin/env python3
"""
Generate `docs/spis_tresci.md` from `mkdocs.yml` nav section.
Usage: python tools/generate_toc.py
Requires PyYAML (`pip install pyyaml`). If PyYAML is missing the script will exit with a hint.
"""
import os
import sys

try:
    import yaml
except Exception:
    print("PyYAML is required. Install with: pip install pyyaml")
    sys.exit(2)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MKDOCS = os.path.join(ROOT, 'mkdocs.yml')
OUT = os.path.join(ROOT, 'docs', 'spis_tresci.md')

def render_nav(items, level=0):
    lines = []
    for item in items:
        if isinstance(item, dict):
            for k, v in item.items():
                indent = '  ' * level
                if isinstance(v, str):
                    lines.append(f"{indent}- [{k}]({v})")
                elif isinstance(v, list):
                    lines.append(f"{indent}- **{k}**")
                    lines.extend(render_nav(v, level + 1))
                else:
                    lines.append(f"{indent}- {k}: {v}")
        else:
            lines.append('  ' * level + f"- {item}")
    return lines

def main():
    if not os.path.exists(MKDOCS):
        print('mkdocs.yml not found at expected path:', MKDOCS)
        sys.exit(1)
    with open(MKDOCS, 'r', encoding='utf-8') as f:
        cfg = yaml.safe_load(f)

    nav = cfg.get('nav', [])
    md = [
        '# Spis treści',
        '',
        'Poniższa lista została wygenerowana automatycznie z `mkdocs.yml`.',
        '',
    ]
    md += render_nav(nav)
    md_text = '\n'.join(md) + '\n'

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write(md_text)

    print('Wygenerowano', OUT)

if __name__ == '__main__':
    main()
