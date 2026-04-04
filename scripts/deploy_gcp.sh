#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="fli-further-public"
KEY_FILE="${1:-}"
REGION="${2:-us-central}"
DOMAIN_ROOT="${3:-flifurther.com}"
DOMAIN_WWW="www.${DOMAIN_ROOT}"

if [[ -z "$KEY_FILE" ]]; then
  KEY_FILE="$(find . -maxdepth 1 -type f -name '*.json' ! -name 'firebase.json' | head -n 1 | sed 's#^\./##')"
fi

if [[ ! -f "$KEY_FILE" ]]; then
  echo "Missing key file: $KEY_FILE" >&2
  exit 1
fi

gcloud auth activate-service-account --key-file="$KEY_FILE" --quiet >/dev/null
gcloud config set project "$PROJECT_ID" --quiet >/dev/null

if ! gcloud app describe --project "$PROJECT_ID" >/dev/null 2>&1; then
  gcloud app create --project "$PROJECT_ID" --region "$REGION" --quiet
fi

gcloud app deploy app.yaml --project "$PROJECT_ID" --quiet
APP_HOSTNAME="$(gcloud app describe --project "$PROJECT_ID" --format='value(defaultHostname)')"

echo "Deployed: https://${APP_HOSTNAME}"

gcloud app domain-mappings create "$DOMAIN_ROOT" --project "$PROJECT_ID" --quiet || true
gcloud app domain-mappings create "$DOMAIN_WWW" --project "$PROJECT_ID" --quiet || true

echo
echo "Domain DNS records required by GCP:"
gcloud app domain-mappings describe "$DOMAIN_ROOT" --project "$PROJECT_ID" --format='yaml(resourceRecords)' || true
gcloud app domain-mappings describe "$DOMAIN_WWW" --project "$PROJECT_ID" --format='yaml(resourceRecords)' || true
