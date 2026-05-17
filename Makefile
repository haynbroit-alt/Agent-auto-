# Makefile — raccourcis FogLifter (optionnel)
# Prérequis : Docker + plugin « docker compose »

.PHONY: help check up down logs backup ps

help:
	@echo "Cibles utiles :"
	@echo "  make check   — prérequis (Docker, .env, JSON workflows)"
	@echo "  make up      — docker compose up -d"
	@echo "  make down    — docker compose down"
	@echo "  make logs    — docker compose logs -f n8n"
	@echo "  make backup  — ./scripts/backup-foglifter.sh"
	@echo "  make ps      — docker compose ps"

check:
	@./scripts/check-environment.sh

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f n8n

backup:
	@./scripts/backup-foglifter.sh

ps:
	docker compose ps
