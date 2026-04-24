SELECT @@SERVERNAME;

SELECT TOP 10 * 
FROM customer_data;

--Q1 Revenue by Gender (with % contribution)
-- Revenue contribution by gender with percentage
SELECT 
    gender,
    SUM(purchase_amount) AS total_revenue,
    ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 2) AS revenue_percentage
FROM customer_data
GROUP BY gender
ORDER BY total_revenue DESC;


--Q2  High Value Discount Customers
-- Customers who used discount but spent above average
SELECT 
    customer_id,
    purchase_amount,
    discount_applied
FROM customer_data
WHERE discount_applied = 'Yes'
  AND purchase_amount > (
        SELECT AVG(purchase_amount) 
        FROM customer_data
    )
ORDER BY purchase_amount DESC;


--Q3 Top Rated Products
-- Top 5 products by average rating
SELECT TOP 5
    item_purchased,
    ROUND(AVG(CAST(review_rating AS FLOAT)), 2) AS avg_product_rating,
    COUNT(*) AS total_reviews
FROM customer_data
GROUP BY item_purchased
ORDER BY avg_product_rating DESC;


--Q4  Shipping Comparison
-- Compare purchase behavior by shipping type
SELECT 
    shipping_type,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer_data
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type
ORDER BY avg_purchase DESC;


--Q5 Subscriber vs Non-Subscriber
-- Customer spending behavior by subscription status
SELECT 
    subscription_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    SUM(purchase_amount) AS total_revenue
FROM customer_data
GROUP BY subscription_status
ORDER BY total_revenue DESC;


--Q6 Discount Effectiveness
-- Products with highest discount usage rate
SELECT TOP 5
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_usage_percentage,
    COUNT(*) AS total_orders
FROM customer_data
GROUP BY item_purchased
ORDER BY discount_usage_percentage DESC;


--Q7  Customer Segmentation
-- Customer segmentation based on purchase behavior
WITH customer_segments AS (
    SELECT 
        customer_id,
        previous_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 5 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_data
)

SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;


--Q8 Top Products per Category
-- Top 3 products in each category
WITH ranked_products AS (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM customer_data
    GROUP BY category, item_purchased
)

SELECT 
    category,
    item_purchased,
    total_orders
FROM ranked_products
WHERE rank <= 3
ORDER BY category, total_orders DESC;


--Q9 Repeat Buyers vs Subscription
-- Subscription behavior of repeat buyers
SELECT 
    subscription_status,
    COUNT(*) AS repeat_buyers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM customer_data
WHERE previous_purchases > 5
GROUP BY subscription_status
ORDER BY repeat_buyers DESC;


--Q10 Revenue by Age Group
-- Revenue contribution by age group
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue,
    ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 2) AS contribution_percentage
FROM customer_data
GROUP BY age_group
ORDER BY total_revenue DESC;