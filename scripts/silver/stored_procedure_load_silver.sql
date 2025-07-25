/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/




CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
BEGIN TRY
Declare @start_time DATETIME,@end_time DATETIME,@batch_time_start DATETIME,@batch_time_end DATETIME

        SET @batch_time_start=GETDATE()

        PRINT '<<<<<<<<<<<<<<<<<<<LOADING SILVER LAYER>>>>>>>>>>>>>>>>>>>>>'

        -------------------------------------------------------------------------------------------------------------------------------------------------------------------
        --loading of silver.crm_cust_info

        SET @start_time=GETDATE();

        PRINT '<<<TRUNCATING THE TABLES>>>>'
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '---Inserting the Data---- in silver.crm_cust_info-----'

        INSERT  INTO silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
        )


        SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
             WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
             ELSE 'n/a'
        END AS cst_marital_status,

        CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male' 
             WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
             ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
        FROM(
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rown
        FROM bronze.crm_cust_info
        WHERE cst_id is not null
        )t
        WHERE rown=1; --Selecting the most recent date/value of the table

        SET @end_time=GETDATE()

        PRINT '<<<LOADING DURATION>>>' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'seconds'

        ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --loading of silver.crm_prd_info
        SET @start_time=GETDATE()


        PRINT '<<<TRUNCATING THE TABLES>>>>'
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '---Inserting the Data---- in silver.crm_prd_info-----'




        INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )

        SELECT prd_id,
               REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
               SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
               prd_nm,
               ISNULL(prd_cost,0) as prd_cost,
               CASE UPPER(TRIM(prd_line))
                    WHEN 'M' then 'Mountain'
                    WHEN 'R' then 'Road'
                    WHEN 'S' then 'Other Sales'
                    WHEN 'T' then 'Touring'
                    else 'n/a'
               END AS prd_line,
               CAST(prd_start_dt AS DATE) as prd_start_dt,
               CAST(lead(prd_start_dt)over(partition by prd_key order by prd_start_dt)-1 AS DATE) as prd_end_dt

          FROM bronze.crm_prd_info
          
          SET @end_time=GETDATE()

          PRINT '<<<LOADING DURATION>>>' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'seconds'

          ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

          --loading of silver.crm_sales_details
          SET @start_time=GETDATE()

          PRINT '<<<TRUNCATING THE TABLES>>>>'
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '---Inserting the Data---- in silver.crm_sales_details-----'



        INSERT INTO silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
        )


        SELECT 
	        sls_ord_num,
	        sls_prd_key,
	        sls_cust_id,
	        CASE WHEN sls_order_dt=0 Or len(sls_order_dt)!=8 then NULL 
	        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
	        END AS sls_order_dt,
	
	        CASE WHEN sls_ship_dt=0 Or len(sls_ship_dt)!=8 then NULL 
	        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
	        END AS sls_ship_dt,

	        CASE WHEN sls_due_dt=0 Or len(sls_due_dt)!=8 then NULL 
	        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
	        END AS sls_due_dt,

	        CASE WHEN sls_sales<=0 or sls_sales is null or sls_sales!=sls_quantity*abs(sls_price)
	        THEN sls_quantity*abs(sls_price)
	        ELSE sls_sales
	        END AS sls_sales,

	        sls_quantity,

	        CASE WHEN sls_price is null or sls_price<=0 
	        THEN sls_sales/NULLIF(sls_quantity,0)
	        ELSE sls_price
	        END AS sls_price
        FROM bronze.crm_sales_details;


        SET @end_time=GETDATE()
        PRINT '<<<LOADING DURATION>>>' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'seconds'

        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


        --loading of silver.erp_cust_az12
        SET @start_time=GETDATE()
        PRINT '<<<TRUNCATING THE TABLES>>>>'
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '---Inserting the Data---- in silver.erp_cust_az12-----'



        INSERT INTO silver.erp_cust_az12(
        cid,
        bdate,
        gen
        )

        SELECT 
                CASE WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid,4,len(cid))
                ELSE cid
                END AS cid,

                CASE WHEN bdate>GETDATE() 
                THEN NULL
                ELSE bdate
                END AS bdate,

                CASE WHEN UPPER(TRIM(gen)) in ('F','FEMALE') THEN 'Female'
                     WHEN UPPER(TRIM(gen)) in ('M','MALE') THEN 'Male'
                ELSE 'n/a'
                END AS gen
        FROM bronze.erp_cust_az12


        SET @end_time=GETDATE()
        PRINT '<<<LOADING DURATION>>>' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'seconds'


        ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --loading of silver.erp_loc_a101
        SET @start_time=GETDATE()
        PRINT '<<<TRUNCATING THE TABLES>>>>'
        TRUNCATE TABLE silver.erp_loc_a101
        PRINT '---Inserting the Data---- in silver.erp_loc_a101-----'




        INSERT INTO silver.erp_loc_a101(
        cid,
        cntry
        )


        SELECT REPLACE (cid,'-','') as cid,
        CASE WHEN cntry='DE' then 'Germany'
             WHEN cntry in ('US','USA') then 'United States'
             WHEN cntry='' or cntry is null then 'n/a'
        ELSE TRIM(cntry)
        END AS cntry
        FROM bronze.erp_loc_a101;

        SET @end_time=GETDATE()
        PRINT '<<<LOADING DURATION>>>' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'seconds'


        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --loading of silver.erp_px_cat_g1v2
        SET @start_time=GETDATE()
        PRINT '<<<TRUNCATING THE TABLES>>>>'
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '---Inserting the Data---- in silver.erp_px_cat_g1v2-----'


        INSERT INTO silver.erp_px_cat_g1v2(
        id,
        cat,
        subcat,
        maintenance
        )


        SELECT id,
        cat,
        subcat,
        maintenance
        FROM bronze.erp_px_cat_g1v2
        
        SET @end_time=GETDATE()
        PRINT '<<<LOADING DURATION>>>' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'seconds'

        SET @batch_time_end=GETDATE()
        PRINT '<<<<<<<<<<<<<<<<<<LOADING SILVER LAYER IS COMPLETED>>>>>>>>>>>>> '+ 'in ' +CAST(DATEDIFF(second,@batch_time_start,@batch_time_end) AS NVARCHAR)+'seconds'
        
END TRY
BEGIN CATCH
        PRINT 'ERROR OCCURED DURING LOADING SILVER_LAYER' 
        PRINT 'Error Message' + ERROR_MESSAGE()
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS VARCHAR)
        PRINT 'Error Message' + CAST(ERROR_STATE() AS VARCHAR)

END CATCH

END

--For executing whole stored procedure above
--EXEC silver.load_silver
