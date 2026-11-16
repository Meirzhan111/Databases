-- Part 1: Database Setup
-- Use existing employees, departments, and projects tables from Lab 6 and Lab 7.


-- Part 2: Creating Basic Indexes

-- Exercise 2.1: Simple B-tree Index
CREATE INDEX IF NOT EXISTS emp_salary_idx
ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Answer: 2 indexes at this stage:
-- 1. Primary key index (created automatically).
-- 2. emp_salary_idx.


-- Exercise 2.2: Index on a Foreign Key
CREATE INDEX IF NOT EXISTS emp_dept_idx
ON employees(dept_id);

SELECT *
FROM employees
WHERE dept_id = 101;

-- Answer: Indexing foreign keys improves JOIN and search performance.


-- Exercise 2.3: View Index Information
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Primary key indexes are created automatically.
-- Other indexes are created manually.


-- Part 3: Multicolumn Indexes

-- Exercise 3.1
CREATE INDEX IF NOT EXISTS emp_dept_salary_idx
ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Answer: This index is not efficient for queries filtering only by salary,
-- because dept_id is the first column in the index.


-- Exercise 3.2
CREATE INDEX IF NOT EXISTS emp_salary_dept_idx
ON employees(salary, dept_id);

-- Query 1
SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;

-- Query 2
SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;

-- Answer: Yes, column order matters.
-- B-tree indexes work most efficiently when queries use the leftmost column.
-- The first index is useful for dept_id and salary.
-- The second index is useful for salary and dept_id.


-- Part 4: Unique Indexes

-- Exercise 4.1
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS email VARCHAR(100);

UPDATE employees
SET email = 'john.smith@company.com'
WHERE emp_id = 1;

UPDATE employees
SET email = 'jane.doe@company.com'
WHERE emp_id = 2;

UPDATE employees
SET email = 'mike.johnson@company.com'
WHERE emp_id = 3;

UPDATE employees
SET email = 'sarah.williams@company.com'
WHERE emp_id = 4;

UPDATE employees
SET email = 'tom.brown@company.com'
WHERE emp_id = 5;

CREATE UNIQUE INDEX IF NOT EXISTS emp_email_unique_idx
ON employees(email);

-- This INSERT should fail with a unique violation error.
-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Answer: ERROR: duplicate key value violates unique constraint.


-- Exercise 4.2
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
AND indexname LIKE '%phone%';

-- Answer: Yes, PostgreSQL automatically creates a unique B-tree index.


-- Part 5: Indexes and Sorting

-- Exercise 5.1
CREATE INDEX IF NOT EXISTS emp_salary_desc_idx
ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Answer: The index helps PostgreSQL retrieve rows in descending salary order.


-- Exercise 5.2
CREATE INDEX IF NOT EXISTS proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

SELECT project_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- Part 6: Indexes on Expressions

-- Exercise 6.1
CREATE INDEX IF NOT EXISTS emp_name_lower_idx
ON employees(LOWER(emp_name));

SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

-- Answer: Without this index, PostgreSQL may perform a sequential scan
-- and apply LOWER() to every employee name.


-- Exercise 6.2
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS hire_date DATE;

UPDATE employees
SET hire_date = '2020-01-15'
WHERE emp_id = 1;

UPDATE employees
SET hire_date = '2019-06-20'
WHERE emp_id = 2;

UPDATE employees
SET hire_date = '2021-03-10'
WHERE emp_id = 3;

UPDATE employees
SET hire_date = '2020-11-05'
WHERE emp_id = 4;

UPDATE employees
SET hire_date = '2018-08-25'
WHERE emp_id = 5;

CREATE INDEX IF NOT EXISTS emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- Part 7: Managing Indexes

-- Exercise 7.1
ALTER INDEX emp_salary_idx
RENAME TO employees_salary_index;

SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';

-- Exercise 7.2
DROP INDEX IF EXISTS emp_salary_dept_idx;

-- Answer: We drop unused or duplicate indexes to save disk space
-- and improve INSERT, UPDATE, and DELETE performance.


-- Exercise 7.3
REINDEX INDEX employees_salary_index;

-- Answer: REINDEX rebuilds an index.
-- It is useful when an index becomes bloated or needs optimization.


-- Part 8: Practical Scenarios

-- Exercise 8.1
-- Index for the WHERE clause
CREATE INDEX IF NOT EXISTS emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

-- Index for the JOIN
-- Already created: emp_dept_idx.

-- Index for ORDER BY
-- Already created: emp_salary_desc_idx.

SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;


-- Exercise 8.2: Partial Index
CREATE INDEX IF NOT EXISTS proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT project_name, budget
FROM projects
WHERE budget > 80000;

-- Answer: A partial index uses less disk space because
-- it indexes only rows that satisfy the condition.


-- Exercise 8.3: Analyze Index Usage
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;

-- Answer: Index Scan means PostgreSQL uses an index.
-- Seq Scan means PostgreSQL scans the entire table.
-- With a small table, PostgreSQL may choose Seq Scan.


-- Part 9: Index Types Comparison

-- Exercise 9.1: Hash Index
CREATE INDEX IF NOT EXISTS dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT *
FROM departments
WHERE dept_name = 'IT';

-- Answer: HASH indexes are useful for equality comparisons (=).


-- Exercise 9.2: Compare Index Types

-- B-tree index
CREATE INDEX IF NOT EXISTS proj_name_btree_idx
ON projects(project_name);

-- Hash index
CREATE INDEX IF NOT EXISTS proj_name_hash_idx
ON projects USING HASH (project_name);

-- Equality search: B-tree or Hash
SELECT *
FROM projects
WHERE project_name = 'Website Redesign';

-- Range search: B-tree
SELECT *
FROM projects
WHERE project_name > 'Database';

-- Answer: B-tree supports equality and range searches.
-- Hash supports equality searches only.


-- Part 10: Cleanup and Best Practices

-- Exercise 10.1: Review All Indexes
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(
        pg_relation_size(indexname::regclass)
    ) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer: The largest index depends on the amount of data
-- and the number of indexed columns.


-- Exercise 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Keep only necessary indexes.


-- Exercise 10.3: Document Your Indexes
CREATE OR REPLACE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;


-- Summary Questions

-- 1. What is the default index type in PostgreSQL?
-- B-tree.

-- 2. Name three scenarios where you should create an index:
-- WHERE clauses, JOIN conditions, and ORDER BY operations.

-- 3. Name two scenarios where you should NOT create an index:
-- On rarely queried columns and on very small tables when unnecessary.

-- 4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
-- PostgreSQL automatically updates the related indexes.
-- These operations can become slower.

-- 5. How can you check if a query is using an index?
-- Use EXPLAIN or EXPLAIN ANALYZE.


-- Brief Reflection
-- Indexes improve query performance and make data retrieval faster.
-- However, they consume disk space and can slow down data modifications.
-- Therefore, indexes should be created only on frequently queried columns.