#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Both domain name and email are required"
    echo "Usage: $0 <domain_name> <email> [prod]"
    echo "Example: $0 myapp.example.com admin@example.com prod"
    exit 1
fi

DOMAIN="$1"
EMAIL="$2"
RSA_KEY_SIZE=4096

echo "### Cleaning up any existing certificates for $DOMAIN ..."
docker compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$DOMAIN && \
  rm -Rf /etc/letsencrypt/archive/$DOMAIN && \
  rm -Rf /etc/letsencrypt/renewal/$DOMAIN.conf" certbot

echo "### Requesting Let's Encrypt certificate for $DOMAIN ..."

if [ "$3" != "prod" ]; then
  staging_flag="--staging"
fi

docker compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
  $staging_flag \
  --email $EMAIL \
  -d $DOMAIN \
  --rsa-key-size $RSA_KEY_SIZE \
  --agree-tos \
  --force-renewal" certbot

echo "### Reloading nginx to pick up real certificates..."
docker compose exec nginx nginx -s reload

echo "Setup complete. Certificate is now active."