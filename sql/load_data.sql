-- sql/load_data.sql
-- Load CSV files into the SQLite database created by schema.sql
-- Assumes the SQLite database file is named ecommerce.db and resides in the project root.

.mode csv
.separator ","

-- Load dimension tables
.import data/products.csv dim_product
.import data/customers.csv dim_customer

-- Load warehouse dimension (already populated in schema, no import needed)

-- Load fact tables
.import data/orders.csv fact_order
.import data/inventory.csv fact_inventory
.import data/returns.csv fact_return

-- Create indexes for faster analytical queries
CREATE INDEX IF NOT EXISTS idx_fact_order_date ON fact_order(order_date);
CREATE INDEX IF NOT EXISTS idx_fact_order_customer ON fact_order(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_order_product ON fact_order(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_inventory_product ON fact_inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_return_product ON fact_return(product_id);
