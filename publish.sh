#!/bin/bash
# publish.sh - 發布每週市場回顧到 GitHub Pages
# 用法: bash publish.sh 2026-W23 "2026.06.01—06.05"
#   第一個參數：ISO 週數（如 2026-W23）
#   第二個參數：日期範圍（如 "2026.06.01—06.05"）

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WEEK="${1:-}"
PERIOD="${2:-}"

if [ -z "$WEEK" ]; then
  echo "用法: bash publish.sh <YYYY-WXX> \"<YYYY.MM.DD—MM.DD>\""
  echo "範例: bash publish.sh 2026-W23 \"2026.06.01—06.05\""
  exit 1
fi

REPORT_SRC="D:/Reports/weekly-market-wrap-${WEEK}.html"
REPORT_DEST="$REPO_DIR/reports/${WEEK}.html"

# 複製報告文件到倉庫
if [ ! -f "$REPORT_DEST" ]; then
  if [ -f "$REPORT_SRC" ]; then
    mkdir -p "$REPO_DIR/reports"
    cp "$REPORT_SRC" "$REPORT_DEST"
    echo "Copied report from D:/Reports/"
  else
    echo "Error: No report found at $REPORT_SRC"
    exit 1
  fi
fi

cd "$REPO_DIR"

# 更新 reports.json
node -e "
  const fs = require('fs');
  const data = JSON.parse(fs.readFileSync('reports.json', 'utf8'));
  const week = '${WEEK}';
  const period = '${PERIOD}';
  if (!data.find(r => r.week === week)) {
    data.push({ week, period, file: 'reports/${WEEK}.html' });
    data.sort((a, b) => a.week.localeCompare(b.week));
  }
  fs.writeFileSync('reports.json', JSON.stringify(data, null, 2) + '\n');
"

# Git commit & push
git add reports/ reports.json
git diff --staged --quiet || {
  git commit -m "Add weekly market wrap for ${WEEK} (${PERIOD})"
  git push
}

echo ""
echo "Published! View at: https://stevenhchang.github.io/weekly-market-wrap/reports/${WEEK}.html"
