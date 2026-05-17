#!/usr/bin/env bash
# Sauvegardes compressées des bases n8n et FogLifter (pg_dump via Docker).
# Usage : depuis la racine du dépôt, après docker compose up -d
#   ./scripts/backup-foglifter.sh
# Variables : BACKUP_ROOT (défaut ./backups), RETENTION_DAYS (défaut 14)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

BACKUP_ROOT="${BACKUP_ROOT:-$ROOT/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
mkdir -p "$BACKUP_ROOT"

TS="$(date +%Y%m%d_%H%M%S)"
FOGLIFTER_USER="${FOGLIFTER_DB_USER:-foglifter}"
FOGLIFTER_DB="${FOGLIFTER_DB_NAME:-foglifter}"
N8N_USER="${POSTGRES_USER:-n8n}"
N8N_DB="${POSTGRES_DB:-n8n}"

echo "[backup] FogLifter DB -> ${BACKUP_ROOT}/foglifter_${TS}.sql.gz"
docker compose exec -T foglifter-postgres pg_dump -U "$FOGLIFTER_USER" "$FOGLIFTER_DB" | gzip -9 >"${BACKUP_ROOT}/foglifter_${TS}.sql.gz"

echo "[backup] n8n internal DB -> ${BACKUP_ROOT}/n8n_${TS}.sql.gz"
docker compose exec -T postgres pg_dump -U "$N8N_USER" "$N8N_DB" | gzip -9 >"${BACKUP_ROOT}/n8n_${TS}.sql.gz"

find "$BACKUP_ROOT" -name 'foglifter_*.sql.gz' -mtime "+${RETENTION_DAYS}" -delete 2>/dev/null || true
find "$BACKUP_ROOT" -name 'n8n_*.sql.gz' -mtime "+${RETENTION_DAYS}" -delete 2>/dev/null || true

echo "[backup] Terminé. Fichiers conservés ${RETENTION_DAYS} jours max."
