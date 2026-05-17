# Architecture « GitHub au centre » (Clarity / FogLifter)

> **Par où commencer** : [`00-DEMARRAGE.md`](00-DEMARRAGE.md) — ce fichier décrit la vision modulaire long terme.

Ce document fixe une **vision modulaire** : le dépôt GitHub est le **référentiel de vérité** (code, SQL, workflows n8n exportés, IaC légère) et le **point d’orchestration** (Actions planifiées ou manuelles). Les ressources d’exécution (VPS, bases managées, Redis, LLM) se branchent autour et sont **remplaçables** sans réécrire toute l’usine.

## Schéma logique

| Couche | Rôle | Options typiques |
|--------|------|-------------------|
| **Commandement** | Versions, CI/CD, tâches planifiées, documentation | **GitHub** (ce dépôt + Actions + éventuellement Pages) |
| **Moteur** | Orchestration métier 24/7, webhooks, intégrations | **n8n** sur VPS (Oracle Free, Hetzner, autre) + Docker du dépôt |
| **Données structurées** | Tables métier, API, auth | **PostgreSQL** embarqué dans ce repo *ou* **Supabase** (Postgres managé + API) |
| **File / cache** | Queue n8n avancée, rate limit, idempotence | **Upstash Redis** *ou* Redis self-hosté *ou* mode queue n8n officiel |
| **LLM** | Extraction / rédaction | **OpenAI**, **Groq**, **Anthropic**, etc. (clés en secrets) |

## Pourquoi GitHub Actions ici ?

- **Planification** fiable (cron UTC) sans dépendre uniquement du scheduler n8n pour certaines tâches (backups, healthchecks, déclenchement distant).
- **Déclenchement manuel** depuis l’app GitHub mobile (`workflow_dispatch`).
- **Secrets centralisés** pour appeler des endpoints (ex. webhook n8n sur ton VPS) sans exposer d’URL sensibles dans le code.

Le workflow `.github/workflows/foglifter-engine.yml` illustre le pattern minimal : **checkout** + **POST optionnel** vers `secrets.N8N_CRON_WEBHOOK_URL` pour réveiller un scénario n8n déjà déployé sur ton serveur.

## Branchement concret (sans te enfermer)

1. **VPS (Oracle, Hetzner, …)** : `git clone` + `docker compose up -d` comme dans `docs/GUIDE-COMPLET.md` — le moteur reste **sous ton contrôle**.
2. **Supabase** : tu peux migrer progressivement `foglifter-postgres` vers leur Postgres en adaptant les **credentials** n8n (URL, user, mot de passe) ; les fichiers `sql/*.sql` restent la source de schéma.
3. **Upstash** : utile quand tu passes n8n en **mode queue** ou pour un cache applicatif ; les variables iront dans `.env` du VPS et/ou dans les secrets Actions si un job GitHub en a besoin.
4. **Groq / OpenAI** : interchangeables dans les nœuds HTTP des workflows ; les clés restent dans **Secrets** (GitHub Actions) ou **Credentials** (n8n).

## Garde-fous

- Ne commite **jamais** de clés ; utilise **GitHub Secrets** et **n8n Credentials**.
- Le **cron Actions** est en **UTC** : décale si tu veux aligner sur `Europe/Paris`.
- Oracle Free Tier et autres offres « gratuites » évoluent : garde une **procédure d’export** (`scripts/backup-foglifter.sh`) pour changer de cloud en quelques heures.

## Prochaines évolutions possibles dans ce dépôt

- Job Action qui lance `scripts/backup-foglifter.sh` via SSH sur le VPS (clé dédiée en secret).
- Job qui applique `sql/*.sql` sur Supabase via `psql` ou l’API (selon ta politique de migration).
- Pages GitHub pour un mini dashboard statique (hors secret).

L’objectif est une **fondation modulaire** : tu changes une brique (DB, cloud, LLM) en gardant le même dépôt comme plan d’usine.
