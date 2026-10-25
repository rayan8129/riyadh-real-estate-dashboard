# Riyadh Apartments: Data Preparation, Analysis & Power BI Dashboard 🏙️📊

An end-to-end analysis of 10,000 apartment sale listings across Riyadh, Saudi Arabia. Python is used to inspect the data and engineer price features, and the prepared dataset feeds an interactive **Power BI dashboard** for exploring prices by region, price tier, and property features.

<p align="center">
  <img src="Riyadh_Apartments_Dashboard.png" alt="Riyadh Apartments Power BI Dashboard" width="760">
</p>
<p align="center"><em>Power BI dashboard, shown with the Affordable tier selected (4,949 listings).</em></p>

---

## 📌 Project Overview
- **Data**: Riyadh apartments dataset with 10,000 listings and 13 columns: City, Region, Neighborhood, Property Type, Area (sqm), Bedrooms, Bathrooms, Floor Number, Elevator, Property Age (years), Furnished, Listing Type, and Selling Price (SAR).
- **Coverage**: 5 regions (North, East, West, Central, South) and 75 neighborhoods. All listings are apartment **sale** listings; the dataset has no rental listings.
- **Tech Stack**: Python (Pandas, Jupyter Notebook) and Microsoft Power BI.

## 📁 Repository Contents
| File | Description |
|---|---|
| `data_cleaning_riyadh_apartments.ipynb` | Data inspection, feature engineering, and export of the prepared dataset |
| `riyadh_apartments_cleaned.csv` | Prepared dataset (15 columns) used by the dashboard |
| `Riyadh_Apartments_Dashboard.pbix` | Interactive Power BI report |
| `Riyadh_Apartments_Dashboard.png` | Screenshot of the dashboard |

---

## 🧹 Data Preparation
The notebook performs the following steps:
1. **Load and inspect** the raw data (`riyadh_apartments_data.csv`, read from `riyadh_data.zip`): structure, data types, and null counts. The dataset has no missing values and no duplicate rows, so no imputation or row removal was needed.
2. **Price per square meter**: `Price_per_sqm = Selling Price (SAR) / Area (sqm)`.
3. **Price tiers** based on price per square meter:

| Tier | Rule (SAR per sqm) | Listings |
|---|---|---|
| Affordable (اقتصادية) | below 3,000 | 4,949 |
| Mid-tier (متوسطة) | 3,000 up to (not including) 8,000 | 3,453 |
| Luxury (فاخرة) | 8,000 and above | 1,598 |

4. **Export** to `riyadh_apartments_cleaned.csv` (UTF-8 with BOM) so the Arabic tier labels display correctly in Power BI.

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
2. Review the data preparation steps in `data_cleaning_riyadh_apartments.ipynb`.
3. To rerun the notebook, place `riyadh_data.zip` (containing `riyadh_apartments_data.csv`) in the same folder and run `pip install pandas numpy jupyter`.

---

## 👤 Author
**Rayan Almahmoud**
[LinkedIn](https://linkedin.com/in/rayan-almahmoud-534339308) | [GitHub](https://github.com/rayan8129)
