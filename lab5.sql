
-- Name: Kurmangali Meirzhan
-- Student ID: 25B031356
-- Database Constraints - Laboratory Work

-- Part 1: CHECK Constraints

-- Task 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES
(1, 'John', 'Smith', 30, 50000),
(2, 'Sarah', 'Brown', 45, 65000);

-- Invalid tests
-- INSERT INTO employees VALUES (3, 'Tom', 'Lee', 16, 30000);
-- Result: CHECK violation on age.
-- INSERT INTO employees VALUES (4, 'Anna', 'Kim', 25, 0);
-- Result: CHECK violation on salary.


-- Task 1.2
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

INSERT INTO products_catalog VALUES
(1, 'Laptop', 1500, 1200),
(2, 'Mouse', 50, 40);

-- Invalid tests
-- INSERT INTO products_catalog VALUES (3, 'Keyboard', 100, 120);
-- Result: valid_discount violation.
-- INSERT INTO products_catalog VALUES (4, 'Monitor', 0, 10);
-- Result: valid_discount violation.
-- INSERT INTO products_catalog VALUES (5, 'Tablet', 200, 0);
-- Result: valid_discount violation.


-- Task 1.3
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CONSTRAINT valid_num_guests CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_booking_dates CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES
(1, '2026-11-01', '2026-11-05', 2),
(2, '2026-12-10', '2026-12-15', 5);

-- Invalid tests
-- INSERT INTO bookings VALUES (3, '2026-11-01', '2026-11-03', 12);
-- Result: valid_num_guests violation.
-- INSERT INTO bookings VALUES (4, '2026-11-10', '2026-11-05', 2);
-- Result: valid_booking_dates violation.


-- Part 2: NOT NULL Constraints

-- Task 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

INSERT INTO customers VALUES
(1, 'john@example.com', '111111111', '2026-01-10'),
(2, 'sarah@example.com', NULL, '2026-02-15');

-- Invalid tests
-- INSERT INTO customers VALUES (3, NULL, '123456789', '2026-03-01');
-- Result: NOT NULL violation on email.
-- INSERT INTO customers VALUES (4, 'tom@example.com', NULL, NULL);
-- Result: NOT NULL violation on registration_date.


-- Task 2.2
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO inventory VALUES
(1, 'Laptop', 10, 1200, CURRENT_TIMESTAMP),
(2, 'Mouse', 50, 25, CURRENT_TIMESTAMP);

-- Invalid tests
-- INSERT INTO inventory VALUES (3, NULL, 10, 20, CURRENT_TIMESTAMP);
-- Result: NOT NULL violation on item_name.
-- INSERT INTO inventory VALUES (4, 'Keyboard', NULL, 50, CURRENT_TIMESTAMP);
-- Result: NOT NULL violation on quantity.
-- INSERT INTO inventory VALUES (5, 'Monitor', -1, 200, CURRENT_TIMESTAMP);
-- Result: CHECK violation on quantity.
-- INSERT INTO inventory VALUES (6, 'Tablet', 5, 0, CURRENT_TIMESTAMP);
-- Result: CHECK violation on unit_price.
-- INSERT INTO inventory VALUES (7, 'Phone', 5, 100, NULL);
-- Result: NOT NULL violation on last_updated.

-- Task 2.3
-- phone allows NULL, as demonstrated by customer 2 above.


-- Part 3: UNIQUE Constraints

-- Task 3.1
CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);


-- Task 3.2
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course_semester
        UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES
(1, 101, 'CS101', 'Fall 2026'),
(2, 101, 'CS102', 'Fall 2026'),
(3, 101, 'CS101', 'Spring 2027');

-- Invalid test
-- INSERT INTO course_enrollments VALUES (4, 101, 'CS101', 'Fall 2026');
-- Result: unique_student_course_semester violation.


-- Task 3.3
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES
(1, 'john_smith', 'john@example.com', CURRENT_TIMESTAMP),
(2, 'sarah_brown', 'sarah@example.com', CURRENT_TIMESTAMP);

-- Invalid tests
-- INSERT INTO users VALUES (3, 'john_smith', 'john2@example.com', CURRENT_TIMESTAMP);
-- Result: unique_username violation.
-- INSERT INTO users VALUES (4, 'tom_lee', 'john@example.com', CURRENT_TIMESTAMP);
-- Result: unique_email violation.


-- Part 4: PRIMARY KEY Constraints

-- Task 4.1
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'HR', 'Astana'),
(3, 'Finance', 'Shymkent');

-- Invalid tests
-- INSERT INTO departments VALUES (1, 'Marketing', 'Almaty');
-- Result: PRIMARY KEY violation.
-- INSERT INTO departments VALUES (NULL, 'Sales', 'Astana');
-- Result: PRIMARY KEY violation.


-- Task 4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES
(101, 1, '2026-09-01', 'A'),
(101, 2, '2026-09-01', 'B'),
(102, 1, '2026-09-02', 'A');

-- Invalid test
-- INSERT INTO student_courses VALUES (101, 1, '2026-09-05', 'B');
-- Result: PRIMARY KEY violation because (101, 1) already exists.


-- Task 4.3: Comparison Exercise
-- PRIMARY KEY uniquely identifies each row and cannot contain NULL.
-- UNIQUE prevents duplicate values and can allow NULL values.
-- A table can have only one PRIMARY KEY but multiple UNIQUE constraints.
-- Use a single-column key when one column uniquely identifies a row.
-- Use a composite key when a combination of columns identifies a row.


-- Part 5: FOREIGN KEY Constraints

