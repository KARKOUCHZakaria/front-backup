-- Clean database script for creditxai
-- Run this in pgAdmin or psql to clean and recreate the database

-- Drop all tables if they exist
DROP TABLE IF EXISTS prediction_results CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS credit_applications CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop flyway schema history to restart migrations
DROP TABLE IF EXISTS flyway_schema_history CASCADE;

-- Now restart your Spring Boot application
-- Flyway will recreate all tables with correct schema
