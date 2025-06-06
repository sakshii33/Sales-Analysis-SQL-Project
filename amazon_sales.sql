-- 1. Create Table
USE iso;
CREATE TABLE amazon_sales (
    Region VARCHAR(100),
    Country VARCHAR(100),
    Item_Type VARCHAR(100),
    Sales_Channel VARCHAR(50),
    Order_Priority CHAR(1),
    Order_Date DATE,
    Order_ID BIGINT PRIMARY KEY,
    Ship_Date DATE,
    Units_Sold INT,
    Unit_Price DECIMAL(10,2),
    Unit_Cost DECIMAL(10,2),
    Total_Revenue DECIMAL(15,2),
    Total_Cost DECIMAL(15,2),
    Total_Profit DECIMAL(15,2)
);
-- load data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AmazonSalesData.csv'
INTO TABLE amazon_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Region, Country, Item_Type, Sales_Channel, Order_Priority, @Order_Date, Order_ID, @Ship_Date, Units_Sold, Unit_Price, Unit_Cost, Total_Revenue, Total_Cost, Total_Profit)
SET
  Order_Date = STR_TO_DATE(@Order_Date, '%m/%d/%Y'),
  Ship_Date = STR_TO_DATE(@Ship_Date, '%m/%d/%Y');

--  Basic SELECT
SELECT * FROM amazon_sales;


--  (Mock Second Table)
--  Simulated supporting table for JOINS
CREATE TABLE region_details (
    Region VARCHAR(100) PRIMARY KEY,
    Region_Manager VARCHAR(100)
);

-- Insert some sample values
INSERT INTO region_details (Region, Region_Manager) VALUES ('Australia and Oceania', 'Manager_1');
INSERT INTO region_details (Region, Region_Manager) VALUES ('Central America and the Caribbean', 'Manager_2');
INSERT INTO region_details (Region, Region_Manager) VALUES ('Europe', 'Manager_3');
INSERT INTO region_details (Region, Region_Manager) VALUES ('Sub-Saharan Africa', 'Manager_4');
INSERT INTO region_details (Region, Region_Manager) VALUES ('Asia', 'Manager_5');
INSERT INTO region_details (Region, Region_Manager) VALUES ('Middle East and North Africa', 'Manager_6');
INSERT INTO region_details (Region, Region_Manager) VALUES ('North America', 'Manager_7');

--  Total Profit by Region
SELECT Region, SUM(Total_Profit) AS Total_Profit
FROM amazon_sales
GROUP BY Region
ORDER BY Total_Profit DESC;

--  High priority orders with large revenue
SELECT Order_ID, Country, Order_Priority, Total_Revenue
FROM amazon_sales
WHERE Order_Priority = 'H' AND Total_Revenue > 1000000
ORDER BY Total_Revenue DESC;

--  Average Unit Price by Product Category
SELECT Item_Type, AVG(Unit_Price) AS Avg_Price
FROM amazon_sales
GROUP BY Item_Type;

-- Subquery: Countries with above-average total revenue
SELECT Country, SUM(Total_Revenue) AS Country_Revenue
FROM amazon_sales
GROUP BY Country
HAVING SUM(Total_Revenue) > (
    SELECT AVG(Total_Revenue) FROM amazon_sales
);

-- JOIN: Sales with region manager details
SELECT a.Region, a.Country, r.Region_Manager, a.Total_Profit
FROM amazon_sales a
LEFT JOIN region_details r ON a.Region = r.Region;

-- View for Top Performing Products
CREATE VIEW top_products AS
SELECT Item_Type, SUM(Total_Profit) AS Total_Profit
FROM amazon_sales
GROUP BY Item_Type
ORDER BY Total_Profit DESC
LIMIT 5;

-- Create index on frequently queried columns
CREATE INDEX idx_order_date ON amazon_sales(Order_Date);
CREATE INDEX idx_country ON amazon_sales(Country);

--  Querying the created view
SELECT * FROM top_products;
