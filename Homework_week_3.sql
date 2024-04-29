-- Making sure we are using the right database and that everything is ok
USE shop;
SELECT * FROM sales1;

-- We need to change salesperson's name Inga to Annette.
SELECT * FROM sales1;
UPDATE sales1
SET salesperson = 'Annette'
WHERE salesperson ='Inga';

-- Find out how many sales Annette did.
SELECT 
	COUNT(*) AS total_sales,
    salesperson AS sales_person
FROM sales1 AS s
    WHERE salesperson ='Annette';
    
-- How much (sum) each person sold for the given period.
SELECT
	s.salesperson,
	SUM(salesamount) AS total_sales
    FROM sales1 AS s
    GROUP BY s.salesperson;
    
-- Find the number of sales by each person if they did less than 3 sales for the past period.
SELECT 
	s.salesperson,
    COUNT(*) AS total_sales_count
    FROM sales1 AS s
    GROUP BY s.salesperson
    HAVING total_sales_count < 3;
    
-- Find the total monetary sales amount achieved by each store.
SELECT 
	s.store,
    SUM(salesamount) as total_sales_amount
    FROM sales1 AS s
    GROUP BY store;

-- Find the total sales amount by each person by day.
SELECT 
	s.salesperson AS sales_person,
	s.day AS day_of_the_week,
    SUM(s.salesamount) AS total_sales
    FROM sales1 AS s
    GROUP BY sales_person, day_of_the_week
    ORDER BY sales_person, day_of_the_week;
    
-- Find out how many sales took place each week (in no particular order)
SELECT 
	s.week,
	COUNT(*) AS weekly_sales_count
FROM sales1 AS s
GROUP BY week;

-- Find out how many sales took place each week (and present data by week in descending and then in ascending order)
SELECT 
	s.week,
	COUNT(*) AS weekly_sales_count
FROM sales1 AS s
GROUP BY week
ORDER BY weekly_sales_count DESC;

SELECT 
	s.week,
	COUNT(*) AS weekly_sales_count
FROM sales1 AS s
GROUP BY s.week
ORDER by  weekly_sales_count;

-- Find the total amount of sales by month where combined total is less than £100
SELECT
	s.month,
    SUM(salesamount) as total_month_sales
    FROM sales1 AS s
    GROUP BY s.month
    HAVING total_month_sales < 100
    ORDER BY total_month_sales DESC;
    
-- Find out how many sales were recorded each week on different days of the week
SELECT 
	s.week,
    s.day,
    COUNT(*)
    FROM sales1 AS s
    GROUP BY s.week, s.day
    ORDER BY s.week;

-- How much (sum) each person sold for the given period, including the number of sales per person, their average, lowest and highest sale amounts
SELECT
	s.salesperson,
    COUNT(*) AS total_sales,
	ROUND(AVG(s.salesamount),2) AS total_sales_amount,
    MIN(s.salesamount) AS lowest_sale_amount,
    MAX(s.salesamount) AS highest_sale_amount
    FROM sales1 AS s
    GROUP BY s.salesperson;
    
-- Find all sales records (and all columns) that took place in the London store, not in December, but sales concluded by Bill or Frank for the amount higher than £50.
SELECT *
FROM sales1 as s
WHERE s.month != 'Dec'
AND s.store = 'London'
AND s.salesperson IN ('Bill', 'Frank')
AND s.salesamount > 50;