#!/usr/bin/env bash
# Сборка сайта-учебника «1С 8.3».
set -euo pipefail

echo "==> Сборка сайта"

# 1. Чистая папка сборки
rm -rf dist
mkdir -p dist

# 2. Копируем страницы и ресурсы
cp ./*.html dist/
cp -r assets dist/

# 3. Проверяем, что все относительные ссылки из всех страниц существуют
python3 - <<'PY'
import glob, os, re, sys

missing = []
total_refs = 0
pages = sorted(glob.glob("dist/*.html"))

for page in pages:
    html = open(page, encoding="utf-8").read()
    base = os.path.dirname(page)
    refs = re.findall(r'(?:src|href)="((?!https?:|#|mailto:|data:)[^"]+)"', html)
    total_refs += len(refs)
    for r in refs:
        target = os.path.normpath(os.path.join(base, r))
        if not os.path.exists(target):
            missing.append(f"{os.path.basename(page)} -> {r}")

if missing:
    print("ОШИБКА: не найдены файлы, на которые ссылаются страницы:")
    for m in sorted(set(missing)):
        print("  -", m)
    sys.exit(1)

imgs = 0
for page in pages:
    html = open(page, encoding="utf-8").read()
    imgs += len([r for r in re.findall(r'(?:src|href)="([^"]+)"', html)
                 if r.lower().endswith((".png", ".jpg", ".jpeg", ".svg", ".webp"))])

for page in pages:
    html = open(page, encoding="utf-8").read()
    for tag in ("<title>", "<h1", "</html>"):
        if tag not in html:
            print(f"ОШИБКА: в {page} нет {tag}")
            sys.exit(1)

print(f"OK: страниц: {len(pages)}, ссылок: {total_refs}, картинок: {imgs}")
PY

# 4. Статистика
echo "==> Файлы сборки:"
find dist -type f | sort
echo "==> Готово: dist/"
