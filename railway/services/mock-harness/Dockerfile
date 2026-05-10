# railway/services/mock-harness/Dockerfile
FROM node:20-alpine AS base
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm install --omit=dev

FROM base AS runner
ENV NODE_ENV=production
ENV PORT=8080
COPY --from=deps /app/node_modules ./node_modules
COPY server.js ./
# Os arquivos Scripted REST reais vivem em servicenow/scripted-rest/.
# Em CI, montar /app/servicenow via volume ou copiar com contexto raiz do build.
# Em Railway, usar build context = root do repo (ajustar railway service config).
COPY --chown=node:node . .

USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1

CMD ["node", "server.js"]
