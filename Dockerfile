# Image n8n pour Render (et plateformes qui exposent PORT)
# Le dépôt utilise docker-compose en local ; ce Dockerfile sert uniquement au build « Web Service » Render.

FROM docker.n8n.io/n8nio/n8n:latest

USER root
COPY docker/render-n8n-entrypoint.sh /render-n8n-entrypoint.sh
RUN chmod +x /render-n8n-entrypoint.sh && chown node:node /render-n8n-entrypoint.sh
USER node

ENTRYPOINT ["/render-n8n-entrypoint.sh"]
