-- E-Commerce Analytics Platform - Analytics Tables
-- Tables for customer behavior tracking and business intelligence

-- ============================================================================
-- CUSTOMER BEHAVIOR TRACKING
-- ============================================================================

-- User sessions for website analytics
CREATE TABLE user_sessions (
    session_id BIGINT PRIMARY KEY IDENTITY(1,1),
    user_id BIGINT,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    device_type VARCHAR(50),
    browser VARCHAR(100),
    session_start DATETIME2 DEFAULT GETDATE(),
    session_end DATETIME2,
    page_views INT DEFAULT 0,
    session_duration_minutes INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Page views for user journey analysis
CREATE TABLE page_views (
    page_view_id BIGINT PRIMARY KEY IDENTITY(1,1),
    session_id BIGINT NOT NULL,
    user_id BIGINT,
    page_url VARCHAR(500) NOT NULL,
    page_type VARCHAR(50),
    product_id BIGINT,
    category_id BIGINT,
    time_on_page_seconds INT,
    viewed_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (session_id) REFERENCES user_sessions(session_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Search queries for search optimization
CREATE TABLE search_queries (
    search_id BIGINT PRIMARY KEY IDENTITY(1,1),
    session_id BIGINT,
    user_id BIGINT,
    search_term VARCHAR(500) NOT NULL,
    results_count INT DEFAULT 0,
    clicked_product_id BIGINT,
    search_date DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (session_id) REFERENCES user_sessions(session_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (clicked_product_id) REFERENCES products(product_id)
);

-- ============================================================================
-- CUSTOMER FEEDBACK AND REVIEWS
-- ============================================================================

-- Product reviews and ratings
CREATE TABLE product_reviews (
    review_id BIGINT PRIMARY KEY IDENTITY(1,1),
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_title VARCHAR(255),
    review_text TEXT,
    is_verified BIT DEFAULT 0,
    helpful_votes INT DEFAULT 0,
    total_votes INT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================================
-- BUSINESS OPERATIONS TRACKING
-- ============================================================================

-- Payment transactions
CREATE TABLE payment_transactions (
    transaction_id BIGINT PRIMARY KEY IDENTITY(1,1),
    order_id BIGINT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_provider VARCHAR(100),
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
    processing_fee DECIMAL(8,2) DEFAULT 0,
    transaction_date DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Inventory movements for stock tracking
CREATE TABLE inventory_movements (
    movement_id BIGINT PRIMARY KEY IDENTITY(1,1),
    product_id BIGINT NOT NULL,
    movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('restock', 'sale', 'adjustment', 'return')),
    quantity_change INT NOT NULL,
    previous_quantity INT NOT NULL,
    new_quantity INT NOT NULL,
    reference_id BIGINT,
    notes TEXT,
    movement_date DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================================
-- MARKETING AND PROMOTIONS
-- ============================================================================

-- Discount codes
CREATE TABLE discount_codes (
    discount_id BIGINT PRIMARY KEY IDENTITY(1,1),
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed_amount')),
    discount_value DECIMAL(10,2) NOT NULL,
    minimum_order_amount DECIMAL(10,2) DEFAULT 0,
    usage_limit INT,
    used_count INT DEFAULT 0,
    valid_from DATETIME2 NOT NULL,
    valid_until DATETIME2 NOT NULL,
    is_active BIT DEFAULT 1
);

-- Discount usage tracking
CREATE TABLE discount_usages (
    usage_id BIGINT PRIMARY KEY IDENTITY(1,1),
    discount_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (discount_id) REFERENCES discount_codes(discount_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

PRINT 'Analytics tables created successfully';
GO