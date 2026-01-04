import os
import json
import shutil
from pathlib import Path

WORKDIR = Path(__file__).resolve().parent.parent
JSON_PATH = WORKDIR / "assets" / "compendium_shadow_demon_lord.json"
DOCS_BASE = WORKDIR / "docs" / "compendium" / "shadow_demon_lord"
ASSETS_BASE = WORKDIR / "assets" / "compendium" / "shadow_demon_lord"

def slugify(name):
    s = name.strip().lower()
    s = s.replace(' ', '_')
    s = ''.join(c for c in s if c.isalnum() or c in '_-')
    return s


def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)


def copy_markdown(src: Path, dest: Path):
    ensure_dir(dest.parent)
    shutil.copy2(src, dest)


def make_stub(item, dest: Path):
    ensure_dir(dest.parent)
    title = item.get('name') or item.get('title') or 'Brak tytułu'
    book = item.get('book')
    page = item.get('page')
    description = item.get('description', '')
    lines = [f"# {title}", "",]
    if book or page:
        src = ' • '.join([str(x) for x in (book, f"str. {page}") if x])
        lines.append(f"**Źródło:** {src}")
        lines.append("")
    if description:
        lines.append(description)
        lines.append("")
    lines.append('> Strona wygenerowana automatycznie z JSON.')
    dest.write_text('\n'.join(lines), encoding='utf-8')


def main():
    # plik może zawierać BOM, dlatego używamy 'utf-8-sig'
    data = json.loads(JSON_PATH.read_text(encoding='utf-8-sig'))
    ensure_dir(DOCS_BASE)

    categories = data.get('categories', [])
    for cat in categories:
        cid = cat.get('id')
        items = cat.get('items', [])
        # map category id to folder name in docs
        folder = DOCS_BASE / (cid if cid else 'misc')
        for item in items:
            if 'markdown_path' in item and item['markdown_path']:
                src = WORKDIR / item['markdown_path']
                if not src.exists():
                    # try alternative folder names (magic_traditions <-> tradycje_magii)
                    alt = Path(str(item['markdown_path']).replace('magic_traditions', 'tradycje_magii'))
                    alt = WORKDIR / alt
                    if alt.exists():
                        src = alt
                if src.exists():
                    dest = folder / Path(src).name
                    copy_markdown(src, dest)
                else:
                    # fallback to stub if source missing
                    name = item.get('name', 'bez_nazwy')
                    dest = folder / f"{slugify(name)}.md"
                    make_stub(item, dest)
            else:
                name = item.get('name', item.get('title', 'bez_nazwy'))
                dest = folder / f"{slugify(name)}.md"
                # avoid overwriting existing file
                if not dest.exists():
                    make_stub(item, dest)

    print('Import finished.')

if __name__ == '__main__':
    main()
