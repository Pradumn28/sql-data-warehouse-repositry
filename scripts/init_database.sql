/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, 3 databases are created to keep the three layers
    different from each other
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- creating the databases

create database datawarehouse;

  -- used 3 different databases for 3 different layers

create database bronze;
create database silver;
create database gold;
