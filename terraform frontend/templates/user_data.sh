#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl gnupg2 ca-certificates lsb-release git

# Install Node.js 16 LTS (Angular 13 compatible)
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

## No Nginx — we'll run Angular dev server on port 4200

# Clone and build the Angular app
mkdir -p /opt/app-src
cd /opt/app-src

if [ -n "${repo_url}" ]; then
  git clone "${repo_url}" .
  cd "${frontend_dir_relative}"

  # Install dependencies (includes @angular/cli in devDependencies)
  npm install > /var/log/angular-dev.log 2>&1 || echo "npm install failed" >> /var/log/angular-dev.log

  # Create a systemd unit to keep Angular dev server running
  FRONTEND_DIR="/opt/app-src/${frontend_dir_relative}"
  cat > /etc/systemd/system/angular.service <<SYSTEMD
[Unit]
Description=Angular Dev Server
After=network.target

[Service]
Type=simple
WorkingDirectory=$${FRONTEND_DIR}
ExecStart=/usr/bin/npm run start -- --host 0.0.0.0 --port 4200 --disable-host-check --poll 2000
Restart=always
Environment=CI=true

[Install]
WantedBy=multi-user.target
SYSTEMD

  systemctl daemon-reload
  systemctl enable angular
  systemctl start angular

  # Quick health check (non-fatal if not ready yet)
  sleep 8
  if ! curl -sf http://localhost:4200/ >/dev/null; then
    echo "Angular dev server not ready yet; continuing." >> /var/log/angular-dev.log
  fi
else
  echo "No repo_url provided; nothing to run." >> /var/log/angular-dev.log
fi
