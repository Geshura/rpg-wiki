#!/usr/bin/env python3
"""Assemble mkdocs.yml from mkdocs.template.yml and nav.yml.

Usage: python scripts/assemble_mkdocs.py
Creates/overwrites mkdocs.yml in repository root.
"""
import io
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "mkdocs.template.yml"
NAV = ROOT / "nav.yml"
OUT = ROOT / "mkdocs.yml"


def main():
    if not TEMPLATE.exists():
        raise SystemExit(f"Missing template: {TEMPLATE}")
    if not NAV.exists():
        raise SystemExit(f"Missing nav file: {NAV}")

    tpl = TEMPLATE.read_text(encoding="utf-8")
    nav = NAV.read_text(encoding="utf-8")

    if "# NAV_PLACEHOLDER" not in tpl:
        raise SystemExit("mkdocs.template.yml has no NAV_PLACEHOLDER marker")

    assembled = tpl.replace("# NAV_PLACEHOLDER", nav.strip())
    OUT.write_text(assembled, encoding="utf-8")
    print(f"Assembled {OUT.relative_to(ROOT)} from template and nav.yml")


if __name__ == "__main__":
    main()
