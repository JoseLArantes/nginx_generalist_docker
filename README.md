# Nginx App Configuration Manager

A simple Docker-based tool to manage Nginx configurations with automatic SSL certificate generation using Let's Encrypt.

## Description

Provides an easy way to:
- Create Nginx configurations for applications
- Set up SSL certificates automatically using Let's Encrypt
- Configure reverse proxy with upstream servers
- Handle HTTP to HTTPS redirections

## Requirements

- Docker and Docker Compose
- A domain or subdomain pointing to server
- Ports 80 and 443 available on host machine

## Usage

1. Create configuration for a new app:
```bash
./create_for_app.sh <app_name> <port> <domain> <email> [prod]
```

Example (staging certificate - for testing):
```bash
./create_for_app.sh myapp 3000 example.com admin@example.com
```

Example (production certificate):
```bash
./create_for_app.sh myapp 3000 example.com admin@example.com prod
```

This will:
- Create temporary HTTP-only Nginx configuration for certificate challenge
- Start nginx to serve certbot challenges on port 80
- Generate SSL certificates using Let's Encrypt (staging by default, production with 'prod' flag)
- Replace config with full SSL configuration
- Set up reverse proxy to application
- Make app accessible at `https://myapp.example.com`

## Structure

- `nginx/conf.d/`: Directory containing all Nginx configurations
- `example_conf`: Template for new app configurations
- `docker-compose.yml`: Docker services configuration
- `init-letsencrypt.sh`: Script for SSL certificate initialization
- `create_for_app.sh`: Main script for creating new app configurations

## How It Works

1. **HTTP-only Setup**: Creates a temporary nginx config that serves certbot challenges on port 80
2. **Certificate Request**: Uses certbot to request SSL certificate via HTTP-01 challenge
3. **SSL Configuration**: Replaces the temporary config with full SSL setup including HTTPS redirect
4. **Production Ready**: Application is now accessible via HTTPS with valid SSL certificate

## Notes

- Make sure your application is running and accessible on the specified port
- DNS records must be properly configured and pointing to your server before running the setup
- Use staging certificates (default) for testing to avoid Let's Encrypt rate limits
- Use production certificates (add 'prod' flag) only when ready for production
- Certificates are automatically renewed by the certbot service

## Troubleshooting

### Certificate Challenge Fails
- Ensure DNS is properly configured and pointing to your server
- Check that ports 80 and 443 are accessible from the internet
- Verify nginx is running: `docker compose ps`
- Check nginx logs: `docker compose logs nginx`

### Placeholder Not Replaced
- The script now properly replaces all placeholders ({{app_name}}.{{domain}}, {{app_name}}, {{port}})
- If issues persist, check the generated config: `cat nginx/conf.d/<app_name>.conf`

### Application Not Accessible
- Ensure your application container is on the correct network (playspace-network)
- Verify the application is running on the specified port
- Check nginx can reach the application: `docker compose exec nginx ping <app_name>`