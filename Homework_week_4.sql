/* We are going to use the database called parts. These queries require joins and nested subqueries.

WRITE THE FOLLOWING QUERIES
1. Find the name and status of each supplier who supplies project J2
2. Find the name and city of each project supplied by a London-based supplier
3. Find the name and city of each project NOT supplied by a London-based supplier
4. Find the supplier name, part name and project name for each case WHERE a
supplier supplies a project with a part, BUT ALSO the supplier city, project city
AND part city are the same.*/

-- Chosing right database
USE parts;

-- inspection of tables
SELECT * FROM project;
SELECT * FROM supply;
SELECT * FROM supplier;

/* 1. Find the name and status of each supplier who supplies project J2 */

SELECT DISTINCT
		sr.sname,
        sr.status
FROM supplier as sr
LEFT JOIN 
supply as sy
ON sr.s_id = sy.s_id
WHERE sy.j_id = 'J2';

/*2. Find the name and city of each project supplied by a London-based supplier*/

SELECT 
	p.jname,
    p.city
FROM 
	project AS p
INNER JOIN 
    supply AS s 
ON p.j_id = s.j_id
WHERE s_id IN ( SELECT
					s_id
				FROM supplier
				WHERE city='London');
                
/* 3. Find the name and city of each project NOT supplied by a London-based supplier*/

SELECT
   jname,
   city
FROM project
WHERE j_id NOT IN (	SELECT
					j_id
					FROM supply
					WHERE s_id IN (SELECT
									s_id
									FROM supplier
									WHERE city = 'LONDON'));
                    
/* 4. Find the supplier name, part name and project name for each case WHERE a
supplier supplies a project with a part, BUT ALSO the supplier city, project city
AND part city are the same.*/

SELECT 
	sr.sname,
    p.pname,
    pj.jname
FROM 
supply as s
JOIN supplier AS sr ON s.s_id=sr.s_id
JOIN part AS p ON p.p_id=s.p_id
JOIN project AS pj ON s.j_id=pj.j_id
WHERE sr.city=p.city AND p.city=pj.city;

/*Find part names and the name of their suppliers of all the parts used in London projects*/
        