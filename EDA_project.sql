/*=====================================================================
Project Name:
    EDA Project 
Script Purpose:
    This script is designed to perform an extensive 
    Exploratory Data Analysis (EDA) on the Gold Layer of the database. 

    It systematically explores the structure, metadata, and 
    key metrics of the data, providing insights into the distribution, 
    magnitude, and ranking of various dimensions and measures.

Usage:
    Execute this script in a SQL environment connected to the target database.
    Ensure that the Gold Layer tables (fact_sales, dim_customers, dim_products) 
    are accessible and contain relevant data.

=====================================================================
Database Explorations
=====================================================================
EDA step:   Structural & Metadata Discovery
Target:     System Catalog Views (INFORMATION_SCHEMA) and Gold Layer Fact/Dim Tables

Purpose:
    Map the entire database landscape by identifying all tables, columns, and views.
    Determine data volume (row counts) across the Gold layer to assess scale.
    Validate object existence and data types before proceeding to detailed profiling.
=====================================================================*/
-- Exploring all objects in the DB.
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Exploring all columns in the DB.
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

-- Exploring all views in the DB.
SELECT * FROM INFORMATION_SCHEMA.VIEWS;
 

-- Count total rows
SELECT COUNT(*) AS fact_total_rows FROM gold.fact_sales;
SELECT COUNT(*) AS dc_total_rows   FROM gold.dim_customers;
SELECT COUNT(*) AS dp_total_rows   FROM gold.dim_products;

/*=====================================================================
Dimensions Explorations
=====================================================================
EDA step:   Categorical Value Exploration
Target:     Gold Layer Views (dim_customers, dim_products)

Purpose: 
Identify unique values (cardinality) for all categorical dimensions.
This helps in understanding the scope of categories before grouping.
Recognizing how data might be grouped or segmented which is useful for later analysis.
=====================================================================*/
-- 1. Explore Geographic Distribution
-- Critical for: Regional analysis, filtering, and verifying data completeness.
SELECT DISTINCT 
country
FROM gold.dim_customers;

-- 2. Explore Product Hierarchy - category, subcategory, and product_name. 
-- Critical for: High-level product segmentation and revenue breakdown.
SELECT DISTINCT 
catagory,
subcatagory,
product_name
FROM gold.dim_products
ORDER BY 1,2,3;

-- 3. Explore Maintenance Status
-- Critical for: Filtering out inactive products or analyzing maintenance costs.
SELECT DISTINCT 
maintenance
FROM gold.dim_products;

-- 4. Explore Product Line Segments
-- Critical for: Analyzing performance across different product families.
SELECT DISTINCT 
product_line
FROM gold.dim_products;

/*=====================================================================
Dates Explorations
=====================================================================
Identifying the earliest and latest dates (boundries) to understannd 
the scope of data and the timespan. 
=====================================================================*/
-- First & last order dates 
-- Total days, months, & years of sales 
SELECT 
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS total_months_of_sales,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS total_years_of_sales,
DATEDIFF (DAY, MIN(order_date), MAX(order_date)) AS total_days_of_orders
FROM gold.fact_sales;

-- Finding the youngest and oldest customers.
-- Finding thier ages. 
SELECT 
MIN(birthdate) AS oldest_customer,
DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_customer_age,
MAX(birthdate) AS youngest_customer,
DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_customer_age
FROM gold.dim_customers
WHERE birthdate != '1900-01-01'; -- Filters out the fake default dates which is used to replace NULLs in birthdate.
-- OR WHERE birthdate > '1900-01-01';

/*=====================================================================
Measures Explorations
=====================================================================
Identifying and calculating the key matrics of the business i.e., big numbers.
Doing highest level of aggregation & lowest level of details.  
=====================================================================*/
-- Finding the total sales
SELECT 
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Finding how many items are sold
SELECT
SUM(quantity) AS total_items_sold
FROM gold.fact_sales;

-- Finding the AVG() selling price
SELECT 
    AVG(price) AS avg_selling_price
FROM gold.fact_sales;

-- Finding total number of orders
SELECT
    COUNT(order_number) AS orders,
    COUNT(DISTINCT order_number) AS total_orders -- removing same repeating orders to get correct value
FROM gold.fact_sales;

-- Finding total number of product 
SELECT
    COUNT(product_key) AS total_number_of_products,
    COUNT(DISTINCT product_key) AS total_products 
FROM gold.dim_products;

-- Finding total number of cutomers
SELECT
    COUNT(customer_key) AS total_number_of_customers,
    COUNT(DISTINCT customer_key) AS total_customers 
FROM gold.dim_customers;

-- Finding total number of customers that has placed an order
SELECT
    COUNT(customer_key) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_orders_placed
FROM gold.fact_sales;


-- Generating Report of the key values/ matrics for the business.
PRINT ' >>> Generating Key Measures & Values Report '
PRINT ' =========================================================='

SELECT 'Total Sales' AS Measures, FORMAT(SUM(sales_amount), 'N0') AS Value_of_Measures FROM gold.fact_sales

UNION ALL

SELECT 'Total Sold Items', FORMAT(SUM(quantity), 'N0') FROM gold.fact_sales

UNION ALL

SELECT 'Average selling price', FORMAT(AVG(price), 'N2') FROM gold.fact_sales

