use crate::db::LinkRepository;
use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Redirect},
};
use chrono::Utc;
use sqlx::PgPool;

pub async fn redirect(State(pool): State<PgPool>, Path(slug): Path<String>) -> impl IntoResponse {
    match LinkRepository::get_by_slug(&pool, &slug).await {
        Ok(link) => {
            if let Some(expiry) = link.expires_at {
                if Utc::now() > expiry {
                    return StatusCode::GONE.into_response();
                }
            }

            // TODO: spawn async task to increment click count

            Redirect::temporary(&link.target).into_response()
        }
        Err(_) => StatusCode::NOT_FOUND.into_response(),
    }
}
