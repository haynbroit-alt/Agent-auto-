# FogLifter (stack MVP)

Orchestration **n8n** + **PostgreSQL** (n8n + base métier), workflow d’import JSON, matching léger et alertes **Telegram**. Tout est documenté en français dans `docs/GUIDE-COMPLET.md`.

## Démarrage rapide

```bash
cp .env.example .env
# Éditer .env : mots de passe, OPENAI_API_KEY, TELEGRAM_CHAT_ID, N8N_ENCRYPTION_KEY (prod)

docker compose up -d
```

Importer `workflows/foglifter-main.json` dans n8n, créer les **credentials Postgres** (`foglifter-postgres`) et **Telegram**, puis exécuter un test manuel.

## Contenu du dépôt

- `docker-compose.yml` — services n8n, Postgres interne n8n, Postgres FogLifter
- `sql/001_foglifter_schema.sql` — tables `fl_*`
- `sql/002_seed_example_companies.sql` — données de démo optionnelles
- `workflows/foglifter-main.json` — workflow MVP (RSS → OpenAI → PG → score → Telegram)
- `docs/GUIDE-COMPLET.md` — guide pas à pas (VPS, sécurité, mobile)
- `docs/MAKE-COM-NOCODE.md` — variante orchestrée sur Make.com

## Alternative no-code

Voir `docs/MAKE-COM-NOCODE.md` pour une version sans VPS (coût Make à prévoir).
