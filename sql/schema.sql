-- sql/schema.sql
-- SQLite schema for the e‑commerce analytics project

-- 1. Products dimension
CREATE TABLE IF NOT EXISTS dim_product (
    product_id TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    subcategory TEXT NOT NULL,
    supplier TEXT NOT NULL,
    unit_cost REAL NOT NULL,
    selling_price REAL NOT NULL
);

-- 2. Customers dimension
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id TEXT PRIMARY KEY,
    customer_segment TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    registration_date DATE NOT NULL
);

-- 3. Warehouse dimension (static list)
CREATE TABLE IF NOT EXISTS dim_warehouse (
    warehouse_id TEXT PRIMARY KEY
);

-- 4. Calendar dimension (generated later via script or view)
-- For brevity we will rely on a simple date table constructed in queries.

-- 5. Fact table: Orders (one row per order line)
CREATE TABLE IF NOT EXISTS fact_order (
    order_id TEXT NOT NULL,
    order_date DATE NOT NULL,
    customer_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    discount REAL NOT NULL,               -- stored as fraction (e.g., 0.10 for 10%)
    sales_channel TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    order_status TEXT NOT NULL,
    PRIMARY KEY (order_id, product_id),   -- composite key for order line
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- 6. Fact table: Inventory (snapshot per warehouse)
CREATE TABLE IF NOT EXISTS fact_inventory (
    product_id TEXT NOT NULL,
    warehouse_id TEXT NOT NULL,
    stock_on_hand INTEGER NOT NULL,
    reorder_level INTEGER NOT NULL,
    reorder_quantity INTEGER NOT NULL,
    last_restock_date DATE NOT NULL,
    PRIMARY KEY (product_id, warehouse_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES dim_warehouse(warehouse_id)
);

-- 7. Fact table: Returns (one row per return line)
CREATE TABLE IF NOT EXISTS fact_return (
    return_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    return_date DATE NOT NULL,
    return_quantity INTEGER NOT NULL,
    return_reason TEXT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES fact_order(order_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- Populate static warehouse dimension
INSERT OR IGNORE INTO dim_warehouse (warehouse_id) VALUES
    ('WH-North'), ('WH-South'), ('WH-East'), ('WH-West');
