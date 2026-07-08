import os

replacements = {
    r"android\app\src\main\AndroidManifest.xml": [
        ('android:label="trenx"', 'android:label="ZeniVital"'),
        ('android:label="Trenx"', 'android:label="ZeniVital"'),
    ],
    r"ios\Runner\Info.plist": [
        ('<string>trenx</string>', '<string>ZeniVital</string>'),
        ('<string>Trenx</string>', '<string>ZeniVital</string>'),
    ],
    r"web\index.html": [
        ('<title>trenx</title>', '<title>ZeniVital</title>'),
        ('<title>Trenx</title>', '<title>ZeniVital</title>'),
        ('content="trenx"', 'content="ZeniVital"'),
        ('content="Trenx"', 'content="ZeniVital"'),
    ],
    r"web\manifest.json": [
        ('"name": "trenx"', '"name": "ZeniVital"'),
        ('"name": "Trenx"', '"name": "ZeniVital"'),
        ('"short_name": "trenx"', '"short_name": "ZeniVital"'),
        ('"short_name": "Trenx"', '"short_name": "ZeniVital"'),
    ]
}

for path, rules in replacements.items():
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in rules:
        content = content.replace(old, new)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Processed {path}")
