-- Customer Behavior and Website Analytics
-- Queries for understanding user journey and conversion patterns

-- ============================================================================
-- WEBSITE ENGAGEMENT ANALYSIS
-- ============================================================================

-- Query 1: Session Performance by Device Type
-- Analyze user engagement across different devices
SELECT
    us.device_type,
    COUNT(*) AS total_sessions,
    COUNT(DISTINCT us.user_id) AS unique_users,
    AVG(us.session_duration_minutes) AS avg_session_duration,
    AVG(us.page_views) AS avg_pages_per_session,

    -- Conversion analysis
    COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM orders o
        WHERE o.user_id = us.user_id
        AND o.order_date BETWEEN us.session_start AND us.session_end
        AND o.order_status = 'delivered'
    ) THEN 1 END) AS converted_sessions,

    -- Conversion rate calculation
    ROUND((COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM orders o
        WHERE o.user_id = us.user_id
        AND o.order_date BETWEEN us.session_start AND us.session_end
        AND o.order_status = 'delivered'
    ) THEN 1 END) * 100.0) / COUNT(*), 2) AS conversion_rate_percent,

    -- Engagement quality metrics
    COUNT(CASE WHEN us.session_duration_minutes >= 5 AND us.page_views >= 3 THEN 1 END) AS high_engagement_sessions,
    ROUND((COUNT(CASE WHEN us.session_duration_minutes >= 5 AND us.page_views >= 3 THEN 1 END) * 100.0) / COUNT(*), 2) AS high_engagement_rate

FROM user_sessions us
WHERE us.session_start >= DATEADD(DAY, -90, GETDATE())
GROUP BY us.device_type
ORDER BY total_sessions DESC;


-- ============================================================================
-- PRODUCT BROWSING BEHAVIOR
-- ============================================================================

-- Query 2: Product Page Engagement Analysis
-- Understanding which products generate most interest
SELECT
    p.product_name,
    c.category_name,
    COUNT(pv.page_view_id) AS total_views,
    COUNT(DISTINCT pv.user_id) AS unique_viewers,
    AVG(pv.time_on_page_seconds) AS avg_time_on_page,

    -- Engagement classification
    COUNT(CASE WHEN pv.time_on_page_seconds >= 60 THEN 1 END) AS engaged_views,
    ROUND((COUNT(CASE WHEN pv.time_on_page_seconds >= 60 THEN 1 END) * 100.0) / COUNT(pv.page_view_id), 2) AS engagement_rate,

    -- Conversion to purchase
    COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM order_items oi
        INNER JOIN orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = p.product_id
        AND o.user_id = pv.user_id
        AND o.order_date >= pv.viewed_at
        AND o.order_date <= DATEADD(DAY, 7, pv.viewed_at)
        AND o.order_status = 'delivered'
    ) THEN 1 END) AS views_leading_to_purchase,

    -- View-to-purchase rate
    ROUND((COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM order_items oi
        INNER JOIN orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = p.product_id
        AND o.user_id = pv.user_id
        AND o.order_date >= pv.viewed_at
        AND o.order_date <= DATEADD(DAY, 7, pv.viewed_at)
        AND o.order_status = 'delivered'
    ) THEN 1 END) * 100.0) / COUNT(pv.page_view_id), 2) AS view_to_purchase_rate

FROM page_views pv
INNER JOIN products p ON pv.product_id = p.product_id
INNER JOIN categories c ON p.category_id = c.category_id
WHERE pv.page_type = 'product'
  AND pv.viewed_at >= DATEADD(DAY, -90, GETDATE())
GROUP BY p.product_id, p.product_name, c.category_name
HAVING COUNT(pv.page_view_id) >= 10  -- Only products with meaningful traffic
ORDER BY total_views DESC;


-- ============================================================================
-- SEARCH BEHAVIOR ANALYSIS
-- ============================================================================

-- Query 3: Search Performance and Optimization
-- Analyze search queries for product discovery insights
WITH search_performance AS (
    SELECT
        sq.search_term,
        COUNT(*) AS search_frequency,
        COUNT(DISTINCT sq.user_id) AS unique_searchers,
        AVG(sq.results_count) AS avg_results_returned,
        COUNT(CASE WHEN sq.results_count = 0 THEN 1 END) AS no_results_searches,
        COUNT(CASE WHEN sq.clicked_product_id IS NOT NULL THEN 1 END) AS searches_with_clicks,

        -- Conversion tracking
        COUNT(CASE WHEN EXISTS (
            SELECT 1 FROM orders o
            INNER JOIN order_items oi ON o.order_id = oi.order_id
            WHERE o.user_id = sq.user_id
            AND oi.product_id = sq.clicked_product_id
            AND o.order_date >= sq.search_date
            AND o.order_date <= DATEADD(DAY, 3, sq.search_date)
            AND o.order_status = 'delivered'
        ) THEN 1 END) AS searches_leading_to_purchase

    FROM search_queries sq
    WHERE sq.search_date >= DATEADD(DAY, -90, GETDATE())
    GROUP BY sq.search_term
    HAVING COUNT(*) >= 5  -- Only frequently searched terms
)

SELECT
    search_term,
    search_frequency,
    unique_searchers,
    ROUND(avg_results_returned, 0) AS avg_results,
    no_results_searches,

    -- Performance metrics
    ROUND((searches_with_clicks * 100.0) / search_frequency, 2) AS click_through_rate,
    ROUND((searches_leading_to_purchase * 100.0) / search_frequency, 2) AS search_conversion_rate,
    ROUND((no_results_searches * 100.0) / search_frequency, 2) AS no_results_rate,

    -- Search effectiveness classification
    CASE
        WHEN (no_results_searches * 100.0) / search_frequency > 30 THEN 'High No-Results'
        WHEN (searches_with_clicks * 100.0) / search_frequency < 10 THEN 'Low Click-Through'
        WHEN (searches_leading_to_purchase * 100.0) / search_frequency > 10 THEN 'High Converting'
        ELSE 'Standard Performance'
    END AS search_performance_category

