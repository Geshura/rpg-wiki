#!/usr/bin/env python3
import os
from pathlib import Path

def title_from_name(path: Path) -> str:
    name = path.stem
    name = name.replace('-', ' ').replace('_', ' ')
    return name.title()

def main():
    repo_root = Path.cwd()
    manifest = repo_root / 'docs' / 'missing_targets.txt'
    if not manifest.exists():
        print(f"Manifest not found: {manifest}")
        return

    created = 0
    skipped = 0
    for raw in manifest.read_text(encoding='utf-8').splitlines():
        line = raw.strip()
        if not line or line.startswith('#'):
            continue
        target = Path(line)
        if not target.is_absolute():
            target = repo_root / target
        parent = target.parent
        parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            skipped += 1
            continue
        title = title_from_name(target)
        content = f"# {title}\n\n> Placeholder — content to be added.\n"
        try:
            target.write_text(content, encoding='utf-8')
            created += 1
        except Exception as e:
            print(f"Failed to write {target}: {e}")

    print(f"Stubs created: {created}, skipped (already existed): {skipped}")

if __name__ == '__main__':
    main()
