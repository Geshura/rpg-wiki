import os
from pathlib import Path

docs = Path('docs')
root = docs / 'zaklecia2'

def title_from_name(name):
    name = name.replace('-', ' ').replace('_', ' ')
    return name.capitalize()

lines = []
lines.append("  - Zaklęcia 2:")
lines.append("    - Indeks: zaklecia2.md")

if root.exists():
    for item in sorted(root.iterdir()):
        if item.is_file():
            display = title_from_name(item.stem)
            lines.append(f"    - {display}: zaklecia2/{item.name}")
        elif item.is_dir():
            dir_display = title_from_name(item.name)
            lines.append(f"    - {dir_display}:")
            for f in sorted(item.iterdir()):
                if f.is_file():
                    display = title_from_name(f.stem)
                    lines.append(f"      - {display}: zaklecia2/{item.name}/{f.name}")

output = '\n'.join(lines) + '\n'
out_path = Path('scripts') / 'zaklecia2_nav.yaml'
out_path.write_text(output, encoding='utf-8')
print(f'Wrote nav snippet to {out_path}')
