import json

# Read with utf-8-sig to handle BOM
with open('compendium_shadow_demon_lord.json', 'r', encoding='utf-8-sig') as f:
    data = json.load(f)

# Write back without BOM
with open('compendium_shadow_demon_lord.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print('Naprawiono BOM i zapisano plik!')
