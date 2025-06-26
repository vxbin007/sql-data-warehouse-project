/*
=================================================================================================
DDL Script	 	: Create Gold Views
Purpose:		: This script creates views for the Gold layer in the data warehouse. 

			 The Gold layer represents the final dimension and fact tables (Star Schema)
			 Each view performs transformations and combines data from the Silver layer 
			 to produce a clean, enriched, and business-ready dataset.

Usage			: These views can be queried directly for analytics and reporting.
=================================================================================================
*/




DROP VIEW IF EXISTS 	gold.dim_customers;
CREATE VIEW		gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
	customer_id,
	first_name, 	
	last_name ,	
	birth_date, 	
	phone ,		
	address, 	
	city ,		
	state,		
	points		
FROM silver.customer;



DROP VIEW IF EXISTS	gold.dim_products;
CREATE VIEW		gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
	product_id,
	product_name,
	product_key as product_number,
	product_cat,
	quantity_in_stock as quantity,
	unit_price
FROM silver.products



DROP VIEW IF EXISTS	gold.fact_orders;
CREATE VIEW		gold.fact_orders  AS 
SELECT 
	o.order_id,
	-- o.customer_id,
	c.customer_key,
	o.order_date,
	o.shipped_date,
	-- o.order_status,
	-- os.order_status_id,
	os. status_name,
	-- o.shipper_id,
	s.shipper_name,
	o.comments
FROM		silver.orders o
LEFT JOIN	gold.dim_customers c
ON		o.customer_id = c.customer_id
LEFT JOIN 	silver.order_statuses os
ON		o.order_status = os.order_status_id
LEFT JOIN 	shippers s
ON		o.shipper_id = s.shipper_id;



DROP VIEW IF EXISTS	gold.fact_order_items;
CREATE VIEW		gold.fact_order_items  AS 
SELECT 
	oi.order_id,
	-- oi.product_id,
 	p.product_key,
	oi.quantity,
	oi.unit_price,
	oi.quantity * 
	oi.unit_price as total_sales
FROM		silver.order_items oi
LEFT JOIN	gold.dim_products p
ON		oi.product_id = p.product_id



DROP VIEW IF EXISTS	gold.vw_order_detail_flat;
CREATE VIEW		gold.vw_order_detail_flat  AS 
SELECT 
	o.order_id,
	o.customer_key,
	o.order_date,
	o.shipped_date,
	o.status_name,
	o.shipper_name,
  	p.product_name,
	oi.quantity,
  	oi.unit_price,
  	oi.total_sales,
	o.comments
FROM		gold.fact_orders o
LEFT JOIN 	gold.fact_order_items oi
ON		o.order_id = oi.order_id
LEFT JOIN  	gold.dim_products p
ON		oi.product_key = p.product_key
