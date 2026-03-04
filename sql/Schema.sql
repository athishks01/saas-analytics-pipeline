DROP DATABASE IF EXISTS saas_analytics;
CREATE DATABASE saas_analytics;
USE saas_analytics;

CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    signup_date DATE,
    plan_type VARCHAR(50),
    monthly_fee DECIMAL(10,2),
    acquisition_channel VARCHAR(50)
);

CREATE TABLE subscriptions (
    user_id VARCHAR(50),
    trial_start DATE,
    trial_end DATE,
    start_date DATE,
    cancel_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    amount DECIMAL(10,2),
    payment_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    event_name VARCHAR(50),
    event_time DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE marketing_spend (
    id INT AUTO_INCREMENT PRIMARY KEY,
    channel VARCHAR(50),
    month DATE,
    spend DECIMAL(12,2)
);
