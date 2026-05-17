# FogLifter / Clarity — hub du dépôt

[![Démarrage](https://img.shields.io/badge/docs-00--DEMARRAGE-0366d6)](./docs/00-DEMARRAGE.md)
[![Agents](https://img.shields.io/badge/rules-AGENTS-6f42c1)](./AGENTS.md)

**Commence par** [`docs/00-DEMARRAGE.md`](docs/00-DEMARRAGE.md) (parcours en 10 étapes, carte des docs, dépannage).  
**Agents IA** : lis [`AGENTS.md`](AGENTS.md) avant toute modification.

Ce dépôt contient une **usine à signaux** modulaire :

- **Composer 1** — matching entreprise ↔ subvention : `workflows/foglifter-main.json`, `sql/001_foglifter_schema.sql`.
- **Composer 2** — arbitrage réglementaire ↔ instruments : `workflows/foglifter-arbitrage.json`, `sql/003_arbitrage_schema.sql`, index `sql/005_performance_indexes.sql`.

## En 30 secondes

```bash
git clone <URL_DE_TON_DEPOT>.git
cd <NOM_DU_DOSSIER_REPO>
cp .env.example .env   # puis édite les lignes OBLIGATOIRES
make check
make up
```

Puis importe les workflows dans n8n et configure les **credentials** Postgres + Telegram (détail dans [`docs/00-DEMARRAGE.md`](docs/00-DEMARRAGE.md)).

## Schéma

```mermaid
flowchart LR
  Repo[Dépôt GitHub]
  GA[GitHub Actions]
  VPS[VPS Docker]
  N8N[n8n]
  DB[(Postgres FogLifter + n8n)]
  Repo --> VPS
  GA -->|webhook optionnel| N8N
  VPS --> N8N
  N8N --> DB
```

## Documentation (index)

| Sujet | Fichier |
|-------|---------|
| **Démarrage guidé** | [`docs/00-DEMARRAGE.md`](docs/00-DEMARRAGE.md) |
| **Agents (IA)** | [`AGENTS.md`](AGENTS.md) |
| VPS, mobile, migrations | [`docs/GUIDE-COMPLET.md`](docs/GUIDE-COMPLET.md) |
| Composer 2 | [`docs/COMPOSER-2-ARBITRAGE.md`](docs/COMPOSER-2-ARBITRAGE.md) |
| Performance, backups, HTTPS | [`docs/PERFORMANCE-ET-EXPLOITATION.md`](docs/PERFORMANCE-ET-EXPLOITATION.md) |
| Architecture GitHub + cloud | [`docs/ARCHITECTURE-GITHUB-CENTRE.md`](docs/ARCHITECTURE-GITHUB-CENTRE.md), [`docs/GITHUB-ACTIONS-SECRETS.md`](docs/GITHUB-ACTIONS-SECRETS.md) |
| Make.com | [`docs/MAKE-COM-NOCODE.md`](docs/MAKE-COM-NOCODE.md) |

## Raccourcis Makefile

`make help` — voir `Makefile` (`check`, `up`, `down`, `logs`, `backup`, `ps`).

## Fichiers techniques utiles

| Rôle | Chemin |
|------|--------|
| Stack Docker | `docker-compose.yml` |
| Orchestration planifiée | `.github/workflows/foglifter-engine.yml` |
| Sauvegardes | `scripts/backup-foglifter.sh`, `scripts/restore-foglifter.sh` |
| Vérifs locales | `scripts/check-environment.sh` |
| TLS (exemple) | `docker/caddy/Caddyfile.example` |

## Roadmap (rappel)

Composer 3 → 5 : narrative / marketplace / fonds — voir fin de `docs/GUIDE-COMPLET.md` et `AGENTS.md` pour ne pas dériver hors périmètre.

## Avertissement

**Composer 2** produit des signaux techniques, pas des conseils en investissement (conformité AMF / MiFID selon ton cas).
