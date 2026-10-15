-- Exploratory checks and first analytical query.

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales_reps;
SELECT * FROM order_statuses;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM order_status_history;

-- Order line-item value (not necessarily amount paid).
-- Inner joins omit orders that have no line items.
SELECT
    o.OrderID,
    c.CustomerName,
    SUM(oi.Quantity) AS TotalItems,
    SUM(oi.UnitPrice * oi.Quantity) AS OrderTotal
FROM orders o
JOIN order_items oi ON o.OrderID = oi.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CustomerName
ORDER BY o.OrderID;
