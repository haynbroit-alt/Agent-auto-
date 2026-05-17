# FogLifter — Composer 1 & 2

Orchestration **n8n** + **PostgreSQL** (base interne n8n + base métier `foglifter`). Ce dépôt couvre :

- **Composer 1** — matching entreprise ↔ subvention (commission au succès) : `workflows/foglifter-main.json`, schéma `sql/001_foglifter_schema.sql`.
- **Composer 2** — signaux d’**arbitrage réglementaire** (événements ↔ instruments) : `workflows/foglifter-arbitrage.json`, schéma `sql/003_arbitrage_schema.sql`.

Documentation : `docs/GUIDE-COMPLET.md`, `docs/COMPOSER-2-ARBITRAGE.md`, `docs/MAKE-COM-NOCODE.md`.

## Démarrage rapide

```bash
cp .env.example .env
# Éditer .env : mots de passe, OPENAI_API_KEY, TELEGRAM_CHAT_ID, N8N_ENCRYPTION_KEY (prod), WEBHOOK_URL (HTTPS), optionnel BROKER_WEBHOOK_URL

docker compose up -d
```

Importer les workflows n8n, créer les **credentials Postgres** (`foglifter-postgres`) et **Telegram**, appliquer les SQL sur une base déjà existante si besoin (voir les guides).

## Fichiers clés

| Composer | SQL | Workflow | Doc |
|----------|-----|----------|-----|
| 1 | `001`, `002` (seed entreprises) | `workflows/foglifter-main.json` | `docs/GUIDE-COMPLET.md` |
| 2 | `003`, `004` (seed instruments) | `workflows/foglifter-arbitrage.json` | `docs/COMPOSER-2-ARBITRAGE.md` |

Script utilitaire (hors n8n) : `scripts/arbitrage-scoring.py`.

## Roadmap (esquisse)

- **Composer 3** — veille narrative (X, médias) + indicateurs de « fog » / sentiment public.
- **Composer 4** — marketplace d’experts (Clarity Network).
- **Composer 5** — fonds / exécution (Clarity Fund), garde-fous conformité.

## Avertissement

Les sorties **Composer 2** sont des aides à la décision techniques, pas des conseils en investissement. Conformité AMF / MiFID / obligations d’information à respecter selon ton statut.
