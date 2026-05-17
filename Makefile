# Makefile — raccourcis FogLifter (optionnel)
# Prérequis : Docker + plugin « docker compose »

.PHONY: help check up down logs logs-n8n backup ps

help:
	@echo "FogLifter — cibles Makefile"
	@echo "  make check      — prérequis (JSON workflows, YAML, Docker si présent)"
	@echo "  make up         — docker compose up -d"
	@echo "  make down       — docker compose down"
	@echo "  make logs       — logs de tous les services (-f)"
	@echo "  make logs-n8n   — logs du service n8n uniquement"
	@echo "  make backup     — ./scripts/backup-foglifter.sh"
	@echo "  make ps         — docker compose ps"

check:
	@./scripts/check-environment.sh

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

logs-n8n:
	docker compose logs -f n8n

backup:
	@./scripts/backup-foglifter.sh

ps:
	docker compose ps
