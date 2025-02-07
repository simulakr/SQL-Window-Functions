
###############################################################
 SQL Window Functions
###############################################################


-- 1: Overview Tables
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM regions;
SELECT * FROM customers;
SELECT * FROM sales;


--  ROW_NUMBER() 
-- 2.1: Assign numbers to each row of the departments table

SELECT *,
ROW_NUMBER() OVER() AS ROW_N 
FROM departments
ORDER BY ROW_N ASC


-- 2.2: Assign numbers to each row of 
-- the department for the Entertainment division
SELECT *,
ROW_NUMBER() OVER() AS ROW_N 
FROM departments
WHERE division = 'Entertainment'
ORDER BY ROW_N ASC


--  ROW_NUMBER() and OVER()
-- 3.1: Retrieve all the data from the employees table
SELECT * FROM employees;

-- Order by inside OVER()
-- 3.2: Retrieve a list of employee_id, first_name, 
-- hire_date, and department of all employees in the sports
-- department ordered by the hire date

SELECT employee_id, first_name, hire_date, department,
ROW_NUMBER() OVER() AS ROW_N 
FROM employees 
WHERE department ='Sports'
ORDER BY ROW_N ASC

-- 3.3: Order by multiple columns

SELECT employee_id, first_name, hire_date, salary, department,
ROW_NUMBER() OVER(ORDER BY hire_date, salary DESC) AS ROW_N 
FROM employees 
WHERE department ='Sports'
ORDER BY ROW_N ASC

-- 3.4: Ordering in- and outside the OVER() clause
SELECT employee_id, first_name, hire_date, salary, department,
ROW_NUMBER() OVER(ORDER BY hire_date ASC, salary DESC) AS Row_N
FROM employees
WHERE department = 'Sports'
ORDER BY employee_id



-- the PARTITION BY clause inside OVER()
-- 4.1: Retrieve the employee_id, first_name, 
-- hire_date of employees for different departments

SELECT employee_id, first_name, department,
ROW_NUMBER() OVER(PARTITION BY department) AS ROW_N 
FROM employees 
ORDER BY department

-- 4.2: Order by the hire_date
SELECT employee_id, first_name, department, hire_date,
ROW_NUMBER() OVER(PARTITION BY department
				   ORDER BY hire_date) AS Row_N
FROM employees
ORDER BY department ASC


--  PARTITION BY with CTE
--  CASE clause

-- 5.1: Retrieve all data from the sales and customers tables
SELECT * FROM sales
SELECT * FROM customers

-- 5.2: Create a common table expression to retrieve the
-- customer_id, customer_name, segment and how many 
-- times the customer has purchased from the mall 
WITH customer_purchase AS(SELECT s.Customer_ID, cu.Customer_Name, cu.Segment,
	COUNT(*) AS purchase_count
	FROM sales s
	JOIN customers cu
	ON s.Customer_ID = cu.Customer_ID
	GROUP BY s.Customer_ID, cu.Customer_Name, cu.Segment
	)
    
SELECT * from customer_purchase 
ORDER BY Customer_ID

-- 5.3: Number each customer by how many purchases they've made


-- Same CTE as 5.2
WITH customer_purchase AS (
	SELECT s.customer_id, c.customer_name, c.segment,
	COUNT(*) AS purchase_count
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	GROUP BY s.customer_id, c.customer_name, c.segment
	ORDER BY customer_id)

SELECT customer_id, customer_name, segment, purchase_count,
ROW_NUMBER() OVER (ORDER BY purchase_count DESC) AS Row_N
FROM customer_purchase
ORDER BY Row_N, purchase_count DESC

-- Exercise 5.1: Number each customer by their customer segment
-- and by how many purchases they've made in descending order
SELECT customer_id, customer_name, segment, purchase_count,
ROW_NUMBER OVER (PARTITION by segment
  				ORDER BY purchase_count DESC) AS Row_N
FROM customer_purchase
ORDER BY Row_N, purchase_count DESC;

#############################
--  Fetching: LEAD() & LAG()

-- 6.1: Retrieve all employees first name, department, salary
-- and the salary after that employee

