#!/bin/bash
set -euo pipefail

echo "Fixing ownership for runtime user..."
chown -R bytebrainadmin:bytebrainadmin /opt/bytebrain/app /var/log/bytebrain

echo "Logging in via Managed Identity..."
az login --identity --allow-no-subscriptions

echo "Fetching secrets from Key Vault (with retry for role assignment propagation delay)..."

MAX_RETRIES=20
RETRY_DELAY=15

fetch_secret() {
  local secret_name=$1
  local attempt=1
  while [ $attempt -le $MAX_RETRIES ]; do
    if VALUE=$(az keyvault secret show --name "$secret_name" --vault-name ${key_vault_name} --query value -o tsv 2>/dev/null); then
      echo "$VALUE"
      return 0
    fi
    echo "Attempt $attempt/$MAX_RETRIES: waiting for Key Vault access to propagate..." >&2
    sleep $RETRY_DELAY
    attempt=$((attempt + 1))
  done
  echo "ERROR: Failed to fetch secret '$secret_name' after $MAX_RETRIES attempts." >&2
  return 1
}

DATABASE_URL=$(fetch_secret "bytebrain-db-connection-string")
JWT_SECRET=$(fetch_secret "bytebrain-jwt-secret")

cat > /opt/bytebrain/app/backend/.env <<ENVEOF
DATABASE_URL=$DATABASE_URL
JWT_SECRET=$JWT_SECRET
NODE_ENV=production
ENVEOF

chown bytebrainadmin:bytebrainadmin /opt/bytebrain/app/backend/.env
chmod 600 /opt/bytebrain/app/backend/.env

echo "Starting application via PM2..."
cd /opt/bytebrain/app/backend
sudo -u bytebrainadmin pm2 start ecosystem.config.js
sudo -u bytebrainadmin pm2 save

echo "Startup script completed successfully."