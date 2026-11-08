-- ============== Database Creation ==============
-- DROP DATABASE IF EXISTS company_db;
-- CREATE DATABASE company_db;
-- USE company_db;

-- =========================================================
-- People & Roles (ISA Hierarchy)
-- =========================================================

-- Base table for all people (aligned to table spec)
CREATE TABLE people (
    personalID   INT PRIMARY KEY AUTO_INCREMENT,
    firstName    VARCHAR(30) NOT NULL,           -- was 50 -> table shows 30
    lastName     VARCHAR(30) NOT NULL,           -- was 50 -> table shows 30
    email        VARCHAR(50) UNIQUE,             -- table shows 50
    phoneNumber  VARCHAR(15),                    -- aligns with DBML varchar(15) to accommodate formatted phone numbers (e.g., 050-1234567)
    CHECK (CHAR_LENGTH(firstName) BETWEEN 1 AND 30),
    CHECK (CHAR_LENGTH(lastName)  BETWEEN 1 AND 30)
);

-- Offices (aligned to table spec)
CREATE TABLE offices (
    officeCode VARCHAR(15) PRIMARY KEY,          -- was 10 -> table shows 15
    city       VARCHAR(50) NOT NULL,
    address    VARCHAR(50),                      -- was 200 -> table shows 50
    country    VARCHAR(50) NOT NULL
);

-- Employees (ISA from people)
CREATE TABLE employees (
    employeeNumber INT PRIMARY KEY AUTO_INCREMENT,
    personalID     INT NOT NULL UNIQUE,          -- subtype 1:1 to people
    jobTitle       VARCHAR(50) NOT NULL,
    officeCode     VARCHAR(15) NOT NULL,         -- match offices PK length
    reportTo       INT NULL,                     -- recursive FK (manager)

    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    FOREIGN KEY (officeCode) REFERENCES offices(officeCode) ON DELETE RESTRICT,
    FOREIGN KEY (reportTo) REFERENCES employees(employeeNumber) ON DELETE SET NULL,

    CHECK (CHAR_LENGTH(jobTitle) BETWEEN 1 AND 50)
);

-- Engineers (ISA from people)
CREATE TABLE engineers (
    engineerID INT PRIMARY KEY AUTO_INCREMENT,
    personalID INT NOT NULL UNIQUE,
    expertise  VARCHAR(50) NOT NULL,             -- table shows up to 50, chosen list enforced at app level
    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    CHECK (CHAR_LENGTH(expertise) BETWEEN 1 AND 50)
);

-- Sales Representatives (subset of employees)
CREATE TABLE sales_rep (
    salesRepId     INT PRIMARY KEY AUTO_INCREMENT,
    employeeNumber INT NOT NULL UNIQUE,          -- 1:1 with an employee
    region         VARCHAR(50) NOT NULL,
    hireDate       DATE NOT NULL,
    totalSales     DECIMAL(15,2) DEFAULT 0.00,

    FOREIGN KEY (employeeNumber) REFERENCES employees(employeeNumber) ON DELETE CASCADE,

    CHECK (totalSales >= 0),
    CHECK (CHAR_LENGTH(region) BETWEEN 1 AND 50),
    CHECK (hireDate <= CURRENT_DATE)             -- הגיוני יותר מה"גדול מהיום" שנכתב בטבלה
);

-- Customers (ISA from people)
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
-- Products Domain
-- =========================================================

CREATE TABLE product_lines (
    productLine VARCHAR(50) PRIMARY KEY,
    description TEXT
);

CREATE TABLE products (
    productCode     VARCHAR(15) PRIMARY KEY,     -- table shows 15 (and used by order_details FK)
    productName     VARCHAR(50) NOT NULL,        -- was 70 -> table shows 50
    productLine     VARCHAR(50) NOT NULL,
    quantityInStock INT NOT NULL DEFAULT 0,
    price           DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (productLine) REFERENCES product_lines(productLine) ON DELETE RESTRICT,

    CHECK (quantityInStock >= 0),
    CHECK (price >= 0),
    CHECK (CHAR_LENGTH(productName) BETWEEN 1 AND 50)
);

-- =========================================================
-- Sales & Fulfillment
-- =========================================================

CREATE TABLE orders (
    orderNumber   INT PRIMARY KEY AUTO_INCREMENT,
    customerNumber INT NOT NULL,
    orderDate     DATE NOT NULL,
    requiredDate  DATE NOT NULL,
    shippedDate   DATE NULL,
    status        VARCHAR(50) NOT NULL,          -- table shows VARCHAR(50)

    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber) ON DELETE RESTRICT,

    -- table text listed (Pending Processed, Shipped, Cancelled) -> interpret as {'Pending','Processed','Shipped','Cancelled'}
    CHECK (status IN ('Pending','Processed','In Process','Shipped','Cancelled')),
    CHECK (requiredDate >= orderDate),
    CHECK (shippedDate IS NULL OR shippedDate >= orderDate),
    CHECK (orderDate <= CURRENT_DATE)
);

-- N:M between orders and products
CREATE TABLE order_details (
    orderNumber     INT NOT NULL,
    productCode     VARCHAR(15) NOT NULL,        -- table showed 30, but must equal products(15) for FK integrity
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
-- Indexes for Performance (FKs / common lookups)
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
