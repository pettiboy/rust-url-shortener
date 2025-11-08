use axum::{http::StatusCode, Json};
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct ShortenRequest {
    url: String,
    custom: String,
}

#[derive(Serialize)]
pub struct ShortenResponse {
    id: String,
}

pub async fn shorten(
    // this argument tells axum to parse the request body
    // as JSON into a `ShortenRequest` type
    Json(payload): Json<ShortenRequest>,
) -> (StatusCode, Json<ShortenResponse>) {
    tracing::info!("url is {}", payload.url);

    // insert your application logic here
    let res = ShortenResponse { id: payload.custom };

    // this will be converted into a JSON response
    // with a status code of `201 Created`
    (StatusCode::CREATED, Json(res))
}
