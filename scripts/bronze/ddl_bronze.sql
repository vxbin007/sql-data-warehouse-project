/*
=======================================================================================================================================
DDL Script	     : Create Bronze Tables
Purpose                 : Schema initialization script for the 'bronze' layer of a data warehouse / staging environment. This script
                          creates foundational raw data tables for customer,  order, and product data ingestion.
                                           
Description             : - Drops and recreates base tables under the `bronze` schema.
                          - These tables represent raw ingestion points for data pipelines and will typically be used as sources in 
                            subsequent ETL or ELT processes.
========================================================================================================================================
*/


USE `bronze`;

DROP TABLE IF EXISTS 	bronze.customer;
CREATE TABLE 		bronze.customer (
customer_id 		int(11),
first_name 		varchar(50) NOT NULL,
last_name 		varchar(50) NOT NULL,
birth_date 		date NOT NULL,
phone 			varchar(50) DEFAULT NULL,
address 		varchar(50) NOT NULL,
city 			varchar(50) NOT NULL,
state			char(2) NOT NULL,
points 			int(11) NOT NULL DEFAULT '0'
);



DROP TABLE IF EXISTS	bronze.mosh_products;
CREATE TABLE		bronze.mosh_products (
product_id		int(11),
name			varchar(50),
quantity_in_stock	int(11),
unit_price		decimal(4,2)
);



DROP TABLE IF EXISTS 	bronze.order_items;
CREATE TABLE 		bronze.order_items (
order_id 		int(11),
product_id 		int(11),
quantity		int(11),
unit_price		decimal(6,2)
 );



DROP TABLE IF EXISTS 	bronze.orders;
CREATE TABLE		bronze.orders (
order_id 		int(11),
customer_id 		int(11),
order_date 		date,
status 			tinyint(4),
comments 		varchar(50),
shipped_date 		date,
shipper_id 		smallint(6)
);



DROP TABLE IF EXISTS 	bronze.sql_store_order_item_notes;
CREATE TABLE 		bronze.sql_store_order_item_notes(
note_id 		INT NOT NULL,
order_Id		INT NOT NULL,
product_id		INT NOT NULL,
note`			VARCHAR(255) NOT NULL
);
 


DROP TABLE IF EXISTS 	bronze.sql_store_order_statuses;
CREATE TABLE		bronze.sql_store_order_statuses(
order_status_id 	tinyint(4),
name 			varchar(50)
);	



DROP TABLE IF EXISTS 	bronze.sql_store_shippers;
CREATE TABLE 		bronze.sql_store_shippers ( 
shipper_id 		smallint(6),
name 			varchar(50)
);




/*
------------------------------------------------------------
Script Name  : Bronze Layer Ingestion Notes

Purpose      : Documents the ingestion method for loading raw data 
               into the Bronze Layer of the data warehouse.

Description  : 
  - Data in the `bronze` schema is ingested from source CSV files 
    or source systems using the **MySQL Table Data Import Wizard**.
  - This process loads raw, unvalidated data into staging tables 
    for further transformation in the Silver and Gold layers.
  - No transformations, validations, or constraints are applied 
    at this stage — the focus is on capturing data "as-is".

Ingestion Tool: MySQL Workbench → Table Data Import Wizard

------------------------------------------------------------
*/
