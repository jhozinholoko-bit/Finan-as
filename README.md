# Post diário no LinkedIn — marketing e mídia paga

Automação que, todo dia às 8h (horário de Brasília), pesquisa o que está bombando no mercado de marketing digital, mídia paga, Google Ads, Meta Ads e afins, escreve um post em PT-BR com tom casual e publica no seu LinkedIn via API.

## Como funciona

1. Um **Routine** (agendador durável do Claude Code) dispara todo dia 8h BRT e abre uma sessão nova neste repositório.
2. A sessão executa as instruções do `CLAUDE.md`: pesquisa tendências, escreve o post e publica via `scripts/publish-post.sh`.
3. O script usa a API oficial do LinkedIn (`/v2/ugcPosts`) autenticada com um `access_token` OAuth.

## Setup (uma vez só)

### 1. Criar o app no LinkedIn Developer

1. Acesse https://www.linkedin.com/developers/apps e clique em **Create app**.
2. Preencha nome, LinkedIn Page (pode ser sua página pessoal/empresarial), logo, aceite os termos.
3. Vá em **Products** e solicite:
   - **Share on LinkedIn** — libera o scope `w_member_social` (publicar posts).
   - **Sign In with LinkedIn using OpenID Connect** — libera `openid profile` (necessário pra descobrir seu URN).
4. Em **Auth**, adicione uma **Authorized redirect URL**. Pode ser `http://localhost:8080/callback` — não precisa existir de fato, só é usada como retorno da autorização.
5. Anote o **Client ID** e o **Client Secret** da aba **Auth**.

### 2. Autorizar sua conta e pegar o access token

No seu navegador, cole a URL abaixo trocando `SEU_CLIENT_ID` e o `redirect_uri` pelo que você configurou:

```
https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=SEU_CLIENT_ID&redirect_uri=http://localhost:8080/callback&scope=openid%20profile%20w_member_social
```

Autorize. A página vai redirecionar para algo tipo:

```
http://localhost:8080/callback?code=AQT...longo...&state=...
```

A URL vai dar erro de "site não encontrado" — é esperado. Copie **só o valor do `code`** da URL.

Agora rode localmente (ou em qualquer shell com curl):

```bash
export LINKEDIN_CLIENT_ID="seu_client_id"
export LINKEDIN_CLIENT_SECRET="seu_client_secret"
export LINKEDIN_REDIRECT_URI="http://localhost:8080/callback"
export LINKEDIN_AUTH_CODE="AQT...longo..."

./scripts/exchange-code.sh
```

Isso vai imprimir o `access_token` (válido por ~60 dias) e o `refresh_token`. Guarde os dois.

### 3. Descobrir seu Person URN

```bash
export LINKEDIN_ACCESS_TOKEN="ey..."
./scripts/get-person-urn.sh
```

Vai imprimir algo como `urn:li:person:AbCdEfGh123`. Guarde.

### 4. Salvar as credenciais no ambiente do Claude Code

Na configuração do seu ambiente de Claude Code (https://code.claude.com/docs/en/claude-code-on-the-web), adicione as seguintes environment variables:

- `LINKEDIN_ACCESS_TOKEN` — o token do passo 2
- `LINKEDIN_PERSON_URN` — o URN do passo 3 (formato completo: `urn:li:person:XXXX`)

E, opcionalmente, pra renovação:

- `LINKEDIN_CLIENT_ID`
- `LINKEDIN_CLIENT_SECRET`
- `LINKEDIN_REFRESH_TOKEN`

### 5. Rodar manualmente pra testar

Antes de deixar automatizado, vale testar. Numa sessão do Claude Code neste repo, peça:

> "Roda o fluxo do CLAUDE.md pra publicar um post agora, mas antes me mostra o texto pra eu aprovar."

## Renovação do token

Access tokens do LinkedIn duram **60 dias**. Você recebe um refresh token que dura 1 ano — dá pra renovar automaticamente. Se o post falhar com `401`, roda:

```bash
export LINKEDIN_CLIENT_ID="..."
export LINKEDIN_CLIENT_SECRET="..."
export LINKEDIN_REFRESH_TOKEN="..."
./scripts/refresh-token.sh
```

## Arquivos

- `CLAUDE.md` — instruções que a sessão diária segue
- `scripts/exchange-code.sh` — troca `code` OAuth por `access_token`
- `scripts/get-person-urn.sh` — descobre seu URN
- `scripts/publish-post.sh` — publica o post (recebe texto via stdin)
- `scripts/refresh-token.sh` — renova o access token
- `.env.example` — referência das env vars