UNION ALL

SELECT 'Total Orders', FORMAT(COUNT(DISTINCT order_number), 'N0') FROM gold.fact_sales 

UNION ALL

SELECT 'Total Products', FORMAT(COUNT(DISTINCT product_key), 'N0') FROM gold.dim_products

UNION ALL

SELECT 'Total Customers', FORMAT(COUNT(DISTINCT customer_key), 'N0') FROM gold.dim_customers

UNION ALL

SELECT 'Total Orders Placed', FORMAT(COUNT(DISTINCT customer_key), 'N0') FROM gold.fact_sales;

PRINT ' =========================================================='
PRINT ' >>> End Of Report '

/*=====================================================================
Magnitude Analysis
=====================================================================
Comparing the measures values by catagory to understand the importance 
of different catagories.

[Measure] BY [Dimension];
    e.g., [Total Sales] BY [Country]
=====================================================================*/
-- Find total customers by countries
SELECT 
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country;

-- Find total customers by gender
SELECT 
    gender,
    COUNT(customer_key) AS customer_gender
FROM gold.dim_customers
GROUP BY gender; 

-- Find total products by category
SELECT 
    catagory,
    COUNT(product_key) AS Products_catagories
FROM gold.dim_products
GROUP BY catagory;

-- What is the average costs in each category?
SELECT 
    catagory,
    AVG(cost) AS avg_cost_per_cat
FROM gold.dim_products
GROUP BY catagory;

-- What is the total revenue generated for each category?
SELECT 
    dp.catagory,
    FORMAT(SUM(fs.sales_amount), 'N0') AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON dp.product_key = fs.product_key
GROUP BY dp.catagory;

-- Find total revenue generated by each customer
SELECT 
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc 
ON dc.customer_key = fs.customer_key
GROUP BY   
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY total_revenue DESC;

-- What is the distribution of sold items across countries?
SELECT 
    dc.country,
    FORMAT(SUM(fs.quantity), 'N0') AS items_sold
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fs.customer_key
GROUP BY country
ORDER BY items_sold;

-- What is the revenue share and revenue share percent by country? 
SELECT 
    dc.country,
    FORMAT(SUM(fs.sales_amount), 'N0') AS revenue_share,
    -- Calculating the percentage: (Country Revenue / Total Revenue) * 100
    FORMAT((SUM(fs.sales_amount) * 100/ SUM(SUM(fs.sales_amount)) OVER ()), 'N2') AS revenue_share_percent
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fs.customer_key
GROUP BY country
ORDER BY revenue_share;

-- Finding revenue, cost, and profit by catagory and sub-catagory. 
SELECT 
    dp.catagory,
    dp.subcatagory,
    SUM(fs.sales_amount) AS total_revenue,
    SUM(dp.cost * fs.quantity) AS total_cost,
    SUM(fs.sales_amount - (dp.cost * fs.quantity)) AS total_profit
FROM gold.fact_sales fs
JOIN gold.dim_products dp 
ON   dp.product_key = fs.product_key
GROUP BY dp.catagory,  
         dp.subcatagory
ORDER BY total_profit DESC;

-- Finding reveune distribution by month.
SELECT 
    YEAR(fs.order_date) AS sale_year,
    MONTH(fs.order_date) AS sale_month,
    SUM(fs.sales_amount) AS monthly_revenue,
    COUNT(DISTINCT fs.customer_key) AS active_customers
FROM gold.fact_sales fs
GROUP BY 
    YEAR(fs.order_date), 
    MONTH(fs.order_date)
ORDER BY sale_year, sale_month;
/*=====================================================================
Ranking Analysis
=====================================================================
Order the values of dimensions by measure.
TOP N performers | Bottom N performers

Rank [Dimension] by [Measure] 
=====================================================================*/
-- Which 10 products genrates the highest revenue?
SELECT TOP 10
    dp.product_name,
    SUM(fs.sales_amount)AS highest_revenue_products
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON dp.product_key = fs.product_key
GROUP BY dp.product_name
ORDER BY highest_revenue_products DESC;

-- top 5 via window funtions
SELECT 
    *
FROM(
    SELECT 
        dp.product_name,
        SUM(fs.sales_amount)AS highest_revenue_products,
        ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS product_ranks
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp
    ON dp.product_key = fs.product_key
    GROUP BY dp.product_name
)t 
WHERE product_ranks <= 5;

-- What are the 5 worst performaing products in terms of sales?
SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS highest_revenue_products
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON dp.product_key = fs.product_key
GROUP BY dp.product_name
ORDER BY highest_revenue_products;

-- Finding the top-5 customers who generated highest revenue 
SELECT TOP 5
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount)AS Revenue_top_5_customers
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fs.customer_key
GROUP BY 
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY Revenue_top_5_customers DESC;

-- Finding the top-3 customers who genrated the lowest revenue
SELECT TOP 3
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount)AS revenue_top_3_customers
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fs.customer_key
GROUP BY 
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY revenue_top_3_customers;

-- Finding the top-3 customers who placed the lowest number of orders.
SELECT TOP 3
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    COUNT(DISTINCT order_number)AS lowest_order
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fs.customer_key
GROUP BY 
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY lowest_order;
/*=====================================================================*/