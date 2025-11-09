use crate::routes::create_router;
use std::net::SocketAddr;
use tokio::net::TcpListener;

mod config;
mod db;
mod routes;
mod telemetry;
mod utils;

#[tokio::main]
async fn main() {
    dotenv::dotenv().ok();

    telemetry::init_tracing();

    let cfg = config::AppConfig::from_env();
    let db_pool = db::get_db_pool(&cfg.db_url).await;

    if cfg.run_migrations {
        tracing::info!("Running database migrations...");
        sqlx::migrate!("./migrations")
            .run(&db_pool)
            .await
            .expect("Failed to run migrations");
        tracing::info!("Migrations completed successfully");
    }

    let app = create_router(db_pool);

    let addr = SocketAddr::from(([0, 0, 0, 0], cfg.port.parse().unwrap()));
    let listener = TcpListener::bind(addr)
        .await
        .expect("Failed to bind to address");
    tracing::info!("Running on port {}", cfg.port);

    axum::serve(listener, app).await.expect("Server error");
}
