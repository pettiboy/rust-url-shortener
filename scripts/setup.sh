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

# Generate a random API secret
RANDOM_API_KEY=$(openssl rand -base64 32 | tr -d '/+=' | cut -c1-32)

# Update the password and API secret in .env file
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/CHANGE_THIS_PASSWORD/$RANDOM_PASSWORD/g" .env
  sed -i '' "s/CHANGE_THIS_API_KEY/$RANDOM_API_KEY/g" .env
else
  # Linux
  sed -i "s/CHANGE_THIS_PASSWORD/$RANDOM_PASSWORD/g" .env
  sed -i "s/CHANGE_THIS_API_KEY/$RANDOM_API_KEY/g" .env
fi

# Check if we can prompt interactively (stdin is a terminal)
if [ ! -t 0 ]; then
  echo "❌ Error: Cannot prompt for input when script is piped."
  echo ""
  echo "Please download the script first, then run it:"
  echo "  curl -sSL https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/scripts/setup.sh -o setup.sh"
  echo "  bash setup.sh"
  echo ""
  echo "Or set USE_CADDY as environment variable:"
  echo "  USE_CADDY=y curl -sSL ... | bash"
  exit 1
fi

# Prompt for proxy choice
echo ""
echo "🔀 Reverse Proxy Configuration"
read -p "Use Caddy for reverse proxy? (y/n) [default: y]: " USE_CADDY_INPUT
USE_CADDY_INPUT=${USE_CADDY_INPUT:-y}
USE_CADDY=$(echo "$USE_CADDY_INPUT" | tr '[:upper:]' '[:lower:]')

if [[ "$USE_CADDY" == "y" || "$USE_CADDY" == "yes" ]]; then
  USE_CADDY="true"
  
  # Prompt for domain name
  echo ""
  echo "🌐 Domain Configuration"
  
  # Always prompt for domain (never read from .env)
  while [ -z "$DOMAIN" ]; do
    read -p "Enter your domain name (e.g., example.com): " DOMAIN
    if [ -z "$DOMAIN" ]; then
      echo "⚠️  Domain name cannot be empty. Please try again."
    fi
  done

  # Update .env file with domain
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/DOMAIN=example.com/DOMAIN=$DOMAIN/g" .env
  else
    # Linux
    sed -i "s/DOMAIN=example.com/DOMAIN=$DOMAIN/g" .env
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
        -e "s/{APP_PORT}/$APP_PORT/g" \
        Caddyfile.template > Caddyfile
  else
    # Linux
    sed -e "s/{DOMAIN}/$DOMAIN/g" \
        -e "s/{APP_PORT}/$APP_PORT/g" \
        Caddyfile.template > Caddyfile
  fi

  # Clean up template file
  rm Caddyfile.template
else
  USE_CADDY="false"
  
  # Prompt for exposed app port
  echo ""
  echo "🔌 Application Port Configuration"
  read -p "Enter port to expose the app on [default: 8080]: " EXPOSED_APP_PORT
  EXPOSED_APP_PORT=${EXPOSED_APP_PORT:-8080}
  
  # Update .env file with exposed port
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/EXPOSED_APP_PORT=8080/EXPOSED_APP_PORT=$EXPOSED_APP_PORT/g" .env 2>/dev/null || echo "EXPOSED_APP_PORT=$EXPOSED_APP_PORT" >> .env
  else
    # Linux
    sed -i "s/EXPOSED_APP_PORT=8080/EXPOSED_APP_PORT=$EXPOSED_APP_PORT/g" .env 2>/dev/null || echo "EXPOSED_APP_PORT=$EXPOSED_APP_PORT" >> .env
  fi
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "🔑 Generated API Secret: $RANDOM_API_KEY"
echo "   (saved to .env file)"
echo ""

if [[ "$USE_CADDY" == "true" ]]; then
  echo "🌐 Domain: $DOMAIN"
  echo ""
  echo "⚠️  IMPORTANT: Make sure to point your domain's A record to this server's IP address!"
  echo ""
  echo "🚀 Start the service with:"
  echo "   docker compose --profile caddy up -d"
else
  echo "🔌 Application will be exposed on port: $EXPOSED_APP_PORT"
  echo ""
  echo "⚠️  IMPORTANT: You'll need to configure your own reverse proxy (nginx, traefik, etc.)"
  echo "   to handle SSL/TLS and domain routing to localhost:$EXPOSED_APP_PORT"
  echo ""
  echo "🚀 Start the service with:"
  echo "   docker compose up -d"
fi

echo ""
echo "📝 Check logs with:"
echo "   docker compose logs -f app"
echo ""

