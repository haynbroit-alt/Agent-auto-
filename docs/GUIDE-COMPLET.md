# FogLifter — guide complet (smartphone-friendly)

Ce dépôt regroupe une **stack prête à l’emploi** : Docker (n8n + PostgreSQL), schéma SQL métier, workflows n8n importables (Composer 1 + **Composer 2 — arbitrage réglementaire**, voir `docs/COMPOSER-2-ARBITRAGE.md`), guide **performance / prod** (`docs/PERFORMANCE-ET-EXPLOITATION.md`), et une alternative **Make.com** décrite séparément.

## Objectif

Un agent qui ingère des aides / subventions, extrait une structure JSON via LLM, stocke en PostgreSQL, fait un **matching MVP** (mots-clés + régions), notifie sur **Telegram**, et journalise les actions.

## Architecture (rappel)

| Composant | Rôle |
|-----------|------|
| n8n | Orchestration (RSS, HTTP OpenAI, Postgres, Telegram) |
| PostgreSQL `n8n` | Persistance n8n |
| PostgreSQL `foglifter` | Entreprises, aides extraites, matches, logs |
| OpenAI | Extraction JSON (`gpt-4o-mini` dans le workflow) |
| Telegram | Alertes mobiles |

**Optionnel** : Firecrawl (scraping), Resend (emails), Airtable (CRM), Weaviate (vecteurs) — à brancher dans n8n sans changer le schéma minimal.

## Jour 1 — VPS (Hetzner ou autre)

1. Créer un VPS **Ubuntu 24.04** (ex. CX22).
2. Ajouter ta clé SSH, mettre à jour le pare-feu : **22** (SSH), **5678** (n8n, à refermer derrière HTTPS / IP restreinte dès que possible).
3. Te connecter (Termius, etc.).

## Jour 2 — Installation Docker + n8n + base FogLifter

Sur le serveur :

```bash
curl -fsSL https://get.docker.com | sh
sudo apt-get update && sudo apt-get install -y git
git clone <ton-repo> foglifter && cd foglifter
cp .env.example .env
nano .env   # mots de passe forts + OPENAI_API_KEY + TELEGRAM_CHAT_ID
openssl rand -hex 32   # pour N8N_ENCRYPTION_KEY (recommandé)
```

Puis :

```bash
docker compose up -d
```

- n8n : `http://IP_DU_SERVEUR:5678` (idéalement derrière **Caddy / Traefik / Nginx Proxy Manager** en HTTPS).
- La base métier est initialisée automatiquement via `sql/001_foglifter_schema.sql`.

## Jour 3 — n8n : credentials et import workflow

1. Créer le compte owner n8n au premier lancement.
2. **Credentials → Postgres** : hôte `foglifter-postgres`, port `5432`, database / user / password = valeurs `FOGLIFTER_*` du `.env`. Tester la connexion.
3. **Credentials → Telegram** : token du bot (**@BotFather**).
4. Menu **⋯ → Import from File** : importer `workflows/foglifter-main.json`.
5. Sur chaque node **Postgres** et **Telegram**, rattacher les credentials créés.
6. Vérifier que le conteneur n8n reçoit bien `OPENAI_API_KEY` et `TELEGRAM_CHAT_ID` (voir `docker-compose.yml`).

## Jour 4-5 — Données entreprises + RSS

1. Charger des lignes dans `fl_companies` (API SIRENE, CSV, etc.). Exemple : `sql/002_seed_example_companies.sql`.
2. Adapter l’URL du node **RSS aides (exemple)** (BPI, Europe, régions, etc.). Tu peux dupliquer le node et utiliser un **Merge** pour agréger plusieurs flux.
3. (Optionnel) Insérer un node **HTTP Request** Firecrawl entre RSS et LLM si tu dois lire des pages HTML complètes.

## Jour 6-7 — Tests

1. **Execute Workflow** manuellement dans n8n.
2. Contrôler les tables : `fl_subsidies_raw`, `fl_matches`, `fl_action_logs`.
3. Ajuster le seuil du node **Match fort ?** (score ≥ 35 par défaut) et la logique du Code **Score matches (MVP)**.

## Sécurité (indispensable)

- Ne **jamais** committer `.env`.
- Fermer `5678` sur Internet public dès que tu as un domaine + HTTPS.
- `N8N_ENCRYPTION_KEY` : obligatoire dès que tu stockes des credentials dans n8n en production.
- Préférer **n8n Credentials** pour OpenAI plutôt que la variable d’environnement si tu veux éviter d’exposer la clé au sandbox Code (ce workflow utilise HTTP + `$env` pour rester simple).

## Fichiers utiles

| Fichier | Description |
|---------|-------------|
| `docker-compose.yml` | n8n + 2 bases PostgreSQL |
| `sql/001_foglifter_schema.sql` | Schéma métier Composer 1 |
| `sql/002_seed_example_companies.sql` | Données de test |
| `sql/003_arbitrage_schema.sql` | Schéma Composer 2 |
| `sql/004_seed_arbitrage_instruments.sql` | Instruments de test |
| `sql/005_performance_indexes.sql` | Index GIN/B-tree + ANALYZE (perf lecture / JSON) |
| `workflows/foglifter-main.json` | Workflow MVP Composer 1 |
| `workflows/foglifter-arbitrage.json` | Workflow Composer 2 |
| `scripts/arbitrage-scoring.py` | Scoring backup hors n8n |
| `scripts/backup-foglifter.sh` | Sauvegardes `pg_dump` |
| `scripts/restore-foglifter.sh` | Restauration ciblée |
| `docs/PERFORMANCE-ET-EXPLOITATION.md` | Tuning Postgres/n8n, HTTPS, cron, scaling |
| `docker/caddy/Caddyfile.example` | Exemple TLS (Caddy) |
| `docker-compose.override.example.yml` | Plafonds CPU/RAM type prod |
| `docs/COMPOSER-2-ARBITRAGE.md` | Installation Composer 2 |
| `docs/MAKE-COM-NOCODE.md` | Variante 100 % hébergée (Make) |

## Mobile au quotidien

- **Telegram** : alertes « match fort ».
- **Navigateur** : n8n pour valider / ajuster les workflows.
- **SSH** : maintenance ponctuelle (mises à jour Docker).
