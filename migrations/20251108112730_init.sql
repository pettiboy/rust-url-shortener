-- Add migration script here

-- for UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- required fields
    slug VARCHAR(255) UNIQUE NOT NULL, -- unique so postgres ceates an index on it
    target TEXT NOT NULL,

    -- have default values
    clicks BIGINT NOT NULL DEFAULT 0,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- optional fields
    expires_at TIMESTAMPTZ NULL,

    -- auto
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- efficient TTL queries and cleanups
CREATE INDEX IF NOT EXISTS idx_links_expires_at ON links (expires_at);

-- fast 'top clicked links' queries
CREATE INDEX IF NOT EXISTS idx_links_clicks ON links (clicks DESC);

-- enables key-value filters on JSONB (WHERE metadata->>'tag' = 'promo')
CREATE INDEX IF NOT EXISTS idx_links_metadata ON links USING GIN (metadata);
