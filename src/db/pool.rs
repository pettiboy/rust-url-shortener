use sqlx::PgPool;

pub async fn get_db_pool(db_url: &str) -> PgPool {
    PgPool::connect(db_url)
        .await
        .expect("Failed to connect to database")
}
