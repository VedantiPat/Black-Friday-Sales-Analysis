
#create sales data table#
CREATE TABLE sales_data (
    transaction_id INTEGER PRIMARY KEY,
    product_id TEXT,
    gender TEXT,
    age TEXT,
    occupation INTEGER,
    city_category TEXT,
    marital_status INTEGER,
    product_category1 INTEGER,
    product_category2 INTEGER,
    product_category3 INTEGER,
    purchase INTEGER
    );
    
SELECT * FROM sales_data;    

#create category master table#
CREATE TABLE category_master (
	category_id INTEGER PRIMARY KEY,
    category_name TEXT
);

select * from category_master;

#find out how many unique product categories exist in sales table#
SELECT DISTINCT product_category1 from sales_data ORDER BY product_category1 DESC;

#given unique product categories, enter category id and created name into table#
INSERT INTO category_master (category_id, category_name) VALUES
(1, "Electronics"),
(2, "Clothing"),
(3, "Home Appliances"),
(4, "Furniture"),
(5, "Groceries"),
(6, "Toys"),
(7, "Books"),
(8, "Sports Equipment"),
(9, "Beauty Products"),
(10, "Health Products"),
(11, "Automotive"),
(12, "Jewelry"),
(13, "Footwear"),
(14, "Office Supplies"),
(15, "Pet Supplies"),
(16, "Garden Supplies"),
(17, "Music Instruments"),
(18, "Video Games");

SELECT * FROM category_master;

#find unique product ids from sales data table#
SELECT COUNT(DISTINCT product_id) from sales_data;

#create product master table#
CREATE TABLE product_master (
	product_id TEXT,
    product_name TEXT,
    category_id TEXT,
    unit_price INTEGER
);

select * from product_master;


#find unique product ids#
SELECT DISTINCT product_id from sales_data;

#find unit price for each product#
SELECT 
	product_id, 
	MIN(purchase) AS min_amount
FROM
	sales_data
GROUP BY
	product_id;

SELECT * FROM product_master ORDER BY category_id ASC;

SELECT * FROM sales_data ORDER BY product_id ASC;


#create inventory data table#
CREATE TABLE inventory_data (
	product_id TEXT,
    location TEXT,
    stock_quantity INTEGER
);

SELECT * FROM inventory_data;

#populating columns of inventory data#
CREATE TEMPORARY TABLE product_locations 
AS
SELECT product_id, 'A' AS Location FROM (
    SELECT DISTINCT product_id FROM sales_data
) AS product_ids
UNION
SELECT product_id, 'B' AS Location FROM (
    SELECT DISTINCT product_id FROM sales_data
) AS product_ids
UNION
SELECT product_id, 'C' AS Location FROM (
    SELECT DISTINCT product_id FROM sales_data
) AS product_ids;

SELECT * FROM product_locations ORDER BY product_id;

INSERT INTO inventory_data (product_id, location)
SELECT product_id, Location FROM product_locations ORDER BY product_id;

UPDATE inventory_data
SET stock_quantity = FLOOR(RAND() * 151);

SELECT * FROM inventory_data;


#cleaning the data from initial sales_data table#

ALTER TABLE sales_data
DROP COLUMN gender,
DROP COLUMN age,
DROP COLUMN occupation,
DROP COLUMN marital_status,
DROP COLUMN purchase;

ALTER TABLE sales_data
DROP COLUMN product_category2,
DROP COLUMN product_category3;

SELECT * FROM sales_data;

#creating quantity column for sales_data table#
ALTER TABLE sales_data
ADD COLUMN product_quantity INT;
UPDATE sales_data
SET product_quantity = FLOOR(RAND() * 15);

#updating category on sales data products according to product master#
UPDATE sales_data sd
JOIN product_master pm
ON sd.product_id = pm.product_id
SET sd.product_category1 = pm.category_id;

SELECT * FROM sales_data;
SELECT * FROM category_master;
SELECT * FROM product_master;
SELECT * FROM inventory_data;


#using sales data table to create a mock 3-year sales data in xlx, uploading that here#
CREATE TABLE three_years_sales_data (
    sales_year INT,
    transaction_id INTEGER,
    product_id TEXT,
    city_category TEXT,
    product_category1 INTEGER,
    product_quantity INTEGER,
    PRIMARY KEY (transaction_id)
    ); 

SELECT * FROM three_years_sales_data;


#transforming the data by creating a new combined data table matching all necessary data#

CREATE TABLE combined_sales_data AS 
SELECT * FROM three_years_sales_data;

#add product unit price#
ALTER TABLE combined_sales_data
ADD COLUMN product_unit_price INT;
UPDATE combined_sales_data csd
JOIN product_master pm
ON csd.product_id = pm.product_id
SET csd.product_unit_price = pm.unit_price;

#add transaction purchase amount#
ALTER TABLE combined_sales_data
ADD COLUMN total_purchase_amount INT;
UPDATE combined_sales_data
SET total_purchase_amount = product_quantity * product_unit_price;

#add product name next to product id#
ALTER TABLE combined_sales_data
ADD COLUMN product_name TEXT
AFTER product_id;
UPDATE combined_sales_data csd
JOIN product_master pm
ON csd.product_id = pm.product_id
SET csd.product_name = pm.product_name;

