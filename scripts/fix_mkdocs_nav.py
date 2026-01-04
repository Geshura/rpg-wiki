#!/usr/bin/env python3
import re
from pathlib import Path

p = Path('mkdocs.yml')
txt = p.read_text(encoding='utf-8')
# Remove accidental 'index.md' inserted immediately before filenames (e.g. 'index.mdbrisingamen.md')
txt2 = re.sub(r'index\.md(?=[^\s/\n\'"-])', '', txt)
# Also collapse double 'index.mdindex.md' to single
txt2 = txt2.replace('index.mdindex.md', 'index.md')
if txt2 != txt:
    p.write_text(txt2, encoding='utf-8')
    print('Fixed mkdocs.yml')
else:
    print('No changes')
