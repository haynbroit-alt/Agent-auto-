#!/usr/bin/env bash
# Restauration d'une sauvegarde .sql.gz (ATTENTION : écrase la base cible).
# Usage :
#   ./scripts/restore-foglifter.sh foglifter ./backups/foglifter_20260101_120000.sql.gz
#   ./scripts/restore-foglifter.sh n8n ./backups/n8n_20260101_120000.sql.gz

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

TARGET="${1:?cible: foglifter | n8n}"
FILE="${2:?chemin vers fichier .sql.gz}"

if [[ ! -f "$FILE" ]]; then
  echo "Fichier introuvable : $FILE" >&2
  exit 1
fi

if [[ "$TARGET" == "foglifter" ]]; then
  SERVICE="foglifter-postgres"
  USER="${FOGLIFTER_DB_USER:-foglifter}"
  DB="${FOGLIFTER_DB_NAME:-foglifter}"
elif [[ "$TARGET" == "n8n" ]]; then
  SERVICE="postgres"
  USER="${POSTGRES_USER:-n8n}"
  DB="${POSTGRES_DB:-n8n}"
else
  echo "Cible invalide : $TARGET (foglifter ou n8n)" >&2
  exit 1
fi

echo "[restore] Arrêt conseillé de n8n pendant restore n8n. Continuer ? (Ctrl+C pour annuler)"
sleep 3

echo "[restore] $FILE -> $SERVICE / $DB"
gunzip -c "$FILE" | docker compose exec -T "$SERVICE" psql -U "$USER" -d "$DB" -v ON_ERROR_STOP=1

echo "[restore] Terminé."
