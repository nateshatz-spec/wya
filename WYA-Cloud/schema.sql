-- WYA 3.0 User Data Schema for Cloudflare D1

-- Table for User Accounts
CREATE TABLE IF NOT EXISTS users (
    id            TEXT PRIMARY KEY,
    email         TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name  TEXT,
    created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Table for User Data Snapshots
CREATE TABLE IF NOT EXISTS user_data (
    user_id    TEXT PRIMARY KEY,
    data_json  TEXT NOT NULL,                              -- Full JSON snapshot
    updated_at TEXT NOT NULL,                              -- ISO 8601
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index for listing/auditing by recency
CREATE INDEX IF NOT EXISTS idx_user_data_updated ON user_data(updated_at);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
