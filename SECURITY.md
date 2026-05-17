# Politique de sécurité

## Versions supportées

Ce dépôt est une **stack d’intégration** (Docker, n8n, PostgreSQL). Les correctifs de sécurité passent par la mise à jour des **images** (`docker compose pull`) et des **dépendances** que tu ajoutes localement.

## Signaler une vulnérabilité

- Utilise les [**Security advisories**](https://github.com/haynbroit-alt/Agent-auto-/security/advisories/new) de GitHub (**Private vulnerability report**), si activé sur le dépôt.
- Sinon, ouvre une **issue** en limitant les détails publics jusqu’à correction, ou contacte le mainteneur du fork selon sa politique.

## Bonnes pratiques côté déploiement

- Ne pas exposer **n8n** en HTTP public sur `5678` sans authentification forte.
- Conserver `N8N_ENCRYPTION_KEY` et les mots de passe Postgres **hors** Git.
- Surveiller les logs et appliquer les correctifs d’images de base (`postgres`, `n8n`) régulièrement.
