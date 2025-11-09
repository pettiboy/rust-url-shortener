use std::env;

#[derive(Clone)]
pub struct AppConfig {
    // each value owns its heap data
    pub port: String,
    pub db_url: String,
    pub run_migrations: bool,
    pub api_key: String,
}

impl AppConfig {
    // does not take self, is a an associated function - a constructor
    pub fn from_env() -> Self {
        let port = env::var("PORT")
            // takes in a closure (mini function) that only runs if result is an Err
            .unwrap_or_else(
                // |_| means ignore the argument
                // "8080" is a `&'static str` convert it to heap-allocated `String`
                |_| "8080".to_string(),
            );
        // above is more efficient that unwrap_or("8080") because the closure form only runs on error

        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL not present in .env file");

        let run_migrations = env::var("RUN_MIGRATIONS")
            .unwrap_or_else(|_| "true".to_string())
            .parse()
            .unwrap_or(true);

        let api_key = env::var("API_KEY").expect("API_KEY not present in .env file");

        Self {
            port,
            db_url,
            run_migrations,
            api_key,
        }
    }
}
