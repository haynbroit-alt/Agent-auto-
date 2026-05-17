# Instructions pour agents (IA ou automation)

Ce dépôt est une **stack FogLifter** : Docker (`docker-compose.yml`), schémas SQL, workflows **n8n** exportés en JSON, scripts shell/Python, documentation en français.

## Règles non négociables

1. **Ne jamais** committer de secrets : `.env`, clés API, mots de passe, tokens, URLs de webhook complètes avec jeton.
2. **Ne pas** supprimer les guides existants sans remplacer les liens (`README.md`, `docs/00-DEMARRAGE.md`).
3. Toute nouvelle variable d’environnement doit apparaître dans **`.env.example`** (commentée ou avec placeholder) et être référencée dans **`docker-compose.yml`** si le service `n8n` ou Postgres en a besoin.

## Ordre de lecture pour orienter un humain

1. `docs/00-DEMARRAGE.md` — chemin minimal.
2. `README.md` — hub.
3. Selon le sujet : `docs/GUIDE-COMPLET.md`, `docs/PERFORMANCE-ET-EXPLOITATION.md`, `docs/COMPOSER-2-ARBITRAGE.md`, `docs/ARCHITECTURE-GITHUB-CENTRE.md`.

## Autonomie maximale (checklist avant de dire « terminé »)

- [ ] `./scripts/check-environment.sh` — JSON workflows valides ; YAML `docker-compose.yml` si PyYAML est installé ; Docker absent = avertissement seulement.
- [ ] Si tu as ajouté un script exécutable : `chmod +x scripts/*.sh` et shebang `#!/usr/bin/env bash`.
- [ ] Si tu as ajouté une migration SQL **hors** `docker-entrypoint-initdb.d` : documenter la commande `psql` / `docker compose exec` pour les bases **déjà créées**.
- [ ] Mettre à jour **`docs/00-DEMARRAGE.md`** si le flux utilisateur change (nombre d’étapes, prérequis).

## Branches et livraison

- Préfixe de branche : `cursor/<sujet>-9060` (convention du projet cloud).
- Message de commit : phrase claire en anglais ou français, décrivant l’effet utilisateur.
- Après changement fonctionnel : `git push` et PR si le workflow du projet l’exige.

## Pièges connus

- **Volumes Postgres** : les scripts dans `docker-entrypoint-initdb.d` ne s’exécutent qu’à la **création** du volume. Les environnements existants nécessitent des migrations manuelles.
- **Cron GitHub Actions** : toujours en **UTC** ; ne pas confondre avec `Europe/Paris`.
- **n8n** : les credentials dans l’UI ne sont pas dans le JSON exporté ; les workflows supposent souvent `$env.OPENAI_API_KEY` pour les nœuds HTTP OpenAI.

## Périmètre

- Rester focalisé sur la demande : pas de refactor massif ni de nouveaux services Docker sans besoin exprimé.
- Préférer la **documentation** et les **scripts** idempotents à des explications uniquement dans le chat.
