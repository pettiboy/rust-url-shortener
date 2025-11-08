use sqlx::PgPool;

use crate::db::models::Link;

pub struct LinkRepository;

impl LinkRepository {
    pub async fn create(pool: &PgPool, link: &Link) -> Result<Link, sqlx::Error> {
        let record = sqlx::query_as!(
            Link,
            r#"
            INSERT INTO links (slug, target, expires_at, metadata)
            VALUES ($1, $2, $3, $4)
            RETURNING id, created_at, slug, target, clicks, metadata, expires_at
            "#,
            link.slug,
            link.target,
            link.expires_at,
            link.metadata
        )
        .fetch_one(pool)
        .await?;

        Ok(record)
    }
}
