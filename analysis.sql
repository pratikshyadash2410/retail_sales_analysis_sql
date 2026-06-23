/*----
Retail Sales Analysis Using PostgreSQL

Objective:
Analyze retail sales data to uncover sales trends,
customer behavior, category performance and
revenue driving insights.

Skills Demonstrated:
   - Data Cleaning
   - Data Exploration
   - Aggregations
   - Grouping & Sorting
   - Date & Time Analysis
   - Customer Analytics
   - Business Intelligence
   
----*/

-- Create Database
CREATE DATABASE RETAIL_SALES_ANALYSIS;
-- Create Table
CREATE TABLE RETAIL_SALES
	(
		transactions_id INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT, 
		gender VARCHAR(10),
		age INT,	
		category VARCHAR(15),
		quantity INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
	);
 
-- Preview dataset.
SELECT * FROM RETAIL_SALES
LIMIT 10;

-- Total records in the dataset.
SELECT COUNT(*) FROM RETAIL_SALES;
	
-- DATA CLEANING: Identify and remove records with missing values.

SELECT * FROM RETAIL_SALES
	WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

DELETE FROM RETAIL_SALES
	WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

-- DATA EXPLORATION

-- Total transactions recorded.
SELECT COUNT(*) AS total_transactions
FROM RETAIL_SALES;

-- Unique customers.
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM RETAIL_SALES;

-- SALES ANALYSIS

-- Category wise sales revenue.
SELECT category,
       SUM(total_sale) AS total_sales
FROM RETAIL_SALES
GROUP BY category
ORDER BY total_sales DESC;

-- Top performing product categories.	
SELECT category,
       SUM(total_sale) AS total_sales
FROM RETAIL_SALES
GROUP BY category
ORDER BY total_sales DESC
LIMIT 2;

-- Monthly sales trends.
SELECT 
	 TO_CHAR(sale_date,'YYYY-MM') AS month,
     ROUND(SUM(total_sale)::numeric, 2) AS total_sales
FROM RETAIL_SALES
GROUP BY month
ORDER BY month;

-- Best performing month in each year.
SELECT
    year,
    month,
    total_sales
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        TO_CHAR(sale_date, 'Month') AS month,
        ROUND(SUM(total_sale)::numeric, 2) AS total_sales,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY SUM(total_sale) DESC
        ) AS sales_rank
    FROM RETAIL_SALES
    GROUP BY
        EXTRACT(YEAR FROM sale_date),
        TO_CHAR(sale_date, 'Month')
) ranked_months
WHERE sales_rank = 1;

-- Average transaction value by category.
SELECT category,
       ROUND(AVG(total_sale)::numeric,2) AS avg_transaction_value
FROM RETAIL_SALES
GROUP BY category
ORDER BY avg_transaction_value DESC;

-- Best selling categories by quantity sold.
SELECT category,
       SUM(quantity) AS units_sold
FROM RETAIL_SALES
GROUP BY category
ORDER BY units_sold DESC;

-- CUSTOMER ANALYSIS

-- Sales performance by gender.
SELECT gender,
       ROUND(SUM(total_sale)::numeric, 2) AS total_sales
FROM RETAIL_SALES
GROUP BY gender;

-- Revenue contribution by age group.
SELECT
    CASE
        WHEN age < 25 THEN '18-24'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        ELSE '45+'
    END AS age_group,
    SUM(total_sale) AS revenue
FROM RETAIL_SALES
GROUP BY age_group
ORDER BY revenue DESC;

-- Top customers by spending.
SELECT customer_id,
       SUM(total_sale) AS total_spent
FROM RETAIL_SALES
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- TIME BASED ANALYSIS

-- Sales performance across different time periods.
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS time_period,
    ROUND(SUM(total_sale)::numeric, 2) AS revenue
FROM RETAIL_SALES
GROUP BY time_period
ORDER BY revenue DESC;

-- Weekend versus weekday sales performance.
SELECT
CASE
    WHEN EXTRACT(DOW FROM sale_date) IN (0,6)
         THEN 'Weekend'
    ELSE 'Weekday'
END AS day_type,
SUM(total_sale) AS revenue
FROM RETAIL_SALES
GROUP BY day_type;

-- REVENUE AND CUSTOMER INSIGHTS

-- Revenue contribution by category.
SELECT
    category,
    SUM(total_sale) AS revenue,
    ROUND(
        (
            SUM(total_sale) * 100.0 /
            SUM(SUM(total_sale)) OVER ()
        )::numeric,
        2
    ) AS revenue_percentage
FROM RETAIL_SALES
GROUP BY category
ORDER BY revenue DESC;

-- Top revenue contributing customers.
SELECT
    customer_id,
    SUM(total_sale) AS total_spent
FROM RETAIL_SALES
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Gender wise product category preferences.
SELECT
    gender,
    category,
    COUNT(*) AS purchases
FROM RETAIL_SALES
GROUP BY gender, category
ORDER BY gender, purchases DESC;

-- Revenue contribution by gender and category.
SELECT
    gender,
    category,
    ROUND(SUM(total_sale)::numeric, 2) AS revenue
FROM RETAIL_SALES
GROUP BY gender, category
ORDER BY gender, revenue DESC;
