ALTER TABLE category DROP CONSTRAINT unique_default_category;

CREATE UNIQUE INDEX unique_default_category_per_user
ON category(user_id)
WHERE is_default = true;
