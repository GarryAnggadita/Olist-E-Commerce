-- Cleaning Data Set--

	SELECT COUNT(payment_type) AS payment_method , AVG(payment_value) AS amount_of_payment, payment_type
	FROM olist_order_payments_dataset
	GROUP BY payment_type;

	-- Delete undefined--
	DELETE 
	FROM olist_order_payments_dataset
	WHERE payment_type = 'not_defined';

	-- Rename category table, but first set SQL_safe_updates = 0 , then change again to 1--
	SET SQL_SAFE_UPDATES = 0 ;
	SET SQL_SAFE_UPDATES = 1 ;

	ALTER TABLE product_category_name_translation
	RENAME COLUMN ï»¿product_category_name
	TO product_category_name ;
    
    -- Change telephone category name--
    UPDATE product_category_name_translation
	SET product_category_name_english = 'telephone'
	WHERE product_category_name_english = 'telephony' ;
    
-- Create Index to faster query--

ALTER TABLE olist.product_category_name_translation
ADD INDEX idx_product_category_english (product_category_name_english(20));

ALTER TABLE olist.olist_customers_dataset
ADD INDEX idx_customer_id (customer_id(10));

ALTER TABLE olist.olist_orders_dataset
ADD INDEX idx_order_id (order_id(10));

ALTER TABLE olist.olist_order_payments_dataset
ADD INDEX idx_order_id_2 (order_id(10));

ALTER TABLE olist.olist_products_dataset
ADD INDEX idx_product_id (product_id(10));

ALTER TABLE olist.olist_orders_dataset
ADD INDEX idx_delivery_status (order_status(2));

-- Most Popular product in Olist per state--

SELECT COUNT(OI.order_id) AS amount_of_purchase , PP.product_category_name_english ,
       C.customer_state AS state , year(order_delivered_customer_date ) AS year
FROM olist_customers_dataset C
   JOIN  
     (SELECT a.order_id,customer_id , order_status ,product_id,order_delivered_customer_date
     FROM olist.olist_orders_dataset a 
     JOIN olist.olist_order_items_dataset b
     ON a.order_id = b.order_id
     WHERE order_status = 'delivered') AS OI
   ON C.customer_id = OI.customer_id 
   JOIN 
     (SELECT product_id, c.product_category_name , product_category_name_english
      FROM olist.olist_products_dataset c 
      JOIN olist.product_category_name_translation d
      ON c.product_category_name = d.product_category_name) AS PP
	ON OI.product_id = PP.product_id
	JOIN olist.olist_order_payments_dataset OP
    ON OI.order_id = OP.order_id
GROUP BY PP.product_category_name_english, C.customer_state, year
ORDER BY C.customer_state,year,amount_of_purchase DESC ;

-- Payment type per product category --
SELECT PP.product_category_name_english,COUNT(OI.order_id) AS amount_of_purchase,SUM(payment_value)
	   AS Sum_order_value,payment_type
FROM olist_customers_dataset C
   JOIN  
     (SELECT a.order_id,customer_id , order_status ,product_id,order_delivered_customer_date
     FROM olist.olist_orders_dataset a
     JOIN olist.olist_order_items_dataset b
     ON a.order_id = b.order_id
     WHERE order_status = 'delivered') AS OI
   ON C.customer_id = OI.customer_id 
   JOIN 
     (SELECT product_id, c.product_category_name , product_category_name_english
      FROM olist.olist_products_dataset c 
      JOIN olist.product_category_name_translation d
      ON c.product_category_name = d.product_category_name) AS PP
	ON OI.product_id = PP.product_id
	JOIN olist.olist_order_payments_dataset OP
    ON OI.order_id = OP.order_id
GROUP BY PP.product_category_name_english,payment_type;