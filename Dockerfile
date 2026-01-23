# Estágio de build
FROM node:20-bookworm-slim AS builder
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
ENV NEXT_PRIVATE_STANDALONE=true
RUN npm install && npm run build

# Estágio final (Runtime)
FROM node:20-bookworm-slim
WORKDIR /app

# LABELS PARA LINKAR NO REPO (A mágica que você queria)
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
