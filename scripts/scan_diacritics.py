import os
import unicodedata
from collections import defaultdict

root = os.path.join(os.path.dirname(__file__), '..', 'docs', 'cwd')
root = os.path.normpath(root)

collisions = defaultdict(list)
for dirpath, dirs, files in os.walk(root):
    for f in files:
        if not f.lower().endswith('.md'):
            continue
        key = unicodedata.normalize('NFKD', f)
        key = ''.join(c for c in key if not unicodedata.combining(c))
        key = key.lower()
        collisions[key].append(os.path.join(dirpath, f))

dups = {k: v for k, v in collisions.items() if len(v) > 1}
print(f'Found {len(dups)} diacritic collisions')
for k, paths in sorted(dups.items()):
    print('\nCanonical:', k)
    for p in paths:
        print(' -', os.path.relpath(p))
