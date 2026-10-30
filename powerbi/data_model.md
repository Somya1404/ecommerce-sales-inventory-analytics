# data_model.md

## Power BI Data Model Overview

The model follows a **star schema** design for optimal performance and simplicity.

### Tables
| Table | Type | Key | Description |
|-------|------|-----|-------------|
| `DimProduct` | Dimension | `ProductID` (PK) | Product attributes – name, category, subcategory, supplier, cost, price |
| `DimCustomer` | Dimension | `CustomerID` (PK) | Customer segment, location, registration date |
| `DimWarehouse` | Dimension | `WarehouseID` (PK) | Static list of warehouses (North, South, East, West) |
| `DimDate` | Dimension | `Date` (PK) | Calendar table – every date covering the range of the data, with year, quarter, month, day, etc. |
| `FactOrder` | Fact | Composite PK (`OrderID`, `ProductID`) | Order line details – quantity, unit price, discount, sales channel, payment method, status |
| `FactInventory` | Fact | Composite PK (`ProductID`, `WarehouseID`) | Snapshot of stock on hand, reorder level, reorder quantity, last restock date |
| `FactReturn` | Fact | `ReturnID` (PK) | Return details – linked to order and product |

### Relationships
- `FactOrder[ProductID]` → `DimProduct[ProductID]` (many‑to‑one)
- `FactOrder[CustomerID]` → `DimCustomer[CustomerID]` (many‑to‑one)
- `FactInventory[ProductID]` → `DimProduct[ProductID]`
- `FactInventory[WarehouseID]` → `DimWarehouse[WarehouseID]`
- `FactReturn[ProductID]` → `DimProduct[ProductID]`
- `FactReturn[OrderID]` → `FactOrder[OrderID]`
- `FactOrder[OrderDate]` → `DimDate[Date]`

All relationships are **single‑direction, **filter direction** set from dimensions to facts** (default). No bidirectional filtering is required.

### Calendar Table (DimDate)
Create the calendar table directly in Power BI using **DAX**:
```DAX
DimDate =
    CALENDAR (DATE(2022,1,1), DATE(2024,12,31))

// Add useful columns
DimDate =
    ADDCOLUMNS(
        DimDate,
        "Year", YEAR([Date]),
        "Quarter", "Q" & FORMAT( [Date], "Q" ),
        "MonthNumber", MONTH([Date]),
        "MonthName", FORMAT( [Date], "MMMM" ),
        "MonthYear", FORMAT( [Date], "YYYY-MM" ),
        "Day", DAY([Date]),
        "WeekDay", FORMAT( [Date], "dddd" )
    )
```

### Loading CSVs into Power BI
1. **Get Data → CSV** for each file in the `data/` folder.
2. Rename the imported tables to match the model names above (e.g., `orders.csv` → `FactOrder`).
3. Ensure the data types are correct (dates → Date, numeric → Whole Number or Decimal).
4. After all tables are loaded, go to **Model** view and create the relationships as described.
5. Mark `DimDate` as a **Date Table** (`Mark as Date Table`).

---
*The above file provides the full data‑model specification you need to recreate the Power BI report.*
