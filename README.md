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
./create_for_app.sh <app_name> <port> <domain>
```

Example:
```bash
./create_for_app.sh myapp 3000 example.com
```

This will:
- Create Nginx configuration for app
- Generate SSL certificates using Let's Encrypt
- Set up reverse proxy to application
- Make app accessible at `https://myapp.example.com`

## Structure

- `nginx/conf.d/`: Directory containing all Nginx configurations
- `example_conf`: Template for new app configurations
- `docker-compose.yml`: Docker services configuration
- `init-letsencrypt.sh`: Script for SSL certificate initialization
- `create_for_app.sh`: Main script for creating new app configurations

## Notes

- Make sure application is running and accessible on the specified port
- DNS records must be properly configured before running the setup
- Certificates are automatically renewed by the certbot service