-- E-Commerce Analytics Database Setup
-- Database initialization for e-commerce analytics platform

-- ============================================================================
-- DATABASE CREATION AND INITIAL SETUP
-- ============================================================================

-- Create database
CREATE DATABASE EcommerceAnalytics;
GO
USE EcommerceAnalytics;
GO

-- Enable advanced features for analytics
ALTER DATABASE EcommerceAnalytics SET QUERY_STORE = ON;
GO

-- ============================================================================
-- EXECUTE SCHEMA FILES IN ORDER
-- ============================================================================

-- Step 1: Create core business tables
-- Run: schema/core_tables.sql

-- Step 2: Create analytics tables
-- Run: schema/analytics_tables.sql

-- Step 3: Generate sample data
-- Run: data/sample_data.sql

-- ============================================================================
-- BASIC INDEXES FOR QUERY PERFORMANCE
-- ============================================================================

-- Core business indexes
CREATE NONCLUSTERED INDEX IX_Orders_UserDate ON orders(user_id, order_date);
CREATE NONCLUSTERED INDEX IX_Orders_Status ON orders(order_status, payment_status);
CREATE NONCLUSTERED INDEX IX_OrderItems_Product ON order_items(product_id);
CREATE NONCLUSTERED INDEX IX_Products_Category ON products(category_id, status);
CREATE NONCLUSTERED INDEX IX_Users_Type ON users(user_type, is_active);

-- Analytics indexes
CREATE NONCLUSTERED INDEX IX_PageViews_User ON page_views(user_id, viewed_at);
CREATE NONCLUSTERED INDEX IX_Sessions_User ON user_sessions(user_id, session_start);
CREATE NONCLUSTERED INDEX IX_Reviews_Product ON product_reviews(product_id, rating);

-- ============================================================================
-- VERIFY SETUP
-- ============================================================================

-- Check table creation
SELECT
    'Tables Created' AS component,
    COUNT(*) AS count
FROM sys.tables
WHERE schema_id = SCHEMA_ID('dbo');

-- Check indexes
SELECT
    'Indexes Created' AS component,
    COUNT(*) AS count
FROM sys.indexes
WHERE object_id IN (SELECT object_id FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo'))
AND index_id > 0;

PRINT 'Database setup complete! Ready for data loading.';
GO