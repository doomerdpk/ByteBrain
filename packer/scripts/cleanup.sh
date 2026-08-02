#!/bin/bash
set -euo pipefail

echo "Removing SSH host keys (regenerated fresh per instance)..."
sudo rm -f /etc/ssh/ssh_host_*

echo "Clearing bash history..."
cat /dev/null | sudo tee /root/.bash_history > /dev/null
cat /dev/null > ~/.bash_history
history -c

echo "Clearing apt cache..."
sudo apt-get clean

echo "Removing cloud-init logs/state (fresh per instance)..."
sudo cloud-init clean --logs || true

echo "Deprovisioning via waagent (generalizes VM for imaging)..."
sudo waagent -deprovision+ --force