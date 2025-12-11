CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

INSERT INTO items (name, description) VALUES
('Sample Item 1', 'First sample item from init script'),
('Sample Item 2', 'Second sample item from init script'),
('Sample Item 3', 'Third sample item from init script');
