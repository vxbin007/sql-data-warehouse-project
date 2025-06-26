/*
==============================================================================
DDL Script   : Create Silver Tables
Purpose      : Defines structured staging tables in the 'silver' schema 
               as part of the Silver Layer in the data pipeline.

Description  : 
  - Drops and recreates cleaned and enriched tables based on raw data 
    from the Bronze Layer.
  - Adds standardized fields and formats, including audit column 
    `createDateDwh` for data lineage.
  - Supports downstream analytics and transformations in the Gold Layer.
==============================================================================
*/


USE silver;

DROP TABLE IF EXISTS 	silver.customer;
CREATE TABLE 		silver.customer (
	customer_id 	int(11),
	first_name 	varchar(50) NOT NULL,
	last_name 	varchar(50) NOT NULL,
	birth_date 	date NOT NULL,
	phone 		varchar(50) DEFAULT NULL,
	address 	varchar(50) NOT NULL,
	city 		varchar(50) NOT NULL,
	state		char(2) NOT NULL,
	points 		int(11) NOT NULL DEFAULT '0',
	createDateDwh 	DATETIME DEFAULT CURRENT_TIMESTAMP
);



DROP TABLE IF EXISTS	  silver.products;
CREATE TABLE			      silver.products (
  `product_id`		 	    int DEFAULT NULL,
  `product_name`	 	    varchar(50) DEFAULT NULL,
  `product_key` 		    varchar(50) DEFAULT NULL,
  `product_cat` 		    varchar(50) DEFAULT NULL,
  `quantity_in_stock` 			int DEFAULT NULL,
  `unit_price` 			    decimal(4,2) DEFAULT NULL,
  `createDateDwh`		    datetime DEFAULT CURRENT_TIMESTAMP



DROP TABLE IF EXISTS 	silver.order_items;
CREATE TABLE 			    silver.order_items (
	order_id 			      int(11),
	product_id 			    int(11),
	quantity			      int(11),
	unit_price			    decimal(6,2),
  createDateDwh 	    DATETIME DEFAULT CURRENT_TIMESTAMP
 );



DROP TABLE IF EXISTS 	silver.orders;
CREATE TABLE		    	silver.orders (
	order_id 			      int(11),
	customer_id 		    int(11),
	order_date 			    date,
	shipped_date 		    date,
	order_status		    tinyint(4),
	shipper_id 			    smallint(6),
	comments 			      varchar(50),
  createDateDwh 	    DATETIME DEFAULT CURRENT_TIMESTAMP
);



DROP TABLE IF EXISTS 	silver.order_notes;
CREATE TABLE 			    silver.order_notes(
	note_id 		  	    INT NOT NULL,
	order_id 			      INT NOT NULL,
	product_id	  	    INT NOT NULL,
	note				        VARCHAR(255) NOT NULL,
  createDateDwh 	    DATETIME DEFAULT CURRENT_TIMESTAMP
);



DROP TABLE IF EXISTS 	silver.order_statuses;
CREATE TABLE			    silver.order_statuses(
	order_status_id 	  tinyint(4),
	status_name			    varchar(50),
  createDateDwh 		  DATETIME DEFAULT CURRENT_TIMESTAMP
);	



DROP TABLE IF EXISTS 	silver.shippers;
CREATE TABLE 			    silver.shippers ( 
	shipper_id 			    smallint(6),
	name 				        varchar(50),
  createDateDwh 		  DATETIME DEFAULT CURRENT_TIMESTAMP
);
