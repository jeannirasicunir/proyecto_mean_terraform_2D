#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Update and base deps
apt-get update -y
apt-get install -y curl gnupg ca-certificates lsb-release

# Install MongoDB 7.0 on Ubuntu 22.04 (Jammy)
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update -y
apt-get install -y mongodb-org

# Bind to all interfaces and set port
sed -i "s/^\s*bindIp:.*/  bindIp: 0.0.0.0/" /etc/mongod.conf
sed -i "s/^\s*port:.*/  port: ${mongo_port}/" /etc/mongod.conf || echo -e "net:\n  port: ${mongo_port}" >> /etc/mongod.conf

# Enable and start
systemctl enable mongod
systemctl restart mongod

# Basic health check
sleep 5
systemctl status mongod --no-pager || true
