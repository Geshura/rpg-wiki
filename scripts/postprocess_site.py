#!/usr/bin/env python3
"""Minimal post-processing script for CI compatibility.

This script currently performs no modifications; it exists so the
GitHub Actions workflow step `python scripts/postprocess_site.py`
does not fail if the file is missing.
"""
import sys


def main() -> int:
    # No-op for now. Add site postprocessing here if needed.
    return 0


if __name__ == "__main__":
    sys.exit(main())
