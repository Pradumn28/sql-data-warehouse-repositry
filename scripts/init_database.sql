/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
USE master;
GO

-- checks if database name already exist in the system
IF EXISTS(SELECT 1 FROM sys.databases WHERE name='datawarehouse')
BEGIN
-- This forces the database into single-user mode, meaning only one connection (your current session) can access it.
-- WITH ROLLBACK IMMEDIATE forces all other connections to the database to be disconnected immediately, and any open transactions are rolled back
	ALTER DATABASE datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE datawarehouse;
END;
GO
	

-- Create the 'DataWarehouse' database
CREATE DATABASE datawarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
