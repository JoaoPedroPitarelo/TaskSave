CREATE TABLE subtask (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    deadline DATE,
    last_modification TIMESTAMP,
    priority TEXT NOT NULL,
    status TEXT NOT NULL,
    parent_task_id INTEGER NOT NULL REFERENCES task(id)
);
