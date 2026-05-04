# 🍺 Beverage Sales Intelligence Dashboard

An interactive business intelligence dashboard built from 9M+ beverage sales transactions across Germany (2021–2023).

## 🔴 Live Demo
> Open `Dashboard_Preview.html` locally or host via any static server.

![Dashboard Preview](https://img.shields.io/badge/Status-Live-brightgreen) ![Records](https://img.shields.io/badge/Records-9M%2B-blue) ![Revenue](https://img.shields.io/badge/Revenue-%E2%82%AC1.18B-purple)

---

## 📊 Dashboard Features

- **5 Interactive Pages** — Overview, Products, Regions, Customers, Trends
- **Live Filters** — Year · Category · Customer Type · Region (all update charts instantly)
- **Animated KPIs** — Counters animate on load and filter change
- **Glassmorphism UI** — Dark theme with particle background & glow effects
- **47 Products · 16 German Bundesländer · 4 Categories**

---

## 📁 Project Files

| File | Description |
|---|---|
| `Dashboard_Preview.html` | Interactive HTML dashboard (open in browser) |
| `DAX_Measures.dax` | 50+ Power BI DAX measures |
| `PowerQuery_Transform.m` | Power Query M transformation scripts |
| `DataModel_Guide.md` | Star schema, relationships & dashboard layout guide |

---

## 📈 Key Insights

| Metric | Value |
|---|---|
| Total Revenue | €1.18B |
| Top Category | Alcoholic Beverages (77.5%) |
| Top Product | Veuve Clicquot (€202.6M) |
| B2B Share | 76.6% |
| Avg Discount | 7.57% (€96.4M lost) |
| Top Region | Hamburg (€82.5M) |
| Date Range | Jan 2021 – Dec 2023 |

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/Kevin19e/beverage-sales-dashboard

# Serve locally
python -m http.server 3000

# Open in browser
http://localhost:3000/Dashboard_Preview.html
```

---

## 🛠️ Power BI Setup

1. Load `synthetic_beverage_sales_data.csv` into Power BI Desktop
2. Apply transformations from `PowerQuery_Transform.m`
3. Create Date, Category & Region dimension tables
4. Import DAX measures from `DAX_Measures.dax`
5. Follow the 5-page layout in `DataModel_Guide.md`

---

## 📦 Tech Stack

- **Dashboard** — Vanilla HTML/CSS/JS + Chart.js 4.4
- **Styling** — Glassmorphism, CSS animations, Inter font
- **BI Layer** — Power BI DAX + Power Query M
- **Data** — 9M row CSV · Germany · 2021–2023

---

*Built with Claude Code · Anthropic*
