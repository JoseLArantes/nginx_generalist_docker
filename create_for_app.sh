#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <app_name> <port>"
    echo "Example: $0 myapp 3000"
    exit 1
fi

app_name=$1
app_port=$2
domain="${app_name}.beakcloud.com"

echo "Creating nginx configuration for $app_name (port: $app_port)..."

mkdir -p nginx/conf.d

cp nginx/example_conf "nginx/conf.d/${app_name}.conf"

sed -i '' "s/{{domain}}/${app_name}/g" "nginx/conf.d/${app_name}.conf"
sed -i '' "s/{{port}}/${app_port}/g" "nginx/conf.d/${app_name}.conf"

./init-letsencrypt.sh "${domain}"

echo "Waiting for SSL certificate generation..."
sleep 45
docker compose restart nginx

echo "Setup complete! Application will be accessible at:"
echo "https://${domain}"
