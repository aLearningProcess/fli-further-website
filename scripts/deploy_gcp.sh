#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="fli-further-public"
REGION="${1:-us-central}"
DOMAIN_ROOT="${2:-flifurther.com}"
DOMAIN_WWW="www.${DOMAIN_ROOT}"

if ! gcloud auth list --filter=status:ACTIVE --format='value(account)' | grep -q .; then
  echo "No active gcloud account. Run 'gcloud auth login' before deploying." >&2
  exit 1
fi

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
