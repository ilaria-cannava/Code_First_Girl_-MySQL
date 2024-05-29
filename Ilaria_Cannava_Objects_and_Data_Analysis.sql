USE human_resources;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATING A FUNCTION TO CALCULATE ATTRITION AND CALL IT
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS attrition_rate_calculation;

DELIMITER //

CREATE FUNCTION attrition_rate_calculation()
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE initial_employees INT;
    DECLARE employees_left INT;
    DECLARE churn_rate DECIMAL(5,2);
    
    -- Count the initial number of employees
    SELECT COUNT(employee_ID) INTO initial_employees
    FROM attrition;
    
    -- Count the number of employees who left (attrition=1 means employee left)
    SELECT COUNT(employee_ID) INTO employees_left
    FROM attrition
    WHERE attrition = 1;
    
    -- Calculate the churn rate
    SET churn_rate = (employees_left / initial_employees) * 100;
    
    -- Return the churn rate
    RETURN churn_rate;
END //

DELIMITER ;

-- Calling the function before and after the insert to see the attrition rate changing
SELECT attrition_rate_calculation() AS churn_rate;

use human_resources;

INSERT INTO employees(employee_number, age, distance_from_home, gender_ID, marital_status_ID)
VALUES
		(3567, 28, 35, 2, 3),
        (3568, 39, 12, 1, 1),
        (3569, 45, 10, 2, 2),
        (3570, 32, 19, 1, 1),
        (3571, 49, 45, 1, 2),
        (3572, 22, 17, 2, 3),
        (3573, 31, 22, 1, 1),
        (3574, 37, 11, 2, 2),
        (3575, 55, 19, 1, 3),
        (3576, 34, 12, 2, 1),
        (3577, 24, 16, 1, 2),
        (3578, 24, 16, 1, 2);
        
-- deleting samples values going back to original dataset of 1470 entries
DELETE FROM employees WHERE employee_id>1470;
DELETE FROM attrition WHERE employee_id>1470;

-- resetting autoincrement
ALTER TABLE employees AUTO_INCREMENT = 1471;
ALTER TABLE attrition AUTO_INCREMENT = 1471;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IN YOUR DATABASE, CREATE A STORED PROCEDURE AND DEMONSTRATE HOW IT RUNS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATING A STORED PROCEDURE TO UPDATE ATTRITION TO ZERO WHEN A NEW EMPLOYEE IS HIRED (INSERTED IN EMPLOYEES TABLE)

DELIMITER //

CREATE PROCEDURE update_attrition_after_insert(IN emp_id INT)
BEGIN
    -- Check if the employee exists in the attrition table
    IF EXISTS (SELECT 1 FROM attrition WHERE employee_ID = emp_id) THEN
        -- Update the attrition record for the employee
        UPDATE attrition
        SET attrition = 0
        WHERE employee_ID = emp_id;
    ELSE
        -- Insert a new record into the attrition table for the employee
        INSERT INTO attrition (employee_ID, attrition)
        VALUES (emp_id, 0);
    END IF;
END //
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IN YOUR DATABASE CREATE A TRIGGER AND DEMONSTRATE HOW IT RUNS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating a trigger that calls the attrition_rate function, to update attrition table

DROP TRIGGER after_employee_insert;

DELIMITER //

CREATE TRIGGER after_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    CALL update_attrition_after_insert(NEW.employee_ID);
END //

DELIMITER ;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IN YOUR DATABASE CREATE A TRIGGER AND DEMONSTRATE HOW IT RUNS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATING INSERT TRIGGER FOR EMPLOYEES TABLE, to update the logs table

DELIMITER //
CREATE TRIGGER trg_new_employees
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO human_resources_logs (LogMessage)
    VALUES (CONCAT('New employee hired: ', NEW.employee_number));
END//

-- Change Delimiter
DELIMITER ;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGER AND PROCEDURE ACTION SAMPLE and recovery queries
-- Checking what is in the log before and after the trigger
SELECT * FROM human_resources_logs;

-- Insert sample data into employees (if performing more than once, change employee_number, it will give error otherwise, due to the unique constraint)
INSERT INTO employees(employee_number, age, distance_from_home, gender_ID, marital_status_ID) 
VALUES
		(2570, 38, 28, 1, 2);

-- checking if attrition table was updated after the trigger called the stored procedure
SELECT * FROM attrition
ORDER BY employee_ID DESC
LIMIT 20;

-- checking employees table
SELECT * FROM employees
ORDER BY employee_ID DESC
LIMIT 20;

-- deleting samples values going back to original dataset of 1470 entries
DELETE FROM employees WHERE employee_id>1470;
DELETE FROM attrition WHERE employee_id>1470;

-- resetting autoincrement
ALTER TABLE employees AUTO_INCREMENT = 1471;
ALTER TABLE attrition AUTO_INCREMENT = 1471;

