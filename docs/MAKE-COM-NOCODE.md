# Variante 100 % no-code : Make.com (sans VPS)

Make (ex-Integromat) remplace n8n comme orchestrateur. Tu n’administres pas Docker, mais le coût mensuel est en général **plus élevé** selon le volume d’opérations.

## Scénario équivalent aux 6 étapes FogLifter

1. **Ingestion** — module **RSS** (planification toutes les 6 h) + option **HTTP** vers Firecrawl si besoin de HTML.
2. **Extraction** — module **OpenAI** (ou **Anthropic**) avec prompt imposant une sortie **JSON** stricte (même schéma que dans le workflow n8n).
3. **Stockage** — module **PostgreSQL** (Supabase / Neon / Railway) ou **Airtable** pour MVP plus simple.
4. **Matching** — module **Tools > Iterator** sur la liste entreprises + **Filter** / petit **JSON Parse** + formule de score (équivalent au Code MVP).
5. **Action** — **Resend** ou **Gmail** pour l’email ; **Telegram** pour les alertes mobile.
6. **Feedback** — ligne dans **Airtable** ou table `fl_action_logs` via SQL.

## Ordre de construction recommandé

1. Créer la table (ou base Airtable) entreprises.
2. Brancher un scénario **RSS → OpenAI → stockage ligne « aide »** jusqu’à stabiliser le JSON.
3. Ajouter la boucle matching + Telegram.
4. Ajouter l’email seulement après tests (quota, contenu, RGPD).

## Limites à anticiper

- Coût **opérations** : chaque item RSS × chaque entreprise peut exploser sur de gros volumes → pré-filtrer (secteur, région) avant la boucle.
- Moins de flexibilité que du code dans n8n pour des scores complexes ; prévoir un module **Custom app** ou un **webhook** vers une micro-API si tu scales.

## Quand choisir Make plutôt que n8n self-hosted

- Tu veux **zéro** maintenance serveur.
- Tu acceptes un **abonnement** et des limites d’ops.
- Tu veux des intégrations natives (Google Sheets, HubSpot, etc.) très rapides à cliquer.

Pour l’inverse (contrôle, coût infra bas, workflows versionnés dans Git), reste sur **n8n + ce dépôt**.
