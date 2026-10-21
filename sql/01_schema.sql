/* SUPPLY CHAIN PERFORMANCE & RISK ANALYTICS

Purpose : Create the project database, Create the cleaned analytical table, Import the cleaned CSV into MySQL
Analytical grain : One row = one order item
Source : DataCo Smart Supply Chain Dataset
Cleaned dataset : 180,519 rows and 55 columns
*/


-- 1. CREATE DATABASE 

CREATE DATABASE IF NOT EXISTS supply_chain_analytics ;
USE supply_chain_analytics ;

-- 2. CREATE ANALYTICAL TABLE 

DROP TABLE IF EXISTS supply_chain_orders ; 

CREATE TABLE supply_chain_orders (
	`Type` VARCHAR(50), 
    `Days for shipping (real)` INT, 
	`Days for shipment (scheduled)` INT, 
    `Benefit per order` DECIMAL(28, 10), 
    `Sales per customer` DECIMAL(28, 10), 
	`Delivery Status` VARCHAR(50), 
    `Late_delivery_risk` TINYINT, 
	`Category Id` INT, 
	`Category Name` VARCHAR(150), 
	`Customer City` VARCHAR(150), 
	`Customer Country` VARCHAR(100), 
	`Customer Segment` VARCHAR(100), 
	`Customer State` VARCHAR(150), 
	`Customer Zipcode` INT, 
	`Department Id` INT, 
	`Department Name` VARCHAR(150), 
	`Latitude` DECIMAL(12, 8), 
	`Longitude` DECIMAL(12, 8), 
	`Market` VARCHAR(100), 
	`Order City` VARCHAR(150), 
	`Order Country` VARCHAR(100), 
	`Order Customer Id` INT, 
	`order date (DateOrders)` VARCHAR(50), 
	`Order Id` INT, 
	`Order Item Discount` DECIMAL(28, 10), 
	`Order Item Discount Rate` DECIMAL(28, 10), 
	`Order Item Id` INT, 
	`Order Item Product Price` DECIMAL(28, 10), 
	`Order Item Profit Ratio` DECIMAL(28, 10), 
	`Order Item Quantity` INT, 
	`Sales` DECIMAL(28, 10), 
	`Order Item Total` DECIMAL(28, 10), 
	`Order Profit Per Order` DECIMAL(28, 10), 
	`Order Region` VARCHAR(150), 
	`Order State` VARCHAR(150), 
	`Order Status` VARCHAR(100), 
	`Product Card Id` INT, 
	`Product Name` VARCHAR(250), 
	`Product Price` DECIMAL(28, 10), 
	`shipping date (DateOrders)` VARCHAR(50), 
	`Shipping Mode` VARCHAR(100), 
	
    -- DERIVED DATE FEATURES 
    `Order Year` INT, 
	`Order Month` INT, 	
    `Order Month Name` VARCHAR(20), 
	`Order Quarter` VARCHAR(10), 
	`Order Day` INT, 
	`Order Day of Week` VARCHAR(20), 
	`Order Date Only` VARCHAR(50), 
	
    -- DERIVED SHIPPING PERFORMANCE FEATURES 
    `Shipping Duration Variance` INT, 
	`Shipping Performance` VARCHAR(50), 
	`Delayed Shipment Flag` TINYINT, 
	`On Schedule Flag` TINYINT, 
	`Faster Shipment Flag` TINYINT, 
	`Delayed Sales` DECIMAL(28, 10), 
	`Delayed Profit` DECIMAL(28, 10)
); 

-- 4. VERIFY TABLE STRUCTURE 

DESCRIBE supply_chain_orders ; 

-- 5. CSV IMPORT 

SHOW VARIABLES LIKE 'local_infile' ; 
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 
'C:/Users/Admin/Downloads/Portfolio Projects/Supply Chain Performance and Risk Analytics/data/processed/cleaned_SupplyChainDataset.csv'

INTO TABLE supply_chain_orders 
CHARACTER SET latin1 
FIELDS 
    TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    ESCAPED BY '"' 
LINES 
    TERMINATED BY '\n' 
IGNORE 1 ROWS ; 

ALTER TABLE supply_chain_orders 
MODIFY COLUMN `order date (DateOrders)` DATETIME, 
MODIFY COLUMN `shipping date (DateOrders)` DATETIME, 
MODIFY COLUMN `Order Date Only` DATE ; 

-- 6. BASIC POST-IMPORT CHECK 
SELECT COUNT(*) AS total_records FROM supply_chain_orders ; 

-- 7. DATA PREVIEW 
SELECT * FROM supply_chain_orders 
LIMIT 10 ; 
