use axum::{
    middleware,
    routing::{get, post},
    Router,
};
use sqlx::PgPool;

use crate::config::AppConfig;
use crate::middleware::api::api_key_auth;

mod health;
mod redirect;
mod shorten;

#[derive(Clone)]
pub struct AppState {
    pub db_pool: PgPool,
    pub cfg: AppConfig,
}

pub fn create_router(state: &AppState) -> Router {
    // protected API routes
    let api_routes = Router::new()
        .route("/api/health", get(health::health))
        .route("/api/shorten", post(shorten::shorten))
        .layer(middleware::from_fn_with_state(state.clone(), api_key_auth));

    // public routes
    let public_routes = Router::new()
        // redirect route
        .route("/{slug}", get(redirect::redirect));

    // combine and add state
    Router::new()
        .merge(api_routes)
        .merge(public_routes)
        .with_state(state.clone())
}
