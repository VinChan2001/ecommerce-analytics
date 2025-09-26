# E-Commerce Analytics Project

## 🎯 Project Overview
A comprehensive SQL-based analytics project demonstrating data analyst skills through real-world e-commerce scenarios. This portfolio project showcases advanced SQL techniques, business intelligence thinking, and practical data analysis capabilities.

## 💡 What This Project Demonstrates

### **Core Data Analyst Skills**
- **SQL Proficiency**: Complex queries, joins, aggregations, and window functions
- **Business Intelligence**: KPI development, dashboard design, and reporting
- **Data Analysis**: Customer segmentation, trend analysis, and performance metrics
- **Problem Solving**: Translating business questions into analytical solutions

### **Technical Competencies**
- Writing complex SQL queries for business insights
- Creating automated reports and dashboards
- Performing customer behavior analysis
- Building data models for analytics
- Understanding database design principles

## 📊 Key Analysis Examples

### 1. Revenue Analysis (Entry-Level Focus)
```sql
-- Monthly revenue trends - perfect for junior analyst role
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(total_amount) AS monthly_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE order_status = 'completed'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
```

### 2. Customer Segmentation Analysis
```sql
-- RFM Analysis - demonstrates analytical thinking
WITH customer_rfm AS (
    SELECT
        user_id,
        DATEDIFF(DAY, MAX(order_date), GETDATE()) AS recency,
        COUNT(*) AS frequency,
        SUM(total_amount) AS monetary_value
    FROM orders
    WHERE order_status = 'completed'
    GROUP BY user_id
)
SELECT
    CASE
        WHEN recency <= 30 AND frequency >= 5 AND monetary_value >= 500 THEN 'VIP'
        WHEN recency <= 60 AND frequency >= 3 THEN 'Regular'
        WHEN recency <= 90 THEN 'At Risk'
        ELSE 'Inactive'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    AVG(monetary_value) AS avg_customer_value
FROM customer_rfm
GROUP BY 1;
```

### 3. Product Performance Analysis
```sql
-- Product sales analysis - typical analyst task
SELECT
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS revenue,
    AVG(oi.unit_price) AS avg_price,
    COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= DATEADD(MONTH, -3, GETDATE())
GROUP BY p.product_name, c.category_name
ORDER BY revenue DESC;
```

## 🚀 Entry-Level Skills Showcase

### **SQL Skills Demonstrated**
- ✅ **Joins**: Multiple table relationships and complex joins
- ✅ **Aggregations**: SUM, COUNT, AVG, GROUP BY
- ✅ **Window Functions**: RANK(), ROW_NUMBER(), LAG()
- ✅ **CTEs**: Complex multi-step analysis
- ✅ **Date Functions**: Time-based analysis and trends
- ✅ **Conditional Logic**: CASE statements for categorization

### **Business Analysis Skills**
- ✅ **KPI Development**: Revenue, AOV, customer metrics
- ✅ **Trend Analysis**: Month-over-month growth, seasonality
- ✅ **Customer Analytics**: Segmentation, lifetime value
- ✅ **Performance Metrics**: Product and category analysis
- ✅ **Dashboard Thinking**: View creation for reporting

### **Problem-Solving Approach**
- ✅ **Business Understanding**: E-commerce domain knowledge
- ✅ **Data Exploration**: Understanding data relationships
- ✅ **Query Optimization**: Efficient data retrieval
- ✅ **Result Interpretation**: Actionable insights

## 📈 Sample Analysis Reports

### Monthly Business Performance Report
```sql
-- Executive summary - entry analyst deliverable
SELECT
    'Revenue Growth' AS metric,
    FORMAT((current_month - previous_month) / previous_month * 100, 'N1') + '%' AS value
FROM (
    SELECT
        SUM(CASE WHEN MONTH(order_date) = MONTH(GETDATE()) THEN total_amount END) AS current_month,
        SUM(CASE WHEN MONTH(order_date) = MONTH(GETDATE())-1 THEN total_amount END) AS previous_month
    FROM orders
    WHERE YEAR(order_date) = YEAR(GETDATE())
) t;
```

