CREATE TABLE IF NOT EXISTS attachment (
    id serial PRIMARY KEY,
    task INT NOT NULL,
    file_path TEXT NOT NULL,
    file_name TEXT,
    file_type TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task) REFERENCES task(id) ON DELETE CASCADE
);