# Riyadh Apartments: Data Preparation, SQL Database & Power BI Dashboard 🏙️📊

An end-to-end analysis of 10,000 apartment sale listings across Riyadh, Saudi Arabia. Python (Pandas) is used to inspect the data and engineer price features, **SQLite** is used to store the listings in a local SQL database, and the prepared dataset feeds an interactive **Power BI dashboard** for exploring prices by region, price tier, and property features.

<p align="center">
  <img src="Riyadh_Apartments_Dashboard.png" alt="Riyadh Apartments Power BI Dashboard" width="760">
</p>
<p align="center"><em>Power BI dashboard, shown with the Affordable tier selected (4,949 listings).</em></p>

---

## 📌 Project Overview
- **Data**: Riyadh apartments dataset with 10,000 listings and 13 columns: City, Region, Neighborhood, Property Type, Area (sqm), Bedrooms, Bathrooms, Floor Number, Elevator, Property Age (years), Furnished, Listing Type, and Selling Price (SAR).
- **Coverage**: 5 regions (North, East, West, Central, South) and 75 neighborhoods. All listings are apartment **sale** listings; the dataset has no rental listings.
- **Geocoding**: a companion lookup table (`riyadh_geocoding.csv`) maps each of the 75 neighborhoods to latitude/longitude coordinates.
- **Tech Stack**: Python (Pandas, `sqlite3`, Jupyter Notebook), SQLite, and Microsoft Power BI.

## 📁 Repository Contents
| File | Description |
|---|---|
| `data_cleaning_riyadh_apartments.ipynb` | Data inspection, feature engineering, and export of the prepared dataset |
| `queries.sql` | 10 analytical SQL queries on the listings |
| `sql_analysis.py` | Builds the SQLite database (`riyadh_real_estate.db`) and runs `queries.sql` |
| `riyadh_geocoding.csv` | Latitude/longitude lookup for the 75 neighborhoods (supporting file for geographic analysis) |
| `riyadh_apartments_cleaned.csv` | Prepared dataset (15 columns) used by the dashboard |
| `Riyadh_Apartments_Dashboard.pbix` | Interactive Power BI report |
| `Riyadh_Apartments_Dashboard.png` | Screenshot of the dashboard |

---

## 🧹 Data Preparation
The notebook performs the following steps:
1. **Load and inspect** the raw data (`riyadh_apartments_data.csv`, read from `riyadh_data.zip`): structure, data types, and null counts. The dataset has no missing values and no duplicate rows, so no imputation or row removal was needed.
2. **Store in a SQL database** (SQLite): the raw listings are loaded into a local database and analyzed with SQL (see the next section).
3. **Price per square meter**: `Price_per_sqm = Selling Price (SAR) / Area (sqm)`.
4. **Price tiers** based on price per square meter:

| Tier | Rule (SAR per sqm) | Listings |
|---|---|---|
| Affordable (اقتصادية) | below 3,000 | 4,949 |
| Mid-tier (متوسطة) | 3,000 up to (not including) 8,000 | 3,453 |
| Luxury (فاخرة) | 8,000 and above | 1,598 |

5. **Export** to `riyadh_apartments_cleaned.csv` (UTF-8 with BOM) so the Arabic tier labels display correctly in Power BI.

---

## 🗄️ SQL Analysis (SQLite)
The raw listings are loaded into a local **SQLite** database, and the analysis is repeated in SQL. `sql_analysis.py` builds `riyadh_real_estate.db` and runs every query in `queries.sql`:

| Object | Type | Description |
|---|---|---|
| `riyadh_apartments_sql` | table | The 10,000 raw listings, 13 columns, exactly as in the CSV |
| `apartments_features` | view | Clean column names plus `Price_per_sqm` and `Price_Category`, using the same tier rules as the notebook |

`queries.sql` has 10 queries that use `GROUP BY`/`HAVING`, `CASE`, conditional aggregation, CTEs, and window functions (`RANK`, `SUM() OVER`):

| # | Question | SQL techniques |
|---|---|---|
| Q1 | Market overview (listings, neighborhoods, average price and area) | Aggregates |
| Q2 | Listings and average price per price tier | `GROUP BY`, `SUM() OVER` |
| Q3 | Regional summary (reproduces the Key Findings table) | `GROUP BY` |
| Q4 | Price tier mix inside each region | Conditional aggregation |
| Q5 | Top 3 neighborhoods per sqm in each region | CTE, `RANK() OVER` |
| Q6 | How much neighborhoods differ inside the same region | CTE, `MIN`/`MAX` |
| Q7 | Elevator availability | `GROUP BY` |
| Q8 | Property age buckets | `CASE` |
| Q9 | Bedrooms vs. area and price per sqm | `GROUP BY` |
| Q10 | Furnished vs. unfurnished by region | `GROUP BY` |

