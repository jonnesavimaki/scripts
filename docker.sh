#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Detect the real user if running via sudo
if [ "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
else
    REAL_USER=$USER
fi

echo "=== Cleaning up any old/broken docker repository lists ==="
sudo rm -f /etc/apt/sources.list.d/docker.list

echo "=== Updating system package index ==="
sudo apt-get update -y

echo "=== Installing Docker dependencies ==="
sudo apt-get install -y ca-certificates curl gnupg

echo "=== Setting up Docker's official GPG key ==="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "=== Adding official Docker repository to Apt sources ==="
# Explicitly uses download.docker.com and matches your Debian codename (like trixie)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Updating package index with new repository ==="
sudo apt-get update -y

echo "=== Installing Docker Engine, CLI, and Docker Compose ==="
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Enabling and starting Docker Service ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== Adding user '$REAL_USER' to the docker group ==="
sudo usermod -aG docker "$REAL_USER"

echo "====================================================="
echo " Setup complete! Please log out and log back in, "
echo " or run 'newgrp docker' to apply group permissions. "
echo "====================================================="

# Print versions to verify installation
echo "Installed Versions:"
docker --version
docker compose version
