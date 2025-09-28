-- Legacy Credit Control System Database Schema
-- Phase 1: Legacy System Implementation
-- Created: 2025-09-25

-- Create database (run as postgres superuser)
-- CREATE DATABASE creditcontrol;
-- CREATE USER creditapp WITH PASSWORD 'secure123';
-- GRANT ALL PRIVILEGES ON DATABASE creditcontrol TO creditapp;

-- Connect to creditcontrol database before running the following

-- ===============================================
-- CUSTOMER MANAGEMENT TABLES
-- ===============================================

-- Customer basic information
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    address TEXT,
    industry VARCHAR(50),
    registration_number VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE'
);

-- Customer credit profiles
CREATE TABLE IF NOT EXISTS customer_credit (
    credit_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    credit_limit DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    available_credit DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    credit_rating VARCHAR(10) DEFAULT 'C', -- AAA, AA, A, BBB, BB, B, CCC, CC, C, D
    risk_score INTEGER DEFAULT 50, -- 0-100 scale
    last_review_date DATE,
    credit_officer VARCHAR(100),
    approval_status VARCHAR(20) DEFAULT 'PENDING',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- TRANSACTION TABLES (TableA for daily operations)
-- ===============================================

-- Daily transaction records - this is "TableA" mentioned in requirements
CREATE TABLE IF NOT EXISTS daily_transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- PREMIUM, PAYMENT, ADJUSTMENT, PENALTY
    reference_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    outstanding_amount DECIMAL(15,2) DEFAULT 0.00,
    due_date DATE,
    payment_date DATE,
    payment_method VARCHAR(30), -- CASH, CHECK, TRANSFER, CREDIT_CARD
    description TEXT,
    processed_by VARCHAR(100),
    batch_processed BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment history tracking
CREATE TABLE IF NOT EXISTS payment_history (
    payment_id SERIAL PRIMARY KEY,
    transaction_id INTEGER REFERENCES daily_transactions(transaction_id),
    customer_id INTEGER REFERENCES customers(customer_id),
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(30),
    reference_number VARCHAR(50),
    notes TEXT,
    processed_by VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- BATCH PROCESSING TABLES (TableB for summarization)
-- ===============================================

-- Monthly/periodic summaries - this is "TableB" mentioned in requirements
CREATE TABLE IF NOT EXISTS customer_summaries (
    summary_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    period_year INTEGER NOT NULL,
    period_month INTEGER NOT NULL,
    total_premiums DECIMAL(15,2) DEFAULT 0.00,
    total_payments DECIMAL(15,2) DEFAULT 0.00,
    total_outstanding DECIMAL(15,2) DEFAULT 0.00,
    overdue_amount DECIMAL(15,2) DEFAULT 0.00,
    payment_count INTEGER DEFAULT 0,
    avg_days_overdue DECIMAL(5,2) DEFAULT 0.00,
    credit_utilization DECIMAL(5,4) DEFAULT 0.0000, -- percentage as decimal
    risk_indicator VARCHAR(20) DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH, CRITICAL
    batch_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by VARCHAR(100),
    UNIQUE(customer_id, period_year, period_month)
);

-- Batch processing log
CREATE TABLE IF NOT EXISTS batch_processing_log (
    batch_id SERIAL PRIMARY KEY,
    batch_date DATE NOT NULL,
    batch_type VARCHAR(50) NOT NULL, -- DAILY_SUMMARY, MONTHLY_SUMMARY, CREDIT_REVIEW
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    records_processed INTEGER DEFAULT 0,
    records_successful INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'RUNNING', -- RUNNING, COMPLETED, FAILED
    error_messages TEXT,
    processed_by VARCHAR(100)
);

-- ===============================================
-- SYSTEM CONFIGURATION TABLES
-- ===============================================

-- System parameters
CREATE TABLE IF NOT EXISTS system_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT NOT NULL,
    description TEXT,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(100)
);

-- User access log (simple logging)
CREATE TABLE IF NOT EXISTS access_log (
    log_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100),
    action VARCHAR(100),
    table_name VARCHAR(100),
    record_id VARCHAR(50),
    ip_address INET,
    access_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- INDEXES FOR PERFORMANCE
-- ===============================================

-- Customer indexes
CREATE INDEX IF NOT EXISTS idx_customers_code ON customers(customer_code);
CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(company_name);
CREATE INDEX IF NOT EXISTS idx_customers_status ON customers(status);

-- Credit indexes
CREATE INDEX IF NOT EXISTS idx_credit_customer ON customer_credit(customer_id);
CREATE INDEX IF NOT EXISTS idx_credit_rating ON customer_credit(credit_rating);
CREATE INDEX IF NOT EXISTS idx_credit_risk ON customer_credit(risk_score);

-- Transaction indexes
CREATE INDEX IF NOT EXISTS idx_transactions_customer ON daily_transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON daily_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON daily_transactions(transaction_type);
CREATE INDEX IF NOT EXISTS idx_transactions_batch ON daily_transactions(batch_processed);
CREATE INDEX IF NOT EXISTS idx_transactions_ref ON daily_transactions(reference_number);

-- Payment indexes
CREATE INDEX IF NOT EXISTS idx_payments_customer ON payment_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payment_history(payment_date);
CREATE INDEX IF NOT EXISTS idx_payments_transaction ON payment_history(transaction_id);

-- Summary indexes
CREATE INDEX IF NOT EXISTS idx_summaries_customer ON customer_summaries(customer_id);
CREATE INDEX IF NOT EXISTS idx_summaries_period ON customer_summaries(period_year, period_month);

-- Batch log indexes
CREATE INDEX IF NOT EXISTS idx_batch_date ON batch_processing_log(batch_date);
CREATE INDEX IF NOT EXISTS idx_batch_status ON batch_processing_log(status);

-- ===============================================
-- SAMPLE DATA FOR TESTING
-- ===============================================

-- Insert system configuration
INSERT INTO system_config (config_key, config_value, description, updated_by) VALUES
('CREDIT_LIMIT_DEFAULT', '100000.00', 'Default credit limit for new customers', 'SYSTEM'),
('RISK_THRESHOLD_HIGH', '75', 'Risk score threshold for high risk classification', 'SYSTEM'),
('RISK_THRESHOLD_CRITICAL', '90', 'Risk score threshold for critical risk classification', 'SYSTEM'),
('BATCH_PROCESSING_TIME', '02:00:00', 'Daily batch processing time', 'SYSTEM'),
('OVERDUE_GRACE_DAYS', '30', 'Grace period days before marking as overdue', 'SYSTEM')
ON CONFLICT (config_key) DO NOTHING;

-- Insert sample customers (5 test customers)
INSERT INTO customers (customer_code, company_name, contact_person, phone, email, industry, registration_number) VALUES
('CUST001', 'ABC Manufacturing Ltd', 'John Smith', '+1-555-0101', 'john.smith@abcmfg.com', 'Manufacturing', 'REG001234'),
('CUST002', 'XYZ Trading Corp', 'Jane Doe', '+1-555-0102', 'jane.doe@xyztrading.com', 'Trading', 'REG001235'),
('CUST003', 'Global Logistics Inc', 'Mike Johnson', '+1-555-0103', 'mike.johnson@globallog.com', 'Logistics', 'REG001236'),
('CUST004', 'Tech Solutions LLC', 'Sarah Wilson', '+1-555-0104', 'sarah.wilson@techsol.com', 'Technology', 'REG001237'),
('CUST005', 'Green Energy Co', 'Robert Brown', '+1-555-0105', 'robert.brown@greenenergy.com', 'Energy', 'REG001238')
ON CONFLICT (customer_code) DO NOTHING;

-- Insert credit profiles for sample customers
INSERT INTO customer_credit (customer_id, credit_limit, available_credit, credit_rating, risk_score, credit_officer, approval_status) VALUES
((SELECT customer_id FROM customers WHERE customer_code = 'CUST001'), 150000.00, 150000.00, 'A', 25, 'Credit Officer 1', 'APPROVED'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST002'), 100000.00, 85000.00, 'BBB', 45, 'Credit Officer 1', 'APPROVED'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST003'), 200000.00, 180000.00, 'AA', 15, 'Credit Officer 2', 'APPROVED'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST004'), 75000.00, 60000.00, 'B', 65, 'Credit Officer 2', 'APPROVED'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST005'), 120000.00, 100000.00, 'BBB', 40, 'Credit Officer 1', 'APPROVED')
ON CONFLICT DO NOTHING;

