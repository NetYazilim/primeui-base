# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# 1. AŞAMA — derleme
# ---------------------------------------------------------------------------
FROM node:24-alpine AS build

WORKDIR /app

# Lisans anahtarı DERLEME ZAMANINDA gerekir: VITE_ önekli değişkenler
# bundle'a gömülür, çalışma zamanında okunmaz. Detay için DEPLOY.md.
ARG VITE_PRIMEVUE_LICENSE
ENV VITE_PRIMEVUE_LICENSE=$VITE_PRIMEVUE_LICENSE

# Önce sadece manifest'ler: bağımlılıklar değişmedikçe bu katman önbellekten gelir.
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# npm run build = type-check + vite build (devDependencies gerekir, npm ci onları kurar)
RUN npm run build

# ---------------------------------------------------------------------------
# 2. AŞAMA — sunum
# ---------------------------------------------------------------------------
FROM nginx:alpine AS runtime

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/security-headers.conf /etc/nginx/snippets/security-headers.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