FROM search_performance
ORDER BY search_frequency DESC;


-- ============================================================================
-- CUSTOMER JOURNEY ANALYSIS
-- ============================================================================

-- Query 4: User Journey Funnel Analysis
-- Track progression through the purchase funnel
WITH session_funnel AS (
    SELECT
        us.session_id,
        us.user_id,
        us.device_type,

        -- Define funnel stages
        CASE WHEN EXISTS (SELECT 1 FROM page_views pv WHERE pv.session_id = us.session_id AND pv.page_type = 'product')
             THEN 1 ELSE 0 END AS viewed_products,

        CASE WHEN EXISTS (SELECT 1 FROM page_views pv WHERE pv.session_id = us.session_id AND pv.page_type = 'cart')
             THEN 1 ELSE 0 END AS added_to_cart,

        CASE WHEN EXISTS (SELECT 1 FROM orders o
                         WHERE o.user_id = us.user_id
                         AND o.order_date BETWEEN us.session_start AND us.session_end
                         AND o.order_status IN ('delivered', 'shipped', 'processing'))
             THEN 1 ELSE 0 END AS completed_purchase

    FROM user_sessions us
    WHERE us.session_start >= DATEADD(DAY, -30, GETDATE())
)

SELECT
    device_type,
    COUNT(*) AS total_sessions,

    -- Funnel metrics
    SUM(viewed_products) AS product_views,
    SUM(added_to_cart) AS cart_additions,
    SUM(completed_purchase) AS purchases,

    -- Conversion rates at each stage
    ROUND((SUM(viewed_products) * 100.0) / COUNT(*), 2) AS session_to_product_rate,
    ROUND((SUM(added_to_cart) * 100.0) / NULLIF(SUM(viewed_products), 0), 2) AS product_to_cart_rate,
    ROUND((SUM(completed_purchase) * 100.0) / NULLIF(SUM(added_to_cart), 0), 2) AS cart_to_purchase_rate,
    ROUND((SUM(completed_purchase) * 100.0) / COUNT(*), 2) AS overall_conversion_rate

FROM session_funnel
GROUP BY device_type
ORDER BY total_sessions DESC;


-- ============================================================================
-- REPEAT VISITOR ANALYSIS
-- ============================================================================

-- Query 5: Customer Return Behavior
-- Analyze patterns of repeat website visits
WITH user_visit_patterns AS (
    SELECT
        us.user_id,
        COUNT(*) AS total_sessions,
        MIN(us.session_start) AS first_visit,
        MAX(us.session_start) AS latest_visit,
        AVG(us.session_duration_minutes) AS avg_session_duration,
        SUM(us.page_views) AS total_page_views,

        -- Calculate days between visits
        CASE
            WHEN COUNT(*) > 1
            THEN DATEDIFF(DAY, MIN(us.session_start), MAX(us.session_start)) / (COUNT(*) - 1.0)
            ELSE NULL
        END AS avg_days_between_visits

    FROM user_sessions us
    WHERE us.user_id IS NOT NULL
      AND us.session_start >= DATEADD(DAY, -90, GETDATE())
    GROUP BY us.user_id
),

user_purchase_behavior AS (
    SELECT
        uvp.user_id,
        uvp.total_sessions,
        uvp.avg_session_duration,
        uvp.avg_days_between_visits,
        COUNT(o.order_id) AS orders_count,
        SUM(o.total_amount) AS total_spent

    FROM user_visit_patterns uvp
    LEFT JOIN orders o ON uvp.user_id = o.user_id
        AND o.order_status = 'delivered'
        AND o.order_date >= DATEADD(DAY, -90, GETDATE())
    GROUP BY uvp.user_id, uvp.total_sessions, uvp.avg_session_duration, uvp.avg_days_between_visits
)

SELECT
    -- Visit frequency segmentation
    CASE
        WHEN total_sessions >= 10 THEN 'Frequent Visitor'
        WHEN total_sessions >= 5 THEN 'Regular Visitor'
        WHEN total_sessions >= 2 THEN 'Occasional Visitor'
        ELSE 'One-time Visitor'
    END AS visitor_type,

    COUNT(*) AS user_count,
    AVG(total_sessions) AS avg_sessions,
    AVG(avg_session_duration) AS avg_session_duration,
    AVG(avg_days_between_visits) AS avg_return_frequency,

    -- Purchase behavior
    AVG(orders_count) AS avg_orders_per_user,
    SUM(total_spent) AS total_revenue,
    ROUND(SUM(total_spent) / COUNT(*), 2) AS avg_revenue_per_user,

    -- Conversion metrics
    COUNT(CASE WHEN orders_count > 0 THEN 1 END) AS users_who_purchased,
    ROUND((COUNT(CASE WHEN orders_count > 0 THEN 1 END) * 100.0) / COUNT(*), 2) AS purchase_conversion_rate

FROM user_purchase_behavior
GROUP BY
    CASE
        WHEN total_sessions >= 10 THEN 'Frequent Visitor'
        WHEN total_sessions >= 5 THEN 'Regular Visitor'
        WHEN total_sessions >= 2 THEN 'Occasional Visitor'
        ELSE 'One-time Visitor'
    END
ORDER BY avg_sessions DESC;

PRINT 'Behavioral analysis queries completed';
GO