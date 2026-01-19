#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Update packages and install base tools
apt-get update -y
apt-get install -y unzip curl gnupg lsb-release ca-certificates git

# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Fetch backend code and run it
mkdir -p /opt/app
cd /opt/app
# Fetch code: Git repo (if provided) else S3 artifact
if [ -n "${repo_url}" ]; then
		mkdir -p /opt/app-src
		cd /opt/app-src
		git clone "${repo_url}" .
		cd "${server_dir_relative}"
		npm install
else
		# No repo provided: create a minimal Node app that listens on ${app_port}
		mkdir -p /opt/app-simple
		cd /opt/app-simple
		cat > package.json <<'JSON'
{
	"name": "simple-server",
	"version": "1.0.0",
	"private": true,
	"scripts": {
		"dev": "node index.js"
	},
	"dependencies": {
		"express": "^4.18.2",
		"cors": "^2.8.5"
	}
}
JSON
		cat > index.js <<'JS'
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || ${app_port};

app.use(cors());
app.get('/', (req, res) => {
	res.send('Server is up!');
});

app.listen(PORT, () => {
	console.log(`Listening on port $${PORT}`);
});
JS
		npm install
fi

# Persist environment to disable DB usage
echo "DISABLE_DB=true" >> /etc/environment
export DISABLE_DB=true

nohup npm run dev > /var/log/node-server.log 2>&1 &

# Open firewall for app port (Ubuntu ufw may not be installed; skipped)
# App listens on port ${app_port}
