-- Customer Analytics Queries
-- Advanced customer analysis for business intelligence

-- ============================================================================
-- CUSTOMER SEGMENTATION (RFM ANALYSIS)
-- ============================================================================

-- Query 1: Customer RFM Segmentation
-- Segment customers by Recency, Frequency, and Monetary value
WITH customer_metrics AS (
    SELECT
        u.user_id,
        u.first_name + ' ' + u.last_name AS customer_name,
        u.email,
        u.registration_date,

        -- Recency: Days since last purchase
        DATEDIFF(DAY, MAX(o.order_date), GETDATE()) AS days_since_last_order,

        -- Frequency: Number of orders
        COUNT(o.order_id) AS total_orders,

        -- Monetary: Total amount spent
        SUM(o.total_amount) AS total_spent,

        -- Additional metrics
        AVG(o.total_amount) AS avg_order_value,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date

    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
        AND o.order_status = 'delivered'
        AND o.payment_status = 'paid'
    WHERE u.user_type = 'customer'
    GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.registration_date
    HAVING COUNT(o.order_id) > 0
),

rfm_scores AS (
    SELECT *,
        -- RFM Scoring (1-5 scale)
        CASE
            WHEN days_since_last_order <= 30 THEN 5
            WHEN days_since_last_order <= 60 THEN 4
            WHEN days_since_last_order <= 120 THEN 3
            WHEN days_since_last_order <= 365 THEN 2
            ELSE 1
        END AS recency_score,

        CASE
            WHEN total_orders >= 10 THEN 5
            WHEN total_orders >= 5 THEN 4
            WHEN total_orders >= 3 THEN 3
            WHEN total_orders >= 2 THEN 2
            ELSE 1
        END AS frequency_score,

        NTILE(5) OVER (ORDER BY total_spent) AS monetary_score

    FROM customer_metrics
)

SELECT
    customer_name,
    email,
    total_orders,
    FORMAT(total_spent, 'C') AS lifetime_value,
    FORMAT(avg_order_value, 'C') AS avg_order_value,
    days_since_last_order,

    -- RFM Segment Classification
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'VIP Champions'
        WHEN recency_score >= 4 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'New Big Spenders'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Potential Loyalists'
        WHEN recency_score >= 4 AND frequency_score <= 1 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 4 THEN 'Cannot Lose Them'
        WHEN recency_score <= 2 AND frequency_score >= 2 THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment,

    -- Status indicators
    CASE
        WHEN days_since_last_order <= 30 THEN 'Active'
        WHEN days_since_last_order <= 90 THEN 'At Risk'
        ELSE 'Inactive'
    END AS engagement_status

FROM rfm_scores
ORDER BY total_spent DESC;


-- ============================================================================
-- CUSTOMER LIFETIME VALUE ANALYSIS
-- ============================================================================

-- Query 2: Customer Lifetime Value and Retention
WITH customer_behavior AS (
    SELECT
        u.user_id,
        u.first_name + ' ' + u.last_name AS customer_name,
        u.registration_date,
        DATEDIFF(DAY, u.registration_date, GETDATE()) AS customer_age_days,

        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS lifetime_value,
        AVG(o.total_amount) AS avg_order_value,
        MIN(o.order_date) AS first_purchase_date,
        MAX(o.order_date) AS last_purchase_date,

        -- Purchase frequency calculation
        CASE
            WHEN COUNT(o.order_id) > 1
            THEN DATEDIFF(DAY, MIN(o.order_date), MAX(o.order_date)) / (COUNT(o.order_id) - 1.0)
            ELSE NULL
        END AS avg_days_between_orders

    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
        AND o.order_status = 'delivered'
        AND o.payment_status = 'paid'
    WHERE u.user_type = 'customer'
    GROUP BY u.user_id, u.first_name, u.last_name, u.registration_date
    HAVING COUNT(o.order_id) > 0
)

SELECT
    customer_name,
    total_orders,
    FORMAT(lifetime_value, 'C') AS ltv,
    FORMAT(avg_order_value, 'C') AS aov,
    customer_age_days,
    avg_days_between_orders,

    -- Customer value tier
    CASE
        WHEN lifetime_value >= 2000 THEN 'Platinum'
        WHEN lifetime_value >= 1000 THEN 'Gold'
        WHEN lifetime_value >= 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS value_tier,

    -- Purchase behavior classification
    CASE
        WHEN total_orders >= 10 THEN 'Frequent Buyer'
        WHEN total_orders >= 5 THEN 'Regular Buyer'
        WHEN total_orders >= 2 THEN 'Occasional Buyer'
        ELSE 'One-time Buyer'
    END AS purchase_behavior,

    -- Projected CLV (simple estimation)
    CASE
        WHEN avg_days_between_orders IS NOT NULL AND avg_days_between_orders > 0
        THEN ROUND(avg_order_value * (365.0 / avg_days_between_orders), 2)
        ELSE lifetime_value
    END AS projected_annual_value

