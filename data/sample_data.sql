-- E-Commerce Analytics Sample Data
-- Realistic test dataset for comprehensive business analysis

-- ============================================================================
-- CATEGORIES DATA
-- ============================================================================

INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Fashion and apparel'),
('Books', 'Books and literature'),
('Home & Garden', 'Home improvement and gardening'),
('Sports', 'Sports and outdoor equipment');

-- Subcategories
INSERT INTO categories (parent_category_id, category_name, description) VALUES
(1, 'Smartphones', 'Mobile phones and accessories'),
(1, 'Laptops', 'Portable computers'),
(2, 'Men''s Clothing', 'Clothing for men'),
(2, 'Women''s Clothing', 'Clothing for women');

-- ============================================================================
-- USERS DATA
-- ============================================================================

-- Customer users
INSERT INTO users (email, username, first_name, last_name, phone, date_of_birth, gender, user_type, registration_date) VALUES
('john.doe@email.com', 'johndoe', 'John', 'Doe', '+1234567890', '1985-05-15', 'M', 'customer', '2023-01-15'),
('jane.smith@email.com', 'janesmith', 'Jane', 'Smith', '+1234567891', '1990-08-22', 'F', 'customer', '2023-02-10'),
('mike.wilson@email.com', 'mikewilson', 'Mike', 'Wilson', '+1234567892', '1988-03-10', 'M', 'customer', '2023-03-05'),
('sarah.johnson@email.com', 'sarahjohnson', 'Sarah', 'Johnson', '+1234567893', '1992-12-03', 'F', 'customer', '2023-04-12'),
('david.brown@email.com', 'davidbrown', 'David', 'Brown', '+1234567894', '1987-07-18', 'M', 'customer', '2023-05-20'),
('emma.davis@email.com', 'emmadavis', 'Emma', 'Davis', '+1234567895', '1995-01-25', 'F', 'customer', '2023-06-08'),
('alex.miller@email.com', 'alexmiller', 'Alex', 'Miller', '+1234567896', '1991-09-12', 'M', 'customer', '2023-07-14'),
('lisa.taylor@email.com', 'lisataylor', 'Lisa', 'Taylor', '+1234567897', '1989-11-30', 'F', 'customer', '2023-08-22');

-- Vendor users
INSERT INTO users (email, username, first_name, last_name, user_type, registration_date) VALUES
('techstore@vendor.com', 'techstore', 'Tech', 'Store', 'vendor', '2022-12-01'),
('fashionhub@vendor.com', 'fashionhub', 'Fashion', 'Hub', 'vendor', '2023-01-01'),
('bookworm@vendor.com', 'bookworm', 'Book', 'Worm', 'vendor', '2023-02-01');

-- ============================================================================
-- VENDORS DATA
-- ============================================================================

INSERT INTO vendors (user_id, business_name, commission_rate, rating, total_sales, status) VALUES
(9, 'TechStore Electronics', 0.15, 4.5, 125000.00, 'approved'),
(10, 'Fashion Hub Boutique', 0.12, 4.8, 89000.00, 'approved'),
(11, 'BookWorm Central', 0.10, 4.6, 45000.00, 'approved');

-- ============================================================================
-- PRODUCTS DATA
-- ============================================================================

-- Electronics products
INSERT INTO products (vendor_id, category_id, sku, product_name, description, brand, base_price, sale_price, cost_price, stock_quantity) VALUES
(1, 2, 'IPHONE14-128-BLK', 'iPhone 14 128GB Black', 'Latest iPhone with advanced camera system', 'Apple', 899.99, 849.99, 750.00, 25),
(1, 2, 'SAMSUNG-S23-256', 'Samsung Galaxy S23 256GB', 'Premium Android phone with excellent camera', 'Samsung', 799.99, 759.99, 650.00, 18),
(1, 3, 'MACBOOK-AIR-M2', 'MacBook Air M2 512GB', 'Ultra-thin laptop with M2 chip', 'Apple', 1399.99, 1349.99, 1200.00, 12),
(1, 3, 'DELL-XPS13-I7', 'Dell XPS 13 Intel i7', 'Premium Windows laptop', 'Dell', 1299.99, 1249.99, 1100.00, 8);

