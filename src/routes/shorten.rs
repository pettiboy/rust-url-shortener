use axum::{extract::State, http::StatusCode, Json};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

use crate::{
    db::{Link, LinkRepository},
    utils::slug::generate_slug,
};

#[derive(Deserialize)]
pub struct ShortenRequest {
    url: String,
    slug: Option<String>,
}

#[derive(Serialize)]
pub struct ShortenResponse {
    link: Link,
}

pub async fn shorten(
    State(pool): State<PgPool>,
    // this argument tells axum to parse the request body
    // as JSON into a `ShortenRequest` type
    Json(payload): Json<ShortenRequest>,
) -> (StatusCode, Json<ShortenResponse>) {
    tracing::info!("url is {}", payload.url);

    let link = Link {
        slug: payload.slug.unwrap_or_else(|| generate_slug(6)),
        target: payload.url,
        clicks: 0,
        metadata: serde_json::json!({}),
        ..Default::default()
    };

    let link = LinkRepository::create(&pool, &link).await;

    // insert your application logic here
    let res = ShortenResponse {
        link: link.unwrap(),
    };

    // this will be converted into a JSON response
    // with a status code of `201 Created`
    (StatusCode::CREATED, Json(res))
}
