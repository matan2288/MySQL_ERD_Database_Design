-- =========================================================
-- Master Database Initialization Script
-- Drops, creates, configures, and populates company_db
-- =========================================================

DROP DATABASE IF EXISTS company_db;
CREATE DATABASE company_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE company_db;

-- =========================================================
-- 1. Base People & Roles (ISA Hierarchy)
-- =========================================================

-- Base table for all persons
CREATE TABLE people (
    personalID   INT PRIMARY KEY AUTO_INCREMENT,
    firstName    VARCHAR(30) NOT NULL,
    lastName     VARCHAR(30) NOT NULL,
    email        VARCHAR(50) UNIQUE,
    phoneNumber  VARCHAR(15),
    CHECK (CHAR_LENGTH(firstName) BETWEEN 1 AND 30),
    CHECK (CHAR_LENGTH(lastName)  BETWEEN 1 AND 30)
);

-- Company Offices
CREATE TABLE offices (
    officeCode VARCHAR(15) PRIMARY KEY,
    city       VARCHAR(50) NOT NULL,
    address    VARCHAR(50),
    country    VARCHAR(50) NOT NULL
);

-- Employees (ISA subtype of people)
CREATE TABLE employees (
    employeeNumber INT PRIMARY KEY AUTO_INCREMENT,
    personalID     INT NOT NULL UNIQUE,
    jobTitle       VARCHAR(50) NOT NULL,
    officeCode     VARCHAR(15) NOT NULL,
    reportTo       INT NULL,

    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    FOREIGN KEY (officeCode) REFERENCES offices(officeCode) ON DELETE RESTRICT,
    FOREIGN KEY (reportTo) REFERENCES employees(employeeNumber) ON DELETE SET NULL,

    CHECK (CHAR_LENGTH(jobTitle) BETWEEN 1 AND 50)
);

-- Engineers (ISA subtype of people)
CREATE TABLE engineers (
    engineerID INT PRIMARY KEY AUTO_INCREMENT,
    personalID INT NOT NULL UNIQUE,
    expertise  VARCHAR(50) NOT NULL,
    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    CHECK (CHAR_LENGTH(expertise) BETWEEN 1 AND 50)
);

-- Sales Representatives (1:1 subtype of employees)
CREATE TABLE sales_rep (
    salesRepId     INT PRIMARY KEY AUTO_INCREMENT,
    employeeNumber INT NOT NULL UNIQUE,
    region         VARCHAR(50) NOT NULL,
    hireDate       DATE NOT NULL,
    totalSales     DECIMAL(15,2) DEFAULT 0.00,

    FOREIGN KEY (employeeNumber) REFERENCES employees(employeeNumber) ON DELETE CASCADE,

    CHECK (totalSales >= 0),
    CHECK (CHAR_LENGTH(region) BETWEEN 1 AND 50),
    CHECK (hireDate <= CURRENT_DATE)
);

-- Customers (ISA subtype of people)
CREATE TABLE customers (
    customerNumber         INT PRIMARY KEY AUTO_INCREMENT,
    personalID             INT NOT NULL UNIQUE,
    salesRepEmployeeNumber INT NULL,
    creditLimit            DECIMAL(10,2) DEFAULT 0.00,

    FOREIGN KEY (personalID)             REFERENCES people(personalID) ON DELETE CASCADE,
    FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees(employeeNumber) ON DELETE SET NULL,

    CHECK (creditLimit >= 0)
);

-- =========================================================
-- 2. Products Domain
-- =========================================================

CREATE TABLE product_lines (
    productLine VARCHAR(50) PRIMARY KEY,
    description TEXT
);

CREATE TABLE products (
    productCode     VARCHAR(15) PRIMARY KEY,
    productName     VARCHAR(50) NOT NULL,
    productLine     VARCHAR(50) NOT NULL,
    quantityInStock INT NOT NULL DEFAULT 0,
    price           DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (productLine) REFERENCES product_lines(productLine) ON DELETE RESTRICT,

    CHECK (quantityInStock >= 0),
    CHECK (price >= 0),
    CHECK (CHAR_LENGTH(productName) BETWEEN 1 AND 50)
);

-- =========================================================
-- 3. Sales & Fulfillment
-- =========================================================

CREATE TABLE orders (
    orderNumber    INT PRIMARY KEY AUTO_INCREMENT,
    customerNumber INT NOT NULL,
    orderDate      DATE NOT NULL,
    requiredDate   DATE NOT NULL,
    shippedDate    DATE NULL,
    status         VARCHAR(50) NOT NULL,

    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber) ON DELETE RESTRICT,

    CHECK (status IN ('Pending','Processed','In Process','Shipped','Cancelled')),
    CHECK (requiredDate >= orderDate),
    CHECK (shippedDate IS NULL OR shippedDate >= orderDate),
    CHECK (orderDate <= CURRENT_DATE)
);

