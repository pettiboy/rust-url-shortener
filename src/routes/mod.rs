use axum::{
    routing::{get, post},
    Router,
};
use sqlx::PgPool;

mod health;
mod shorten;

pub fn create_router(db_pool: PgPool) -> Router {
    Router::new()
        .route("/api/health", get(health::health))
        .route("/api/shorten", post(shorten::shorten))
        .with_state(db_pool)
}
