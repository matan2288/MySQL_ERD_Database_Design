-- =========================================================
-- Sample Analytical & Operational Queries
-- Designed for company_db
-- =========================================================

USE company_db;

-- 1. Full Profile of Employees with Office Location and Manager Name
SELECT 
    e.employeeNumber,
    CONCAT(p.firstName, ' ', p.lastName) AS employeeName,
    p.email,
    p.phoneNumber,
    e.jobTitle,
    o.city AS officeCity,
    o.country AS officeCountry,
    CONCAT(mp.firstName, ' ', mp.lastName) AS managerName
FROM employees e
JOIN people p ON e.personalID = p.personalID
JOIN offices o ON e.officeCode = o.officeCode
LEFT JOIN employees m ON e.reportTo = m.employeeNumber
LEFT JOIN people mp ON m.personalID = mp.personalID;

-- 2. Sales Representatives Performance & Assigned Customers
SELECT 
    sr.salesRepId,
    CONCAT(p.firstName, ' ', p.lastName) AS repName,
    sr.region,
    sr.hireDate,
    sr.totalSales,
    COUNT(c.customerNumber) AS assignedCustomersCount
FROM sales_rep sr
JOIN employees e ON sr.employeeNumber = e.employeeNumber
JOIN people p ON e.personalID = p.personalID
LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY sr.salesRepId, repName, sr.region, sr.hireDate, sr.totalSales;

-- 3. Customer Order Summary with Total Order Value and Status
SELECT 
    o.orderNumber,
    CONCAT(p.firstName, ' ', p.lastName) AS customerName,
    o.orderDate,
    o.status,
    COUNT(od.productCode) AS distinctItems,
    SUM(od.quantityOrdered) AS totalUnitsOrdered,
    SUM(od.quantityOrdered * od.priceEach) AS totalOrderValue
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN people p ON c.personalID = p.personalID
JOIN order_details od ON o.orderNumber = od.orderNumber
GROUP BY o.orderNumber, customerName, o.orderDate, o.status;

-- 4. Customer Balance Overview (Total Ordered vs Total Paid)
WITH OrderTotals AS (
    SELECT 
        o.customerNumber,
        SUM(od.quantityOrdered * od.priceEach) AS totalBilled
    FROM orders o
    JOIN order_details od ON o.orderNumber = od.orderNumber
    GROUP BY o.customerNumber
),
PaymentTotals AS (
    SELECT 
        customerNumber,
        SUM(amount) AS totalPaid
    FROM payments
    GROUP BY customerNumber
)
SELECT 
    c.customerNumber,
    CONCAT(p.firstName, ' ', p.lastName) AS customerName,
    c.creditLimit,
    COALESCE(ot.totalBilled, 0.00) AS totalBilled,
    COALESCE(pt.totalPaid, 0.00) AS totalPaid,
    (COALESCE(ot.totalBilled, 0.00) - COALESCE(pt.totalPaid, 0.00)) AS outstandingBalance
FROM customers c
JOIN people p ON c.personalID = p.personalID
LEFT JOIN OrderTotals ot ON c.customerNumber = ot.customerNumber
LEFT JOIN PaymentTotals pt ON c.customerNumber = pt.customerNumber;

-- 5. Inventory & Product Line Distribution
SELECT 
    pl.productLine,
    COUNT(pr.productCode) AS totalProducts,
    SUM(pr.quantityInStock) AS totalStockUnits,
    AVG(pr.price) AS averagePrice
FROM product_lines pl
LEFT JOIN products pr ON pl.productLine = pr.productLine
GROUP BY pl.productLine;

-- 6. People Polymorphic Subtype Verification (ISA Disjointness Check)
SELECT 
    p.personalID,
    CONCAT(p.firstName, ' ', p.lastName) AS fullName,
    p.email,
    CASE 
        WHEN e.employeeNumber IS NOT NULL THEN 'Employee'
        WHEN eng.engineerID IS NOT NULL THEN 'Engineer'
        WHEN c.customerNumber IS NOT NULL THEN 'Customer'
        ELSE 'Unassigned'
    END AS personRole
FROM people p
LEFT JOIN employees e ON p.personalID = e.personalID
LEFT JOIN engineers eng ON p.personalID = eng.personalID
LEFT JOIN customers c ON p.personalID = c.personalID;
