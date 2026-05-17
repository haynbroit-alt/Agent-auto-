# Secrets et variables GitHub Actions (FogLifter Engine)

Workflow : `.github/workflows/foglifter-engine.yml`

## Secrets (Settings → Secrets and variables → Actions → *Secrets*)

| Nom | Usage |
|-----|--------|
| `N8N_CRON_WEBHOOK_URL` | URL **HTTPS** du webhook n8n qui déclenche ton pipeline (Composer 1 / 2 ou agrégateur). Si absent, le job affiche un message et se termine sans erreur. |

À terme, tu peux ajouter par exemple :

| Nom | Usage |
|-----|--------|
| `SUPABASE_DB_URL` | Chaîne `postgresql://…` pour jobs de migration ou ETL (préférer un rôle limité). |
| `GROQ_API_KEY` / `OPENAI_API_KEY` | Uniquement si tu exécutes des scripts Python dans Actions sans passer par n8n. |

## Variables (onglet *Variables*, non sensibles)

| Nom | Exemple |
|-----|---------|
| `FOGFILTER_ENGINE_NOTE` | `prod-oracle-paris` — texte libre affiché dans les logs du job. |

## Webhook n8n côté serveur

1. Dans n8n, crée un workflow avec un nœud **Webhook** (POST) en entrée, puis ton pipeline (ou un appel à **Execute Workflow**).
2. Active le workflow, copie l’URL **Production** (avec `WEBHOOK_URL` correct dans le `.env` du conteneur n8n).
3. Colle cette URL dans le secret GitHub `N8N_CRON_WEBHOOK_URL`.

Ainsi, **GitHub Actions** ne fait qu’**réveiller** le moteur ; le gros du travail reste sur le VPS (latence LLM, Postgres local ou distant).

## Fuseau horaire du cron

La clé `schedule.cron` est en **UTC**. Pour 6 h du matin heure de Paris en hiver (UTC+1), il faut décaler le cron (ex. `0 5 * * *` pour 6 h à Paris selon la saison — vérifier avec un convertisseur cron / DST).
