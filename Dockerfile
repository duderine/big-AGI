FROM node:20-bookworm-slim AS builder
WORKDIR /app
COPY . .
# Força o standalone via variável de ambiente caso o config não tenha
ENV NEXT_PRIVATE_STANDALONE true
RUN npm install && npm run build

FROM node:20-bookworm-slim
WORKDIR /app

# Copiamos o necessário. Se o standalone funcionou, ele usa; se não, vai dar erro aqui e saberemos.
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
