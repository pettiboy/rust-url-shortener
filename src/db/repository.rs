use sqlx::PgPool;

use crate::db::models::Link;

pub struct LinkRepository;

impl LinkRepository {
    pub async fn create(pool: &PgPool, link: &Link) -> Result<Link, sqlx::Error> {
        let record = sqlx::query_as!(
            Link,
            r#"
            INSERT INTO links (slug, target, clicks, metadata, expires_at)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id, created_at, slug, target, clicks, metadata, expires_at
            "#,
            link.slug,
            link.target,
            link.clicks,
            link.metadata,
            link.expires_at,
        )
        .fetch_one(pool)
        .await?;

        Ok(record)
    }

    pub async fn get_by_slug(pool: &PgPool, slug: &str) -> Result<Link, sqlx::Error> {
        let record = sqlx::query_as!(
            Link,
            r#"SELECT id, created_at, slug, target, clicks, metadata, expires_at FROM links WHERE slug = $1"#,
            slug,
        )
            .fetch_one(pool)
            .await?;

        Ok(record)
    }
}
