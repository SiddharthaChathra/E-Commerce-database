-- Create database
CREATE DATABASE IF NOT EXISTS ecom;
USE ecom;
DROP DATABASE IF EXISTS ecom;

-- Drop existing tables if needed (optional)
DROP TABLE IF EXISTS ProductLogs;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50)
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2),
    Stock INT
);

-- Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    Amount DECIMAL(10,2),
    PaymentDate DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- ProductLogs Table (AUTO_INCREMENT)
CREATE TABLE ProductLogs (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    Operation VARCHAR(50),
    OperationDate DATETIME
);

-- Triggers on Products Table
DELIMITER $$

CREATE TRIGGER trg_AfterInsertProduct
AFTER INSERT ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductLogs (ProductID, Operation, OperationDate)
    VALUES (NEW.ProductID, 'INSERT', NOW());
END$$

CREATE TRIGGER trg_AfterUpdateProduct
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductLogs (ProductID, Operation, OperationDate)
    VALUES (NEW.ProductID, 'UPDATE', NOW());
END$$

CREATE TRIGGER trg_AfterDeleteProduct
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductLogs (ProductID, Operation, OperationDate)
    VALUES (OLD.ProductID, 'DELETE', NOW());
END$$

DELIMITER ;

-- Inserting into Customers
INSERT INTO Customers VALUES 
(1, 'Alice', 'alice@mail.com', 'New York'),
(2, 'Bob', 'bob@mail.com', 'Chicago'),
(3, 'Charlie', 'charlie@mail.com', 'LA'),
(4, 'Diana', 'diana@mail.com', 'Dallas'),
(5, 'Eve', 'eve@mail.com', 'Miami');

-- Inserting into Products
INSERT INTO Products VALUES 
(101, 'Laptop', 800.00, 50),
(102, 'Phone', 500.00, 100),
(103, 'Tablet', 300.00, 75),
(104, 'Monitor', 200.00, 60),
(105, 'Keyboard', 40.00, 200);

-- Inserting into Orders
INSERT INTO Orders VALUES 
(201, 1, '2024-04-01'),
(202, 2, '2024-04-02'),
(203, 3, '2024-04-03'),
(204, 4, '2024-04-04'),
(205, 5, '2024-04-05');

-- Inserting into OrderDetails
INSERT INTO OrderDetails VALUES 
(301, 201, 101, 1),
(302, 202, 102, 2),
(303, 203, 103, 3),
(304, 204, 104, 1),
(305, 205, 105, 5);

-- Inserting into Payments
INSERT INTO Payments VALUES 
(401, 201, 800.00, '2024-04-01'),
(402, 202, 1000.00, '2024-04-02'),
(403, 203, 900.00, '2024-04-03'),
(404, 204, 200.00, '2024-04-04'),
(405, 205, 200.00, '2024-04-05');

-- Query 1: Customers who ordered more than 1 product
SELECT C.Name, OD.Quantity
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
WHERE OD.Quantity > 1;

-- Query 2: View the history of product operations
SELECT ProductID, Operation, OperationDate
FROM ProductLogs
ORDER BY OperationDate DESC;

-- Query 3: Customers who spent more than 500
SELECT C.Name, SUM(P.Amount) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN Payments P ON O.OrderID = P.OrderID
GROUP BY C.Name
HAVING SUM(P.Amount) > 500;

-- Query 4: Total revenue of each product
SELECT P.ProductName, SUM(OD.Quantity * P.Price) AS TotalRevenue
FROM Products P
JOIN OrderDetails OD ON P.ProductID = OD.ProductID
GROUP BY P.ProductName;

-- Query 5: Top 3 most ordered products
SELECT P.ProductName, SUM(OD.Quantity) AS TotalOrdered
FROM Products P
JOIN OrderDetails OD ON P.ProductID = OD.ProductID
GROUP BY P.ProductName
ORDER BY TotalOrdered DESC
LIMIT 3;

-- Query 6: Create a view for order summary
CREATE VIEW OrderSummary AS
SELECT 
    O.OrderID,
    C.Name AS CustomerName,
    SUM(OD.Quantity * P.Price) AS TotalOrderAmount
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY O.OrderID, C.Name;

-- Select from view
SELECT * FROM OrderSummary WHERE TotalOrderAmount > 500;

