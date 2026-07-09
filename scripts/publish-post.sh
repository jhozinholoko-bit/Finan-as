#!/usr/bin/env bash
# Publica um post de texto no LinkedIn via /v2/ugcPosts.
#
# Uso:
#   echo "conteudo do post" | ./scripts/publish-post.sh
#   ./scripts/publish-post.sh "conteudo do post"
#   ./scripts/publish-post.sh --file post.txt
#
# Requer:
#   LINKEDIN_ACCESS_TOKEN  (Bearer token OAuth com scope w_member_social)
#   LINKEDIN_PERSON_URN    (formato: urn:li:person:XXXXXXXX)

set -euo pipefail

: "${LINKEDIN_ACCESS_TOKEN:?defina LINKEDIN_ACCESS_TOKEN}"
: "${LINKEDIN_PERSON_URN:?defina LINKEDIN_PERSON_URN (ex: urn:li:person:AbC123)}"

if [[ "${1:-}" == "--file" && -n "${2:-}" ]]; then
  content=$(cat "$2")
elif [[ -n "${1:-}" ]]; then
  content="$1"
else
  content=$(cat)
fi

if [ -z "$content" ]; then
  echo "Erro: conteudo vazio" >&2
  exit 1
fi

# JSON-encode o conteudo preservando quebras de linha e caracteres especiais.
if command -v jq >/dev/null 2>&1; then
  encoded=$(printf '%s' "$content" | jq -Rs .)
else
  # Fallback: escapa " e \, converte quebras de linha.
  encoded=$(printf '%s' "$content" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
    | awk 'BEGIN{ORS=""} {print (NR>1?"\\n":"") $0}')
  encoded="\"$encoded\""
fi

body=$(cat <<JSON
{
  "author": "${LINKEDIN_PERSON_URN}",
  "lifecycleState": "PUBLISHED",
  "specificContent": {
    "com.linkedin.ugc.ShareContent": {
      "shareCommentary": { "text": ${encoded} },
      "shareMediaCategory": "NONE"
    }
  },
  "visibility": { "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC" }
}
JSON
)

response=$(curl -sS -w "\nHTTP_STATUS:%{http_code}" -X POST \
  https://api.linkedin.com/v2/ugcPosts \
  -H "Authorization: Bearer ${LINKEDIN_ACCESS_TOKEN}" \
  -H "X-Restli-Protocol-Version: 2.0.0" \
  -H "Content-Type: application/json" \
  --data-raw "$body")

status=$(echo "$response" | tail -n1 | sed 's/HTTP_STATUS://')
payload=$(echo "$response" | sed '$d')

echo "$payload"
echo
echo "HTTP $status"

if [ "$status" != "201" ]; then
  echo "Falha ao publicar." >&2
  exit 1
fi
