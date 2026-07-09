# Contexto do projeto

Este repositório existe pra publicar automaticamente, todo dia às 8h (horário de Brasília), um post no LinkedIn do dono da conta (Victor) sobre o que está mais em alta no mercado de marketing digital, mídia paga, Google Ads, Meta Ads, TikTok Ads e IA aplicada a marketing.

Tom desejado nos posts: **casual, conversa com o mercado**. Opinativo, provocativo o suficiente pra gerar debate nos comentários. Nada corporativo/institucional.

## Fluxo diário (rotina disparada pelo Routine agendado)

Quando você (Claude) for acionado pelo Routine diário, execute os passos abaixo. Se estiver rodando manualmente a pedido do usuário, faça o mesmo mas **mostre o texto antes de publicar** e peça confirmação.

### 1. Pesquisar tendências
Use `WebSearch` (varie os termos, faça 3-5 buscas) buscando notícias das últimas 24-48h sobre:

- Google Ads, Google Marketing Platform, Google Analytics, Performance Max, atualizações do algoritmo do Google
- Meta Ads (Facebook/Instagram), Advantage+, políticas da Meta, atualizações do Reels/Threads
- TikTok Ads, Spark Ads, TikTok Shop
- IA aplicada a marketing (ChatGPT, Gemini, Claude e ferramentas de criativo)
- Mudanças de privacidade/cookies, Consent Mode v2, GA4
- Cases/benchmarks relevantes de performance no Brasil

Priorize fontes: Search Engine Land, Search Engine Journal, Marketing Land, AdWeek, Meta Newsroom, Google Ads blog, TechCrunch, e no Brasil: Meio & Mensagem, Mundo do Marketing, ProXXIma, Adnews.

### 2. Escolher UM assunto
Escolha 1 assunto — o de maior impacto pra quem trabalha com performance e mídia paga. Se o dia estiver "morno" e sem novidade forte, prefira um tema atemporal (ex: um insight sobre atribuição, um erro comum em campanha) do que forçar uma notícia irrelevante.

### 3. Escrever o post
Regras:

- **Idioma**: português do Brasil.
- **Tom**: casual, primeira pessoa, como se fosse uma conversa no bar sobre o que rolou hoje. Pode discordar, provocar, dar opinião.
- **Formato**: comece com um gancho forte na 1ª linha (o LinkedIn corta o resto). Máx 1300 caracteres no total. Quebras de linha entre parágrafos curtos (2-3 linhas cada) — LinkedIn valoriza whitespace.
- **Sem emojis excessivos**. No máx 1-2, e só se agregar.
- **Sem hashtags no rodapé estilo #marketing #ads #tráfego**. LinkedIn hoje penaliza. Se usar hashtag, no máx 2 e integradas ao texto.
- **Termine com pergunta** pro leitor comentar (gerar engajamento).
- **Não invente dados**. Se citar número, tem que ter vindo da pesquisa. Se não tiver certeza, deixe genérico.

### 4. Publicar
Rode:

```bash
./scripts/publish-post.sh --file /tmp/post.txt
```

(Salve o texto do post em `/tmp/post.txt` antes.)

O script vai usar `LINKEDIN_ACCESS_TOKEN` e `LINKEDIN_PERSON_URN` do ambiente. Se retornar HTTP 201 → sucesso.

### 5. Tratar erros
- **HTTP 401** → token expirou. **Não tente republicar.** Termine a sessão informando ao usuário: "Token do LinkedIn expirou. Rode `./scripts/refresh-token.sh` localmente e atualize a env var `LINKEDIN_ACCESS_TOKEN` no ambiente."
- **HTTP 422 / 400** → provavelmente conteúdo violando política. Ajuste o texto e tente 1x. Se falhar de novo, pare e reporte.
- **HTTP 429** → rate limit. Espere 60s e tente 1x. Se falhar, pare.
- **Outros erros** → pare e reporte.

### 6. Confirmação
Depois de publicar, imprima:
- O texto que foi publicado
- O `id` retornado pela API (fica no header `x-restli-id` ou no corpo da resposta)

## Rodando manualmente

Se o usuário pedir "gera um post agora" ou "roda o fluxo do CLAUDE.md":
- Faça os passos 1-3 acima
- **Mostre o texto e pergunte "publico?"** antes do passo 4

## Setup

Se as env vars `LINKEDIN_ACCESS_TOKEN` ou `LINKEDIN_PERSON_URN` não estiverem definidas, o setup ainda não foi feito. Aponte o usuário pro `README.md`.