-- Clothing products
INSERT INTO products (vendor_id, category_id, sku, product_name, description, brand, base_price, cost_price, stock_quantity) VALUES
(2, 4, 'LEVIS-501-32W32L', 'Levi''s 501 Original Jeans', 'Classic straight-leg jeans', 'Levi''s', 89.99, 45.00, 35),
(2, 4, 'NIKE-HOODIE-L', 'Nike Sportswear Hoodie Large', 'Comfortable cotton hoodie', 'Nike', 64.99, 35.00, 28),
(2, 5, 'ZARA-DRESS-M', 'Zara Midi Dress Medium', 'Elegant black midi dress', 'Zara', 79.99, 40.00, 22);

-- Books
INSERT INTO products (vendor_id, category_id, sku, product_name, description, base_price, cost_price, stock_quantity) VALUES
(3, 1, 'BOOK-DATA-SCI', 'Data Science for Business', 'Comprehensive guide to business analytics', 49.99, 25.00, 75),
(3, 1, 'BOOK-SQL-GUIDE', 'SQL Complete Reference', 'Comprehensive SQL reference guide', 39.99, 20.00, 50);

-- ============================================================================
-- ORDERS DATA
-- ============================================================================

-- Q4 2023 orders
INSERT INTO orders (user_id, order_number, order_status, payment_status, subtotal, tax_amount, shipping_cost, total_amount, order_date, delivered_date) VALUES
(1, 'ORD-2023-001', 'delivered', 'paid', 849.99, 68.00, 15.99, 933.98, '2023-11-15 10:30:00', '2023-11-18 11:45:00'),
(2, 'ORD-2023-002', 'delivered', 'paid', 759.99, 60.80, 15.99, 836.78, '2023-11-20 15:45:00', '2023-11-22 16:20:00'),
(3, 'ORD-2023-003', 'delivered', 'paid', 1349.99, 107.99, 0.00, 1457.98, '2023-12-01 09:15:00', '2023-12-05 14:10:00'),
(4, 'ORD-2023-004', 'delivered', 'paid', 154.98, 12.40, 9.99, 177.37, '2023-12-10 14:20:00', '2023-12-14 10:30:00'),
(5, 'ORD-2023-005', 'delivered', 'paid', 89.99, 7.20, 7.99, 105.18, '2023-12-15 11:30:00', '2023-12-19 15:45:00');

-- 2024 orders
INSERT INTO orders (user_id, order_number, order_status, payment_status, subtotal, tax_amount, shipping_cost, total_amount, order_date) VALUES
(6, 'ORD-2024-001', 'delivered', 'paid', 1249.99, 100.00, 19.99, 1369.98, '2024-01-08 13:45:00'),
(7, 'ORD-2024-002', 'processing', 'paid', 64.99, 5.20, 5.99, 76.18, '2024-01-15 16:20:00'),
(8, 'ORD-2024-003', 'shipped', 'paid', 79.99, 6.40, 0.00, 86.39, '2024-01-18 10:15:00');

-- ============================================================================
-- ORDER ITEMS DATA
-- ============================================================================

-- Order items for the orders above
INSERT INTO order_items (order_id, product_id, vendor_id, quantity, unit_price, total_price, commission_amount) VALUES
-- Order 1: iPhone
(1, 1, 1, 1, 849.99, 849.99, 127.50),
-- Order 2: Samsung phone
(2, 2, 1, 1, 759.99, 759.99, 114.00),
-- Order 3: MacBook
(3, 3, 1, 1, 1349.99, 1349.99, 202.50),
-- Order 4: Clothing bundle
(4, 5, 2, 1, 89.99, 89.99, 10.80),
(4, 6, 2, 1, 64.99, 64.99, 7.80),
-- Order 5: Jeans
(5, 5, 2, 1, 89.99, 89.99, 10.80),
-- 2024 orders
(6, 4, 1, 1, 1249.99, 1249.99, 187.50),
(7, 6, 2, 1, 64.99, 64.99, 7.80),
(8, 7, 2, 1, 79.99, 79.99, 9.60);

-- ============================================================================
-- CUSTOMER BEHAVIOR DATA
-- ============================================================================

-- User sessions
INSERT INTO user_sessions (user_id, session_token, device_type, browser, session_start, session_end, page_views, session_duration_minutes) VALUES
(1, 'sess_1a2b3c4d', 'desktop', 'Chrome', '2023-11-15 10:00:00', '2023-11-15 10:45:00', 8, 45),
(2, 'sess_2b3c4d5e', 'mobile', 'Safari', '2023-11-20 15:20:00', '2023-11-20 16:00:00', 12, 40),
(3, 'sess_3c4d5e6f', 'desktop', 'Firefox', '2023-12-01 08:45:00', '2023-12-01 09:30:00', 15, 45),
(4, 'sess_4d5e6f7g', 'tablet', 'Chrome', '2023-12-10 13:50:00', '2023-12-10 14:35:00', 6, 45),
(5, 'sess_5e6f7g8h', 'mobile', 'Chrome', '2023-12-15 11:00:00', '2023-12-15 11:50:00', 9, 50);

