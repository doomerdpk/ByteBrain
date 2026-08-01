#!/bin/bash
set -euo pipefail

VM_HOST="$1"
VM_USER="$2"
SSH_KEY="${SSH_KEY_PATH:-$HOME/.ssh/deploy_key}"
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no"

RELEASE_TS=$(date +%Y%m%d%H%M%S)
RELEASE_DIR="/opt/bytebrain/releases/$RELEASE_TS"

echo "Deploying release $RELEASE_TS to $VM_HOST"

ssh $SSH_OPTS "$VM_USER@$VM_HOST" "mkdir -p $RELEASE_DIR/frontend $RELEASE_DIR/backend"

rsync -avz --delete -e "ssh $SSH_OPTS" ./frontend/dist/ "$VM_USER@$VM_HOST:$RELEASE_DIR/frontend/dist/"

rsync -avz --delete -e "ssh $SSH_OPTS" ./backend/dist "$VM_USER@$VM_HOST:$RELEASE_DIR/backend/"
rsync -avz --delete -e "ssh $SSH_OPTS" ./backend/node_modules "$VM_USER@$VM_HOST:$RELEASE_DIR/backend/"
rsync -avz --delete -e "ssh $SSH_OPTS" ./backend/ecosystem.config.js "$VM_USER@$VM_HOST:$RELEASE_DIR/backend/"

ssh $SSH_OPTS "$VM_USER@$VM_HOST" "cat > $RELEASE_DIR/backend/.env" <<EOF
DATABASE_URL=${DATABASE_URL}
JWT_SECRET=${JWT_SECRET}
NODE_ENV=production
EOF

ssh $SSH_OPTS "$VM_USER@$VM_HOST" "chmod 600 $RELEASE_DIR/backend/.env"

# 4. Atomically switch symlink
ssh $SSH_OPTS "$VM_USER@$VM_HOST" "ln -sfn $RELEASE_DIR /opt/bytebrain/current"

ssh $SSH_OPTS "$VM_USER@$VM_HOST" "cd /opt/bytebrain/current/backend && pm2 startOrReload ecosystem.config.js"

ssh $SSH_OPTS "$VM_USER@$VM_HOST" "sudo systemctl reload nginx"

sleep 3
if ssh $SSH_OPTS "$VM_USER@$VM_HOST" "curl -sf http://localhost/api/v1/health"; then
  echo "Deployment healthy."
else
  echo "Health check failed — rolling back!"
  PREV_RELEASE=$(ssh $SSH_OPTS "$VM_USER@$VM_HOST" "ls -td /opt/bytebrain/releases/*/ | sed -n 2p")
  ssh $SSH_OPTS "$VM_USER@$VM_HOST" "ln -sfn ${PREV_RELEASE%/} /opt/bytebrain/current"
  ssh $SSH_OPTS "$VM_USER@$VM_HOST" "cd /opt/bytebrain/current/backend && pm2 reload ecosystem.config.js"
  exit 1
fi

ssh $SSH_OPTS "$VM_USER@$VM_HOST" "cd /opt/bytebrain/releases && ls -t | tail -n +6 | xargs -r rm -rf"

echo "Deployment complete."