-- Insert sample transactions
INSERT INTO daily_transactions (customer_id, transaction_date, transaction_type, reference_number, amount, outstanding_amount, due_date, description, processed_by) VALUES
((SELECT customer_id FROM customers WHERE customer_code = 'CUST001'), CURRENT_DATE - INTERVAL '10 days', 'PREMIUM', 'TXN001', 15000.00, 0.00, CURRENT_DATE + INTERVAL '30 days', 'Monthly insurance premium', 'System Auto'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST002'), CURRENT_DATE - INTERVAL '5 days', 'PREMIUM', 'TXN002', 8500.00, 8500.00, CURRENT_DATE + INTERVAL '25 days', 'Quarterly insurance premium', 'System Auto'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST003'), CURRENT_DATE - INTERVAL '3 days', 'PAYMENT', 'PAY001', -20000.00, 0.00, NULL, 'Payment received for premium', 'User Admin'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST004'), CURRENT_DATE - INTERVAL '15 days', 'PREMIUM', 'TXN003', 12000.00, 12000.00, CURRENT_DATE - INTERVAL '15 days', 'Overdue premium payment', 'System Auto'),
((SELECT customer_id FROM customers WHERE customer_code = 'CUST005'), CURRENT_DATE - INTERVAL '7 days', 'PREMIUM', 'TXN004', 18000.00, 9000.00, CURRENT_DATE + INTERVAL '23 days', 'Annual premium - partial payment', 'System Auto')
ON CONFLICT (reference_number) DO NOTHING;

-- Set schema permissions
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO creditapp;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO creditapp;