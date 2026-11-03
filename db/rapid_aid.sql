CREATE DATABASE IF NOT EXISTS rapid_aid;
USE rapid_aid;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(15),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    relationship VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS sos_alerts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    status VARCHAR(30) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Fictional demo rows. Run these INSERT statements once to avoid duplicate records.
-- Replace the demo password hashes with real password hashes before using authentication.
INSERT INTO users (full_name, email, phone, password_hash) VALUES
    ('Ava Shah', 'ava.shah@example.test', '+91-90000-00001', 'DEMO_ONLY_REPLACE_WITH_REAL_HASH'),
    ('Noah Patel', 'noah.patel@example.test', '+91-90000-00002', 'DEMO_ONLY_REPLACE_WITH_REAL_HASH'),
    ('Mia Rao', 'mia.rao@example.test', '+91-90000-00003', 'DEMO_ONLY_REPLACE_WITH_REAL_HASH');

INSERT INTO emergency_contacts (user_id, contact_name, phone, relationship)
SELECT id, 'Riya Shah', '+91-90000-00101', 'Sister'
FROM users
WHERE email = 'ava.shah@example.test';

INSERT INTO emergency_contacts (user_id, contact_name, phone, relationship)
SELECT id, 'Arjun Shah', '+91-90000-00102', 'Brother'
FROM users
WHERE email = 'ava.shah@example.test';

INSERT INTO emergency_contacts (user_id, contact_name, phone, relationship)
SELECT id, 'Leena Patel', '+91-90000-00103', 'Parent'
FROM users
WHERE email = 'noah.patel@example.test';

INSERT INTO sos_alerts (user_id, latitude, longitude, status)
SELECT id, 12.9716000, 77.5946000, 'PENDING'
FROM users
WHERE email = 'ava.shah@example.test';

INSERT INTO sos_alerts (user_id, latitude, longitude, status)
SELECT id, 12.9352000, 77.6245000, 'IN_PROGRESS'
FROM users
WHERE email = 'noah.patel@example.test';

INSERT INTO sos_alerts (user_id, latitude, longitude, status)
SELECT id, 12.9698000, 77.7500000, 'RESOLVED'
FROM users
WHERE email = 'mia.rao@example.test';

-- View user records without exposing password hashes.
SELECT id, full_name, email, phone, created_at
FROM users
ORDER BY id;

SELECT id, user_id, contact_name, phone, relationship
FROM emergency_contacts
ORDER BY id;

SELECT id, user_id, latitude, longitude, status, created_at
FROM sos_alerts
ORDER BY id;
