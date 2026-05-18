# AGENTS.md — règles pour humains et agents IA

Ce fichier cadre le travail sur le dépôt **FogLifter / Clarity Layer** (Docker, SQL, workflows **n8n** exportés, GitHub Actions, documentation).

## Principes

- **Modularité** : un « Composer » = un domaine clair (subventions, arbitrage réglementaire, etc.). Éviter les mélanges de responsabilités dans un même workflow sans bonne raison.
- **Traçabilité** : tout changement **fonctionnel** est versionné (Git) et, si tu touches aux flux métier, documenté (README / `docs/00-DEMARRAGE.md` / guide concerné).
- **Journalisation métier** : les workflows existants écrivent dans **`fl_action_logs`** pour certaines actions (notifications, etc.). Ce n’est **pas** une obligation pour une simple modification de documentation dans le dépôt Git.
- **Sécurité** : jamais de clés API, tokens ou mots de passe dans le code ou les workflows exportés ; utiliser **Secrets GitHub**, **Credentials n8n** et `.env` (non versionné).

## Ressources du dépôt

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution humaine.
- [`docs/INDEX.md`](docs/INDEX.md) — liste ordonnée de toute la documentation.
- [`LICENSE`](LICENSE) — licence MIT.
- [`SECURITY.md`](SECURITY.md) — signalement de vulnérabilités.

## Règles non négociables

1. Ne **jamais** committer : `.env`, clés API, mots de passe, URLs de webhook avec jeton.
2. Ne **pas** retirer les guides d’entrée (`docs/00-DEMARRAGE.md`, `README.md`) sans chemins de remplacement clairs.
3. Toute **nouvelle** variable d’environnement : entrée dans **`.env.example`** + branchement dans **`docker-compose.yml`** si un service en dépend.

## Ordre de lecture pour orienter un humain

1. `docs/00-DEMARRAGE.md`
2. `README.md`
3. Selon le sujet : `docs/GUIDE-COMPLET.md`, `docs/PERFORMANCE-ET-EXPLOITATION.md`, `docs/COMPOSER-2-ARBITRAGE.md`, `docs/ARCHITECTURE-GITHUB-CENTRE.md`

## Standards utiles (prompts / JSON côté n8n)

- **Rôle** explicite (ex. extracteur d’aides publiques françaises).
- **Format de sortie** strict lorsque tu attends du JSON (schéma décrit dans le workflow ou le sticky note).
- **Gestion d’échec** : prévoir contenu minimal en cas de parse error (les workflows du dépôt suivent déjà ce pattern).
- **Confiance** : lorsque le produit métier impose un score, le calcul ou l’extraction doit rester **cohérent** avec les nœuds IF en aval (ne pas casser les seuils sans mise à jour des docs).

## Roadmap (périmètre produit)

- **Composer 1** — Subventions (workflow `foglifter-main.json`).
- **Composer 2** — Arbitrage réglementaire (`foglifter-arbitrage.json`).
- **Composer 3** — Veille narrative + indicateurs type « fog » (hors périmètre actuel du dépôt sauf ajout explicite).
- **Composer 4** — Marketplace experts (idem).
- **Composer 5** — Fonds / exécution (idem).

Ne pas étendre ces périmètres **sans** demande claire ou sans mettre à jour la doc d’entrée.

## Checklist avant de dire « terminé »

- [ ] `./scripts/check-environment.sh` — JSON workflows valides ; YAML si PyYAML disponible ; absence de Docker = avertissement seulement.
- [ ] Scripts shell : `chmod +x` + shebang `#!/usr/bin/env bash` si nouveau.
- [ ] Migration SQL **hors** `docker-entrypoint-initdb.d` : commande `psql` / `docker compose exec` documentée pour bases déjà créées.
- [ ] `docs/00-DEMARRAGE.md` mis à jour si le parcours utilisateur change.

## Branches et livraison

- Branches de travail : préfixe `cursor/<sujet>-9060` lorsque la convention du projet l’exige.
- Commits : message explicite (effet utilisateur).
- Pousser sur `origin` et ouvrir / mettre à jour une PR selon le process du dépôt.

## Pièges connus

- **Volumes Postgres** : scripts `docker-entrypoint-initdb.d` uniquement à la **création** du volume.
- **Cron GitHub Actions** : toujours en **UTC**.
- **Credentials n8n** : absents des exports JSON ; les nœuds HTTP OpenAI du repo utilisent souvent `$env.OPENAI_API_KEY`.

## Périmètre des changements

Rester focalisé sur la demande : pas de refactor massif ni de nouveaux services Docker sans besoin exprimé. Préférer documentation + scripts **idempotents**.

## Cursor Cloud specific instructions

### Services

This is a Docker Compose stack with 3 services:

| Service | Role | Port |
|---------|------|------|
| `postgres` | n8n internal metadata DB (Postgres 16) | 5432 (internal) |
| `foglifter-postgres` | FogLifter business data DB (Postgres 16) | 5432 (internal) |
| `n8n` | Workflow automation engine (UI + API) | 5678 (exposed) |

### Starting the stack

```bash
# Ensure Docker daemon is running (update script handles this)
cd /workspace
docker compose up -d
# Wait ~15s for healthchecks, then:
curl -s http://localhost:5678/healthz  # → {"status":"ok"}
```

### n8n owner account (dev)

On first setup the owner account must be created via:
```bash
curl -s http://localhost:5678/rest/owner/setup -X POST \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@foglifter.local","firstName":"Dev","lastName":"Agent","password":"DevPassword123!"}'
```

Login uses field `emailOrLdapLoginId` (not `email`):
```bash
curl -s http://localhost:5678/rest/login -X POST \
  -H 'Content-Type: application/json' \
  -d '{"emailOrLdapLoginId":"dev@foglifter.local","password":"DevPassword123!"}' \
  -c /tmp/n8n-cookies.txt
```

### Importing workflows

Use the REST API with session cookies (not the public API which requires scoped keys):
```bash
curl -s http://localhost:5678/rest/workflows -X POST \
  -H 'Content-Type: application/json' \
  -b /tmp/n8n-cookies.txt \
  -d @workflows/foglifter-main.json
```

### Loading seed data

```bash
docker compose exec -T foglifter-postgres psql -U foglifter -d foglifter < sql/002_seed_example_companies.sql
docker compose exec -T foglifter-postgres psql -U foglifter -d foglifter < sql/004_seed_arbitrage_instruments.sql
```

### Lint / validation

- `make check` or `./scripts/check-environment.sh` — validates JSON workflows, YAML syntax, Docker presence
- JSON validation only: `python3 -m json.tool workflows/<file>.json`

### Key gotchas

- The `docker-entrypoint-initdb.d` SQL scripts only run on **first volume creation**. If volumes already exist, apply new SQL migrations manually via `docker compose exec -T foglifter-postgres psql ...`.
- The `.env` file is never committed (`.gitignore`). The update script auto-generates one with dev passwords if missing.
- Workflow execution requires a real `OPENAI_API_KEY` — the stack starts fine without it but LLM nodes will fail at runtime.
- n8n credentials (Telegram bot token, etc.) are not in workflow exports — they must be created in the n8n UI after import.
