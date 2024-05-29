-- The dataset I am using in the project is sourced from Kaggle and has 1470 records. I analysed and manipulated the data
-- with Python and created a final csv file ready for import in the database structure I created. 
-- More in detail, I eliminated some columns, converted some data and made sure data types were consistent with
-- database. 
-- The database was created by IBM, there are no employee details such as name or address. I a real life situation I would have stored those details
-- in an additional table connected to employees table. 

-- WORKFLOW:
-- Creating database
-- Creating mapping tables
-- Creating tables while keeping in mind FK connection and writing notes
-- Populating mapping tables manually
-- Populating tables from csv file using import functionality (1470 records)
-- Populating foreign keys in each table using mapping tables and joins
-- Checking all tables
-- Adding FK constraints, previously planned
-- Creating the log table for the database

-- DROP DATABASE human_resources; 
CREATE DATABASE human_resources;
CREATE DATABASE human_resources_2; -- to check backup works (stored procedures and events and functions are not backed up)
DROP DATABASE human_resources_2;
USE human_resources;

CREATE TABLE marital_status(
						marital_status_ID INT PRIMARY KEY AUTO_INCREMENT,
						status VARCHAR(25)
						);
CREATE TABLE gender(
						gender_ID INT PRIMARY KEY AUTO_INCREMENT,
						gender VARCHAR(25)
						);
CREATE TABLE educationlevels(
						education_ID INT PRIMARY KEY AUTO_INCREMENT,
						level VARCHAR(25)
						);
CREATE TABLE educationfields(
						educationfield_ID INT PRIMARY KEY AUTO_INCREMENT,
						field VARCHAR(25)
						);
CREATE TABLE departments(
						department_ID INT PRIMARY KEY AUTO_INCREMENT,
                        department_name VARCHAR(50)
						);
CREATE TABLE jobroles(
						jobrole_ID INT PRIMARY KEY AUTO_INCREMENT,
                        role_name VARCHAR(50)
						);
CREATE TABLE businesstravels(
						businesstravel_ID INT PRIMARY KEY AUTO_INCREMENT,
                        traveltype VARCHAR(25)
                        );

CREATE TABLE attrition (
						attrition_ID INT PRIMARY KEY AUTO_INCREMENT,
                        attrition TINYINT(1),
                        employee_ID INT
                        /* REMINDER FOR COSTRAINT FKs, I WILL ADD LATER
                        FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID),
                        */
						);
SELECT * FROM employees_1;
CREATE TABLE employees_1(
						employee_ID INT PRIMARY KEY AUTO_INCREMENT,
                        employee_number INT,
                        age INT,
                        gender_ID VARCHAR(25),
                        marital_status_ID VARCHAR(25),
                        distance_from_home INT,
                        education_ID INT,
                        educationfield_ID VARCHAR(100),
                        department_ID VARCHAR(100),
                        jobrole_ID VARCHAR(100)
                        /* REMINDER FOR COSTRAINT FKs, I WILL ADD LATER
                        FOREIGN KEY (gender_ID) REFERENCES gender(gender_ID),
						FOREIGN KEY (marital_status_ID) REFERENCES marital_status(marital_status_ID)
                        FOREIGN KEY (education_ID) REFERENCES educationlevels(education_ID),
                        FOREIGN KEY (educationfield_ID) REFERENCES educationfields(educationfield_ID),
                        FOREIGN KEY (department_ID) REFERENCES departments(department_ID),
                        FOREIGN KEY (jobrole_ID) REFERENCES jobroles(jobrole_ID),
						FOREIGN KEY (relationship_ID) REFERENCES relationships(relationship_ID),
                        FOREIGN KEY (payment_ID) REFERENCES payments(payment_ID),
                        FOREIGN KEY (survey_ID) REFERENCES surveys(survey_ID)
                        */
						);
-- adding costraint to avoid having employees with equal employee_number
ALTER TABLE employees
ADD CONSTRAINT unique_employee_number UNIQUE (employee_number);     
   