FROM customer_behavior
ORDER BY lifetime_value DESC;


-- ============================================================================
-- CUSTOMER COHORT ANALYSIS
-- ============================================================================

-- Query 3: Simple Cohort Analysis
-- Track customer retention by registration month
WITH customer_cohorts AS (
    SELECT
        u.user_id,
        FORMAT(u.registration_date, 'yyyy-MM') AS cohort_month,
        MIN(o.order_date) AS first_purchase_date,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
        AND o.order_status = 'delivered'
        AND o.payment_status = 'paid'
    WHERE u.user_type = 'customer'
      AND u.registration_date >= '2023-01-01'
    GROUP BY u.user_id, u.registration_date
),

cohort_summary AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size,
        COUNT(DISTINCT CASE WHEN first_purchase_date IS NOT NULL THEN user_id END) AS customers_purchased,
        SUM(total_orders) AS total_cohort_orders,
        SUM(total_spent) AS total_cohort_revenue
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    cohort_month,
    cohort_size,
    customers_purchased,
    total_cohort_orders,
    FORMAT(total_cohort_revenue, 'C') AS cohort_revenue,

    -- Conversion and engagement rates
    ROUND((customers_purchased * 100.0) / cohort_size, 2) AS conversion_rate_percent,
    ROUND(total_cohort_orders / CAST(customers_purchased AS DECIMAL), 2) AS avg_orders_per_buyer,
    FORMAT(total_cohort_revenue / customers_purchased, 'C') AS avg_revenue_per_buyer,

    -- Cohort performance assessment
    CASE
        WHEN (customers_purchased * 100.0) / cohort_size >= 25 THEN 'High Performing'
        WHEN (customers_purchased * 100.0) / cohort_size >= 15 THEN 'Good'
        WHEN (customers_purchased * 100.0) / cohort_size >= 10 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS cohort_performance

FROM cohort_summary
WHERE cohort_size >= 5  -- Only meaningful cohort sizes
ORDER BY cohort_month DESC;


-- ============================================================================
-- CUSTOMER BEHAVIOR PATTERNS
-- ============================================================================

-- Query 4: Purchase Patterns and Seasonality
SELECT
    DATENAME(MONTH, o.order_date) AS month_name,
    MONTH(o.order_date) AS month_number,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(o.total_amount) AS monthly_revenue,
    AVG(o.total_amount) AS avg_order_value,

    -- Customer behavior metrics
    ROUND(COUNT(DISTINCT o.order_id) / CAST(COUNT(DISTINCT o.user_id) AS DECIMAL), 2) AS orders_per_customer,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT o.user_id), 2) AS revenue_per_customer,

    -- Seasonal performance
    CASE
        WHEN MONTH(o.order_date) IN (11, 12) THEN 'Holiday Season'
        WHEN MONTH(o.order_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(o.order_date) IN (3, 4, 5) THEN 'Spring'
        ELSE 'Regular Period'
    END AS season

FROM orders o
WHERE o.order_status = 'delivered'
  AND o.payment_status = 'paid'
  AND o.order_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY MONTH(o.order_date), DATENAME(MONTH, o.order_date)
ORDER BY month_number;


-- Query 5: Top Customers Analysis
-- Identify and analyze highest value customers
SELECT TOP 20
    u.first_name + ' ' + u.last_name AS customer_name,
    u.email,
    u.registration_date,
    DATEDIFF(DAY, u.registration_date, GETDATE()) AS customer_age_days,

    COUNT(o.order_id) AS total_orders,
    FORMAT(SUM(o.total_amount), 'C') AS lifetime_value,
    FORMAT(AVG(o.total_amount), 'C') AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(DAY, MAX(o.order_date), GETDATE()) AS days_since_last_order,

    -- Value classification
    CASE
        WHEN SUM(o.total_amount) >= 2000 THEN 'VIP'
        WHEN SUM(o.total_amount) >= 1000 THEN 'Premium'
        WHEN SUM(o.total_amount) >= 500 THEN 'Valued'
        ELSE 'Standard'
    END AS customer_tier,

    -- Engagement status
    CASE
        WHEN DATEDIFF(DAY, MAX(o.order_date), GETDATE()) <= 30 THEN 'Active'
        WHEN DATEDIFF(DAY, MAX(o.order_date), GETDATE()) <= 90 THEN 'At Risk'
        ELSE 'Inactive'
    END AS engagement_status

FROM users u
INNER JOIN orders o ON u.user_id = o.user_id
WHERE u.user_type = 'customer'
  AND o.order_status = 'delivered'
  AND o.payment_status = 'paid'
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.registration_date
ORDER BY SUM(o.total_amount) DESC;

PRINT 'Customer analytics queries completed';
GO