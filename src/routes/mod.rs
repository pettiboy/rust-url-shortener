use axum::{routing::get, Router};

mod health;
pub use health::health;

pub fn create_router() -> Router {
    Router::new().route("/health", get(health))
}
