# Rust URL Shortener

A very fast, self-hostable and reliable URL shortener in rust

## Quick Start with Docker

1. **Create a `.env` file** in the project root:

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
```

2. **Start the services**:

```bash
docker compose up -d --build
```

3. **Check the logs**:

```bash
docker compose logs -f app
```

4. **Test the API**:

```bash
# Shorten a URL
curl -X POST http://localhost:8080/api/shorten \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com"}'

# Response:
# {"link":{"id":"...","slug":"abc123","target":"https://example.com",...}}

# Visit the shortened URL
curl -L http://localhost:8080/abc123
```

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

```bash
watchexec -e rs -r cargo run
```

### Database Migrations

Migrations are stored in the `migrations/` directory and are automatically applied when using Docker Compose.

To create a new migration:

```bash
sqlx migrate add <migration_name>
```
