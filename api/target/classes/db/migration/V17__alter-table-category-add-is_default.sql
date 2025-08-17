ALTER TABLE category
ADD COLUMN is_default BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE category
ADD CONSTRAINT unique_default_category UNIQUE (user_id, is_default);