CREATE TABLE relationships(
						relationship_ID INT PRIMARY KEY AUTO_INCREMENT,
						employee_ID INT,
                        businesstravel_ID VARCHAR(25),
						numcompaniesworked INT,
						yearsatcompany INT,
						trainingdayslastyear INT,
						yearsincurrentrole INT,
						yearsincelastpromotion INT,
						yearswithcurrentmanager INT,
						totalworkingyears INT
						/*REMINDER FOR COSTRAINT FKs, I WILL ADD LATER
                        FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID),
                        FOREIGN KEY (businesstravel_ID) REFERENCES businesstravels(businesstravel_ID)*/
						);  
                        
CREATE TABLE payments(
						payment_ID INT PRIMARY KEY AUTO_INCREMENT,
                        employee_ID INT,
                        monthly_rate DECIMAL(10,2),
                        overtime TINYINT(1),
                        percentsalaryhike DECIMAL(4,2)
                        /*FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)*/
						);

CREATE TABLE surveys(
						survey_ID INT PRIMARY KEY AUTO_INCREMENT,
						employee_ID INT,
                        worklifebalance INT,
                        relationshipsatisfaction INT,
						jobsatisfaction INT,
                        jobinvolvement INT,
                        environmentsatisfaction INT,
                        performancerating INT
						/*FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)*/
						);

                        
-- Inserting data in the tables. I will manually insert data in tables with few rows.
-- I did investigate unique values in categorical columns using python so I identified the different categories quickly despite the dataset
-- having 1470 entries. 

-- The table 'marital_status' has 3 rows. 

SELECT * FROM marital_status;

INSERT INTO marital_status(status)
VALUES	('Married'),
		('Single'),
		('Divorced');
        
-- The table 'gender' has 2 rows. 
-- I am not changing this apparently binary attribute in 1 and zero to allow the inclusion of more gender types in the future.

SELECT * FROM gender;

INSERT INTO gender(gender)
VALUES 	('Female'),
		('Male');

-- The table 'educationlevels' has 5 rows. 
-- It could look redundant but I have anticipate an eventual change in the way the levels are defined
-- and the table is ready to take strings and more descriptive way to declare the education levels. 

SELECT * FROM educationlevels;

INSERT INTO educationlevels(level)
VALUES	(1),(2),(3),(4),(5);

-- The table 'educationfields' has 6 rows

SELECT * FROM educationfields;

INSERT INTO educationfields(field)
VALUES	('Life Sciences'),
		('Medical'),
		('Marketing'),
		('Technical Degree'),
		('Human Resources'),
		('Other');

-- The table 'departments' has 3 rows

SELECT * FROM departments;

INSERT INTO departments(department_name)
VALUES	('Sales'),
		('Research & Development'),
		('Human Resources');

-- The table 'jobroles' has 9 rows

select * FROM jobroles;   
      
INSERT INTO jobroles(role_name)
VALUES	('Sales Executive'),
		('Research Scientist'),
		('Laboratory Technician'),
		('Manufacturing Director'),
		('Healthcare Representative'),
		('Manager'),
		('Sales Representative'),
		('Research Director'),
		('Human Resources');
        
-- The table 'businesstravels' has 3 rows

SELECT * FROM businesstravels;

INSERT INTO businesstravels(traveltype)
VALUES	('Travel_Rarely'),
		('Travel_Frequently'),
		('Non-Travel');
        
-- The tables employees, payments, relationships, attrition will have 1470 rows, one for each employee and I will use import function provided
-- by Mysql Workbench

-- POPLULATING TABLE 'employees'
DESCRIBE employees;
-- selecting import from external file, matching the columns, imports and checking if it worked.
SELECT * FROM employees;
SELECT COUNT(*) AS row_count
FROM employees;

-- POPULATING TABLE 'payments'
DESCRIBE payments;
-- selecting import from external file, matching the columns, imports and checking if it worked.
SELECT * FROM payments;
SELECT COUNT(*) AS row_count
FROM payments;

-- Populating the FK
UPDATE payments p
JOIN employees e ON p.payment_ID = e.employee_ID
SET p.employee_ID = e.employee_ID
WHERE p.employee_ID IS NULL;

