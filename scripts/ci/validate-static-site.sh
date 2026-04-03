#!/usr/bin/env bash

set -euo pipefail

required_files=(
  CNAME
  css/style.css
  firebase.json
  index.html
  legal.html
  privacy.html
  refund.html
  terms.html
)

missing=0
for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

html_files=(
  index.html
  legal.html
  privacy.html
  refund.html
  terms.html
)

for html_file in "${html_files[@]}"; do
  if ! grep -q '^<!DOCTYPE html>' "$html_file"; then
    echo "Missing HTML5 doctype: $html_file" >&2
    exit 1
  fi

  if ! grep -q '</html>' "$html_file"; then
    echo "Missing closing </html> tag: $html_file" >&2
    exit 1
  fi

  if ! grep -q '<meta name="viewport"' "$html_file"; then
    echo "Missing viewport meta tag: $html_file" >&2
    exit 1
  fi
done

if [[ -f netlify.toml ]]; then
  echo "netlify.toml should be removed after GCP cutover." >&2
  exit 1
fi

if grep -R -n -E 'NETLIFY_(SITE_ID|AUTH_TOKEN)|netlify/actions/cli' .github/workflows/*.yml >/dev/null 2>&1; then
  echo "Netlify deployment references are still present in GitHub workflows." >&2
  exit 1
fi

jq -e '.' firebase.json >/dev/null

for source_path in /free-guide /start-here /about; do
  jq -e --arg source_path "$source_path" \
    '.hosting.redirects[] | select(.source == $source_path and .destination == "/" and .type == 301)' \
    firebase.json >/dev/null
done

echo "Static validation passed."
