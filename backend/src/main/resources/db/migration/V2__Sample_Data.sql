-- Add test/sample data
INSERT INTO users (email, username, password, identity_verified, is_active, email_verified, role)
VALUES 
    ('demo@example.com', 'Demo User', '$2a$10$xN7qJqPZK8P8v5aR9mZJU.vZm5hW0wXn4Z8D5lL5Jz5K5J5K5J5K5', true, true, true, 'USER'),
    ('admin@example.com', 'Admin User', '$2a$10$xN7qJqPZK8P8v5aR9mZJU.vZm5hW0wXn4Z8D5lL5Jz5K5J5K5J5K5', true, true, true, 'ADMIN');

-- Note: The password above is hashed version of 'password123'
-- In production, users should be created through the registration endpoint with proper password hashing
