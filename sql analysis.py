"""SQL analysis for the Riyadh Apartments project.

1. Loads the raw listings into a local SQLite database (riyadh_real_estate.db).
2. Creates the view apartments_features (Price_per_sqm and Price_Category).
3. Runs every query in queries.sql and prints the results.

Usage:  python sql_analysis.py
"""
import re
import sqlite3
import pandas as pd

RAW_CSV = "riyadh_apartments_data.csv"
DB_FILE = "riyadh_real_estate.db"
QUERIES_FILE = "queries.sql"

# ---------- 1. Build the database ----------
df_apartments = pd.read_csv(RAW_CSV)
conn = sqlite3.connect(DB_FILE)
df_apartments.to_sql("riyadh_apartments_sql", conn, if_exists="replace", index=False)

# ---------- 2. Feature view (same rules as the Python notebook) ----------
conn.executescript("""
DROP VIEW IF EXISTS apartments_features;
CREATE VIEW apartments_features AS
SELECT City, Region, Neighborhood, "Property Type" AS Property_Type,
       "Area (sqm)" AS Area_sqm, Bedrooms, Bathrooms, "Floor Number" AS Floor_Number,
       Elevator, "Property Age (years)" AS Age_years, Furnished, "Listing Type" AS Listing_Type,
       "Selling Price (SAR)" AS Price,
       "Selling Price (SAR)" / "Area (sqm)" AS Price_per_sqm,
       CASE WHEN "Selling Price (SAR)" / "Area (sqm)" < 3000 THEN 'Affordable'
            WHEN "Selling Price (SAR)" / "Area (sqm)" < 8000 THEN 'Mid-tier'
            ELSE 'Luxury' END AS Price_Category
FROM riyadh_apartments_sql;
""")
conn.commit()

print("DATABASE BUILT")
for name in ("riyadh_apartments_sql", "apartments_features"):
    n = conn.execute(f"SELECT COUNT(*) FROM {name}").fetchone()[0]
    print(f"  {name}: {n:,} rows")

# ---------- 3. Run the queries ----------
sql = open(QUERIES_FILE, encoding="utf-8").read()
for block in [b.strip() for b in sql.split(";") if "SELECT" in b or "WITH" in b]:
    title = re.search(r"-- (Q\d+\..*)", block)
    print("\n" + (title.group(1) if title else ""))
    print(pd.read_sql(block + ";", conn).to_string(index=False))
conn.close()
