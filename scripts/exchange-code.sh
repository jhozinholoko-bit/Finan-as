#!/usr/bin/env bash
# Troca o code do OAuth por access_token + refresh_token.
# Uso:
#   export LINKEDIN_CLIENT_ID=...
#   export LINKEDIN_CLIENT_SECRET=...
#   export LINKEDIN_REDIRECT_URI=http://localhost:8080/callback
#   export LINKEDIN_AUTH_CODE=...
#   ./scripts/exchange-code.sh

set -euo pipefail

: "${LINKEDIN_CLIENT_ID:?defina LINKEDIN_CLIENT_ID}"
: "${LINKEDIN_CLIENT_SECRET:?defina LINKEDIN_CLIENT_SECRET}"
: "${LINKEDIN_REDIRECT_URI:?defina LINKEDIN_REDIRECT_URI}"
: "${LINKEDIN_AUTH_CODE:?defina LINKEDIN_AUTH_CODE (o code da URL de callback)}"

response=$(curl -sS -X POST https://www.linkedin.com/oauth/v2/accessToken \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=authorization_code" \
  --data-urlencode "code=${LINKEDIN_AUTH_CODE}" \
  --data-urlencode "client_id=${LINKEDIN_CLIENT_ID}" \
  --data-urlencode "client_secret=${LINKEDIN_CLIENT_SECRET}" \
  --data-urlencode "redirect_uri=${LINKEDIN_REDIRECT_URI}")

if command -v jq >/dev/null 2>&1; then
  echo "$response" | jq
  echo
  echo "Copie os valores abaixo pras env vars do ambiente do Claude Code:"
  echo "LINKEDIN_ACCESS_TOKEN=$(echo "$response" | jq -r .access_token)"
  echo "LINKEDIN_REFRESH_TOKEN=$(echo "$response" | jq -r .refresh_token)"
else
  echo "$response"
fi
