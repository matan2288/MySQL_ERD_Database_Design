CREATE TABLE people (
    personalID INT PRIMARY KEY AUTO_INCREMENT,
    firstName VARCHAR(30) NOT NULL,
    lastName VARCHAR(30) NOT NULL,
    email VARCHAR(50) UNIQUE,
    phoneNumber VARCHAR(15),
    CHECK (CHAR_LENGTH(firstName) BETWEEN 1 AND 30),
    CHECK (CHAR_LENGTH(lastName) BETWEEN 1 AND 30)
);

CREATE TABLE offices (
    officeCode VARCHAR(15) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(50),
    country VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    employeeNumber INT PRIMARY KEY AUTO_INCREMENT,
    personalID INT NOT NULL UNIQUE,
    jobTitle VARCHAR(50) NOT NULL,
    officeCode VARCHAR(15) NOT NULL,
    reportTo INT NULL,
    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    FOREIGN KEY (officeCode) REFERENCES offices(officeCode) ON DELETE RESTRICT,
    FOREIGN KEY (reportTo) REFERENCES employees(employeeNumber) ON DELETE SET NULL,
    CHECK (CHAR_LENGTH(jobTitle) BETWEEN 1 AND 50)
);

CREATE TABLE engineers (
    engineerID INT PRIMARY KEY AUTO_INCREMENT,
    personalID INT NOT NULL UNIQUE,
    expertise VARCHAR(50) NOT NULL,
    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    CHECK (CHAR_LENGTH(expertise) BETWEEN 1 AND 50)
);

CREATE TABLE sales_rep (
    salesRepId INT PRIMARY KEY AUTO_INCREMENT,
    employeeNumber INT NOT NULL UNIQUE,
    region VARCHAR(50) NOT NULL,
    hireDate DATE NOT NULL,
    totalSales DECIMAL(15,2) DEFAULT 0.00,
    FOREIGN KEY (employeeNumber) REFERENCES employees(employeeNumber) ON DELETE CASCADE,
    CHECK (totalSales >= 0),
    CHECK (CHAR_LENGTH(region) BETWEEN 1 AND 50),
    CHECK (hireDate <= CURRENT_DATE)
);

CREATE TABLE customers (
    customerNumber INT PRIMARY KEY AUTO_INCREMENT,
    personalID INT NOT NULL UNIQUE,
    salesRepEmployeeNumber INT NULL,
    creditLimit DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (personalID) REFERENCES people(personalID) ON DELETE CASCADE,
    FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees(employeeNumber) ON DELETE SET NULL,
    CHECK (creditLimit >= 0)
);

CREATE TABLE product_lines (
    productLine VARCHAR(50) PRIMARY KEY,
    description TEXT
);

CREATE TABLE products (
    productCode VARCHAR(15) PRIMARY KEY,
    productName VARCHAR(50) NOT NULL,
    productLine VARCHAR(50) NOT NULL,
    quantityInStock INT NOT NULL DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (productLine) REFERENCES product_lines(productLine) ON DELETE RESTRICT,
    CHECK (quantityInStock >= 0),
    CHECK (price >= 0),
    CHECK (CHAR_LENGTH(productName) BETWEEN 1 AND 50)
);

CREATE TABLE orders (
    orderNumber INT PRIMARY KEY AUTO_INCREMENT,
    customerNumber INT NOT NULL,
    orderDate DATE NOT NULL,
    requiredDate DATE NOT NULL,
    shippedDate DATE NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber) ON DELETE RESTRICT,
    CHECK (status IN ('Pending','Processed','In Process','Shipped','Cancelled')),
    CHECK (requiredDate >= orderDate),
    CHECK (shippedDate IS NULL OR shippedDate >= orderDate),
    CHECK (orderDate <= CURRENT_DATE)
);

CREATE TABLE order_details (
    orderNumber INT NOT NULL,
    productCode VARCHAR(15) NOT NULL,
    quantityOrdered INT NOT NULL,
    priceEach DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (orderNumber, productCode),
    FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber) ON DELETE CASCADE,
    FOREIGN KEY (productCode) REFERENCES products(productCode) ON DELETE RESTRICT,
    CHECK (quantityOrdered > 0),
    CHECK (priceEach >= 0)
);

CREATE TABLE payments (
    customerNumber INT NOT NULL,
    checkNumber VARCHAR(50) NOT NULL,
    paymentDate DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (customerNumber, checkNumber),
    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber) ON DELETE RESTRICT,
    CHECK (amount > 0),
    CHECK (paymentDate <= CURRENT_DATE)
);
