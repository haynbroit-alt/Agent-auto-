# Contribuer à FogLifter / Clarity Layer

Dépôt principal : **https://github.com/haynbroit-alt/Agent-auto-**

Merci de t’intéresser au dépôt. Ce court guide évite les allers-retours inutiles.

## Avant d’écrire du code

1. Lis [`AGENTS.md`](AGENTS.md) — règles pour humains et agents IA.
2. Lis [`docs/00-DEMARRAGE.md`](docs/00-DEMARRAGE.md) — pour comprendre la stack telle qu’elle est pensée.

## Règles rapides

- **Aucun secret** dans les commits (`.env`, clés API, mots de passe, URL avec jeton).
- **Migrations SQL** : si tu ajoutes un fichier sous `docker-entrypoint-initdb.d`, documente l’équivalent `psql` pour les volumes Postgres **déjà créés**.
- **Workflows n8n** : valider le JSON (`python3 -m json.tool workflows/<fichier>.json`).
- **Documentation** : mettre à jour `docs/00-DEMARRAGE.md` ou `docs/INDEX.md` si le parcours utilisateur change.

## Branches

Convention utilisée sur ce dépôt pour les agents cloud : `cursor/<sujet>-9060`. Adapte si le mainteneur du repo impose une autre convention.

## Pull requests

Le modèle dans `.github/pull_request_template.md` s’affiche à l’ouverture d’une PR : coche les cases pertinentes.

Pour les signalements de **vulnérabilité**, voir [`SECURITY.md`](SECURITY.md).
