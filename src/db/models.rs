use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, FromRow, Default)]
pub struct Link {
    // db auto sets this field
    pub id: Option<Uuid>,
    pub created_at: Option<DateTime<Utc>>,

    // required fields
    pub slug: String,
    pub target: String,

    // optional fields
    // - db has default values
    pub clicks: i64,
    pub metadata: serde_json::Value,
    // - nullable
    pub expires_at: Option<DateTime<Utc>>,
}
