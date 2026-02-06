#!/usr/bin/env bash
set -e

echo "=== Nginx Proxy Manager deploy ==="

# --- check docker ---
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not installed"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose plugin not installed"
  exit 1
fi

# --- create dirs ---
BASE_DIR="$HOME/devops/nginxproxymanager"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

echo "Directory: $BASE_DIR"

# --- create compose file ---
cat > docker-compose.yml <<'EOF'
services:
  app:
    image: 'docker.io/jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

echo "docker-compose.yml created"

# --- start stack ---
docker compose up -d

echo "Container starting..."
sleep 5

# --- check status ---
docker compose ps

# --- get public IP ---
PUBLIC_IP=$(curl -fsSL https://api.ipify.org || curl -fsSL ifconfig.me || echo "UNKNOWN")

echo
echo "======================================"
echo "Nginx Proxy Manager started"
echo "Open in browser:"
echo
echo "http://$PUBLIC_IP:81"
echo
echo "Default login:"
echo "email: admin@example.com"
echo "password: changeme"
echo "======================================"