-- NOTES ON A BIG CHALLENGE WITH EASY SOLUTION :-)
-- Since I did relize I could insert new employees with same employee_number I decided to add a constraint to the table
-- To do so I had to drop employee_ID as FK in all relevant tables to be able to drop existing rows with duplicates and reset autoincrement
-- then add the constraint and finally reassign the FKs. I did also code the constraint immediately after the code for creating
-- employees table, where it should have been added.  

/*-- Dropping FK constraints to be able to alter table employees
ALTER TABLE relationships
DROP FOREIGN KEY fk_relationshsip_employee_ID;
ALTER TABLE surveys
DROP FOREIGN KEY fk_surveys_employee_ID;
ALTER TABLE attrition
DROP FOREIGN KEY fk_attrition_employee_ID;
ALTER TABLE payments
DROP FOREIGN KEY fk_payments_employee_ID;

-- deliting samples values going back to original dataset of 1470 entries
DELETE FROM employees WHERE employee_id>1470;
DELETE FROM attrition WHERE employee_id>1470;

-- resetting autoincrement
ALTER TABLE employees AUTO_INCREMENT = 1471;
ALTER TABLE attrition AUTO_INCREMENT = 1471;

-- adding costraint to avoid having employees with equal employee_number
ALTER TABLE employees
ADD CONSTRAINT unique_employee_number UNIQUE (employee_number);

-- ADDING CONSTRAINT FKS BACK
ALTER TABLE attrition
ADD CONSTRAINT fK_attrition_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID); 

ALTER TABLE surveys
ADD CONSTRAINT fk_surveys_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID); 
  
ALTER TABLE relationships
ADD CONSTRAINT fk_relationshsip_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID);*/

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IN YOUR DATABASE, CREATE AN EVENT AND DEMONSTRATE HOW IT RUNS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATE AN EVENT TO UPDATE MONITORING_ATTRITION TABLE EVERY MONTH. Here I am setting up the event every minute, to be able to demonstrate how it runs. 
-- The event calls the function to calculate attrition rate

DROP TABLE monitoring_attrition;

CREATE TABLE monitoring_attrition(
		monthly_update TIMESTAMP NOT NULL,
        attrition_value DECIMAL(5,2));
        
-- Turn ON Event Scheduler 
SET GLOBAL event_scheduler = ON;

DROP EVENT attrition_monthly_check;
-- Change Delimiter
DELIMITER //

CREATE EVENT attrition_monthly_check
ON SCHEDULE EVERY 1 minute
STARTS NOW()
DO BEGIN
    DECLARE attrition_value DECIMAL(5,2);
    
    -- Calculate attrition rate using the function
    SET attrition_value = attrition_rate_calculation();
    
    -- Insert the current timestamp and attrition value into the monitoring table
	INSERT INTO monitoring_attrition (monthly_update, attrition_value) VALUES (NOW(), attrition_value);
END//

-- rechanging delimiter back to ;
DELIMITER ;

-- Monitoring if the table gets updated correctly before and after inserting new employees, remember to delete them and reset autoincrement after test. 
SELECT * FROM monitoring_attrition;
INSERT INTO employees(employee_number, age, distance_from_home, gender_ID, marital_status_ID)
VALUES
		(3567, 28, 35, 2, 3),
        (3568, 39, 12, 1, 1),
        (3569, 45, 10, 2, 2),
        (3570, 32, 19, 1, 1),
        (3571, 49, 45, 1, 2),
        (3572, 22, 17, 2, 3),
        (3573, 31, 22, 1, 1),
        (3574, 37, 11, 2, 2),
        (3575, 55, 19, 1, 3),
        (3576, 34, 12, 2, 1),
        (3577, 24, 16, 1, 2);
        
-- deliting samples values going back to original dataset of 1470 entries
DELETE FROM employees WHERE employee_id>1470;
DELETE FROM attrition WHERE employee_id>1470;

-- resetting autoincrement
ALTER TABLE employees AUTO_INCREMENT = 1471;
ALTER TABLE attrition AUTO_INCREMENT = 1471;

SHOW VARIABLES LIKE 'event_scheduler';
SET GLOBAL event_scheduler = OFF;

/*************************************************************************************************************************************************************************
DATA ANALYSIS
**************************************************************************************************************************************************************************/

USE human_resources;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PREPARE AN EXAMPLE QUERY WITH A SUBQUERY TO DEMONSTRATE HOW TO EXTRACT DATA FROM YOUR DB FOR ANALYSIS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- COUNTING TOTAL EMPLOYEES PER DEPARTMENT
SELECT 
    department_name,
    (SELECT COUNT(*) FROM employees e WHERE e.department_id = d.department_id) AS employee_count
FROM 
    departments d;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- PREPARE AN EXAMPLE QUERY WITH GROUP BY AND HAVING TO DEMONSTRATE HOW TO EXTRACT DATA FROM YOUR DB FOR ANALYSIS 
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Identifying departments with more than 100 employees
SELECT 
    department_name,
    COUNT(*) AS employee_count
FROM 
    employees e
