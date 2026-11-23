#!/usr/bin/env bash
# 下载 Retailrocket 电商行为数据集（Kaggle，CC BY-NC-SA 4.0）
# 用法：bash download_data.sh
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p data

if [ -f data/events.csv ]; then
  echo "✅ data/events.csv 已存在，跳过下载"
  exit 0
fi

echo "⬇️  正在从 Kaggle 下载（约 291MB）..."
curl -L --fail --progress-bar \
  -o data/retailrocket.zip \
  "https://www.kaggle.com/api/v1/datasets/download/retailrocket/ecommerce-dataset"

echo "📦 解压 events.csv ..."
unzip -o data/retailrocket.zip events.csv -d data
rm -f data/retailrocket.zip

echo "✅ 完成：$(wc -l < data/events.csv) 行"
