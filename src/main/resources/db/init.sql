-- Recreate items table with richer payload and deterministic IDs
DROP TABLE IF EXISTS items;

CREATE TABLE items (
    id BIGINT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    details JSONB NOT NULL
);

-- Populate 10,000 rows with predictable IDs and a ~1.5 KB payload each
INSERT INTO items (id, name, category, details)
SELECT
    gs AS id,
    CONCAT('Item ', gs) AS name,
    (ARRAY['books', 'electronics', 'grocery', 'toys', 'tools', 'fashion'])[(gs % 6) + 1] AS category,
    jsonb_build_object(
        'description', CONCAT('Item ', gs, ' long description'),
        'category', (ARRAY['books', 'electronics', 'grocery', 'toys', 'tools', 'fashion'])[(gs % 6) + 1],
        'index', gs,
        'data', repeat('X', 1500)
    ) AS details
FROM generate_series(1, 10000) AS gs;
