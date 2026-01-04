import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
MK = os.path.join(ROOT, 'mkdocs.yml')
DOCS = os.path.join(ROOT, 'docs')

pat = re.compile(r'cwd/[^)\n\']+\.md')
missing = []
with open(MK, 'r', encoding='utf-8') as f:
    text = f.read()
for m in pat.findall(text):
    rel = m.strip()
    full = os.path.join(DOCS, rel.replace('/', os.sep))
    if not os.path.exists(full):
        missing.append((rel, full))

if missing:
    print('Missing files referenced in mkdocs.yml:')
    for rel, full in missing:
        print(rel, '->', full)
    raise SystemExit(2)
else:
    print('All referenced cwd/*.md paths exist.')
