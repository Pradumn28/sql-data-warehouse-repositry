-- ✅ Data Quality Checks: Bronze ➡️ Silver Layer Transformation
-- Author: [Your Name]
-- Description: This script contains all the essential quality checks performed on the Bronze (raw) layer
--              before loading into the Silver (cleaned) layer. These checks ensure data integrity, consistency,
--              and accuracy for downstream analytics and reporting.

-- -----------------------------
-- 📌 1. crm_cust_info Checks
-- -----------------------------
-- 🧪 Check for duplicates or NULLs in primary key (cst_id)
SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- 🧽 Trim unwanted spaces in cst_firstname
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- 🔄 Check for standardization in categorical columns
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;

-- ✅ Repeat same checks on Bronze layer for before-after comparison
-- Helps validate the transformation logic.

-- -----------------------------
-- 📌 2. crm_prd_info Checks
-- -----------------------------
-- 🔑 Check for duplicates/NULLs in primary key
SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- 🧽 Unwanted spaces in product names
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- ⚠️ Negative or NULL costs
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 🔄 Product Line validation
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- 📆 Invalid date sequences
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- 📏 Date alignment across overlapping records
SELECT prd_id, prd_key, prd_start_dt,
       LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prev_value
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

-- -----------------------------
-- 📌 3. crm_sales_details Checks
-- -----------------------------
-- 📅 Invalid or malformed dates
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 OR sls_due_dt > 20500101 OR sls_due_dt < 19000101;

-- 📆 Logical date relationships
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- 📊 Sales calculation and data accuracy
SELECT sls_sales AS old_sales, sls_quantity, sls_price AS old_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

-- -----------------------------
-- 📌 4. erp_cust_az12 Checks
-- -----------------------------
-- 🧾 Checking for prefixed IDs (NAS%) and mapping
SELECT cid,
       CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid_cleaned,
       bdate, gen
FROM silver.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END
      NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

-- 🕒 Future birth dates (invalid)
SELECT bdate FROM silver.erp_cust_az12 WHERE bdate > GETDATE();

-- 🚻 Gender standardization
SELECT DISTINCT gen,
       CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a' END AS gen_cleaned
FROM silver.erp_cust_az12;

-- -----------------------------
-- 📌 5. erp_loc_a101 Checks
-- -----------------------------
-- 🔍 CID consistency check with crm_cust_info
SELECT REPLACE(cid, '-', '') AS cleaned_cid, cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- 🌍 Country column standardization
SELECT DISTINCT cntry FROM silver.erp_loc_a101 ORDER BY cntry;

-- -----------------------------
-- 📌 6. erp_px_cat_g1v2 Checks
-- -----------------------------
-- 🧽 Unwanted lowercase entries and extra spaces
SELECT cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2
WHERE cat != UPPER(cat) OR subcat != UPPER(subcat) OR maintenance != UPPER(maintenance);

-- 🔄 Standardization in subcategory
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;

-- ✅ These checks ensure data quality before promoting to Silver layer,
--    making analytics, joins, and dashboards more reliable and robust.

-- 📘 You can further automate these with data validation tools or triggers in ETL pipelines.
-- 📤 Useful for GitHub documentation, audit trails, and onboarding new team members.
