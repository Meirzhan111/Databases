-- PART 1: BASIC SELECT QUERIES

-- Task 1.1
-- Select all employees with full name, department and salary

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    department,
    salary
FROM employees;


-- Task 1.2
-- Find all unique departments

SELECT DISTINCT
    department
FROM employees;


-- Task 1.3
-- Select projects with budget category

SELECT
    project_name,
    budget,
    CASE
        WHEN budget > 150000 THEN 'Large'
        WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
        ELSE 'Small'
    END AS budget_category
FROM projects;


-- Task 1.4
-- Display employee names and emails using COALESCE

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    COALESCE(email, 'No email provided') AS email
FROM employees;


-- PART 2: WHERE CLAUSE AND COMPARISON OPERATORS
-- Task 2.1
-- Employees hired after January 1, 2020

SELECT *
FROM employees
WHERE hire_date > '2020-01-01';


-- Task 2.2
-- Employees with salary between 60000 and 70000

SELECT *
FROM employees
WHERE salary BETWEEN 60000 AND 70000;


-- Task 2.3
-- Employees whose last name starts with S or J

SELECT *
FROM employees
WHERE last_name LIKE 'S%'
   OR last_name LIKE 'J%';


-- Task 2.4
-- Employees who have a manager and work in IT

SELECT *
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT';


-- PART 3: STRING AND MATHEMATICAL FUNCTIONS

-- Task 3.1
-- Uppercase names, last name length and first 3 characters of email

SELECT
    UPPER(CONCAT(first_name, ' ', last_name)) AS full_name,
    LENGTH(last_name) AS last_name_length,
    SUBSTRING(email FROM 1 FOR 3) AS email_first_3
FROM employees;


-- Task 3.2
-- Annual salary, monthly salary and 10% raise

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary AS annual_salary,
    ROUND(salary / 12, 2) AS monthly_salary,
    salary * 0.10 AS raise_amount
FROM employees;


-- Task 3.3
-- Formatted project information

SELECT
    FORMAT(
        'Project: %s - Budget: $%s - Status: %s',
        project_name,
        budget,
        status
    ) AS project_info
FROM projects;


-- Task 3.4
-- Calculate how many years each employee has worked

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;



-- PART 4: AGGREGATE FUNCTIONS AND GROUP BY

-- Task 4.1
-- Average salary for each department

SELECT
    department,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department;


-- Task 4.2
-- Total hours worked on each project

SELECT
    p.project_name,
    COALESCE(SUM(a.hours_worked), 0) AS total_hours
FROM projects p
LEFT JOIN assignments a
    ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name;


-- Task 4.3
-- Count employees in each department
-- Only departments with more than 1 employee

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;


-- Task 4.4
-- Maximum salary, minimum salary and total payroll

SELECT
    MAX(salary) AS maximum_salary,
    MIN(salary) AS minimum_salary,
    SUM(salary) AS total_payroll
FROM employees;


-- PART 5: SET OPERATIONS

-- Task 5.1
-- UNION: employees with salary > 65000
-- OR employees hired after 2020-01-01

SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary
FROM employees
WHERE salary > 65000

UNION

SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary
FROM employees
WHERE hire_date > '2020-01-01';


-- Task 5.2
-- INTERSECT: employees who work in IT
-- AND have salary greater than 65000

SELECT
    employee_id
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT
    employee_id
FROM employees
WHERE salary > 65000;


-- Task 5.3
-- EXCEPT: employees who are not assigned to any projects

SELECT
    employee_id
FROM employees

EXCEPT

SELECT
    employee_id
FROM assignments;


-- PART 6: SUBQUERIES

-- Task 6.1
-- Employees who have at least one project assignment

SELECT
    e.*
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
);


-- Task 6.2
-- Employees working on Active projects

SELECT *
FROM employees
WHERE employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    JOIN projects p
        ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);


-- Task 6.3
-- Employees whose salary is greater than ANY
-- employee in the Sales department

SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);


-- PART 7: COMPLEX QUERIES

-- Task 7.1
-- Employee name, department, average hours worked
-- and rank within department by salary

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.department,
    COALESCE(AVG(a.hours_worked), 0) AS average_hours,
    RANK() OVER (
        PARTITION BY e.department
        ORDER BY e.salary DESC
    ) AS salary_rank
FROM employees e
LEFT JOIN assignments a
    ON e.employee_id = a.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    e.salary;


-- Task 7.2
-- Projects where total hours worked exceeds 150

SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS number_of_employees
FROM projects p
JOIN assignments a
    ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;


-- Task 7.3
-- Department report:
-- total employees, average salary,
-- highest paid employee
-- Using GREATEST and LEAST

SELECT
    e.department,
    COUNT(*) AS total_employees,
    ROUND(AVG(e.salary), 2) AS average_salary,
    (
        SELECT CONCAT(e2.first_name, ' ', e2.last_name)
        FROM employees e2
        WHERE e2.department = e.department
        ORDER BY e2.salary DESC
        LIMIT 1
    ) AS highest_paid_employee,
    GREATEST(MAX(e.salary), AVG(e.salary)) AS greatest_salary_value,
    LEAST(MIN(e.salary), AVG(e.salary)) AS least_salary_value
FROM employees e
GROUP BY e.department;