-- POPULATING TABLE 'relationships'
DESCRIBE relationships;
-- selecting import from external file, matching the columns, imports and checking if it worked.
SELECT * FROM relationships;
SELECT COUNT(*) AS row_count
FROM relationships;

-- populating the FK
UPDATE relationships r
JOIN employees e ON r.relationship_ID = e.employee_ID
SET r.employee_ID = e.employee_ID
WHERE r.employee_ID IS NULL;

-- POPULATING TABLE 'surveys'
DESCRIBE surveys;
-- selecting import from external file, matching the columns, imports and checking if it worked.
SELECT * FROM surveys;
SELECT COUNT(*) AS row_count
FROM surveys;

-- populating the FK
UPDATE surveys s
JOIN employees e ON s.survey_ID = e.employee_ID
SET s.employee_ID = e.employee_ID
WHERE s.employee_ID IS NULL;

-- POPULATING TABLE 'attrition'
DESCRIBE attrition;
-- selecting import from external file, matching the columns, imports and checking if it worked.
SELECT * FROM attrition;
SELECT COUNT(*) AS row_count
FROM attrition;

-- populating the FK
UPDATE attrition a
JOIN employees e ON a.attrition_ID = e.employee_ID
SET a.employee_ID = e.employee_ID
WHERE a.employee_ID IS NULL;

/**************************************************************************************************************************************************************************/
-- USING MAPPING TABLES TO CONVERT DATA IN EMPLOYEES AND RELATIONSHIPS TABLES

-- Converting EDUCATIONFIELD_ID using mapping table
-- Temporary extra column to store converted values
SELECT * FROM employees;
ALTER TABLE employees
ADD COLUMN temp_educationfield_id INT;

-- use new column with INT type to convert educationfield_ID
UPDATE employees e
JOIN educationfields ed ON e.educationfield_ID = ed.field
SET e.temp_educationfield_id = ed.educationfield_ID;

-- Drop the original educationfield_ID column
ALTER TABLE employees DROP COLUMN educationfield_ID;
-- Rename the temporary column to educationfield_ID
ALTER TABLE employees CHANGE COLUMN temp_educationfield_id educationfield_ID INT;

-- Converting JOBROLE_ID using mapping table
-- Temporary extra column to store converted values
SELECT * FROM employees;
ALTER TABLE employees
ADD COLUMN temp_jobrole_ID INT;

-- use new column with INT type to convert JOBROLE_ID
UPDATE employees e
JOIN jobroles j ON e.jobrole_ID = j.role_name
SET e.temp_jobrole_ID = j.jobrole_ID;

-- Drop the original JOBROLE_ID column
ALTER TABLE employees DROP COLUMN jobrole_ID;
-- Rename the temporary column to JOBROLE_ID
ALTER TABLE employees CHANGE COLUMN temp_jobrole_ID jobrole_ID INT;


-- Converting DEPARTEMENT_ID using mapping table
-- Temporary extra column to store converted values
SELECT * FROM employees;
ALTER TABLE employees
ADD COLUMN temp_department_ID INT;

-- Use new column with INT type to convert department_ID
UPDATE employees e
JOIN departments d ON e.department_ID = d.department_name
SET e.temp_department_ID = d.department_ID;

-- Drop the original department_ID column
ALTER TABLE employees DROP COLUMN department_ID;
-- Rename the temporary column to department_ID
ALTER TABLE employees CHANGE COLUMN temp_department_ID department_ID INT;

-- Converting 'businesstravel_ID' columns in table 'relationships' using businesstravels mapping table
-- Temporary extra column to store converted values
SELECT * FROM relationships;
ALTER TABLE relationships
ADD COLUMN temp_businesstravel_ID INT;

-- Use new column with INT type to convert educationfield_ID
UPDATE relationships r
JOIN businesstravels b ON r.businesstravel_ID = b.traveltype
SET r.temp_businesstravel_ID = b.businesstravel_ID;

-- Drop the original educationfield_ID column
ALTER TABLE relationships DROP COLUMN businesstravel_ID;
-- Rename the temporary column to educationfield_ID
ALTER TABLE relationships CHANGE COLUMN temp_businesstravel_ID businesstravel_ID INT;

