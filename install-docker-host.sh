#!/usr/bin/env bash
set -e

echo "=== Install Docker + Docker Compose (official repo) ==="

sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo tee /etc/apt/keyrings/docker.asc > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
"Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" \
| sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

sudo apt update

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

echo "=== Docker installed ==="
docker --version
docker compose version || true

echo "=== Create user dock ==="

if id "dock" >/dev/null 2>&1; then
  echo "User dock already exists"
else
  sudo useradd -m -s /bin/bash dock
fi

sudo usermod -aG docker dock

echo "=== Generate password ==="

PASS=$(uuidgen | tr 'A-Z' 'a-z')
echo "dock:$PASS" | sudo chpasswd

echo "=== Enable SSH password auth ==="

sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

sudo systemctl restart ssh || sudo systemctl restart sshd

echo
echo "====================================="
echo "USER: dock"
echo "PASSWORD: $PASS"
echo "SSH: ssh dock@$(hostname -I | awk '{print $1}')"
echo "====================================="
echo

echo "Done."

