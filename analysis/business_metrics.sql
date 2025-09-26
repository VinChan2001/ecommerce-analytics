-- Business Performance Analysis Queries
-- Revenue analysis and key performance indicators for e-commerce platforms

-- ============================================================================
-- REVENUE ANALYSIS
-- ============================================================================

-- Query 1: Monthly Revenue Trends
-- Shows growth patterns and business performance over time
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DATENAME(MONTH, order_date) AS month_name,

    -- Core metrics
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(total_amount) AS monthly_revenue,
    AVG(total_amount) AS avg_order_value,

    -- Growth analysis
    LAG(SUM(total_amount)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS prev_month_revenue,
    CASE
        WHEN LAG(SUM(total_amount)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) IS NOT NULL
        THEN ROUND(((SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)))
                   / LAG(SUM(total_amount)) OVER (ORDER BY YEAR(order_date), MONTH(order_date))) * 100, 2)
        ELSE NULL
    END AS growth_percent

FROM orders
WHERE order_status = 'delivered'
  AND payment_status = 'paid'
  AND order_date >= DATEADD(MONTH, -12, GETDATE())
GROUP BY YEAR(order_date), MONTH(order_date), DATENAME(MONTH, order_date)
ORDER BY year DESC, month DESC;


-- Query 2: Product Performance Analysis
-- Identify top-performing products and categories
SELECT
    p.product_name,
    p.sku,
    c.category_name,
    v.business_name AS vendor,

    -- Sales metrics
    COUNT(DISTINCT oi.order_id) AS orders_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.unit_price) AS avg_selling_price,

    -- Performance ranking
    RANK() OVER (ORDER BY SUM(oi.total_price) DESC) AS revenue_rank,

    -- Profitability (if cost data available)
    CASE
        WHEN p.cost_price > 0
        THEN ROUND(((AVG(oi.unit_price) - p.cost_price) / p.cost_price) * 100, 2)
        ELSE NULL
    END AS profit_margin_percent,

    -- Stock status
    p.stock_quantity,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity <= p.min_stock_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status

FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN categories c ON p.category_id = c.category_id
INNER JOIN vendors v ON p.vendor_id = v.vendor_id

WHERE o.order_status = 'delivered'
  AND o.payment_status = 'paid'
  AND o.order_date >= DATEADD(MONTH, -6, GETDATE())

GROUP BY p.product_id, p.product_name, p.sku, c.category_name, v.business_name,
         p.cost_price, p.stock_quantity, p.min_stock_level
ORDER BY total_revenue DESC;


-- Query 3: Category Performance Comparison
-- Compare sales performance across product categories
WITH category_metrics AS (
    SELECT
        c.category_name,
        SUM(oi.total_price) AS category_revenue,
        SUM(oi.quantity) AS units_sold,
        COUNT(DISTINCT oi.order_id) AS orders,
        COUNT(DISTINCT o.user_id) AS unique_customers,
        AVG(oi.unit_price) AS avg_price
    FROM categories c
    INNER JOIN products p ON c.category_id = p.category_id
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.payment_status = 'paid'
      AND o.order_date >= DATEADD(MONTH, -3, GETDATE())
    GROUP BY c.category_id, c.category_name
),
total_revenue AS (
    SELECT SUM(category_revenue) AS total_marketplace_revenue
    FROM category_metrics
)
SELECT
    cm.category_name,
    FORMAT(cm.category_revenue, 'C') AS revenue,
    cm.units_sold,
    cm.orders,
    cm.unique_customers,
    FORMAT(cm.avg_price, 'C') AS avg_price,
    ROUND((cm.category_revenue / tr.total_marketplace_revenue) * 100, 2) AS market_share_percent,
    RANK() OVER (ORDER BY cm.category_revenue DESC) AS revenue_rank
FROM category_metrics cm
CROSS JOIN total_revenue tr
ORDER BY cm.category_revenue DESC;

PRINT 'Business metrics analysis queries completed';
GO