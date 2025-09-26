-- E-Commerce Analytics Platform - Core Database Schema
-- Core business entities for multi-vendor e-commerce analytics

-- ============================================================================
-- BUSINESS ENTITIES
-- ============================================================================

-- Users: Customers and vendors
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY IDENTITY(1,1),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    user_type VARCHAR(20) DEFAULT 'customer' CHECK (user_type IN ('customer', 'vendor')),
    registration_date DATETIME2 DEFAULT GETDATE(),
    last_login DATETIME2,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- Product categories
CREATE TABLE categories (
    category_id BIGINT PRIMARY KEY IDENTITY(1,1),
    parent_category_id BIGINT NULL,
    category_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Vendors/sellers
CREATE TABLE vendors (
    vendor_id BIGINT PRIMARY KEY IDENTITY(1,1),
    user_id BIGINT NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    commission_rate DECIMAL(5,4) DEFAULT 0.15,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_sales DECIMAL(15,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'suspended')),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Products
CREATE TABLE products (
    product_id BIGINT PRIMARY KEY IDENTITY(1,1),
    vendor_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    base_price DECIMAL(10,2) NOT NULL,
    sale_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    stock_quantity INT DEFAULT 0,
    min_stock_level INT DEFAULT 10,
    max_stock_level INT DEFAULT 1000,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'discontinued')),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Orders
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY IDENTITY(1,1),
    user_id BIGINT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    subtotal DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_cost DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    order_date DATETIME2 DEFAULT GETDATE(),
    shipped_date DATETIME2,
    delivered_date DATETIME2,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Order items
CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY IDENTITY(1,1),
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    commission_amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
);

PRINT 'Core business tables created successfully';
GO