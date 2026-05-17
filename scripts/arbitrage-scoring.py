#!/usr/bin/env python3
"""
Scoring « backup » pour Composer 2 — rejoue des règles simples hors n8n
(cron, audit, reprise après incident). Ne constitue pas un conseil en investissement.

Usage:
  python3 scripts/arbitrage-scoring.py < event.json
  python3 scripts/arbitrage-scoring.py --file event.json
"""

from __future__ import annotations

import argparse
import json
import sys
from typing import Any, Mapping


def _urgency_base(niveau: str | None) -> float:
    n = (niveau or "").lower()
    if n == "high":
        return 72.0
    if n == "medium":
        return 55.0
    if n == "low":
        return 38.0
    return 45.0


def _direction_signal(direction: str | None) -> str:
    d = (direction or "").lower()
    if "positif" in d:
        return "BUY"
    if "négatif" in d or "negatif" in d:
        return "SELL"
    return "HOLD"


def score_event(extracted: Mapping[str, Any]) -> dict[str, Any]:
    impact = float(extracted.get("impact_estime_pct") or 0.0)
    conf = _urgency_base(str(extracted.get("niveau_urgence")))
    conf += min(28.0, abs(impact) * 1.6)
    conf = max(0.0, min(100.0, conf))
    signal = _direction_signal(str(extracted.get("direction")))
    return {
        "signal": signal,
        "confidence": round(conf, 2),
        "expected_return": round(impact, 4),
        "impact_score": round(abs(impact) * 1.2, 4),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Score heuristique d’un JSON extrait (Composer 2).")
    parser.add_argument("--file", help="Chemin JSON (sinon stdin)", default=None)
    args = parser.parse_args()

    if args.file:
        with open(args.file, encoding="utf-8") as f:
            payload = json.load(f)
    else:
        payload = json.load(sys.stdin)

    if not isinstance(payload, dict):
        print("Le JSON racine doit être un objet.", file=sys.stderr)
        return 2

    out = score_event(payload)
    sys.stdout.write(json.dumps({"input": payload, "scoring": out}, ensure_ascii=False) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
