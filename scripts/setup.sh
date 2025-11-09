#!/bin/bash
set -e

echo "🚀 Setting up Rust URL Shortener..."
echo ""

# Download docker-compose file
echo "📦 Downloading docker-compose.yml..."
curl -sSL https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/docker-compose.prod.yml -o docker-compose.yml

# Download .env.example and rename
echo "⚙️  Creating .env file..."
curl -sSL https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/.env.example -o .env

# Generate a random password
RANDOM_PASSWORD=$(openssl rand -base64 16 | tr -d '/+=' | cut -c1-16)

# Update the password in .env file
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/CHANGE_THIS_PASSWORD/$RANDOM_PASSWORD/g" .env
else
  # Linux
  sed -i "s/CHANGE_THIS_PASSWORD/$RANDOM_PASSWORD/g" .env
fi

# Prompt for domain name
echo ""
echo "🌐 Domain Configuration"
if [ -z "$DOMAIN" ]; then
  read -p "Enter your domain name (e.g., example.com): " DOMAIN
fi

# Prompt for Caddy ports
if [ -z "$CADDY_HTTP_PORT" ]; then
  read -p "Enter HTTP port for Caddy [default: 80]: " CADDY_HTTP_PORT
  CADDY_HTTP_PORT=${CADDY_HTTP_PORT:-80}
fi

if [ -z "$CADDY_HTTPS_PORT" ]; then
  read -p "Enter HTTPS port for Caddy [default: 443]: " CADDY_HTTPS_PORT
  CADDY_HTTPS_PORT=${CADDY_HTTPS_PORT:-443}
fi

# Update .env file with domain and ports
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/DOMAIN=example.com/DOMAIN=$DOMAIN/g" .env
  sed -i '' "s/CADDY_HTTP_PORT=80/CADDY_HTTP_PORT=$CADDY_HTTP_PORT/g" .env
  sed -i '' "s/CADDY_HTTPS_PORT=443/CADDY_HTTPS_PORT=$CADDY_HTTPS_PORT/g" .env
else
  # Linux
  sed -i "s/DOMAIN=example.com/DOMAIN=$DOMAIN/g" .env
  sed -i "s/CADDY_HTTP_PORT=80/CADDY_HTTP_PORT=$CADDY_HTTP_PORT/g" .env
  sed -i "s/CADDY_HTTPS_PORT=443/CADDY_HTTPS_PORT=$CADDY_HTTPS_PORT/g" .env
fi

# Download Caddyfile template
echo ""
echo "📄 Downloading Caddyfile template..."
curl -sSL https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/Caddyfile.template -o Caddyfile.template

# Generate Caddyfile from template
echo "🔧 Generating Caddyfile..."

# Read APP_PORT from .env file (default to 8080 if not set)
APP_PORT=$(grep "^APP_PORT=" .env 2>/dev/null | cut -d '=' -f2 || echo "8080")
APP_PORT=${APP_PORT:-8080}

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -e "s/{DOMAIN}/$DOMAIN/g" \
      -e "s/{HTTP_PORT}/$CADDY_HTTP_PORT/g" \
      -e "s/{HTTPS_PORT}/$CADDY_HTTPS_PORT/g" \
      -e "s/{APP_PORT}/$APP_PORT/g" \
      Caddyfile.template > Caddyfile
else
  # Linux
  sed -e "s/{DOMAIN}/$DOMAIN/g" \
      -e "s/{HTTP_PORT}/$CADDY_HTTP_PORT/g" \
      -e "s/{HTTPS_PORT}/$CADDY_HTTPS_PORT/g" \
      -e "s/{APP_PORT}/$APP_PORT/g" \
      Caddyfile.template > Caddyfile
fi

# Clean up template file
rm Caddyfile.template

echo ""
echo "✅ Setup complete!"
echo ""
echo "🔑 Generated secure password: $RANDOM_PASSWORD"
echo "   (saved to .env file)"
echo ""
echo "🌐 Domain: $DOMAIN"
echo "   HTTP Port: $CADDY_HTTP_PORT"
echo "   HTTPS Port: $CADDY_HTTPS_PORT"
echo ""
echo "⚠️  IMPORTANT: Make sure to point your domain's A record to this server's IP address!"
echo ""
echo "🚀 Start the service with:"
echo "   docker compose up -d"
echo ""
echo "📝 Check logs with:"
echo "   docker compose logs -f app"
echo ""

