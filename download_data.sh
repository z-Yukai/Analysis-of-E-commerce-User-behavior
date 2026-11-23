#!/usr/bin/env bash
# 下载 Retailrocket 电商行为数据集（Kaggle，CC BY-NC-SA 4.0）
# 用法：
#   bash download_data.sh          # 只取 events.csv + category_tree.csv（约 90MB）
#   bash download_data.sh --full   # 额外解压 item_properties 并生成品类映射（约 1.7GB）
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p data

FULL=0
if [ "${1:-}" = "--full" ]; then FULL=1; fi

if [ -f data/events.csv ]; then
  echo "✅ data/events.csv 已存在，跳过下载"
else
  echo "⬇️  正在从 Kaggle 下载（约 291MB）..."
  curl -L --fail --progress-bar \
    -o data/retailrocket.zip \
    "https://www.kaggle.com/api/v1/datasets/download/retailrocket/ecommerce-dataset"

  echo "📦 解压 ..."
  NAMES=(events.csv category_tree.csv)
  if [ "$FULL" = "1" ]; then
    NAMES+=(item_properties_part1.csv item_properties_part2.csv)
  fi
  if command -v unzip >/dev/null 2>&1; then
    unzip -o -q data/retailrocket.zip "${NAMES[@]}" -d data
  else
    EXTRA="$(IFS=,; echo "${NAMES[*]}")" python3 - <<'PY'
import os, zipfile
names = os.environ["EXTRA"].split(",")
z = zipfile.ZipFile("data/retailrocket.zip")
for n in names:
    z.extract(n, "data")
    print("  extracted", n)
PY
  fi
  rm -f data/retailrocket.zip
fi

if [ "$FULL" = "1" ]; then
  if [ -f data/item_properties_part1.csv ]; then
    echo "🧩 生成品类映射 ..."
    python3 build_item_category.py
  else
    echo "⚠️ 未找到 item_properties，跳过品类映射（请用 --full 重新下载）"
  fi
fi

echo "✅ 完成：$(wc -l < data/events.csv) 行"
