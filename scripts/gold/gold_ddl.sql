/*
╔═══════════════════════════════════════════════════════════════════════════════╗
║                           🌟 DDL Script: Create Gold Views                   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ 📜 Script Purpose:                                                            ║
║    This script creates views for the 🌟 Gold Layer in the data warehouse.     ║
║    The Gold Layer represents the final 🧩 Dimension and 📊 Fact tables         ║
║    organized in a Star Schema format.                                        ║
║                                                                               ║
║    Each view performs transformations and combines data from the 🪞 Silver    ║
║    Layer to produce a clean, enriched, and business-ready dataset.           ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ 🚀 Usage:                                                                     ║
║    - These views can be queried directly for dashboards, analytics, and      ║
║      business reporting.                                                     ║
╚═══════════════════════════════════════════════════════════════════════════════╝
*/



--------------------------------------------------CREATE gold.dim_customers-------------------------------------------

--USE of Surrogate Key
SELECT
ROW_NUMBER() over(order by cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,

CASE WHEN cst_gndr!='n/a' then cst_gndr
ELSE COALESCE(gen,'n/a')
END AS gender,
ca.bdate AS birth_date,
ci.cst_create_date AS create_date




FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key=ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key=la.cid


-----------------------------------------------------CREATE gold.dim_products--------------------------------------------


CREATE VIEW gold.dim_products As

SELECT 
ROW_NUMBER() over(order by ci.prd_start_dt,ci.prd_key) AS product_key,
ci.prd_id AS product_id,
ci.prd_key AS product_number,
ci.prd_nm AS product_name,
ci.cat_id AS category_id,
pc.cat AS categories,
pc.subcat AS subcategories,
pc.maintenance AS maintenance,
ci.prd_cost AS cost,
ci.prd_line AS product_line,
ci.prd_start_dt AS start_date

FROM silver.crm_prd_info ci
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON ci.cat_id=pc.id
WHERE prd_end_dt is null   --FILTER out historical values in the data


-----------------------------------------------------CREATE gold.fact_sales-------------------------------------------------

CREATE VIEW gold.fact_sales AS
SELECT 
sls_ord_num AS order_number,
pr.product_key ,
cs.customer_key,
sls_order_dt AS order_date,
sls_ship_dt AS shipping_date,
sls_due_dt AS due_date,
sls_sales AS sales,
sls_quantity AS quantity,
sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key=pr.product_number
LEFT JOIN gold.dim_customers cs
ON sd.sls_cust_id=cs.customer_id


