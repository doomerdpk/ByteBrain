#!/bin/bash
# set -euo pipefail
set -x

VM_HOST="$1"
VM_USER="$2"
RELEASE_TS=$(date +%Y%m%d%H%M%S)
RELEASE_DIR="/opt/bytebrain/releases/$RELEASE_TS"

echo "Deploying release $RELEASE_TS to $VM_HOST"

ssh -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "mkdir -p $RELEASE_DIR/frontend $RELEASE_DIR/backend"

rsync -avz --delete ./frontend/dist/ "$VM_USER@$VM_HOST:$RELEASE_DIR/frontend/dist/"
rsync -avz --delete ./backend/dist/ ./backend/node_modules/ ./backend/ecosystem.config.js \
  "$VM_USER@$VM_HOST:$RELEASE_DIR/backend/"

ssh "$VM_USER@$VM_HOST" "cat > $RELEASE_DIR/backend/.env" <<EOF
DATABASE_URL=${DATABASE_URL}
JWT_SECRET=${JWT_SECRET}
NODE_ENV=production
EOF

ssh "$VM_USER@$VM_HOST" "chmod 600 $RELEASE_DIR/backend/.env"

# Atomically switch symlink (zero-downtime cutover)
ssh "$VM_USER@$VM_HOST" "ln -sfn $RELEASE_DIR /opt/bytebrain/current"

ssh "$VM_USER@$VM_HOST" "cd /opt/bytebrain/current/backend && pm2 startOrReload ecosystem.config.js"

ssh "$VM_USER@$VM_HOST" "sudo systemctl reload nginx"

sleep 3
if ssh "$VM_USER@$VM_HOST" "curl -sf http://localhost/api/v1/health"; then
  echo "Deployment healthy."
else
  echo "Health check failed — rolling back!"
  PREV_RELEASE=$(ssh "$VM_USER@$VM_HOST" "ls -td /opt/bytebrain/releases/*/ | sed -n 2p")
  ssh "$VM_USER@$VM_HOST" "ln -sfn ${PREV_RELEASE%/} /opt/bytebrain/current"
  ssh "$VM_USER@$VM_HOST" "cd /opt/bytebrain/current/backend && pm2 reload ecosystem.config.js"
  exit 1
fi

ssh "$VM_USER@$VM_HOST" "cd /opt/bytebrain/releases && ls -t | tail -n +6 | xargs -r rm -rf"

echo "Deployment complete."