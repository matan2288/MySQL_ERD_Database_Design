
-- ============== Sample Data Insertion ==============

-- Sample offices
INSERT INTO offices (officeCode, city, address, country) VALUES
('1', 'Tel Aviv', 'Rothschild Blvd 1', 'Israel'),
('2', 'Jerusalem', 'King George St 10', 'Israel'),
('3', 'Haifa', 'Herzl St 5', 'Israel');

-- Sample product lines
INSERT INTO product_lines (productLine, description) VALUES
('Classic Cars', 'Attention car enthusiasts: Make your wildest car ownership dreams come true.'),
('Motorcycles', 'Our motorcycles are state of the art replicas of classic as well as contemporary motorcycle legends.'),
('Planes', 'Unique, diecast airplane and helicopter replicas suitable for museums, gift shops, or the home.');

-- Sample people
INSERT INTO people (firstName, lastName, email, phoneNumber) VALUES
('John', 'Doe', 'john.doe@example.com', '050-1234567'),
('Jane', 'Smith', 'jane.smith@example.com', '050-2345678'),
('Mike', 'Johnson', 'mike.johnson@example.com', '050-3456789'),
('Sarah', 'Williams', 'sarah.williams@example.com', '050-4567890');

-- Sample employees
INSERT INTO employees (personalID, jobTitle, officeCode, reportTo) VALUES
(1, 'Sales Manager', '1', NULL),
(2, 'Sales Rep', '1', 1);

-- Sample sales rep
INSERT INTO sales_rep (employeeNumber, region, hireDate, totalSales) VALUES
(2, 'Center', '2024-01-15', 50000.00);

-- Sample customers
INSERT INTO customers (personalID, salesRepEmployeeNumber, creditLimit) VALUES
(3, 2, 25000.00),
(4, 2, 15000.00);

-- Sample products
INSERT INTO products (productCode, productName, productLine, quantityInStock, price) VALUES
('S10_1678', '1969 Harley Davidson Ultimate Chopper', 'Motorcycles', 7933, 48.81),
('S10_1949', '1952 Alpine Renault 1300', 'Classic Cars', 7305, 98.58);

-- Sample orders
INSERT INTO orders (customerNumber, orderDate, requiredDate, status) VALUES
(1, '2025-01-01', '2025-01-10', 'Shipped'),
(2, '2025-01-02', '2025-01-12', 'In Process');

-- Sample order details
INSERT INTO order_details (orderNumber, productCode, quantityOrdered, priceEach) VALUES
(1, 'S10_1678', 2, 48.81),
(1, 'S10_1949', 1, 98.58),
(2, 'S10_1678', 1, 48.81);

-- Sample payments
INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount) VALUES
(1, 'HQ336336', '2025-01-05', 6543.23),
(2, 'JM555205', '2025-01-03', 14571.44);