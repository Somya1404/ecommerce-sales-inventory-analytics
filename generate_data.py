# generate_data.py
"""Generate synthetic e‑commerce CSV datasets.
The script creates five linked CSV files in the `data/` folder:
- orders.csv
- products.csv
- customers.csv
- inventory.csv
- returns.csv
"""

import os
import random
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
from faker import Faker

fake = Faker()

# ----- Configuration -----
NUM_PRODUCTS = 200
NUM_CUSTOMERS = 500
NUM_ORDERS = 5000  # order‑lines (not distinct orders)
START_DATE = datetime(2022, 1, 1)
END_DATE = datetime(2024, 12, 31)

# Helper functions
def random_date(start, end):
    return start + timedelta(seconds=random.randint(0, int((end - start).total_seconds())))

# 1. Products
product_ids = [f"P{str(i).zfill(4)}" for i in range(1, NUM_PRODUCTS + 1)]
categories = ["Electronics", "Clothing", "Home & Kitchen", "Sports", "Books"]
subcategories = {
    "Electronics": ["Phones", "Computers", "Accessories"],
    "Clothing": ["Men", "Women", "Kids"],
    "Home & Kitchen": ["Appliances", "Furniture", "Decor"],
    "Sports": ["Outdoor", "Gym", "Team Sports"],
    "Books": ["Fiction", "Non‑Fiction", "Children"]
}
products = []
for pid in product_ids:
    cat = random.choice(categories)
    sub = random.choice(subcategories[cat])
    supplier = fake.company()
    unit_cost = round(random.uniform(5, 200), 2)
    selling_price = round(unit_cost * random.uniform(1.2, 2.5), 2)
    products.append({
        "Product ID": pid,
        "Product Name": f"{cat} {sub} {fake.word().title()}",
        "Category": cat,
        "Subcategory": sub,
        "Supplier": supplier,
        "Unit Cost": unit_cost,
        "Selling Price": selling_price,
    })
products_df = pd.DataFrame(products)

# 2. Customers
customer_ids = [f"C{str(i).zfill(5)}" for i in range(1, NUM_CUSTOMERS + 1)]
segments = ["Consumer", "Corporate", "Home Office", "Small Business"]
customers = []
for cid in customer_ids:
    seg = random.choice(segments)
    city = fake.city()
    state = fake.state_abbr()
    reg_date = random_date(START_DATE - timedelta(days=365), START_DATE)
    customers.append({
        "Customer ID": cid,
        "Customer Segment": seg,
        "City": city,
        "State": state,
        "Customer Registration Date": reg_date.date().isoformat(),
    })
customers_df = pd.DataFrame(customers)

# 3. Inventory (one row per product per warehouse)
warehouses = ["WH‑North", "WH‑South", "WH‑East", "WH‑West"]
inventory = []
for pid in product_ids:
    for wh in warehouses:
        stock = random.randint(0, 500)
        reorder_level = random.randint(50, 150)
        reorder_qty = random.randint(100, 300)
        last_restock = random_date(START_DATE, END_DATE).date().isoformat()
        inventory.append({
            "Product ID": pid,
            "Warehouse": wh,
            "Stock on Hand": stock,
            "Reorder Level": reorder_level,
            "Reorder Quantity": reorder_qty,
            "Last Restock Date": last_restock,
        })
inventory_df = pd.DataFrame(inventory)

# 4. Orders (order lines)
order_ids = []
orders = []
for i in range(NUM_ORDERS):
    oid = f"O{str(i+1).zfill(6)}"
    order_ids.append(oid)
    order_date = random_date(START_DATE, END_DATE).date().isoformat()
    cust_id = random.choice(customer_ids)
    prod_id = random.choice(product_ids)
    qty = random.randint(1, 10)
    unit_price = products_df.loc[products_df["Product ID"] == prod_id, "Selling Price"].iloc[0]
    discount = round(random.choice([0, 0.05, 0.10, 0.15, 0.20]), 2)  # up to 20% discount
    channel = random.choice(["Online", "Marketplace", "Retail Store", "Phone Sale"])
    payment = random.choice(["Credit Card", "PayPal", "Bank Transfer", "Cash"])
    status = random.choice(["Completed", "Shipped", "Pending", "Cancelled"])
    orders.append({
        "Order ID": oid,
        "Order Date": order_date,
        "Customer ID": cust_id,
        "Product ID": prod_id,
        "Quantity": qty,
        "Unit Price": unit_price,
        "Discount": discount,
        "Sales Channel": channel,
        "Payment Method": payment,
        "Order Status": status,
    })
orders_df = pd.DataFrame(orders)

# 5. Returns – subset of completed orders
returned_orders = orders_df[orders_df["Order Status"] == "Completed"].sample(frac=0.05, random_state=42)
returns = []
for idx, row in returned_orders.iterrows():
    ret_id = f"R{str(idx+1).zfill(6)}"
    return_date = (datetime.fromisoformat(row["Order Date"]) + timedelta(days=random.randint(1,30))).date().isoformat()
    return_qty = random.randint(1, row["Quantity"])
    reason = random.choice(["Damaged", "Wrong Item", "Late Delivery", "Customer Dissatisfaction"])
    returns.append({
        "Return ID": ret_id,
        "Order ID": row["Order ID"],
        "Product ID": row["Product ID"],
        "Return Date": return_date,
        "Return Quantity": return_qty,
        "Return Reason": reason,
    })
returns_df = pd.DataFrame(returns)

# ----- Write CSV files -----
output_dir = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(output_dir, exist_ok=True)
products_df.to_csv(os.path.join(output_dir, "products.csv"), index=False)
customers_df.to_csv(os.path.join(output_dir, "customers.csv"), index=False)
inventory_df.to_csv(os.path.join(output_dir, "inventory.csv"), index=False)
orders_df.to_csv(os.path.join(output_dir, "orders.csv"), index=False)
returns_df.to_csv(os.path.join(output_dir, "returns.csv"), index=False)

print("Synthetic CSV datasets generated in 'data/' folder.")
