import re
from pathlib import Path

def main():
    root = Path(__file__).resolve().parents[1]
    mk = root / 'mkdocs.yml'
    docs1 = root / 'docs' / '1'
    txt = mk.read_text(encoding='utf-8')
    # find markdown paths like foo/bar.md or name.md
    matches = re.findall(r"[A-Za-z0-9_\-ąćęłńóśżźĄĆĘŁŃÓŚŻŹąćęłńóśżź/]+\.md", txt)
    seen = set()
    for m in matches:
        if m in seen:
            continue
        seen.add(m)
        target = docs1 / m
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists():
            title = Path(m).stem.replace('_', ' ').replace('-', ' ')
            content = f"# {title}\n\n_Placeholder generated from mkdocs.yml for {m}_\n"
            target.write_text(content, encoding='utf-8')
            print('Created', target)
        else:
            print('Exists', target)

if __name__ == '__main__':
    main()
