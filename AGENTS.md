# AGENTS.md — règles pour humains et agents IA

Ce fichier cadre le travail sur le dépôt **FogLifter / Clarity Layer** (Docker, SQL, workflows **n8n** exportés, GitHub Actions, documentation).

## Principes

- **Modularité** : un « Composer » = un domaine clair (subventions, arbitrage réglementaire, etc.). Éviter les mélanges de responsabilités dans un même workflow sans bonne raison.
- **Traçabilité** : tout changement **fonctionnel** est versionné (Git) et, si tu touches aux flux métier, documenté (README / `docs/00-DEMARRAGE.md` / guide concerné).
- **Journalisation métier** : les workflows existants écrivent dans **`fl_action_logs`** pour certaines actions (notifications, etc.). Ce n’est **pas** une obligation pour une simple modification de documentation dans le dépôt Git.
- **Sécurité** : jamais de clés API, tokens ou mots de passe dans le code ou les workflows exportés ; utiliser **Secrets GitHub**, **Credentials n8n** et `.env` (non versionné).

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