### Customer Behavior Insights
```sql
-- Website engagement analysis
SELECT
    device_type,
    AVG(session_duration_minutes) AS avg_session_time,
    AVG(page_views) AS avg_pages_per_session,
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN converted_in_session = 1 THEN 1 ELSE 0 END) AS conversions,
    ROUND(SUM(CASE WHEN converted_in_session = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_sessions
WHERE session_start >= DATEADD(DAY, -30, GETDATE())
GROUP BY device_type;
```

## 🎓 Learning Outcomes

### **What I Learned Building This**
- How to design databases for analytical workloads
- Writing complex SQL queries for business insights
- Creating automated reporting processes
- Understanding e-commerce business metrics
- Building scalable data solutions

### **Skills Developed**
- **SQL Mastery**: From basic queries to advanced analytics
- **Business Intelligence**: KPI design and dashboard creation
- **Data Modeling**: Relationship design and optimization
- **Analytical Thinking**: Problem decomposition and solution design
- **Documentation**: Clear communication of technical work

## 🏗️ Project Structure

```
📁 E-Commerce Analytics Project
├── 📄 Database Setup
│   ├── database_setup.sql          # Database initialization
│   └── schema/                     # Table definitions
│       ├── core_tables.sql         # Business entities
│       └── analytics_tables.sql    # Tracking tables
├── 📊 Sample Data
│   └── data/
│       └── sample_data.sql         # Realistic test dataset
└── 📈 Analysis Queries
    ├── business_metrics.sql        # Revenue and performance analysis
    ├── customer_analytics.sql      # Customer segmentation and RFM
    └── behavioral_analysis.sql     # Website engagement and conversion
```

## 💼 Interview Talking Points

### **For Entry-Level Positions**
- "I built this to learn SQL and understand how data drives business decisions"
- "Each query solves a real business problem I researched"
- "I focused on metrics that entry-level analysts typically work with"
- "The project helped me understand the full analytics workflow"

### **Technical Discussion Points**
- "I can walk you through how I calculated customer lifetime value"
- "Here's how I optimized this query for better performance"
- "I learned to validate my analysis results for accuracy"
- "This taught me to think about data quality and edge cases"

## 🎯 Entry-Level Role Alignment

### **Perfect for these positions:**
- **Junior Data Analyst** - SQL skills and business metrics
- **Business Intelligence Analyst** - Dashboard and reporting focus
- **Marketing Analyst** - Customer segmentation and behavior
- **E-commerce Analyst** - Domain-specific knowledge
- **Financial Analyst** - Revenue and performance analysis

### **Key Strengths for Entry-Level**
- **Self-Directed Learning**: Shows initiative and motivation
- **Practical Application**: Real business scenarios, not academic exercises
- **Comprehensive Scope**: End-to-end analytical thinking
- **Clear Documentation**: Professional communication skills
- **Growth Mindset**: Demonstrates continuous learning approach

## 🚀 Quick Start

### **Setup Instructions**
1. **Create Database**: Run `database_setup.sql`
2. **Create Schema**: Execute files in `schema/` folder
3. **Load Data**: Run `data/sample_data.sql`
4. **Run Analysis**: Execute queries from `analysis/` folder

### **Sample Analysis**
```sql
-- Monthly revenue trends
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE order_status = 'delivered'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year DESC, month DESC;

-- Customer segmentation
SELECT
    CASE
        WHEN total_spent >= 1000 THEN 'High Value'
        WHEN total_spent >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS segment,
    COUNT(*) AS customers
FROM (
    SELECT user_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY user_id
) customer_totals
GROUP BY segment;
```

## 📚 What This Shows Employers

### **Technical Competency**
- Can write complex SQL queries independently
- Understands database relationships and design
- Knows how to optimize queries for performance
- Comfortable with data analysis workflows

### **Business Acumen**
- Understands key e-commerce metrics
- Can translate business questions into analysis
- Thinks about data quality and accuracy
- Focuses on actionable insights

### **Professional Skills**
- Self-directed learning ability
- Clear documentation and communication
- Project organization and structure
- Initiative to build comprehensive solutions

---

**Perfect for Entry-Level Data Analyst Applications!**

This project strikes the ideal balance: sophisticated enough to impress, but presented as a learning journey that's perfect for someone starting their data analytics career.