### Key SQL findings
- **The SQL results match the Python results**: the tier counts (4,949 / 3,453 / 1,598) and the regional averages in the table above are reproduced exactly by Q2 and Q3.
- **Price tiers follow the region**: South and Central listings are 100% Affordable, all East listings are Mid-tier, and North is 79% Luxury (1,598 of 2,020 listings) with the rest Mid-tier. West is split between Affordable and Mid-tier.
- **Region matters, neighborhood barely does**: inside each region the cheapest and priciest neighborhoods differ by only about 3.5% to 5.4% per sqm, while North is about eight times South across regions.
- **Property features add little**: an elevator, property age (1 to 10 years in this data), bedrooms, and furnishing each change average price per sqm by about 2% at most.

> **Note:** column names in the raw table keep the original CSV headers, including spaces and parentheses (for example `Area (sqm)`). `apartments_features` renames them, so the queries can use plain names like `Area_sqm` and `Price`.

**Run the SQL step:**
```bash
python sql_analysis.py   # builds riyadh_real_estate.db, then runs and prints all queries in queries.sql
```
SQLite needs no installation, since `sqlite3` ships with Python. The script reads `riyadh_apartments_data.csv` from the same folder.

---

## 📍 Geocoding Data
`riyadh_geocoding.csv` is a lookup table with one row per neighborhood (75 rows) and 5 columns:

| Column | Description |
|---|---|
| `City` | City name (Riyadh) |
| `Region` | One of North, East, West, Central, South |
| `Neighborhood` | Neighborhood name, matching the listings dataset |
| `latitude` | Latitude of the neighborhood |
| `longitude` | Longitude of the neighborhood |

It can be joined to the listings on `City`, `Region`, and `Neighborhood` to plot prices on a map (for example, a map visual in Power BI or a geospatial plot in Python). The current dashboard does not include a map visual.

> **Note:** the coordinates are approximate points per neighborhood, not boundaries. A few neighborhoods share the same point (for example Al-Batha and Al-Wurud), so check the coordinates before doing distance-based analysis.

---

## 📊 Power BI Dashboard
The dashboard was built in Power BI Desktop on top of `riyadh_apartments_cleaned.csv` and includes:

| Component | Purpose |
|---|---|
| **KPI cards** | Average selling price and average price per sqm for the current selection |
| **Price tier slicer** (`Price_Category`) | Filters every visual by Affordable, Mid-tier, or Luxury |
| **Average selling price by region** | Compares price levels across Riyadh regions |
| **Average price per sqm by bedrooms** | Shows how unit size relates to price per sqm |
| **Elevator availability** | Splits listings with and without an elevator |

Selecting a tier in the slicer cross-filters all visuals, so each price segment can be explored on its own.

---

## 🔍 Key Findings

| Region | Avg. selling price (SAR) | Avg. price per sqm (SAR) | Listings |
|---|---|---|---|
| North | 1,767,500 | 9,451 | 2,020 |
| East | 732,998 | 3,996 | 2,047 |
| West | 555,051 | 2,985 | 1,997 |
| Central | 277,569 | 1,501 | 1,972 |
| South | 212,781 | 1,148 | 1,964 |

- **Location drives price**: North Riyadh averages about 9,451 SAR per sqm, roughly eight times South Riyadh (1,148).
- **Bedrooms barely change price per sqm** in this dataset (about 3,805 to 3,870 SAR across 1 to 4 bedrooms).
- **Elevator availability** shows little difference in average selling price (about 724K SAR without an elevator vs. 705K SAR with one).

---

## 🛠️ How to View
1. Download `Riyadh_Apartments_Dashboard.pbix` and open it with **Power BI Desktop**.
2. Review the data preparation steps in `data_cleaning_riyadh_apartments.ipynb` and the SQL analysis in `queries.sql`.
3. To rerun the notebook, place `riyadh_data.zip` (containing `riyadh_apartments_data.csv`) in the same folder and run `pip install pandas numpy jupyter`.
4. To rerun the SQL analysis, put `riyadh_apartments_data.csv` next to `sql_analysis.py` and `queries.sql`, then run `python sql_analysis.py`.

---

## 👤 Author
**Rayan Almahmoud**
[LinkedIn](https://linkedin.com/in/rayan-almahmoud-534339308) | [GitHub](https://github.com/rayan8129)
