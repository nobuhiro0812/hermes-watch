#!/bin/bash
# Fetch the Hermes JP product sitemap and diff against the previous snapshot.
# New URLs = newly listed (or re-listed) products.
set -euo pipefail

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
STATE="state/products.txt"
mkdir -p state reports

TMP=$(mktemp)
curl -s --max-time 90 -A "$UA" \
  "https://www.hermes.com/jp/ja/sitemaps/products.xml?page=1" \
  | grep -o '<loc>[^<]*</loc>' | sed 's/<[^>]*>//g' | sort -u > "$TMP"

COUNT=$(wc -l < "$TMP" | tr -d ' ')

# Safety valve: if the fetch looks broken/blocked, keep the previous state.
if [ "$COUNT" -lt 1000 ]; then
  echo "ERROR: too few items ($COUNT), keeping previous state"
  exit 1
fi

if [ ! -f "$STATE" ]; then
  cp "$TMP" "$STATE"
  echo "BASELINE_CREATED: $COUNT items"
  exit 0
fi

NEW=$(comm -13 "$STATE" "$TMP" || true)
cp "$TMP" "$STATE"

if [ -z "$NEW" ]; then
  echo "NO_NEW: $COUNT items"
else
  echo "NEW_PRODUCTS: $(echo "$NEW" | wc -l | tr -d ' ')"
  echo "$NEW"
fi
