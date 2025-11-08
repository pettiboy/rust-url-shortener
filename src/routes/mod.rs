use axum::{
    routing::{get, post},
    Router,
};

mod health;
mod shorten;

pub fn create_router() -> Router {
    Router::new()
        .route("/api/health", get(health::health))
        .route("/api/shorten", post(shorten::shorten))
}
