# Déployer n8n sur Render

Render attend un **`Dockerfile` à la racine** du dépôt quand le service est en **Runtime: Docker**. Ce dépôt fournit ce fichier pour l’image **n8n** officielle, avec prise en charge de la variable **`PORT`** (mappée sur **`N8N_PORT`**).

## 1. Créer le Web Service

1. **New +** → **Web Service** → connecter `haynbroit-alt/Agent-auto-`.
2. **Branch** : `main` (ou celle que tu déploies).
3. **Runtime** : **Docker** (ne pas utiliser « Native » sans Dockerfile).
4. **Dockerfile path** : `Dockerfile` (racine, valeur par défaut).
5. **Instance type** : Free ou supérieur.

## 2. Variables d’environnement minimales

Dans **Environment** du service, configure au minimum :

| Variable | Exemple / remarque |
|----------|-------------------|
| `N8N_ENCRYPTION_KEY` | `openssl rand -hex 32` — **obligatoire** pour stocker des credentials dans n8n. |
| `WEBHOOK_URL` | URL **HTTPS** publique du service Render (ex. `https://foglifter-n8n.onrender.com`) pour que les webhooks générés soient corrects. |
| `GENERIC_TIMEZONE` | `Europe/Paris` |
| `N8N_PROTOCOL` | `https` |
| `N8N_HOST` | Souvent le hostname Render sans `https://` (ex. `foglifter-n8n.onrender.com`) — à aligner avec la doc n8n derrière reverse-proxy. |

**LLM / Telegram** : comme en local, utilise les **Credentials** n8n ou passe par les variables documentées dans `.env.example` (`OPENAI_API_KEY`, `TELEGRAM_CHAT_ID`, …) si tu les ajoutes aussi dans Render.

## 3. Base de données n8n (important)

Par défaut, n8n peut utiliser **SQLite** dans le volume du conteneur. Sur Render Free, le disque peut être **éphémère** : prévoir une **Render PostgreSQL** (gratuite limitée) et les variables **`DB_TYPE=postgresdb`** + `DB_POSTGRESDB_*` comme dans `docker-compose.yml` du dépôt.

Sans Postgres managé, accepte le risque de **perte des données** au redéploiement.

## 4. Ce que ce Dockerfile ne fait pas

- Il ne lance **pas** `foglifter-postgres` : la base métier FogLifter reste soit une autre instance Render Postgres + variables adaptées dans n8n, soit ton **VPS** avec `docker compose` complet.
- Les workflows et le SQL du dépôt sont des **sources** : importe toujours les JSON depuis `workflows/` dans l’UI n8n après déploiement.

## 5. Déploiement après merge

Après `git push` sur la branche suivie par Render, un nouveau build doit afficher **Build successful** si le `Dockerfile` est présent à la racine.

Render ne redéploie pas toujours tout seul immédiatement après un merge sur `main` : ouvre le service → **Manual Deploy** → **Deploy latest commit** (ou attends le webhook GitHub).

## 6. Dépannage : « open Dockerfile: no such file or directory » alors que le fichier existe sur GitHub

1. **Lire la ligne `==> Checking out commit …` dans les logs de build.** Compare ce hash avec le dernier commit de la branche `main` sur GitHub (`https://github.com/haynbroit-alt/Agent-auto-/commits/main`). Si Render affiche encore un commit **antérieur** au merge qui a ajouté le `Dockerfile` à la racine, le build utilise un **ancien snapshot** : force un déploiement (**Manual Deploy** → **Deploy latest commit**) ou vérifie que le dépôt / la branche connectée est bien celui où tu as mergé.
2. **Root Directory** : laisse vide (ou `.`). Si tu mets un sous-dossier (ex. `apps/n8n`), Render cherche le `Dockerfile` **dans ce dossier** ; un `Dockerfile` uniquement à la racine du dépôt ne sera pas trouvé.
3. **Dockerfile path** : exactement `Dockerfile` (sensible à la casse sur Linux).
4. Optionnel : **Clear build cache** puis redeploy, si Render propose l’option et que tu soupçonnes un cache incohérent.