#add category name next to category id#
ALTER TABLE combined_sales_data
ADD COLUMN category_name TEXT
AFTER product_category1;
UPDATE combined_sales_data csd
JOIN category_master cm
ON csd.product_category1 = cm.category_id
SET csd.category_name = cm.category_name;

SELECT * FROM combined_sales_data;



#create an aggragated table, which by city, shows the total quantity of a product purchased for each product#
CREATE TABLE sales_summary AS
SELECT
	sales_year,
    city_category,
    product_id,
    product_name,
    SUM(product_quantity) AS total_quantity,
    SUM(total_purchase_amount) AS total_amount_dollars
FROM
    combined_sales_data
GROUP BY
    sales_year,
    city_category,
    product_id,
    product_name; 
    
SELECT * FROM sales_summary ORDER BY sales_year ASC, city_category ASC;

SELECT * FROM sales_summary WHERE total_quantity = 0;

#Create a query (to put into python) to plot the highest selling to lowest selling categories per city per year#
SELECT
	sales_year,
    city_category,
    product_category1,
    category_name,
    SUM(product_quantity) AS total_quantity
FROM
    combined_sales_data
GROUP BY
    sales_year,
    city_category,
    product_category1,
    category_name 
ORDER BY
    sales_year ASC, city_category ASC, total_quantity DESC;

#Create a query (to put into python) to select 5 random products and show their sales trends for 3 years#
WITH random_products AS (
    SELECT DISTINCT product_id, city_category
    FROM combined_sales_data
    ORDER BY RAND()
    LIMIT 5
)
SELECT
    c.sales_year,
    c.city_category,
    c.product_id,
    c.product_name,
    SUM(c.product_quantity) AS total_quantity,
    SUM(c.total_purchase_amount) AS total_amount_dollars
FROM
    combined_sales_data c
JOIN
    random_products rp
ON
    c.product_id = rp.product_id AND c.city_category = rp.city_category
GROUP BY
    c.sales_year,
    c.city_category,
    c.product_id,
    c.product_name
ORDER BY
    rp.product_id, c.sales_year;

    
#pivot table to show side by side yearly sales#
CREATE TABLE projected_values AS
SELECT 
    city_category,
    product_id,
    product_name,
    SUM(CASE WHEN sales_year = 2021 THEN total_quantity ELSE 0 END) AS quantity_2021,
    SUM(CASE WHEN sales_year = 2022 THEN total_quantity ELSE 0 END) AS quantity_2022,
    SUM(CASE WHEN sales_year = 2023 THEN total_quantity ELSE 0 END) AS quantity_2023
FROM 
    sales_summary
GROUP BY 
    city_category, 
    product_id, 
    product_name;

SELECT * FROM projected_values ORDER BY city_category ASC;
ALTER TABLE projected_values ADD COLUMN projected_quantity_2024 INT;

#Calculate percent change for each year#
CREATE TEMPORARY TABLE pct_changes AS
SELECT
    city_category,
    product_id,
    product_name,
    quantity_2021,
    quantity_2022,
    quantity_2023,
    ((IFNULL(quantity_2022, 0) - IFNULL(quantity_2021, 0)) / NULLIF(quantity_2021, 0)) * 100 AS pct_change_2021_2022,
    ((IFNULL(quantity_2023, 0) - IFNULL(quantity_2022, 0)) / NULLIF(quantity_2022, 0)) * 100 AS pct_change_2022_2023
FROM 
    projected_values;

SELECT * FROM pct_changes;


#Calculate the average annual growth rate (AAGR)#
CREATE TEMPORARY TABLE growth_rates AS
SELECT
    city_category,
    product_id,
    product_name,
    quantity_2021,
    quantity_2022,
    quantity_2023,
    (IFNULL(pct_change_2021_2022, 0) + IFNULL(pct_change_2022_2023, 0)) / 2 AS avg_annual_growth_rate
FROM 
    pct_changes;
    
SELECT * FROM growth_rates;

#Project the quantity for 2024 using the AAGR and add it to the projected_values table#
UPDATE projected_values pv
JOIN growth_rates gr ON pv.city_category = gr.city_category AND pv.product_id = gr.product_id
SET pv.projected_quantity_2024 = IFNULL(gr.quantity_2023, 0) * (1 + (IFNULL(gr.avg_annual_growth_rate, 0) / 100));

SELECT * FROM projected_values ORDER BY product_id ASC, city_category ASC;

#Add 2024 inventory values to the projected_values table#
ALTER TABLE projected_values ADD COLUMN inventory_2024 INT;

UPDATE projected_values pv
JOIN inventory_data inv
ON pv.city_category = inv.location AND pv.product_id = inv.product_id
SET pv.inventory_2024 = inv.stock_quantity;

#Create a column listing the adjustments to the stock based on the projected quantity - current inventory#
ALTER TABLE projected_values ADD COLUMN stock_adjustment INT;

ALTER TABLE projected_values MODIFY COLUMN stock_adjustment VARCHAR(20);

UPDATE projected_values
SET stock_adjustment = CASE
    WHEN projected_quantity_2024 - inventory_2024 > 0 THEN CONCAT('+', projected_quantity_2024 - inventory_2024)
    ELSE projected_quantity_2024 - inventory_2024
END;

SELECT * FROM projected_values ORDER BY product_id ASC, city_category ASC;