JOIN departments d ON e.department_ID = d.department_ID
GROUP BY 
    department_name
HAVING 
    COUNT(*) > 100;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- USING ANY TYPE OF THE JOINS CREATE A VIEW THAT COMBINES MULTIPLE TABLES IN A LOGICAL WAY
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I am creating a worklifebalance view to analyse worklifebalance by gender

DROP VIEW worklifebalance_view;

CREATE VIEW worklifebalance_view AS
SELECT
	e.employee_ID,
    g.gender,
    s.worklifebalance
FROM employees e
JOIN 
    gender g ON e.gender_ID = g.gender_ID
JOIN 
	surveys AS s ON e.employee_ID = s.employee_ID;

SELECT * FROM worklifebalance_view
ORDER BY employee_ID;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATE A VIEW THAT USES AT LEAST 3-4 BASE TABLES; PREPARE AND DEMONSTRATE A QUERY THAT USES THE VIEW 
-- TO PRODUCE A LOGICALLY ARRANGED RESULT SET FOR ANALYSIS.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating a view with employees, payments, departments and gender to investigate average salaries per gender

DROP VIEW salaries_analysis_view;

CREATE VIEW salaries_analysis_view AS
SELECT
	e.employee_ID,
    p.monthly_rate,
    g.gender,
    d.department_name
FROM 
    employees e
JOIN 
    gender g ON e.gender_ID = g.gender_ID
JOIN 
    payments p ON e.employee_ID = p.employee_ID
JOIN 
	departments d ON e.department_ID = d.department_ID;

-- Checking the view was made correctly
SELECT COUNT(*) AS row_count
FROM salaries_analysis_view;

-- QUERIES ON THE VIEW
-- Finding average wage for men and women
SELECT
	gender,
    ROUND(AVG(monthly_rate),2) AS average_monthly_salary
FROM salaries_analysis_view
GROUP BY 
    gender;
    
 -- Finding average salary per department and gender    
SELECT 
    department_name,
    gender,
    ROUND(AVG(monthly_rate),2) AS average_salary
FROM 
    salaries_analysis_view
GROUP BY 
    department_name, 
    gender;
    
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PREPARE AN EXAMPLE QUERY WITH A SUBQUERY TO DEMONSTRATE HOW TO EXTRACT DATA FROM YOUR DB FOR ANALYSIS (quering the 4 tables view)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Investigating which gender is earning above average salary by department
-- subquery is the calculation of average salary

SELECT ROUND(AVG(monthly_rate),2) as average_salary
FROM salaries_analysis_view;

-- main query using the result of the subquery
SELECT 
    department_name,
    gender,
    ROUND(AVG(monthly_rate), 2) AS average_salary,
    COUNT(employee_ID) AS employee_count
FROM salaries_analysis_view
GROUP BY 
    department_name, gender
HAVING 
    ROUND(AVG(monthly_rate), 2) > (SELECT ROUND(AVG(monthly_rate), 2) as average_salary FROM salaries_analysis_view);

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXTRAS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Count the number of employees for each gender 
SELECT * FROM gender;          
SELECT 
    g.gender,
    COUNT(e.gender_ID) as employees_count
FROM 
    employees e
JOIN 
    gender g ON e.gender_ID = g.gender_ID
GROUP BY 
    g.gender;
-- ------------------------------------------------------------------------
-- Count the number of employees by gender and by department
SELECT 
	g.gender,
    d.department_name,
    COUNT(e.employee_ID) as emploees_count
FROM employees e
JOIN
	gender g ON e.gender_ID=g.gender_ID
JOIN 
	departments d ON e.department_ID=d.department_ID
GROUP BY 
    g.gender, d.department_name;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Count how many leavers
SELECT
        count(attrition) as leavers
FROM attrition
WHERE attrition=1;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Count the leavers by gender and department     
SELECT 
	g.gender,
	COUNT(e.employee_ID) as Leavers
FROM 
	employees e
JOIN 
	gender g on  e.gender_ID = g.gender_ID
JOIN
	attrition a on e.employee_ID = a.employee_ID
WHERE a.attrition = 1
GROUP BY gender;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Count the leavers by gender and department that declared worklife balance <=2 
SELECT 
    g.gender,
    d.department_name,
    s.worklifebalance,
    COUNT(e.employee_ID) as Leavers
FROM 
    employees e
JOIN 
    gender g ON e.gender_ID = g.gender_ID
JOIN 
    departments d ON e.department_ID = d.department_ID 
JOIN
    attrition a ON e.employee_ID = a.employee_ID
JOIN
    surveys s ON e.employee_ID = s.employee_ID
WHERE 
    a.attrition = 1
    AND s.worklifebalance <= 2
GROUP BY 
    d.department_name, 
    g.gender, 
    s.worklifebalance;
    
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTES ON MORE QUERIES

-- What is the attrition rate in each department
-- what is attrition rate among females employees
-- what is attrition rate among male employees

-- Count how many leavers with low surveys rate


