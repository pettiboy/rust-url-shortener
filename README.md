# Rust URL Shortener

A very fast, self-hostable and reliable URL shortener in rust

## Quick Start with Docker (Production)

**One command to set everything up:**

```bash
curl -sSL https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/scripts/setup.sh -o setup.sh
bash setup.sh
```

This automated setup will:

- Download `docker-compose.yml`
- Create `.env` with a secure random password
- Prompt for your domain name and configure Caddy
- Generate Caddyfile with automatic SSL/TLS support
- Configure all necessary settings

**Before starting, make sure:**

- Your domain's A record points to your server's IP address
- Ports 80 and 443 are accessible (required for Let's Encrypt)

Then start the service:

```bash
docker compose up -d
```

Check the logs:

```bash
docker compose logs -f app
```

---

<details>
<summary>Manual Setup (if you prefer)</summary>

1. **Download the required files**:

```bash
curl -O https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/docker-compose.prod.yml
mv docker-compose.prod.yml docker-compose.yml
curl -O https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/.env.example
mv .env.example .env
```

2. **Edit `.env` and:**

   - Change `POSTGRES_PASSWORD` to a secure value
   - Set `DOMAIN` to your domain name
   - Configure `CADDY_HTTP_PORT` and `CADDY_HTTPS_PORT` if needed (defaults: 80, 443)

3. **Download and generate Caddyfile:**

```bash
curl -O https://raw.githubusercontent.com/pettiboy/rust-url-shortener/main/Caddyfile.template
# Read APP_PORT from .env (defaults to 8080)
APP_PORT=$(grep "^APP_PORT=" .env 2>/dev/null | cut -d '=' -f2 || echo "8080")
# Replace {DOMAIN}, {HTTP_PORT}, {HTTPS_PORT}, {APP_PORT} with your values
sed -e "s/{DOMAIN}/your-domain.com/g" \
    -e "s/{HTTP_PORT}/80/g" \
    -e "s/{HTTPS_PORT}/443/g" \
    -e "s/{APP_PORT}/${APP_PORT:-8080}/g" \
    Caddyfile.template > Caddyfile
rm Caddyfile.template
```

4. **Start the services**:

```bash
docker compose up -d
```

5. **Check the logs**:

```bash
docker compose logs -f app
```

</details>

## Development Setup

For developers who want to build and modify the application locally:

1. **Clone the repository**:

```bash
git clone https://github.com/pettiboy/rust-url-shortener.git
cd rust-url-shortener
```

2. **Create a `.env` file** in the project root:

```env
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=rust_url_shortener
POSTGRES_PORT=5433

# Application Configuration
APP_PORT=8080

# Database URL (for local development)
DATABASE_URL=postgres://postgres:postgres@localhost:5433/rust_url_shortener

# Migration Configuration
RUN_MIGRATIONS=true
```

3. **Start the services** (this will build the image locally):

```bash
docker compose up -d --build
```

4. **Check the logs**:

```bash
docker compose logs -f app
```

4. **Test the API**:

The application is accessible through Caddy at `http://localhost` (port 80):

```bash
# Shorten a URL
curl -X POST http://localhost/api/shorten \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com"}'

# Response:
# {"link":{"id":"...","slug":"abc123","target":"https://example.com",...}}

# Visit the shortened URL
curl -L http://localhost/abc123
```

**Note:** For local development, the app uses a simple Caddyfile with `localhost` (no SSL). The app is only accessible through Caddy, not directly on port 8080.

## API Endpoints

### Shorten URL

```bash
POST /api/shorten
Content-Type: application/json

{
  "url": "https://example.com",
  "slug": "custom-slug",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

### Redirect

```bash
GET /{slug}
```

## Development

### Local Setup (without Docker)

1. **Install dependencies**:

```bash
cargo build
```

2. **Run migrations**:

```bash
# Start PostgreSQL
docker compose up -d postgres

# Run migrations
sqlx migrate run
```

3. **Generate SQLx offline metadata** (required for Docker builds):

```bash
cargo sqlx prepare
```

4. **Run the application**:

```bash
cargo run
```

OR for live reload

Set `RUN_MIGRATIONS` to false before using live reload

```bash
watchexec -e rs -r cargo run
```

### Database Migrations

Migrations are stored in the `migrations/` directory and are bundled with the Docker image. They are automatically applied on application startup when the `RUN_MIGRATIONS` environment variable is set to `true`.

To create a new migration:

```bash
sqlx migrate add <migration_name>
```

### Custom Domain & SSL/TLS

This application uses **Caddy** as a reverse proxy, which provides:

- **Automatic HTTPS**: Caddy automatically obtains and renews SSL/TLS certificates from Let's Encrypt
- **Custom Domain Support**: Configure your domain in the `.env` file
- **Zero-config SSL**: No manual certificate management required

**Port Configuration:**

- `APP_PORT`: The port on which the Rust application runs inside the container (default: 8080)
- Caddy automatically forwards requests to `app:APP_PORT`
- You can customize this port in your `.env` file if needed
- The setup script automatically reads `APP_PORT` from `.env` and configures Caddy accordingly

**Production Setup:**

- The setup script will prompt for your domain name
- Make sure your domain's A record points to your server's IP
- Ports 80 and 443 must be accessible for Let's Encrypt to work
- Caddy will automatically handle HTTP to HTTPS redirects
- The generated Caddyfile uses the `APP_PORT` value from your `.env` file

**Local Development:**

- Uses a simple `Caddyfile` with `localhost` (no SSL)
- Access the app at `http://localhost`
- No domain configuration needed for local development
- The local `Caddyfile` proxies to `app:8080` by default
