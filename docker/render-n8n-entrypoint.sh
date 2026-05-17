#!/bin/sh
# Point d'entrée pour hébergeurs qui injectent PORT (Render, Railway, etc.)
# L'image officielle n8n écoute N8N_PORT (défaut 5678) ; Render impose PORT.

set -e

if [ -n "${PORT:-}" ]; then
  export N8N_PORT="$PORT"
fi

export N8N_HOST="${N8N_HOST:-0.0.0.0}"

exec tini -- /docker-entrypoint.sh n8n start
