#!/usr/bin/env bash
# Сборка сайта-учебника «1С 8.3: отчёты».
set -euo pipefail

echo "==> Сборка учебника"

# 1. Чистая папка сборки
rm -rf dist
mkdir -p dist

# 2. Копируем страницы и ресурсы
cp index.html dist/
cp -r assets dist/

# 3. Проверяем, что все картинки из index.html существуют
python3 - <<'PY'
import os, re, sys

html = open("index.html", encoding="utf-8").read()

# Все относительные ссылки на ресурсы
refs = re.findall(r'(?:src|href)="((?!https?:|#|mailto:)[^"]+)"', html)
missing = [r for r in refs if not os.path.exists(os.path.join("dist", r)) or not os.path.exists(r)]

if missing:
    print("ОШИБКА: не найдены файлы, на которые ссылается index.html:")
    for m in sorted(set(missing)):
        print("  -", m)
    sys.exit(1)

# Подсчёт картинок
imgs = [r for r in refs if r.lower().endswith((".png", ".jpg", ".jpeg", ".svg", ".webp"))]
print(f"OK: страница найдена, ссылок: {len(refs)}, картинок: {len(imgs)}")

# Минимальная проверка разметки
for tag in ("<title>", "<h1", "</html>"):
    if tag not in html:
        print(f"ОШИБКА: в index.html нет {tag}")
        sys.exit(1)
PY

# 4. Статистика
echo "==> Файлы сборки:"
find dist -type f | sort
echo "==> Готово: dist/"
