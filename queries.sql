-- Riyadh Apartments: SQL analysis (SQLite)
-- Run through sql_analysis.py (or paste into any SQLite client). Table: riyadh_apartments_sql. View: apartments_features.

-- Q1. Market overview
SELECT COUNT(*)                          AS listings,
       COUNT(DISTINCT Neighborhood)      AS neighborhoods,
       ROUND(AVG(Price))                 AS avg_price,
       ROUND(AVG(Price_per_sqm))         AS avg_price_per_sqm,
       ROUND(AVG(Area_sqm))              AS avg_area_sqm
FROM apartments_features;

-- Q2. Price tiers (same rules as the Python notebook)
SELECT Price_Category,
       COUNT(*)                                           AS listings,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_listings,
       ROUND(AVG(Price))                                  AS avg_price
FROM apartments_features
GROUP BY Price_Category
ORDER BY MIN(Price_per_sqm);

-- Q3. Regional summary (reproduces the Key Findings table)
SELECT Region,
       ROUND(AVG(Price))          AS avg_price,
       ROUND(AVG(Price_per_sqm))  AS avg_price_per_sqm,
       COUNT(*)                   AS listings
FROM apartments_features
GROUP BY Region
ORDER BY avg_price DESC;

-- Q4. Tier mix inside each region (conditional aggregation)
SELECT Region,
       SUM(Price_Category = 'Affordable')                    AS affordable,
       SUM(Price_Category = 'Mid-tier')                      AS mid_tier,
       SUM(Price_Category = 'Luxury')                        AS luxury,
       ROUND(100.0 * SUM(Price_Category = 'Luxury') / COUNT(*), 1) AS luxury_pct
FROM apartments_features
GROUP BY Region
ORDER BY luxury_pct DESC;

-- Q5. Top 3 most expensive neighborhoods (per sqm) in each region (CTE + RANK)
WITH hood AS (
    SELECT Region, Neighborhood,
           COUNT(*)                  AS listings,
           ROUND(AVG(Price_per_sqm)) AS avg_price_per_sqm
    FROM apartments_features
    GROUP BY Region, Neighborhood
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY Region ORDER BY avg_price_per_sqm DESC) AS rnk
    FROM hood
)
SELECT Region, rnk, Neighborhood, listings, avg_price_per_sqm
FROM ranked
WHERE rnk <= 3
ORDER BY Region, rnk;

-- Q6. How much do neighborhoods differ inside the same region? (CTE)
WITH hood AS (
    SELECT Region, Neighborhood, AVG(Price_per_sqm) AS avg_psqm
    FROM apartments_features
    GROUP BY Region, Neighborhood
)
SELECT Region,
       COUNT(*)                                         AS neighborhoods,
       ROUND(MIN(avg_psqm))                             AS cheapest_hood_per_sqm,
       ROUND(MAX(avg_psqm))                             AS priciest_hood_per_sqm,
       ROUND(100.0 * (MAX(avg_psqm) / MIN(avg_psqm) - 1), 1) AS spread_pct
FROM hood
GROUP BY Region
ORDER BY spread_pct DESC;

-- Q7. Elevator availability
SELECT Elevator,
       COUNT(*)                  AS listings,
       ROUND(AVG(Price))         AS avg_price,
       ROUND(AVG(Price_per_sqm)) AS avg_price_per_sqm
FROM apartments_features
GROUP BY Elevator;

-- Q8. Property age buckets
SELECT CASE WHEN Age_years <= 5  THEN '1) 0-5 years'
            WHEN Age_years <= 10 THEN '2) 6-10 years'
            WHEN Age_years <= 20 THEN '3) 11-20 years'
            ELSE                      '4) 21+ years' END AS age_bucket,
       COUNT(*)                  AS listings,
       ROUND(AVG(Price))         AS avg_price,
       ROUND(AVG(Price_per_sqm)) AS avg_price_per_sqm
FROM apartments_features
GROUP BY age_bucket
ORDER BY age_bucket;

-- Q9. Bedrooms: price per sqm and average area
SELECT Bedrooms,
       COUNT(*)                  AS listings,
       ROUND(AVG(Area_sqm))      AS avg_area_sqm,
       ROUND(AVG(Price_per_sqm)) AS avg_price_per_sqm
FROM apartments_features
GROUP BY Bedrooms
ORDER BY Bedrooms;

-- Q10. Furnished vs unfurnished by region
SELECT Region, Furnished,
       COUNT(*)                  AS listings,
       ROUND(AVG(Price))         AS avg_price,
       ROUND(AVG(Price_per_sqm)) AS avg_price_per_sqm
FROM apartments_features
GROUP BY Region, Furnished
ORDER BY Region, Furnished;
