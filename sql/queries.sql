-- sql/queries.sql
-- Example analytical queries for the e‑commerce analytics project.
-- Run against the SQLite database (ecommerce.db) after loading data.

-- 1. Total Sales (gross revenue) and Net Sales (after discount)
SELECT
    SUM(quantity * unit_price) AS total_gross_sales,
    SUM(quantity * unit_price * (1 - discount)) AS total_net_sales
FROM fact_order
WHERE order_status = 'Completed';

-- 2. Gross Profit (sales minus cost of goods sold)
SELECT
    SUM(quantity * unit_price * (1 - discount)) -
    SUM(quantity * p.unit_cost) AS gross_profit
FROM fact_order o
JOIN dim_product p USING (product_id)
WHERE o.order_status = 'Completed';

-- 3. Monthly Sales Trend (net sales by month)
SELECT
    strftime('%Y-%m', order_date) AS month,
    SUM(quantity * unit_price * (1 - discount)) AS net_sales
FROM fact_order
WHERE order_status = 'Completed'
GROUP BY month
ORDER BY month;

-- 4. Top 10 Products by Net Sales
SELECT
    p.product_id,
    p.product_name,
    SUM(o.quantity * o.unit_price * (1 - o.discount)) AS net_sales,
    SUM(o.quantity) AS units_sold
FROM fact_order o
JOIN dim_product p ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY net_sales DESC
LIMIT 10;

-- 5. Return Rate per Product (units returned / units sold)
WITH sold AS (
    SELECT product_id, SUM(quantity) AS units_sold
    FROM fact_order
    WHERE order_status = 'Completed'
    GROUP BY product_id
),
returned AS (
    SELECT product_id, SUM(return_quantity) AS units_returned
    FROM fact_return
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    COALESCE(r.units_returned, 0) * 1.0 / s.units_sold AS return_rate
FROM sold s
JOIN dim_product p ON s.product_id = p.product_id
LEFT JOIN returned r ON s.product_id = r.product_id
ORDER BY return_rate DESC
LIMIT 20;

-- 6. Inventory Risk: Products where stock on hand <= reorder level
SELECT
    i.product_id,
    p.product_name,
    i.warehouse_id,
    i.stock_on_hand,
    i.reorder_level,
    CASE WHEN i.stock_on_hand <= i.reorder_level THEN 'Low Stock'
         WHEN i.stock_on_hand = 0 THEN 'Out of Stock'
         ELSE 'In Stock' END AS stock_status
FROM fact_inventory i
JOIN dim_product p USING (product_id)
WHERE i.stock_on_hand <= i.reorder_level;

-- 7. Sales by Channel (net sales)
SELECT
    sales_channel,
    SUM(quantity * unit_price * (1 - discount)) AS net_sales,
    COUNT(DISTINCT order_id) AS orders_count
FROM fact_order
WHERE order_status = 'Completed'
GROUP BY sales_channel
ORDER BY net_sales DESC;

-- 8. Discount vs Gross Profit (average discount per product)
SELECT
    p.category,
    AVG(o.discount) AS avg_discount,
    SUM(o.quantity * o.unit_price * (1 - o.discount)) - SUM(o.quantity * p.unit_cost) AS gross_profit
FROM fact_order o
JOIN dim_product p USING (product_id)
WHERE o.order_status = 'Completed'
GROUP BY p.category;

-- 9. Year‑over‑Year Sales Growth (using window function)
WITH monthly AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(quantity * unit_price * (1 - discount)) AS net_sales
    FROM fact_order
    WHERE order_status = 'Completed'
    GROUP BY month
)
SELECT
    month,
    net_sales,
    LAG(net_sales, 12) OVER (ORDER BY month) AS net_sales_last_year,
    (net_sales - LAG(net_sales, 12) OVER (ORDER BY month)) * 100.0 / LAG(net_sales, 12) OVER (ORDER BY month) AS yoy_growth_percent
FROM monthly
ORDER BY month;
