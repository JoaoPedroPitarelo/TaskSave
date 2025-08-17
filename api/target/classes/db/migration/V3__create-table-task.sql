CREATE TABLE task (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    deadline DATE,
    last_modification TIMESTAMP,
    priority priority NOT NULL,
    category_id INTEGER NOT NULL REFERENCES category(id),
    status status NOT NULL,
    reminder_type reminder_type
);