SELECT first_name, department, salary,
LEAD(salary) OVER() AS next_salary 
FROM employees

-- 6.2: Retrieve all employees first name, department, salary
-- and the salary before that employee

SELECT first_name, department, salary,
LAG(salary) OVER() AS previous_salary
FROM employees


-- 6.3: Retrieve all employees first name, department, salary
-- and the salary after that employee in order of their salaries
SELECT first_name, department, salary, 
LEAD(salary) OVER(order by salary DESC) AS next_salary 
FROM employees

--6.4: Salary differences 
SELECT first_name, department, salary, 
LEAD(salary) OVER(order by salary DESC) AS next_salary, 
salary - LEAD(salary) OVER(order by salary DESC) as salary_difference
FROM employees

-- Exercise 6.1: Retrieve all employees first name, department, salary
-- and the salary before that employee in order of their salaries in
-- descending order. Call the new column closest_higher_salary
SELECT first_name, department, salary,
LAG(salary) OVER (ORDER BY salary DESC) AS closest_higher_salary
FROM employees;

-- Exercise 6.2: Retrieve all employees first name, department, salary
-- and the salary after that employee for each department in descending order
-- of their salaries. Call the new column closest_lowest_salary 
SELECT first_name, department, salary,
LEAD(salary) OVER (PARTITION BY department 
                   ORDER BY salary DESC) AS closest_lowest_salary
FROM employees

-- After 1 and 2
SELECT first_name, department, salary,
LEAD(salary, 1) OVER (ORDER BY salary DESC) closest_salary,
LEAD(salary, 2) OVER (ORDER BY salary DESC) next_closest_salary
FROM employees
WHERE department = 'Clothing'


-- FIRST_VALUE() clause with the OVER() clause

-- 7.1: Retrieve the first_name, last_name, department, and 
-- hire_date of all employees. Add a new column called first_emp_date 
-- that returns the hire date of the first hired employee

SELECT first_name, last_name, department, hire_date, 
FIRST_VALUE(hire_date) OVER(ORDER BY hire_date ) AS first_emp_date 
FROM employees

-- 7.2: Find the difference between the hire date of the first employee
-- hired and every other employees

SELECT *, AGE(hire_date, first_emp_date) AS hiredate_difference
FROM (SELECT first_name, last_name, department, hire_date,
FIRST_VALUE(hire_date) OVER (ORDER BY hire_date) AS first_emp_date
FROM employees)

-- 7.3: Partition by department

SELECT first_name, last_name, department, hire_date,
FIRST_VALUE(hire_date) OVER (PARTITION BY department
					 ORDER BY hire_date) AS first_emp_date
FROM employees

-- 7.4: Find the difference between the hire date of the 
-- first employee hired and every other employees partitioned by department
SELECT *, AGE(hire_date, first_emp_date) AS hiredate_difference
FROM (SELECT first_name, last_name, department, hire_date,
FIRST_VALUE(hire_date) OVER (PARTITION BY department
  						ORDER BY hire_date) AS first_emp_date
FROM employees)


--FIRST_VALUE() clause with the OVER() clause

-- 8.1: Return the first salary for different departments
-- Order by the salary in descending order
SELECT *,  first_salary - salary as salary_difference
FROM
(SELECT first_name, salary, department,
FIRST_VALUE(salary) OVER(PARTITION BY department
                        ORDER BY salary DESC) AS first_salary 
FROM employees)

-- OR
SELECT first_name, salary, department,
MAX(salary) OVER(PARTITION BY department) AS first_salary 
FROM employees
                 

-- 8.2: Return the first salary for different departments
-- Order by the first_name in ascending order
SELECT first_name, department, salary, 
FIRST_VALUE(salary) OVER(PARTITION BY department 
                         ORDER BY first_name ASC) AS first_salary_name 
FROM employees

-- 8.3: Return the fifth salary for different departments
-- Order by the first_name in ascending order
SELECT first_name, department, salary,
NTH_VALUE(salary, 5) OVER(PARTITION BY department 
                          ORDER BY first_name ASC) AS fifth_salary 
FROM employees



