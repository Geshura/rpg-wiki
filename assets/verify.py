import json

with open('compendium_shadow_demon_lord.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

categories = len(data.get('categories', []))
spells = sum(1 for c in data.get('categories', []) for i in c.get('items', []) if 'tradition' in i)

print(f'Plik JSON jest poprawny!')
print(f'Kategorii: {categories}')
print(f'Zaklęć: {spells}')
