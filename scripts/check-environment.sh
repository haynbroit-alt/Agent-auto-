#!/usr/bin/env bash
# Vérifie les prérequis locaux avant docker compose up (Docker, fichier .env, YAML).
# Usage : ./scripts/check-environment.sh   (depuis la racine du dépôt)

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
ERR=0

echo "== FogLifter — vérification d'environnement =="
WARN=0

if ! command -v docker >/dev/null 2>&1; then
  echo "[ATTENTION] Docker n'est pas installé — impossible de lancer la stack ici (normal sur une machine sans Docker)."
  WARN=1
else
  echo "[OK] Docker présent : $(docker --version)"
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[ATTENTION] Plugin « docker compose » introuvable."
  WARN=1
else
  echo "[OK] docker compose : $(docker compose version --short 2>/dev/null || docker compose version)"
fi

if [[ ! -f .env ]]; then
  echo "[ATTENTION] Fichier .env absent — copie .env.example vers .env avant un déploiement réel."
else
  echo "[OK] Fichier .env présent."
fi

if python3 -c "import yaml; yaml.safe_load(open('docker-compose.yml'))" 2>/dev/null; then
  echo "[OK] docker-compose.yml : YAML syntaxe valide (PyYAML)."
else
  echo "[INFO] PyYAML absent ou erreur de parse — installe python3-yaml ou vérifie le fichier à la main."
fi

for wf in workflows/*.json; do
  [[ -e "$wf" ]] || continue
  if python3 -m json.tool "$wf" >/dev/null 2>&1; then
    echo "[OK] $wf (JSON)"
  else
    echo "[KO] JSON invalide : $wf"
    ERR=1
  fi
done

if [[ $ERR -ne 0 ]]; then
  echo "== Terminé avec erreurs (JSON/YAML) =="
  exit 1
fi
if [[ $WARN -ne 0 ]]; then
  echo "== OK pour fichiers ; avertissements Docker (voir ci-dessus) =="
else
  echo "== Tout est prêt pour « docker compose up -d » =="
fi
exit 0
