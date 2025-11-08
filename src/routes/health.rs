use axum::{extract::State, response::IntoResponse, Json};
use serde::Serialize;
use sqlx::PgPool;

#[derive(Serialize)]
struct HealthResponse {
    status: bool,
    database: bool,
}

pub async fn health(State(pool): State<PgPool>) -> impl IntoResponse {
    let database = pool.acquire().await.is_ok();

    Json(HealthResponse {
        status: true,
        database,
    })
}