-- Converting gender_ID in table employees using mapping table
-- Temporary extra column to store converted values
SELECT * FROM employees;
ALTER TABLE employees
ADD COLUMN temp_gender_ID INT;

-- Use new column with INT type to convert educationfield_ID
UPDATE employees e
JOIN gender g ON e.gender_ID = g.gender
SET e.temp_gender_ID = g.gender_ID;

ALTER TABLE employees DROP COLUMN gender_ID;
ALTER TABLE employees CHANGE COLUMN temp_gender_ID gender_ID INT;

-- Converting marital_status_ID in table employees using mapping table
-- Temporary extra column to store converted values
SELECT * FROM employees;
ALTER TABLE employees
ADD COLUMN temp_marital_status_ID INT;

-- Use new column with INT type to convert educationfield_ID
UPDATE employees e
JOIN marital_status m ON e.marital_status_ID = m.status
SET e.temp_marital_status_ID = m.marital_status_ID;

ALTER TABLE employees DROP COLUMN marital_status_ID;
ALTER TABLE employees CHANGE COLUMN temp_marital_status_ID marital_status_ID INT;


-- CHECKING ALL TABLES ONCE MORE
-- NOW THEY SHOULD BE ALL CORRECTLY POPULATED
SELECT * FROM attrition;
DESCRIBE attrition;
SELECT * FROM businesstravels;
SELECT * FROM departments;
SELECT * FROM educationfields;
SELECT * FROM educationlevels;
SELECT * FROM employees;
DESCRIBE employees;
SELECT * FROM gender;
SELECT * FROM jobroles;
SELECT * FROM marital_status;
SELECT * FROM payments;
DESCRIBE payments;
SELECT * FROM relationships;
DESCRIBE relationships;
SELECT * FROM surveys;
DESCRIBE surveys;


/************************************************************************************************************************************************************************/
-- ADDING FOREING KEYS CONSTRAINTS

-- adding FK to attrition table

ALTER TABLE attrition
ADD CONSTRAINT fK_attrition_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID);

-- Adding FK to employees table

ALTER TABLE employees
ADD CONSTRAINT fk_educationfield
FOREIGN KEY (educationfield_ID)
REFERENCES educationfields(educationfield_ID);

ALTER TABLE employees
ADD CONSTRAINT fk_educationlevel
FOREIGN KEY (education_ID)
REFERENCES educationlevels(education_ID);

ALTER TABLE employees
ADD CONSTRAINT fk_department_ID
FOREIGN KEY (department_ID)
REFERENCES departments(department_ID);

ALTER TABLE employees
ADD CONSTRAINT fk_jobrole_ID
FOREIGN KEY (jobrole_ID)
REFERENCES jobroles(jobrole_ID);

ALTER TABLE employees
ADD CONSTRAINT fk_gender_ID
FOREIGN KEY (gender_ID)
REFERENCES gender(gender_ID); 

ALTER TABLE employees
ADD CONSTRAINT fk_marital_status_ID
FOREIGN KEY (marital_status_ID)
REFERENCES marital_status(marital_status_ID); 

-- Adding FK to relationships table

ALTER TABLE relationships
ADD CONSTRAINT fk_relationshsip_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID); 
 
ALTER TABLE relationships
ADD CONSTRAINT fk_businesstravel_ID
FOREIGN KEY (businesstravel_ID)
REFERENCES businesstravels(businesstravel_ID);   

-- Adding FK to payments table

ALTER TABLE payments
ADD CONSTRAINT fk_payments_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID); 

-- Adding FK to  surveys tables

ALTER TABLE surveys
ADD CONSTRAINT fk_surveys_employee_ID
FOREIGN KEY (employee_ID)
REFERENCES employees(employee_ID);   
  
/**************************************************************************************************************************************************************************/
-- ADDING LOGS TABLES FOR TRIGGERS

CREATE TABLE human_resources_logs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    LogMessage VARCHAR(255),
    LogDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
                            