-- Task 5.1
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES
(1, 'John Smith', 1, '2024-01-10'),
(2, 'Sarah Brown', 2, '2024-03-15');

-- Invalid test
-- INSERT INTO employees_dept VALUES (3, 'Tom Lee', 99, '2025-01-01');
-- Result: FOREIGN KEY violation.


-- Task 5.2
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES
(1, 'George Orwell', 'United Kingdom'),
(2, 'Jane Austen', 'United Kingdom'),
(3, 'Mark Twain', 'United States'),
(4, 'Leo Tolstoy', 'Russia'),
(5, 'Chingiz Aitmatov', 'Kyrgyzstan');

INSERT INTO publishers VALUES
(1, 'Penguin Books', 'London'),
(2, 'Oxford University Press', 'Oxford'),
(3, 'HarperCollins', 'New York'),
(4, 'Vintage Books', 'London'),
(5, 'Bilkent Publishing', 'Bishkek');

INSERT INTO books VALUES
(1, '1984', 1, 1, 1949, '9780000000001'),
(2, 'Pride and Prejudice', 2, 2, 1813, '9780000000002'),
(3, 'Tom Sawyer', 3, 3, 1876, '9780000000003'),
(4, 'War and Peace', 4, 4, 1869, '9780000000004'),
(5, 'Jamila', 5, 5, 1958, '9780000000005');

-- Invalid tests
-- INSERT INTO books VALUES (6, 'Unknown Book', 99, 1, 2020, '9780000000006');
-- Result: FOREIGN KEY violation.
-- INSERT INTO books VALUES (7, 'Another Book', 1, 1, 2020, '9780000000001');
-- Result: UNIQUE violation on isbn.


-- Task 5.3
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id)
        ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Books');

INSERT INTO products_fk VALUES
(1, 'Laptop', 1),
(2, 'Novel', 2);

INSERT INTO orders VALUES
(1, '2026-10-01'),
(2, '2026-10-02');

INSERT INTO order_items VALUES
(1, 1, 1, 2),
(2, 1, 2, 1),
(3, 2, 2, 3);

-- Test RESTRICT: should fail while products reference the category.
-- DELETE FROM categories WHERE category_id = 1;
-- Result: FOREIGN KEY violation due to ON DELETE RESTRICT.

-- Test CASCADE: order items are automatically deleted.
DELETE FROM orders WHERE order_id = 1;

-- Verify remaining order items.
SELECT * FROM order_items;


-- Part 6: Practical Application

-- Task 6.1: E-commerce Database Design

CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL
        REFERENCES ecommerce_customers(customer_id)
        ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN (
            'pending',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    )
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL
        REFERENCES ecommerce_orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER NOT NULL
        REFERENCES ecommerce_products(product_id)
        ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Insert 5 customers
INSERT INTO ecommerce_customers VALUES
(1, 'John Smith', 'john@example.com', '111111111', '2026-01-10'),
(2, 'Sarah Brown', 'sarah@example.com', '222222222', '2026-02-12'),
(3, 'Michael Lee', 'michael@example.com', NULL, '2026-03-15'),
(4, 'Anna Kim', 'anna@example.com', '444444444', '2026-04-18'),
(5, 'David Wilson', 'david@example.com', NULL, '2026-05-20');

-- Insert 5 products
INSERT INTO ecommerce_products VALUES
(1, 'Laptop', 'Laptop computer', 1200, 10),
(2, 'Mouse', 'Wireless mouse', 25, 50),
(3, 'Keyboard', 'Mechanical keyboard', 75, 30),
(4, 'Monitor', 'Full HD monitor', 200, 15),
(5, 'Headphones', 'Wireless headphones', 100, 20);

-- Insert 5 orders
INSERT INTO ecommerce_orders VALUES
(1, 1, '2026-06-01', 1250, 'pending'),
(2, 2, '2026-06-02', 75, 'processing'),
(3, 3, '2026-06-03', 200, 'shipped'),
(4, 4, '2026-06-04', 100, 'delivered'),
(5, 5, '2026-06-05', 300, 'cancelled');

-- Insert 5 order details
INSERT INTO order_details VALUES
(1, 1, 1, 1, 1200),
(2, 1, 2, 2, 25),
(3, 2, 3, 1, 75),
(4, 3, 4, 1, 200),
(5, 4, 5, 1, 100);

-- Constraint tests

-- Duplicate customer email: UNIQUE violation.
-- INSERT INTO ecommerce_customers
-- VALUES (6, 'Duplicate User', 'john@example.com', NULL, '2026-06-10');

-- Negative price: CHECK violation.
-- INSERT INTO ecommerce_products
-- VALUES (6, 'Invalid Product', 'Negative price', -10, 5);

-- Negative stock: CHECK violation.
-- INSERT INTO ecommerce_products
-- VALUES (7, 'Invalid Stock', 'Negative stock', 10, -1);

-- Invalid status: CHECK violation.
-- INSERT INTO ecommerce_orders
-- VALUES (6, 1, '2026-06-10', 50, 'unknown');

-- Zero quantity: CHECK violation.
-- INSERT INTO order_details
-- VALUES (6, 1, 2, 0, 25);

-- Non-existent customer: FOREIGN KEY violation.
-- INSERT INTO ecommerce_orders
-- VALUES (7, 99, '2026-06-10', 50, 'pending');

-- Verify sample data
SELECT * FROM ecommerce_customers;
SELECT * FROM ecommerce_products;
SELECT * FROM ecommerce_orders;
SELECT * FROM order_details;