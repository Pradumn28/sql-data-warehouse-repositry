These steps I have written during my journey of this DataWarehouse Project


--==================== BASIC DATA PIPELINE STEPS ====================--

-- 1. First, create the necessary tables with correct column names and data types.

-- 2. Load the raw data into these tables from the Bronze Layer (the uncleaned/raw layer).

-- 3. For each column in every table, carefully check for bad or messy data:
--    ➤ Look for NULL values, unwanted spaces, duplicates, wrong formats, etc.

-- 4. If you plan to join two tables:
--    ➤ Always check both tables you're joining.
--    ➤ Make sure the join key (like customer ID or product ID) exists in both tables and is clean.

-- 5. Once the data is cleaned:
--    ➤ Insert it into the Silver Layer (the cleaned/processed layer).
--    ➤ Double-check that the data types and column names match what you defined in Step 1.

-- 6. Finally, run quality checks again on the Silver Layer tables to ensure everything is clean and ready for use.
--    ➤ This includes checking for duplicates, nulls, invalid values, and consistency across columns.

--==================================================================--
