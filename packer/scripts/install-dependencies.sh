#!/bin/bash
set -euo pipefail

echo "Updating package lists..."
sudo apt-get update -o APT::Update::Post-Invoke-Success::=""

echo "Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Installing nginx..."
sudo apt-get install -y nginx

echo "Installing PM2 globally..."
sudo npm install -g pm2

echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "Creating app directories..."
sudo mkdir -p /opt/bytebrain/app /var/log/bytebrain
sudo chown -R packer:packer /opt/bytebrain /var/log/bytebrain