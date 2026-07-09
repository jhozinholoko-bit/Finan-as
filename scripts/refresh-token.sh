#!/usr/bin/env bash
# Renova o access_token usando o refresh_token.
# Uso:
#   export LINKEDIN_CLIENT_ID=...
#   export LINKEDIN_CLIENT_SECRET=...
#   export LINKEDIN_REFRESH_TOKEN=...
#   ./scripts/refresh-token.sh

set -euo pipefail

: "${LINKEDIN_CLIENT_ID:?defina LINKEDIN_CLIENT_ID}"
: "${LINKEDIN_CLIENT_SECRET:?defina LINKEDIN_CLIENT_SECRET}"
: "${LINKEDIN_REFRESH_TOKEN:?defina LINKEDIN_REFRESH_TOKEN}"

response=$(curl -sS -X POST https://www.linkedin.com/oauth/v2/accessToken \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=refresh_token" \
  --data-urlencode "refresh_token=${LINKEDIN_REFRESH_TOKEN}" \
  --data-urlencode "client_id=${LINKEDIN_CLIENT_ID}" \
  --data-urlencode "client_secret=${LINKEDIN_CLIENT_SECRET}")

if command -v jq >/dev/null 2>&1; then
  echo "$response" | jq
  echo
  echo "Atualize as env vars do ambiente:"
  echo "LINKEDIN_ACCESS_TOKEN=$(echo "$response" | jq -r .access_token)"
  new_refresh=$(echo "$response" | jq -r '.refresh_token // empty')
  if [ -n "$new_refresh" ]; then
    echo "LINKEDIN_REFRESH_TOKEN=$new_refresh"
  fi
else
  echo "$response"
fi
