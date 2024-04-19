/* TASK 1: QUERIES USING DB parts */

/* Find the name and weight of each red part */
USE parts;
SELECT 
	pname AS red_part_name,
    weight
FROM part
WHERE colour = 'red';

/* Count unique red parts in part */
SELECT COUNT(*)
FROM (SELECT DISTINCT pname FROM part WHERE colour='red') AS red_parts;#

/* Find all UNIQUE supplier(s) name from London */
SELECT DISTINCT sname
FROM supplier
WHERE city = 'London';

/* Count unique supplier in London */
SELECT
	COUNT(DISTINCT sname)
FROM supplier
WHERE city = 'London';

-- -----------------------------------------------------------------------------------
		
/* TASK 2 */
/* Create a database called shop and a table in it called sales1 and insert the given data*/
CREATE DATABASE shop;
USE shop;

CREATE TABLE sales1
(
store VARCHAR(25),
week INT,
day VARCHAR(9),
salesperson VARCHAR(50),
salesamount DECIMAL(6,2),
month VARCHAR(3)
);

INSERT INTO sales1
VALUES
('London', 2, 'Monday', 'Frank', 56.25, 'May'),
('London', 5, 'Tuesday', 'Frank', 74.32, 'Sep'),
('London', 5, 'Monday', 'Bill', 98.42, 'Sep'),
('London', 5, 'Saturday', 'Bill', 73.90, 'Dec'),
('London', 1, 'Tuesday', 'Josie', 44.27, 'Sep'),
('Dusseldorf', 4, 'Monday', 'Manfred', 77.00, 'Jul'),
('Dusseldorf', 3, 'Tuesday', 'Inga', 9.99, 'Jun'),
('Dusseldorf', 4, 'Wednesday', 'Manfred', 86.81, 'Jul'),
('London', 6, 'Friday', 'Josie', 74.02, 'Oct'),
('Dusseldorf', 1, 'Saturday', 'M nfred', 43.11, 'Apr');

/* Checking the data were inserted */
SELECT * FROM sales1;

/* Checking how many entries were inserted */
SELECT COUNT(*)
FROM sales1;