-- Page views
INSERT INTO page_views (session_id, user_id, page_url, page_type, product_id, time_on_page_seconds, viewed_at) VALUES
(1, 1, '/products/iphone-14', 'product', 1, 300, '2023-11-15 10:02:00'),
(1, 1, '/cart', 'cart', NULL, 90, '2023-11-15 10:25:00'),
(2, 2, '/products/samsung-s23', 'product', 2, 420, '2023-11-20 15:25:00'),
(3, 3, '/products/macbook-air', 'product', 3, 480, '2023-12-01 08:50:00'),
(4, 4, '/products/levis-jeans', 'product', 5, 180, '2023-12-10 14:00:00');

-- Search queries
INSERT INTO search_queries (session_id, user_id, search_term, results_count, clicked_product_id, search_date) VALUES
(1, 1, 'iphone 14', 5, 1, '2023-11-15 10:01:00'),
(2, 2, 'samsung phone', 8, 2, '2023-11-20 15:22:00'),
(3, 3, 'macbook air', 4, 3, '2023-12-01 08:50:00');

-- ============================================================================
-- REVIEWS AND RATINGS
-- ============================================================================

-- Product reviews
INSERT INTO product_reviews (product_id, user_id, order_id, rating, review_title, review_text, is_verified, helpful_votes, total_votes, created_at) VALUES
(1, 1, 1, 5, 'Excellent phone!', 'Great camera quality and battery life. Very satisfied.', 1, 12, 15, '2023-11-25 16:30:00'),
(2, 2, 2, 4, 'Good Android phone', 'Nice phone but battery could be better. Camera is excellent.', 1, 8, 12, '2023-11-28 14:20:00'),
(3, 3, 3, 5, 'Perfect for work', 'Fast, reliable, great build quality. M2 chip is amazing.', 1, 18, 22, '2023-12-08 11:45:00'),
(5, 5, 5, 5, 'Classic jeans', 'Perfect fit and great quality denim. Will buy again.', 1, 4, 5, '2023-12-22 13:30:00');

-- ============================================================================
-- PAYMENT TRANSACTIONS
-- ============================================================================

INSERT INTO payment_transactions (order_id, payment_method, payment_provider, amount, status, processing_fee, transaction_date) VALUES
(1, 'credit_card', 'stripe', 933.98, 'completed', 27.24, '2023-11-15 10:35:00'),
(2, 'paypal', 'paypal', 836.78, 'completed', 24.26, '2023-11-20 15:50:00'),
(3, 'credit_card', 'stripe', 1457.98, 'completed', 42.28, '2023-12-01 09:20:00'),
(4, 'debit_card', 'stripe', 177.37, 'completed', 5.14, '2023-12-10 14:25:00'),
(5, 'credit_card', 'stripe', 105.18, 'completed', 3.05, '2023-12-15 11:35:00');

-- ============================================================================
-- INVENTORY MOVEMENTS
-- ============================================================================

-- Sample inventory movements
INSERT INTO inventory_movements (product_id, movement_type, quantity_change, previous_quantity, new_quantity, reference_id, movement_date) VALUES
-- Initial stock
(1, 'restock', 50, 0, 50, NULL, '2023-10-01 09:00:00'),
(2, 'restock', 30, 0, 30, NULL, '2023-10-01 09:00:00'),
-- Sales
(1, 'sale', -1, 50, 49, 1, '2023-11-15 10:30:00'),
(2, 'sale', -1, 30, 29, 2, '2023-11-20 15:45:00');

-- ============================================================================
-- DISCOUNT CODES AND USAGE
-- ============================================================================

-- Sample discount codes
INSERT INTO discount_codes (code, discount_type, discount_value, minimum_order_amount, usage_limit, valid_from, valid_until) VALUES
('WELCOME10', 'percentage', 10.00, 50.00, 1000, '2023-01-01', '2024-12-31'),
('SAVE50', 'fixed_amount', 50.00, 500.00, 100, '2023-11-01', '2023-12-31');

PRINT 'Sample data loaded successfully!';
PRINT 'Database ready for analytics queries.';
GO