#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/doomerdpk/ByteBrain.git"
BRANCH="master"

echo "Cloning repository..."
git clone --branch "$BRANCH" --depth 1 "$REPO_URL" /tmp/bytebrain-src

echo "Building frontend..."
cd /tmp/bytebrain-src/frontend
npm ci
npm run build
cp -r dist /opt/bytebrain/app/frontend-dist

echo "Building backend..."
cd /tmp/bytebrain-src/backend
npm ci --include=dev
npm run build
npm ci --omit=dev
mkdir -p /opt/bytebrain/app/backend
cp -r dist node_modules ecosystem.config.js /opt/bytebrain/app/backend/

echo "Installing nginx config..."
sudo cp /tmp/bytebrain-src/nginx.conf /etc/nginx/nginx.conf
sudo nginx -t

echo "Cleaning up source clone..."
rm -rf /tmp/bytebrain-src