-- Flyway Migration V1: Initial Schema
-- Create Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    identity_verified BOOLEAN DEFAULT FALSE,
    cin VARCHAR(50),
    cin_photo VARCHAR(500),
    phone VARCHAR(20),
    country_code VARCHAR(5),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(20) DEFAULT 'USER',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_username ON users(username);

-- Create Credit Applications table
CREATE TABLE credit_applications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    application_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Demographic Information
    code_gender VARCHAR(10),
    days_birth INTEGER,
    name_education_type VARCHAR(100),
    name_family_status VARCHAR(100),
    cnt_children INTEGER,
    
    -- Financial Information
    amt_income_total DECIMAL(15, 2),
    amt_credit DECIMAL(15, 2),
    amt_annuity DECIMAL(15, 2),
    amt_goods_price DECIMAL(15, 2),
    
    -- Employment Information
    days_employed INTEGER,
    occupation_type VARCHAR(100),
    organization_type VARCHAR(100),
    
    -- Contract Information
    name_contract_type VARCHAR(50),
    name_income_type VARCHAR(100),
    name_housing_type VARCHAR(100),
    
    -- Additional Features
    flag_own_car VARCHAR(1),
    flag_own_realty VARCHAR(1),
    region_rating_client INTEGER,
    ext_source_1 DECIMAL(10, 6),
    ext_source_2 DECIMAL(10, 6),
    ext_source_3 DECIMAL(10, 6),
    
    -- Application Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    processed_at TIMESTAMP
);

CREATE INDEX idx_app_user_id ON credit_applications(user_id);
CREATE INDEX idx_app_status ON credit_applications(status);
CREATE INDEX idx_app_created_at ON credit_applications(created_at);

-- Create Documents table
CREATE TABLE documents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    application_id BIGINT REFERENCES credit_applications(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    file_name VARCHAR(500) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    file_extension VARCHAR(10),
    is_verified BOOLEAN DEFAULT FALSE,
    verification_status VARCHAR(20),
    description TEXT,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_doc_user_id ON documents(user_id);
CREATE INDEX idx_doc_application_id ON documents(application_id);
CREATE INDEX idx_doc_type ON documents(document_type);

-- Create Prediction Results table
CREATE TABLE prediction_results (
    id BIGSERIAL PRIMARY KEY,
    application_id BIGINT NOT NULL REFERENCES credit_applications(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    application_id_ref VARCHAR(100) UNIQUE,
    prediction_probability DECIMAL(10, 6) NOT NULL,
    credit_score INTEGER NOT NULL,
    decision VARCHAR(20) NOT NULL,
    confidence DECIMAL(10, 6) NOT NULL,
    shap_values JSONB,
    risk_level VARCHAR(20),
    
    -- Fairness Metrics
    demographic_parity DECIMAL(10, 6),
    equal_opportunity DECIMAL(10, 6),
    disparate_impact DECIMAL(10, 6),
    average_odds_difference DECIMAL(10, 6),
    fairness_score INTEGER,
    
    -- Model Information
    model_version VARCHAR(50),
    processing_time_ms BIGINT,
    metadata JSONB,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pred_application_id ON prediction_results(application_id);
CREATE INDEX idx_pred_user_id ON prediction_results(user_id);
CREATE INDEX idx_pred_decision ON prediction_results(decision);

-- Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credit_applications_updated_at BEFORE UPDATE ON credit_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
