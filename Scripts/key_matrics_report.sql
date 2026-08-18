/*================================================================================
Script Description: 
    Generating Report of the key values/metrics for the business.

Purpose: 
    Provides a comprehensive summary of key business measures including
    total sales, items sold, pricing metrics, orders, products, and customers.

Database: 
    gold schema
================================================================================*/ 

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

/*================================================================================*/ 