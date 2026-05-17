# FogLifter — Composer 1 & 2

Orchestration **n8n** + **PostgreSQL** (base interne n8n + base métier `foglifter`). Ce dépôt couvre :

- **Composer 1** — matching entreprise ↔ subvention (commission au succès) : `workflows/foglifter-main.json`, schéma `sql/001_foglifter_schema.sql`.
- **Composer 2** — signaux d’**arbitrage réglementaire** (événements ↔ instruments) : `workflows/foglifter-arbitrage.json`, schémas `sql/003_arbitrage_schema.sql` + index `sql/005_performance_indexes.sql`.

## Documentation

| Sujet | Fichier |
|-------|---------|
| Déploiement smartphone / VPS | `docs/GUIDE-COMPLET.md` |
| Composer 2 (installation, migration SQL) | `docs/COMPOSER-2-ARBITRAGE.md` |
| **Performance, sauvegardes, HTTPS, scaling** | `docs/PERFORMANCE-ET-EXPLOITATION.md` |
| Variante Make.com | `docs/MAKE-COM-NOCODE.md` |

## Démarrage rapide

```bash
cp .env.example .env
# Éditer .env : mots de passe, OPENAI_API_KEY, TELEGRAM_CHAT_ID, N8N_ENCRYPTION_KEY (prod),
# WEBHOOK_URL (HTTPS), timeouts / pruning n8n, tuning Postgres (optionnel)

docker compose up -d
```

Importer les workflows n8n, créer les **credentials Postgres** (`foglifter-postgres`) et **Telegram**, appliquer les migrations SQL sur une base **déjà existante** si besoin (`005` et seeds — voir les guides).

## Performance et exploitation

- **Postgres** : paramètres serveur injectés via `docker-compose.yml` (variables `POSTGRES_*` dans `.env.example`), `shm_size`, index GIN/B-tree dans `sql/005_performance_indexes.sql`.
- **n8n** : pruning des exécutions, timeouts, limite de payload ; **retries** sur les nœuds HTTP OpenAI / broker dans les workflows exportés.
- **Docker** : rotation des logs conteneurs (`x-logging`).
- **Sauvegardes** : `scripts/backup-foglifter.sh` et `scripts/restore-foglifter.sh`.
- **HTTPS** : exemple Caddy dans `docker/caddy/Caddyfile.example`.
- **Ressources** : exemple de plafonds CPU/RAM dans `docker-compose.override.example.yml`.

## Fichiers clés (résumé)

| Composer | SQL | Workflow |
|----------|-----|----------|
| 1 | `001`, `002` (seed entreprises), `005` (index partagés) | `workflows/foglifter-main.json` |
| 2 | `003`, `004` (seed instruments), `005` | `workflows/foglifter-arbitrage.json` |

Scripts : `scripts/arbitrage-scoring.py`, `scripts/backup-foglifter.sh`, `scripts/restore-foglifter.sh`.

## Roadmap (esquisse)

- **Composer 3** — veille narrative (X, médias) + indicateurs de « fog » / sentiment public.
- **Composer 4** — marketplace d’experts (Clarity Network).
- **Composer 5** — fonds / exécution (Clarity Fund), garde-fous conformité.

## Avertissement

Les sorties **Composer 2** sont des aides à la décision techniques, pas des conseils en investissement. Conformité AMF / MiFID / obligations d’information à respecter selon ton statut.
