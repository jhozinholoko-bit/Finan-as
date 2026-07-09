#!/usr/bin/env bash
# Descobre o Person URN via /v2/userinfo (OpenID Connect).
# Uso:
#   export LINKEDIN_ACCESS_TOKEN=...
#   ./scripts/get-person-urn.sh

set -euo pipefail

: "${LINKEDIN_ACCESS_TOKEN:?defina LINKEDIN_ACCESS_TOKEN}"

response=$(curl -sS -H "Authorization: Bearer ${LINKEDIN_ACCESS_TOKEN}" \
  https://api.linkedin.com/v2/userinfo)

if command -v jq >/dev/null 2>&1; then
  sub=$(echo "$response" | jq -r .sub)
  if [ -z "$sub" ] || [ "$sub" = "null" ]; then
    echo "Erro ao obter o sub. Resposta:" >&2
    echo "$response" >&2
    exit 1
  fi
  echo "LINKEDIN_PERSON_URN=urn:li:person:${sub}"
else
  echo "$response"
  echo
  echo "Extraia o campo 'sub' e monte: urn:li:person:<sub>"
fi
