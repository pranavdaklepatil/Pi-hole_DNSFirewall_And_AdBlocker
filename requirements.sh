#!/bin/bash

echo "[+] Installing required packages..."

sudo apt update
sudo apt install -y \
  docker.io \
  docker-compose \
  curl \
  net-tools \
  dnsutils

sudo systemctl enable docker
sudo systemctl start docker

echo "[✓] Requirements installed successfully"
