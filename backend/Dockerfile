FROM node:20.19-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY ./src ./src
RUN npm run build

FROM node:20.19-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
RUN groupadd --system appgroup && useradd --system --gid appgroup --no-create-home appuser
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
USER appuser
EXPOSE 3000
CMD ["npm", "run", "start"]