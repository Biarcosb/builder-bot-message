# Etapa de construcción
FROM node:21-alpine3.18 AS builder

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@latest --activate
ENV PNPM_HOME=/usr/local/bin

# Copiar archivos necesarios para la instalación
COPY package.json pnpm-lock.yaml ./
RUN apk add --no-cache git && pnpm install

# Copiar el código fuente
COPY . . 

# Construir el proyecto
RUN pnpm run build

# Etapa de producción
FROM node:21-alpine3.18 AS deploy

WORKDIR /app

# Definir puerto
ENV PORT=3008
EXPOSE 3008

# Copiar archivos necesarios desde la construcción
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/assets ./assets
COPY --from=builder /app/ecosystem.config.cjs ./
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./

# Habilitar PNPM y limpiar caché
RUN corepack enable && corepack prepare pnpm@latest --activate 
ENV PNPM_HOME=/usr/local/bin
RUN pnpm install --production --ignore-scripts && rm -rf $PNPM_HOME/.npm $PNPM_HOME/.node-gyp

# Instalar PM2
RUN pnpm add -g pm2

# Ejecutar con PM2
CMD ["pm2-runtime", "start", "ecosystem.config.cjs"]