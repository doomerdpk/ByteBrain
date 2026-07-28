FROM node:22.22-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY ./src ./src
RUN npm run build

FROM node:22.22-slim
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN npm install -g npm@12.0.1
COPY package*.json ./
RUN npm ci --omit=dev
RUN groupadd --system appgroup && useradd --system --gid appgroup --no-create-home appuser
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
USER appuser
EXPOSE 3000
CMD ["npm", "run", "start"]