-- N:M between orders and products
CREATE TABLE order_details (
    orderNumber     INT NOT NULL,
    productCode     VARCHAR(15) NOT NULL,
    quantityOrdered INT NOT NULL,
    priceEach       DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (orderNumber, productCode),
    FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber)   ON DELETE CASCADE,
    FOREIGN KEY (productCode) REFERENCES products(productCode) ON DELETE RESTRICT,

    CHECK (quantityOrdered > 0),
    CHECK (priceEach >= 0)
);

CREATE TABLE payments (
    customerNumber INT NOT NULL,
    checkNumber    VARCHAR(50) NOT NULL,
    paymentDate    DATE NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (customerNumber, checkNumber),
    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber) ON DELETE RESTRICT,

    CHECK (amount > 0),
    CHECK (paymentDate <= CURRENT_DATE)
);

-- =========================================================
-- 4. Indexes for Query Performance
-- =========================================================

CREATE INDEX idx_people_email            ON people(email);
CREATE INDEX idx_employees_office        ON employees(officeCode);
CREATE INDEX idx_employees_reportto      ON employees(reportTo);
CREATE INDEX idx_customers_salesrep      ON customers(salesRepEmployeeNumber);
CREATE INDEX idx_products_line           ON products(productLine);
CREATE INDEX idx_orders_customer         ON orders(customerNumber);
CREATE INDEX idx_orders_date             ON orders(orderDate);
CREATE INDEX idx_order_details_product   ON order_details(productCode);
CREATE INDEX idx_payments_date           ON payments(paymentDate);

-- =========================================================
-- 5. Seed Data
-- =========================================================

-- Offices
INSERT INTO offices (officeCode, city, address, country) VALUES
('1', 'Tel Aviv', 'Rothschild Blvd 1', 'Israel'),
('2', 'Jerusalem', 'King George St 10', 'Israel'),
('3', 'Haifa', 'Herzl St 5', 'Israel');

-- Product Lines
INSERT INTO product_lines (productLine, description) VALUES
('Classic Cars', 'Attention car enthusiasts: Make your wildest car ownership dreams come true.'),
('Motorcycles', 'Our motorcycles are state of the art replicas of classic as well as contemporary motorcycle legends.'),
('Planes', 'Unique, diecast airplane and helicopter replicas suitable for museums, gift shops, or the home.');

-- People (Base Entity)
INSERT INTO people (firstName, lastName, email, phoneNumber) VALUES
('John', 'Doe', 'john.doe@example.com', '050-1234567'),
('Jane', 'Smith', 'jane.smith@example.com', '050-2345678'),
('Mike', 'Johnson', 'mike.johnson@example.com', '050-3456789'),
('Sarah', 'Williams', 'sarah.williams@example.com', '050-4567890'),
('David', 'Cohen', 'david.cohen@example.com', '052-5551234'),
('Rachel', 'Levi', 'rachel.levi@example.com', '054-9998877');

-- Employees
INSERT INTO employees (personalID, jobTitle, officeCode, reportTo) VALUES
(1, 'Sales Manager', '1', NULL),
(2, 'Sales Rep', '1', 1);

-- Engineers
INSERT INTO engineers (personalID, expertise) VALUES
(5, 'Database Architecture'),
(6, 'DevOps & Cloud');

-- Sales Representatives
INSERT INTO sales_rep (employeeNumber, region, hireDate, totalSales) VALUES
(2, 'Center', '2024-01-15', 50000.00);

-- Customers
INSERT INTO customers (personalID, salesRepEmployeeNumber, creditLimit) VALUES
(3, 2, 25000.00),
(4, 2, 15000.00);

-- Products
INSERT INTO products (productCode, productName, productLine, quantityInStock, price) VALUES
('S10_1678', '1969 Harley Davidson Ultimate Chopper', 'Motorcycles', 7933, 48.81),
('S10_1949', '1952 Alpine Renault 1300', 'Classic Cars', 7305, 98.58),
('S18_1342', '1937 Lincoln Berline', 'Classic Cars', 2014, 102.74),
('S700_1691', 'American Airlines B777-200ER', 'Planes', 6884, 51.15);

-- Orders
INSERT INTO orders (customerNumber, orderDate, requiredDate, shippedDate, status) VALUES
(1, '2025-01-01', '2025-01-10', '2025-01-05', 'Shipped'),
(2, '2025-01-02', '2025-01-12', NULL, 'In Process');

-- Order Details
INSERT INTO order_details (orderNumber, productCode, quantityOrdered, priceEach) VALUES
(1, 'S10_1678', 2, 48.81),
(1, 'S10_1949', 1, 98.58),
(2, 'S10_1678', 1, 48.81),
(2, 'S700_1691', 3, 51.15);

-- Payments
INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount) VALUES
(1, 'HQ336336', '2025-01-05', 6543.23),
(2, 'JM555205', '2025-01-03', 14571.44);
