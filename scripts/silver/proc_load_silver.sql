/*
===============================================================================================
Stored Procedure	: silver.load_silver                                                       
Purpose			: This stored procedure handles the ETL process that loads cleaned and     
			  transformed data from the Bronze layer into the Silver layer tables.     
																							   
Description  :                                                                                 
    - Clears (truncates) data in Silver tables.                                                
    - Loads updated and cleaned data from Bronze tables.                                       
    - Applies some transformations like trimming names, formatting phone numbers,              
      generating product keys, and handling nulls or empty values.                             
																							   
How to Run:                                                                                    
    CALL silver.load_silver();                                                                 
===============================================================================================
*/
	
	

DROP PROCEDURE IF EXISTS silver.load_silver;
DELIMITER $$
CREATE PROCEDURE silver.load_silver()
BEGIN


  
	TRUNCATE TABLE	silver.customer;
	INSERT INTO	silver.customer (
		customer_id,
		first_name,
		last_name,
		birth_date,
		phone,
		address,
		city,
		state,
		points
	)
	SELECT 
		customer_id, 
		TRIM(first_name) as first_name, 	
		TRIM(last_name) as last_name,	
		birth_date, 	
		CASE 
		WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) >= 10 THEN
			CONCAT(
				'1-',
				SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ''), 
						  LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) - 9, 3), '-',
				SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ''), 
						  LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) - 6, 3), '-',
				SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ''), 
						  LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) - 3, 4),
				CASE 
					WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) > 10 THEN
						CONCAT(' ext.', 
							   LEFT(REGEXP_REPLACE(phone, '[^0-9]', ''), 
							   LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) - 10))
					ELSE ''
				END
			)
		ELSE NULL
		END AS phone,
		address,	
		city, 		
		state,		
		points
		-- flag
	FROM (
		SELECT *,
		ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY first_name) as flag
		FROM bronze.customer
		WHERE customer_id IS NOT NULL
	)t WHERE flag = 1;  




	TRUNCATE TABLE	silver.order_items;
	INSERT INTO	silver.order_items (
		order_id,
		product_id,
		quantity,
		unit_price
	)
	SELECT
		order_id,
		product_id,
		quantity,
		unit_price
	FROM bronze.order_items;




	TRUNCATE TABLE	silver.order_notes;
	INSERT INTO	silver.order_notes(
		note_id,
		order_id,
		product_id,
		note
	)
	SELECT * FROM bronze.sql_store_order_item_notes;





	TRUNCATE TABLE	silver.order_statuses;
	INSERT INTO	silver.order_statuses(
		order_status_id,
		status_name	
	)
	SELECT * FROM bronze.sql_store_order_statuses;




	TRUNCATE TABLE	silver.orders;
	INSERT INTO 	silver.orders(
		order_id,
		customer_id,
		order_date,
		shipped_date,
		order_status,
		shipper_id,
		comments
	)

	SELECT
		order_id,
		customer_id,
		order_date,
		shipped_date,
		status as order_status,
		shipper_id,
		CASE WHEN comments = '' THEN 'No Comment'
			   ELSE comments
		END comments
	FROM bronze.orders;




	TRUNCATE TABLE  silver.products;
	INSERT INTO 	silver.products (
	 	product_id,
	 	product_name,
	 	product_key,
	 	product_cat,
	 	quantity_in_stock,
	 	unit_price
	 )
	 SELECT 
		product_id,
		
		-- capitalized both first and second word
		CONCAT(
		UPPER(LEFT(SUBSTRING_INDEX(trim(name), ' ', 1), 1)),
		LOWER(SUBSTRING(SUBSTRING_INDEX(trim(name), ' ', 1), 2)),
		' ',
		UPPER(LEFT(SUBSTRING_INDEX(trim(name), ' ', -1), 1)),
		LOWER(SUBSTRING(SUBSTRING_INDEX(trim(name), ' ', -1), 2))
		) as product_name,
		
		
		 -- combined product_id + second word of product_name
		CONCAT(
		LPAD(product_id, 5, '0'), 
			UPPER(LEFT(SUBSTRING_INDEX(trim(name), ' ', -1), 1)),
			LOWER(SUBSTRING(SUBSTRING_INDEX(trim(name), ' ', -1), 2)) 
		 ) AS product_key,
		 
		 
		  -- second word of product_name
		 CONCAT(
		 UPPER(LEFT(SUBSTRING_INDEX(trim(name), ' ', -1), 1)),
		 LOWER(SUBSTRING(SUBSTRING_INDEX(trim(name), ' ', -1), 2)) 
		 )as product_cat,
		
		IFNULL(quantity_in_stock, 0) as quantity_in_stock,
		
		IFNULL(unit_price, 0) as unit_price 
	   
	 FROM (
	 SELECT *,
  		ROW_NUMBER () OVER (PARTITION BY product_id ORDER BY name) as flag
  		FROM bronze.mosh_products
  		WHERE product_id IS NOT NULL
	 )t WHERE flag = 1;


	TRUNCATE TABLE 	silver.shippers;
	INSERT INTO 	  silver.shippers( 
		shipper_id,
		shipper_name
	)
	SELECT * FROM bronze.sql_store_shippers;
    
END$$
DELIMITER ;
