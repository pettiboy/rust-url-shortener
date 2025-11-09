use axum::{extract::{Request, State}, http::StatusCode, middleware::Next, response::Response};

use crate::routes::AppState;

pub async fn api_key_auth(
    State(state): State<AppState>,
    req: Request,
    next: Next,
) -> Result<Response, StatusCode> {
    tracing::info!("api_key_auth middleware");
    tracing::info!("state: {:?}", state.cfg.api_key);

    // extract api key from request headers
    let api_key = req
        .headers()
        .get("x-api-key")
        .and_then(|header| header.to_str().ok())
        .unwrap_or_default();

    tracing::info!("api_key: {:?}", api_key);

    if api_key == state.cfg.api_key {
        // all good, continue
        Ok(next.run(req).await)
    } else {
        Err(StatusCode::UNAUTHORIZED)
    }
}
