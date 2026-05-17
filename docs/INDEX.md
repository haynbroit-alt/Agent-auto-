# Index de la documentation — FogLifter / Clarity Layer

**Dépôt GitHub** : [haynbroit-alt/Agent-auto-](https://github.com/haynbroit-alt/Agent-auto-)

Tous les fichiers Markdown du projet (ordre logique de lecture).

| Ordre | Fichier | Contenu |
|:-----:|---------|---------|
| 1 | [`00-DEMARRAGE.md`](00-DEMARRAGE.md) | Point d’entrée : 30 secondes, 10 étapes, carte, dépannage |
| 2 | [`../README.md`](../README.md) | Hub du dépôt, badges, liens |
| 3 | [`../AGENTS.md`](../AGENTS.md) | Règles pour agents IA et contributeurs |
| 4 | [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Comment contribuer |
| 5 | [`GUIDE-COMPLET.md`](GUIDE-COMPLET.md) | VPS, mobile, migrations SQL, sécurité |
| 6 | [`COMPOSER-2-ARBITRAGE.md`](COMPOSER-2-ARBITRAGE.md) | Composer 2 — arbitrage réglementaire |
| 7 | [`PERFORMANCE-ET-EXPLOITATION.md`](PERFORMANCE-ET-EXPLOITATION.md) | Perf Postgres/n8n, backups, HTTPS, scaling |
| 8 | [`ARCHITECTURE-GITHUB-CENTRE.md`](ARCHITECTURE-GITHUB-CENTRE.md) | GitHub au centre, briques cloud remplaçables |
| 9 | [`GITHUB-ACTIONS-SECRETS.md`](GITHUB-ACTIONS-SECRETS.md) | Secrets Actions, webhooks, cron UTC |
| 10 | [`MAKE-COM-NOCODE.md`](MAKE-COM-NOCODE.md) | Alternative Make.com |
| 11 | [`RENDER.md`](RENDER.md) | Déploiement n8n sur Render (Dockerfile racine, `PORT`, env) |

## Fichiers hors `docs/`

| Fichier | Rôle |
|---------|------|
| [`LICENSE`](../LICENSE) | Licence MIT |
| [`SECURITY.md`](../SECURITY.md) | Signalement de vulnérabilités |
| [`.github/workflows/foglifter-engine.yml`](../.github/workflows/foglifter-engine.yml) | Workflow GitHub Actions |
| [`Dockerfile`](../Dockerfile) | Image n8n pour Render (`PORT` → `N8N_PORT`) |
| [`docker-compose.yml`](../docker-compose.yml) | Stack Docker complète (local / VPS) |
| [`Makefile`](../Makefile) | Raccourcis `make` |
