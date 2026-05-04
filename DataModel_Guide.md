# Beverage Sales — Power BI Data Model Guide

## Dataset Overview
| Property | Value |
|---|---|
| File | synthetic_beverage_sales_data.csv |
| Rows | ~9,000,000 |
| Date Range | 2021-01-01 → 2023-12-30 |
| Total Revenue | €1,176,681,163 |
| Regions | 16 German Bundesländer |
| Products | 47 |
| Categories | 4 |
| Customer Types | B2B, B2C |

---

## Star Schema (Recommended Model)

```
                    ┌─────────────┐
                    │  Date Table │
                    │  (DimDate)  │
                    └──────┬──────┘
                           │ Order_Date
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────┴──────┐  ┌──────┴──────┐  ┌─────┴──────┐
    │  DimProduct│  │  FactSales  │  │  DimRegion │
    │  (Product) │  │  (main CSV) │  │  (Region)  │
    └────────────┘  └──────┬──────┘  └────────────┘
                           │
                    ┌──────┴──────┐
                    │ DimCustomer │
                    │(Customer_ID)│
                    └─────────────┘
```

## Tables to Create

### 1. FactSales (Main CSV)
All columns from CSV + calculated columns added via Power Query:
- `Year`, `Month`, `Quarter`, `Year-Month`
- `Discount Tier` (No Discount / Low / Medium / High)
- `Gross Revenue` (Unit_Price × Quantity)
- `Discount Value €` (Gross Revenue − Total_Price)
- `Est. COGS`, `Est. Gross Margin`, `Est. Margin %`

### 2. DimDate (Date Dimension)
Generated via Power Query M — see `PowerQuery_Transform.m`
- Link: `DimDate[Date]` → `FactSales[Order_Date]` (Many-to-One)
- Mark as **Date Table** in Power BI

### 3. DimCategory (Category Dimension)
4 rows: Alcoholic Beverages, Juices, Soft Drinks, Water
- Link: `DimCategory[Category]` → `FactSales[Category]`

### 4. DimRegion (Region Dimension)
16 rows with Area (South/North/West/East/Central) and State Code
- Link: `DimRegion[Region]` → `FactSales[Region]`

---

## Relationships
| From | To | Cardinality | Cross-filter |
|---|---|---|---|
| DimDate[Date] | FactSales[Order_Date] | 1:Many | Single |
| DimCategory[Category] | FactSales[Category] | 1:Many | Single |
| DimRegion[Region] | FactSales[Region] | 1:Many | Single |

---

## Recommended Dashboard Pages

### Page 1 — Executive Overview
**KPI Cards:** Total Revenue · Total Orders · AOV · Unique Customers · Avg Discount
**Visuals:**
- Line chart: Monthly Revenue Trend (2021–2023)
- Donut: Revenue by Category
- Donut: B2B vs B2C split
- Stacked bar: Annual revenue by category
- Bar: Discount impact (Gross vs Net)

**Slicers:** Year · Category · Customer Type · Region

---

### Page 2 — Product Performance
**KPI Cards:** Top Product · Top Category · Avg Unit Price · Total SKUs
**Visuals:**
- Horizontal bar: Top 10 Products by Revenue
- Matrix table: Product × Year revenue with conditional formatting
- Treemap: Category → Product hierarchy
- Scatter: Unit Price vs Quantity (bubble = revenue)

---

### Page 3 — Regional Analysis
**KPI Cards:** Top Region · Regions Above Avg · Revenue per Region
**Visuals:**
- Map visual (ArcGIS/Bing): Germany Bundesländer choropleth
- Bar chart: All 16 regions ranked
- Bar: Region × Category heatmap
- Line: Top 5 regions trend over time

---

### Page 4 — Customer Insights
**KPI Cards:** B2B Revenue · B2C Revenue · B2B Share · Discount Gap B2B/B2C
**Visuals:**
- Clustered bar: B2B vs B2C by year
- 100% stacked bar: Customer type by region
- Donut: B2B vs B2C by category
- Table: Customer segment × product performance

---

### Page 5 — Time & Trends
**KPI Cards:** YoY Growth % · QoQ Growth · Best Month · Worst Month
**Visuals:**
- Multi-line: Revenue per category over time
- Waterfall: YoY revenue bridge
- Bar: QoQ revenue (12 quarters)
- Radar: Seasonal pattern (avg by month)
- Line: Discount % trend

---

## Key Insights from Data

| Insight | Value |
|---|---|
| **Alcoholic Beverages dominates** | 77.5% of all revenue |
| **Top 2 products = 32% of revenue** | Veuve Clicquot + Moët & Chandon |
| **B2B is core** | 76.6% of revenue |
| **Steady growth** | +3.9% 2021→2022, +1.8% 2022→2023 |
| **Discounts cost €96.4M** | 7.57% average across all orders |
| **Top region: Hamburg** | €82.5M (7.0% share) |
| **Most balanced: Bayern** | Strong across all categories |
| **Summer peak** | Jul–Aug highest revenue months |

---

## Performance Tips (9M rows)

1. **Import Mode** — For best performance with 9M rows, use Import (not DirectQuery)
2. **Date table** — Always use a dedicated date table, never auto date/time
3. **Column removal** — Drop any unused columns in Power Query before load
4. **Aggregation tables** — Create summary tables by Month/Region/Category for fast visuals
5. **Incremental refresh** — Set up if data will be refreshed regularly
6. **Composite model** — Use aggregation table for KPIs + detail table for drill-through

---

## Aggregation Table (Optional, for Speed)

Create in Power Query:
```
Group FactSales by: Year, Month, Region, Category, Customer_Type
Aggregate: Sum(Total_Price), Sum(Quantity), Count(Order_ID)
```
This reduces 9M rows → ~10K rows for most dashboard visuals.
