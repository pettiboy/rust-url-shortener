use axum::{extract::State, response::IntoResponse, Json};
use serde::Serialize;

use crate::routes::AppState;

#[derive(Serialize)]
struct HealthResponse {
    status: bool,
    database: bool,
}

pub async fn health(State(state): State<AppState>) -> impl IntoResponse {
    let database = state.db_pool.acquire().await.is_ok();

    Json(HealthResponse {
        status: true,
        database,
    })
}
