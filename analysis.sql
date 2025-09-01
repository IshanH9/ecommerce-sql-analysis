-- Total users, products, orders, successful payments
SELECT 
  (SELECT COUNT(*) FROM Users)        AS users_cnt,
  (SELECT COUNT(*) FROM Products)     AS products_cnt,
  (SELECT COUNT(*) FROM Orders)       AS orders_cnt,
  (SELECT COUNT(*) FROM Payments WHERE status = 'Success') AS successful_payments_cnt;

-- 1) Average Order Value (AOV)
SELECT 
  ROUND(AVG(p.amount)::numeric, 2) AS aov_overall
FROM Payments p
WHERE p.status = 'Success';

SELECT 
  DATE_TRUNC('month', o.order_date) AS month,
  ROUND(AVG(p.amount)::numeric, 2) AS aov_overall FROM Orders o
JOIN Payments p ON p.order_id = o.order_id
WHERE p.status = 'Success'
GROUP BY 1
ORDER BY 1;

-- 2) Repeat Customer Rate
WITH successful_orders AS (
  SELECT o.user_id, o.order_id
  FROM Orders o
  JOIN Payments p ON p.order_id = o.order_id
  WHERE p.status = 'Success'
),
agg AS (
  SELECT user_id, COUNT(DISTINCT order_id) AS successful_order_cnt
  FROM successful_orders
  GROUP BY user_id
)

SELECT
  COUNT(*) FILTER (WHERE successful_order_cnt >= 2)::decimal
  / NULLIF(COUNT(*), 0) AS repeat_customer_rate
FROM agg;

--list repeat customers with counts
SELECT u.user_id, u.name, COUNT(DISTINCT o.order_id) AS successful_orders
FROM Users u
JOIN Orders o ON o.user_id = u.user_id
JOIN Payments p ON p.order_id = o.order_id AND p.status = 'Success'
GROUP BY u.user_id, u.name
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY successful_orders DESC, u.name;

-- 3) Category-Level Gross Margin
WITH category_cost_pct AS (
  SELECT * FROM (VALUES
    ('Electronics',     0.78::numeric),
    ('Home & Kitchen',  0.65::numeric),
    ('Accessories',     0.60::numeric),
    ('Sports',          0.55::numeric),
    ('Fashion',         0.50::numeric)
  ) AS t(category, cost_pct)
),
successful_orders AS (
  SELECT o.order_id, o.order_date
  FROM Orders o
  JOIN Payments p ON p.order_id = o.order_id
  WHERE p.status = 'Success'
),
line_revenue AS (
  SELECT 
    oi.order_id,
    p.category,
    (oi.quantity * oi.unit_price)::numeric AS line_sales
  FROM Order_Items oi
  JOIN Products p ON p.product_id = oi.product_id
  JOIN successful_orders so ON so.order_id = oi.order_id
),
category_rollup AS (
  SELECT 
    lr.category,
    SUM(lr.line_sales) AS sales
  FROM line_revenue lr
  GROUP BY lr.category
)
SELECT 
  c.category,
  cr.sales,
  ROUND(cr.sales * (1 - ccp.cost_pct), 2) AS gross_margin,
  ROUND( (1 - ccp.cost_pct) * 100, 1)     AS gross_margin_pct_assumed
FROM category_rollup cr
JOIN category_cost_pct ccp ON ccp.category = cr.category
JOIN (SELECT DISTINCT category FROM Products) c ON c.category = cr.category
ORDER BY gross_margin DESC

WITH category_cost_pct AS (
  SELECT * FROM (VALUES
    ('Electronics',     0.78::numeric),
    ('Home & Kitchen',  0.65::numeric),
    ('Accessories',     0.60::numeric),
    ('Sports',          0.55::numeric),
    ('Fashion',         0.50::numeric)
  ) AS t(category, cost_pct)
),
successful_orders AS (
  SELECT o.order_id, o.order_date
  FROM Orders o
  JOIN Payments p ON p.order_id = o.order_id
  WHERE p.status = 'Success'
),
line_revenue AS (
  SELECT 
    DATE_TRUNC('month', so.order_date) AS month,
    pr.category,
    (oi.quantity * oi.unit_price)::numeric AS line_sales
  FROM Order_Items oi
  JOIN Products pr ON pr.product_id = oi.product_id
  JOIN successful_orders so ON so.order_id = oi.order_id
)
SELECT 
  month,
  category,
  SUM(line_sales)                                         AS sales,
  ROUND(SUM(line_sales) * (1 - ccp.cost_pct), 2)          AS gross_margin,
  ROUND((1 - ccp.cost_pct) * 100, 1)                      AS gross_margin_pct_assumed
FROM line_revenue
JOIN category_cost_pct ccp USING (category)
GROUP BY month, category, ccp.cost_pct
ORDER BY month, category;

-- 4) Refund Rate by Month
WITH payments_by_month AS (
  SELECT 
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(CASE WHEN p.status = 'Refunded' THEN 1 ELSE 0 END) AS refunded_cnt,
    COUNT(*) AS all_payments_cnt
  FROM Orders o
  JOIN Payments p ON p.order_id = o.order_id
  GROUP BY 1
)
SELECT
  month,
  refunded_cnt,
  all_payments_cnt,
  ROUND(refunded_cnt::numeric / NULLIF(all_payments_cnt, 0), 4) AS refund_rate
FROM payments_by_month
ORDER BY month;

-- 5) Product Cross-Sell Pairs (Market Basket)
WITH successful_orders AS (
  SELECT DISTINCT o.order_id
  FROM Orders o
  JOIN Payments p ON p.order_id = o.order_id
  WHERE p.status = 'Success'
),
pairs AS (
  SELECT 
    LEAST(oi1.product_id, oi2.product_id) AS product_a,
    GREATEST(oi1.product_id, oi2.product_id) AS product_b,
    oi1.order_id
  FROM Order_Items oi1
  JOIN Order_Items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id  -- avoid duplicates & self-pairs
  JOIN successful_orders so ON so.order_id = oi1.order_id
)
SELECT 
  p1.name AS product_a,
  p2.name AS product_b,
  COUNT(DISTINCT pairs.order_id) AS pair_orders,
  ROUND(
    COUNT(DISTINCT pairs.order_id)::numeric 
    / NULLIF( (SELECT COUNT(*) FROM successful_orders), 0), 4
  ) AS support
FROM pairs
JOIN Products p1 ON p1.product_id = pairs.product_a
JOIN Products p2 ON p2.product_id = pairs.product_b
GROUP BY p1.name, p2.name
ORDER BY pair_orders DESC, product_a, product_b
LIMIT 20;

-- 6) Extra: Customer LTV (to-date) using successful payments
SELECT 
  u.user_id,
  u.name,
  ROUND(SUM(p.amount)::numeric, 2) AS ltv
FROM Users u
JOIN Orders o ON o.user_id = u.user_id
JOIN Payments p ON p.order_id = o.order_id
WHERE p.status = 'Success'
GROUP BY u.user_id, u.name
ORDER BY ltv DESC, u.name;

-- 7) Extra: Ratings summary per product
SELECT 
  pr.product_id,
  pr.name,
  COUNT(r.rating) AS reviews,
  ROUND(AVG(r.rating)::numeric, 2) AS avg_rating
FROM Products pr
LEFT JOIN Reviews r ON r.product_id = pr.product_id
GROUP BY pr.product_id, pr.name
ORDER BY avg_rating DESC NULLS LAST, reviews DESC, pr.name;

