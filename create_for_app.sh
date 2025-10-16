#!/bin/bash

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <app_name> <port> <domain> <email>"
    echo "Example: $0 myapp 3000 example.com admin@example.com"
    echo "This will create configuration for myapp.example.com"
    exit 1
fi

app_name=$1
app_port=$2
base_domain=$3
email=$4
domain="${app_name}.${base_domain}"

echo "Creating nginx configuration for $app_name (port: $app_port)..."

mkdir -p nginx/conf.d

cp nginx/example_conf "nginx/conf.d/${app_name}.conf"

sed -i '' "s/{{app_name}}/${app_name}/g" "nginx/conf.d/${app_name}.conf"
sed -i '' "s/{{domain}}/${base_domain}/g" "nginx/conf.d/${app_name}.conf"
sed -i '' "s/{{port}}/${app_port}/g" "nginx/conf.d/${app_name}.conf"

./init-letsencrypt.sh "${domain}" "${email}"

echo "Waiting for SSL certificate generation..."
sleep 45
docker compose restart nginx

echo "Setup complete! Application will be accessible at:"
echo "https://${domain}"
