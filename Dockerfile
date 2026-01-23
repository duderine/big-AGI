# Estágio de build
FROM node:20-bookworm-slim AS builder
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .

# ATIVAÇÃO DO MIDDLEWARE (O pulo do gato)
# Removemos qualquer middleware existente e forçamos o de Basic Auth
RUN rm -f middleware.ts src/middleware.ts && cp middleware_BASIC_AUTH.ts middleware.ts

ENV NEXT_PRIVATE_STANDALONE=true
RUN npm install && npm run build

# Estágio final (Runtime)
FROM node:20-bookworm-slim
WORKDIR /app

# LABELS PARA LINKAR NO REPO
LABEL org.opencontainers.image.source="https://github.com/duderine/big-agi"
LABEL org.opencontainers.image.description="big-AGI container for Hugging Face"
LABEL org.opencontainers.image.licenses=MIT

# Variáveis de ambiente para o Hugging Face não se perder
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Porta padrão que o HF espera
EXPOSE 3000

CMD ["node", "server.js"]
