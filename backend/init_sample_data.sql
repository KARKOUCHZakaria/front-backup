-- ================================================================================
-- Sample Application Data Initialization
-- Creates test applications to verify ML models are working
-- ================================================================================

-- Insert sample applications for user ID 2 (drissrk@gmail.com)
-- These show different credit scores based on ML model analysis

-- Application 1: APPROVED - High score (780)
INSERT INTO credit_applications (
    user_id, application_number, name_contract_type, code_gender, flag_own_car,
    flag_own_realty, cnt_children, amt_income_total, amt_credit, amt_annuity,
    amt_goods_price, name_income_type, name_education_type, name_family_status,
    name_housing_type, days_birth, days_employed, status, created_at, updated_at
) VALUES (
    2, 'APP-2025-001', 'Cash loans', 'M', 'Y',
    'Y', 0, 45000.00, 25000.00, 1200.00,
    23000.00, 'Working', 'Higher education', 'Married',
    'House / apartment', -12775, -2190, 'APPROVED', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'
);

-- Application 2: APPROVED - Medium score (720)
INSERT INTO credit_applications (
    user_id, application_number, name_contract_type, code_gender, flag_own_car,
    flag_own_realty, cnt_children, amt_income_total, amt_credit, amt_annuity,
    amt_goods_price, name_income_type, name_education_type, name_family_status,
    name_housing_type, days_birth, days_employed, status, created_at, updated_at
) VALUES (
    2, 'APP-2025-002', 'Cash loans', 'M', 'N',
    'Y', 1, 32000.00, 15000.00, 800.00,
    14000.00, 'Working', 'Higher education', 'Married',
    'House / apartment', -11315, -1460, 'APPROVED', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'
);

-- Application 3: PENDING - Being processed
INSERT INTO credit_applications (
    user_id, application_number, name_contract_type, code_gender, flag_own_car,
    flag_own_realty, cnt_children, amt_income_total, amt_credit, amt_annuity,
    amt_goods_price, name_income_type, name_education_type, name_family_status,
    name_housing_type, days_birth, days_employed, status, created_at, updated_at
) VALUES (
    2, 'APP-2025-003', 'Cash loans', 'M', 'N',
    'N', 0, 28000.00, 10000.00, 600.00,
    9500.00, 'Working', 'Secondary education', 'Single',
    'Rented apartment', -10585, -1095, 'PENDING', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'
);

-- Application 4: REJECTED - Low score (550)
INSERT INTO credit_applications (
    user_id, application_number, name_contract_type, code_gender, flag_own_car,
    flag_own_realty, cnt_children, amt_income_total, amt_credit, amt_annuity,
    amt_goods_price, name_income_type, name_education_type, name_family_status,
    name_housing_type, days_birth, days_employed, status, created_at, updated_at
) VALUES (
    2, 'APP-2025-004', 'Cash loans', 'M', 'N',
    'N', 2, 18000.00, 8000.00, 500.00,
    7500.00, 'Working', 'Secondary education', 'Married',
    'With parents', -9855, -365, 'REJECTED', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'
);

-- Get the application IDs for adding prediction results
DO $$
DECLARE
    app1_id BIGINT;
    app2_id BIGINT;
    app3_id BIGINT;
    app4_id BIGINT;
BEGIN
    -- Get application IDs
    SELECT id INTO app1_id FROM credit_applications WHERE application_number = 'APP-2025-001';
    SELECT id INTO app2_id FROM credit_applications WHERE application_number = 'APP-2025-002';
    SELECT id INTO app3_id FROM credit_applications WHERE application_number = 'APP-2025-003';
    SELECT id INTO app4_id FROM credit_applications WHERE application_number = 'APP-2025-004';

    -- Add ML prediction results for Application 1 (APPROVED - High score)
    INSERT INTO prediction_results (
        application_id, user_id, application_id_ref, prediction_probability,
        credit_score, decision, confidence, risk_level, processing_time_ms,
        timestamp, created_at, updated_at
    ) VALUES (
        app1_id, 2, app1_id, 0.85, 780, 'APPROVED', 0.92, 'LOW', 245,
        NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'
    );

    -- Add ML prediction results for Application 2 (APPROVED - Medium score)
    INSERT INTO prediction_results (
        application_id, user_id, application_id_ref, prediction_probability,
        credit_score, decision, confidence, risk_level, processing_time_ms,
        timestamp, created_at, updated_at
    ) VALUES (
        app2_id, 2, app2_id, 0.72, 720, 'APPROVED', 0.84, 'MEDIUM', 198,
        NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'
    );

    -- Add ML prediction results for Application 4 (REJECTED - Low score)
    INSERT INTO prediction_results (
        application_id, user_id, application_id_ref, prediction_probability,
        credit_score, decision, confidence, risk_level, processing_time_ms,
        timestamp, created_at, updated_at
    ) VALUES (
        app4_id, 2, app4_id, 0.35, 550, 'REJECTED', 0.79, 'HIGH', 187,
        NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'
    );

    -- Add sample documents for Application 1 to show ML processed them
    INSERT INTO documents (
        user_id, application_id, document_type, file_path, file_size,
        mime_type, uploaded_at
    ) VALUES
    (2, app1_id, 'CIN_FRONT', 'uploads/identity-scans/cin_front_app1.jpg', 245678, 'image/jpeg', NOW() - INTERVAL '5 days'),
    (2, app1_id, 'CIN_BACK', 'uploads/identity-scans/cin_back_app1.jpg', 234567, 'image/jpeg', NOW() - INTERVAL '5 days'),
    (2, app1_id, 'PAY_SLIP', 'uploads/general/payslip1_app1.pdf', 156789, 'application/pdf', NOW() - INTERVAL '5 days'),
    (2, app1_id, 'PAY_SLIP', 'uploads/general/payslip2_app1.pdf', 158234, 'application/pdf', NOW() - INTERVAL '5 days'),
    (2, app1_id, 'PAY_SLIP', 'uploads/general/payslip3_app1.pdf', 159012, 'application/pdf', NOW() - INTERVAL '5 days'),
    (2, app1_id, 'TAX_DECLARATION', 'uploads/general/tax_app1.pdf', 345678, 'application/pdf', NOW() - INTERVAL '5 days'),
    (2, app1_id, 'BANK_STATEMENT', 'uploads/general/bank_app1.pdf', 456789, 'application/pdf', NOW() - INTERVAL '5 days');

    RAISE NOTICE 'Sample data initialized successfully!';
    RAISE NOTICE 'User ID 2 now has 4 applications:';
    RAISE NOTICE '  - APP-2025-001: APPROVED (780 credit score)';
    RAISE NOTICE '  - APP-2025-002: APPROVED (720 credit score)';
    RAISE NOTICE '  - APP-2025-003: PENDING (awaiting ML analysis)';
    RAISE NOTICE '  - APP-2025-004: REJECTED (550 credit score)';
END $$;
