# Composer 2 — Agent d’arbitrage réglementaire

Composer 2 transforme des flux **réglementaires / supervision** (AMF, EUR-Lex, etc.) en **signaux structurés** (BUY / SELL / HOLD) reliés à des **instruments** (`fl_instruments`), avec persistance dans `fl_arbitrage_matches` et alertes **Telegram** lorsque la confiance dépasse un seuil.

Ce document complète `docs/GUIDE-COMPLET.md` (Composer 1) et `docs/PERFORMANCE-ET-EXPLOITATION.md` (tuning, sauvegardes, HTTPS).

## Prérequis

- Stack Docker déjà opérationnelle (`docker-compose.yml`).
- Credentials n8n **Postgres** pointant vers `foglifter-postgres` (base `foglifter`).
- Variables `OPENAI_API_KEY`, `TELEGRAM_CHAT_ID` injectées dans le service `n8n` (voir `.env.example`).

## 1. Schéma SQL

Sur une base **déjà initialisée** (volume existant), exécuter manuellement :

```bash
docker compose exec -T foglifter-postgres psql -U "$FOGLIFTER_DB_USER" -d "$FOGLIFTER_DB_NAME" -f - < sql/003_arbitrage_schema.sql
docker compose exec -T foglifter-postgres psql -U "$FOGLIFTER_DB_USER" -d "$FOGLIFTER_DB_NAME" -f - < sql/004_seed_arbitrage_instruments.sql
docker compose exec -T foglifter-postgres psql -U "$FOGLIFTER_DB_USER" -d "$FOGLIFTER_DB_NAME" -f - < sql/005_performance_indexes.sql
```

Sur **nouvelle** installation, `003` et `005` sont montés dans `docker-entrypoint-initdb.d` et s’appliquent au premier démarrage du volume `foglifter-postgres`.

## 2. Workflow n8n

1. Importer `workflows/foglifter-arbitrage.json`.
2. Rattacher les **credentials Postgres** (même instance que Composer 1) et **Telegram**.
3. Activer le workflow.
4. **Webhook** : copier l’URL produite par n8n (node *Webhook urgent*) et la coller dans ton pare-feu / outil source (alerting interne). En production, sert le tout en **HTTPS** (`WEBHOOK_URL` dans `.env`).

## 3. Déclencheurs

- **Schedule** : toutes les **4 heures**, lecture du flux RSS AMF *Réglementation* (modifiable dans le node RSS).
- **Webhook POST** : pour pousser un événement urgent sans attendre le prochain cycle.

## 4. Matching (MVP)

Le workflow :

1. Extrait un JSON via LLM (schéma décrit dans le sticky note du workflow).
2. Enregistre l’événement dans `fl_regulatory_events` (UPSERT sur `source_url` + `content_hash`).
3. Charge `fl_instruments` et fait correspondre les jetons `instruments_impactes[]` avec **ISIN** ou **symbole** (insensible à la casse).
4. Calcule **signal**, **confiance** et **rendement attendu** à partir de `direction`, `impact_estime_pct` et `niveau_urgence`.
5. **Upsert** dans `fl_arbitrage_matches`.
6. **Telegram** si `confidence >= 80`.

La **recherche vectorielle** (Weaviate, pgvector, etc.) n’est pas incluse dans ce MVP : remplace ou enrichit le node *Match instruments & signaux (MVP)* selon ton infra.

## 5. Script Python de secours

```bash
cat sample.json | python3 scripts/arbitrage-scoring.py
```

Utile pour rejouer un scoring déterministe hors n8n ou comparer avec la sortie LLM.

## 6. Boucle avec Composer 1 (Clarity Layer)

- Les **retours terrain** (signaux validés / invalidés, P&L réalisé) peuvent être stockés dans une table dédiée (à ajouter) ou dans `metadata` JSON des instruments / événements.
- Les **commissions** Composer 1 peuvent alimenter la trésorerie d’exécution — implémentation comptable hors scope de ce dépôt.

## 7. Avertissement

Les signaux générés sont des **helpers d’analyse**, pas des recommandations d’investissement. Respecte la réglementation (MiFID II, marketing financier, etc.) et ton statut professionnel.
