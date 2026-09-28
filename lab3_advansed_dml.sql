-- Part A: Database and Table Setup

-- 1. Create database and tables

CREATE DATABASE advanced_lab
WITH
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);


-- Part B: Advanced INSERT Operations

-- 2. INSERT with column specification

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'John', 'Smith', 'IT');


-- 3. INSERT with DEFAULT values

ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 0;

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Alice', 'Brown', 'HR', DEFAULT, DEFAULT);


-- 4. INSERT multiple rows in single statement

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('Sales', 120000, 2),
    ('HR', 80000, 3);


-- 5. INSERT with expressions

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Michael', 'Wilson', 'IT', 50000 * 1.1, CURRENT_DATE);


-- 6. INSERT from SELECT (subquery)

CREATE TEMPORARY TABLE temp_employees (
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20)
);

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';


-- Part C: Complex UPDATE Operations

-- 7. UPDATE with arithmetic expressions

UPDATE employees
SET salary = salary * 1.10;


-- 8. UPDATE with WHERE clause and multiple conditions

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';


-- 9. UPDATE using CASE expression

UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;


-- 10. UPDATE with DEFAULT

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


-- 11. UPDATE with subquery

UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);


-- 12. UPDATE multiple columns

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- Part D: Advanced DELETE Operations

-- 13. DELETE with simple WHERE condition

DELETE FROM employees
WHERE status = 'Terminated';


-- 14. DELETE with complex WHERE clause

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


-- 15. DELETE with subquery

DELETE FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);


-- 16. DELETE with RETURNING clause

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- Part E: Operations with NULL Values

-- 17. INSERT with NULL values

INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Robert', 'Taylor', NULL, NULL);


-- 18. UPDATE NULL handling

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


-- 19. DELETE with NULL conditions

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


-- Part F: RETURNING Clause Operations

-- 20. INSERT with RETURNING

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Daniel', 'Anderson', 'IT', 65000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;


-- 21. UPDATE with RETURNING

WITH old_data AS (
    SELECT emp_id, salary AS old_salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM old_data o
WHERE e.emp_id = o.emp_id
RETURNING e.emp_id, o.old_salary, e.salary AS new_salary;


-- 22. DELETE with RETURNING all columns

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Part G: Advanced DML Patterns

-- 23. Conditional INSERT

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'John', 'Smith', 'IT', 60000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'John'
      AND last_name = 'Smith'
);


-- 24. UPDATE with JOIN logic using subqueries

UPDATE employees e
SET salary = salary *
    CASE
        WHEN (
            SELECT d.budget
            FROM departments d
            WHERE d.dept_name = e.department
        ) > 100000
        THEN 1.10
        ELSE 1.05
    END;


-- 25. Bulk operations

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Adam', 'Brown', 'IT', 50000, CURRENT_DATE),
    ('James', 'Wilson', 'Sales', 55000, CURRENT_DATE),
    ('Emma', 'Davis', 'HR', 60000, CURRENT_DATE),
    ('Oliver', 'Taylor', 'IT', 65000, CURRENT_DATE),
    ('Sophia', 'Miller', 'Sales', 70000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Adam', 'James', 'Emma', 'Oliver', 'Sophia');


-- 26. Data migration simulation

CREATE TABLE employee_archive AS
SELECT *
FROM employees
WHERE FALSE;

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';


-- 27. Complex business logic

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d
        ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
  ) > 3;