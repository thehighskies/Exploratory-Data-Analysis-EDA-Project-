# SQL EDA Project - Exploratory Data Analysis

## Overview
This project performs an extensive **Exploratory Data Analysis (EDA)** on the Gold Layer of a data warehouse. It systematically explores the structure, metadata, and key metrics of the data, providing insights into distribution, magnitude, and ranking of various dimensions and measures.

## Project Structure
```
SQL_EDA_Project/
├── EDA_project.sql    # Main SQL script containing all EDA queries
README.md              # Project documentation
```

## Database Architecture
The analysis operates on a star schema with:
- **Fact Table**: `gold.fact_sales` - Contains transactional sales data
- **Dimension Tables**: 
  - `gold.dim_customers` - Customer information and demographics
  - `gold.dim_products` - Product hierarchy and attributes

## EDA Components

### 1. **Structural & Metadata Discovery**
Explores the database landscape by identifying all tables, columns, and views using system catalog views (`INFORMATION_SCHEMA`).
- Database objects and their metadata
- Total row counts across Gold layer tables
- Data volume assessment and scale

### 2. **Dimensions Exploration**
Analyzes categorical values and their cardinality across dimensions:
- **Geographic Distribution**: Country-level customer segmentation
- **Product Hierarchy**: Category, subcategory, and product names
- **Maintenance Status**: Product maintenance classifications
- **Product Lines**: Different product family segments

### 3. **Dates Exploration**
Identifies temporal boundaries and data span:
- Earliest and latest order dates
- Total days, months, and years of sales data
- Customer age demographics (oldest and youngest customers)

### 4. **Measures Exploration**
Calculates key business metrics at various aggregation levels:
- Total sales revenue
- Total items sold
- Average selling price
- Total orders and distinct orders
- Product and customer counts
- **Key Measures Report**: Comprehensive summary of all critical business metrics

### 5. **Magnitude Analysis**
Compares measures by dimensions to understand relative importance:
- Total customers by country and gender
- Product distribution by category
- Average costs per category
- Revenue generation by:
  - Product category and subcategory
  - Individual customers
  - Geographic regions
  - Monthly time periods
- Revenue share and percentage distribution by country
- Profitability analysis (revenue, cost, and profit by category)

### 6. **Ranking Analysis**
Identifies top and bottom performers:
- **Top 10**: Highest revenue-generating products
- **Top 5**: Best and worst performing products by sales
- **Customer Rankings**: 
  - Top 5 customers by revenue
  - Bottom 3 customers by revenue
  - Customers with lowest order counts

## Key Tables and Fields

### fact_sales
- `order_number`: Unique order identifier
- `order_date`: Date of transaction
- `sales_amount`: Revenue amount
- `quantity`: Number of items sold
- `price`: Selling price
- `product_key`: Foreign key to dim_products
- `customer_key`: Foreign key to dim_customers

### dim_customers
- `customer_key`: Primary key
- `first_name`, `last_name`: Customer name
- `country`: Geographic location
- `gender`: Customer gender
- `birthdate`: Date of birth for age calculations

### dim_products
- `product_key`: Primary key
- `product_name`: Product description
- `category`: High-level product category
- `subcategory`: Sub-level classification
- `product_line`: Product family grouping
- `cost`: Product cost
- `maintenance`: Maintenance status indicator

## Usage

1. **Prerequisites**:
   - SQL Server or compatible SQL database
   - Access to the Gold Layer database with fact_sales, dim_customers, and dim_products tables

2. **Execution**:
   ```sql
   -- Execute the script in your SQL environment
   -- Ensure proper database and schema context (gold schema)
   EXECUTE EDA_project.sql
   ```

3. **Interpreting Results**:
   - Run queries sequentially or in sections to explore different aspects
   - Check the PRINT statements for report markers
   - Adjust filtering conditions (e.g., WHERE clauses) as needed for your data

## Key Insights Generated

The analysis provides answers to:
- What is the scale and scope of the data?
- What are the geographic and demographic distributions?
- What drives revenue and profitability?
- Which products, customers, and categories are top performers?
- How does revenue distribution look across dimensions?
- What are the temporal trends in sales?

## Data Quality Notes

- Default birthdate value `1900-01-01` is used as a placeholder for NULL values in the `dim_customers.birthdate` field
- Queries include appropriate filtering to handle these default values
- Uses `COUNT(DISTINCT)` to ensure accurate counting of unique entities

## Technologies Used
- **SQL Server** (T-SQL dialect)
- System catalog views (INFORMATION_SCHEMA)
- Window functions (ROW_NUMBER, SUM OVER)
- Common aggregations (GROUP BY, HAVING)
- Date functions (DATEDIFF, YEAR, MONTH, GETDATE)

## Author
Khan

## Version
1.0 - Initial comprehensive EDA analysis

---
*Last Updated: 2026*
