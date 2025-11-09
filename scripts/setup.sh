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

echo ""
echo "✅ Setup complete!"
echo ""
echo "🔑 Generated secure password: $RANDOM_PASSWORD"
echo "   (saved to .env file)"
echo ""
echo "🚀 Start the service with:"
echo "   docker compose up -d"
echo ""
echo "📝 Check logs with:"
echo "   docker compose logs -f app"
echo ""

