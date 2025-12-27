#!/bin/bash

set -e

# Generate random password
PIHOLE_PASS=$(openssl rand -base64 12)

echo "[+] Removing old Pi-hole container (if any)"
docker rm -f pihole 2>/dev/null || true

echo "[+] Starting Pi-hole container"

docker run -d \
  --name pihole \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 \
  -p 443:443 \
  -e TZ="Asia/Kolkata" \
  -e WEBPASSWORD="${PIHOLE_PASS}" \
  -e DNS1="1.1.1.1" \
  -e DNS2="8.8.8.8" \
  -v "$(pwd)/etc-pihole:/etc/pihole" \
  -v "$(pwd)/etc-dnsmasq.d:/etc/dnsmasq.d" \
  --restart=unless-stopped \
  pihole/pihole:latest

printf "[+] Waiting for Pi-hole to become healthy"

for i in {1..40}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' pihole 2>/dev/null || echo "starting")
  if [ "$STATUS" = "healthy" ]; then
    echo " ✅"
    IP=$(hostname -I | awk '{print $1}')
    echo "======================================"
    echo " Pi-hole Admin URL : http://${IP}/admin"
    echo " Pi-hole Password  : ${PIHOLE_PASS}"
    echo "======================================"
    exit 0
  fi
  sleep 3
  printf "."
done

echo
echo "[!] Pi-hole failed to become healthy"
docker logs pihole | tail -30
exit 1

sudo docker exec pihole pihole -a -p  # It will ask for new password
