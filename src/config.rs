use std::env;

pub struct AppConfig {
    // each value owns its heap data
    pub port: String,
    pub db_url: String,
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

        // same as AppConfig { port, db_url }
        Self { port, db_url }
    }
}
