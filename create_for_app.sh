#!/bin/bash

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <app_name> <port> <domain> <email> [prod]"
    echo "Example: $0 app 3000 example.com admin@example.com"
    echo "Example (production): $0 app 3000 example.com admin@example.com prod"
    echo "This will create configuration for app.example.com"
    exit 1
fi

app_name=$1
app_port=$2
base_domain=$3
email=$4
prod_flag=$5
domain="${app_name}.${base_domain}"

echo "Creating nginx configuration for $app_name (port: $app_port)..."
echo "Full domain will be: $domain"

mkdir -p nginx/conf.d

# Step 1: Create HTTP-only config for certificate challenge
echo "Step 1: Creating temporary HTTP-only configuration..."
cp nginx/http_only_conf "nginx/conf.d/${app_name}.conf"

# Replace placeholders - use full domain for {{app_name}}.{{domain}}
sed -i.bak "s|{{app_name}}.{{domain}}|${domain}|g" "nginx/conf.d/${app_name}.conf"
rm -f "nginx/conf.d/${app_name}.conf.bak"

echo "Temporary HTTP config created:"
cat "nginx/conf.d/${app_name}.conf"

# Step 2: Start nginx with HTTP-only config
echo "Step 2: Starting nginx with HTTP-only configuration..."
docker compose up -d nginx

# Wait for nginx to be ready
echo "Waiting for nginx to be ready..."
sleep 5

# Step 3: Get SSL certificate
echo "Step 3: Requesting SSL certificate..."
./init-letsencrypt.sh "${domain}" "${email}" "${prod_flag}"

# Step 4: Create full SSL config
echo "Step 4: Creating full SSL configuration..."
cp nginx/example_conf "nginx/conf.d/${app_name}.conf"

# Replace placeholders - replace combined pattern first, then individual ones
sed -i.bak "s|{{app_name}}.{{domain}}|${domain}|g" "nginx/conf.d/${app_name}.conf"
sed -i.bak "s|{{app_name}}|${app_name}|g" "nginx/conf.d/${app_name}.conf"
sed -i.bak "s|{{port}}|${app_port}|g" "nginx/conf.d/${app_name}.conf"
rm -f "nginx/conf.d/${app_name}.conf.bak"

echo "Final SSL config created:"
cat "nginx/conf.d/${app_name}.conf"

# Step 5: Restart nginx with SSL config
echo "Step 5: Restarting nginx with SSL configuration..."
docker compose restart nginx

echo "Setup complete! Application will be accessible at:"
echo "https://${domain}"
