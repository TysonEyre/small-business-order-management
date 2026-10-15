-- Run after 01_schema.sql, against an empty database.
-- All names, addresses, and transactions are fictional.
-- Seed identifiers are looked up by natural keys rather than assuming identity values.

BEGIN;

INSERT INTO customers (CustomerName, CustomerEmail, CustomerPhone, CurrentAddress)
VALUES
    ('Sarah Smith', 'sarah@example.com', '3035551234', '123 Main St'),
    ('John Lee', 'john@example.com', NULL, '98 Oak Ave');

INSERT INTO products (ProductName, CurrentPrice, SKU)
VALUES
    ('Laptop', 1999.99, 'LAP-001'),
    ('Mouse', 49.99, 'MOU-001'),
    ('Keyboard', 149.99, 'MON-001');
-- MON-001 is preserved from the original DDL, but is an odd SKU for a keyboard.
-- Consider changing to KEY-001 before using this seed in other environments.

INSERT INTO sales_reps (SalesRepName)
VALUES ('Melissa'), ('Kyle'), ('Jarom');

INSERT INTO order_statuses (StatusName)
VALUES ('Pending'), ('Paid'), ('Shipped'), ('Delivered'), ('Canceled');

-- Capture the generated order IDs for the order-item inserts.
CREATE TEMP TABLE seeded_order_ids (
    sample_order_no INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE
) ON COMMIT DROP;

WITH sample_orders (sample_order_no, customer_email, rep_name, order_date, shipping_address) AS (
    VALUES
        (1, 'sarah@example.com', 'Kyle',   TIMESTAMPTZ '2026-10-14 00:00:00+00', '123 Main St'),
        (2, 'john@example.com',  'Melissa', TIMESTAMPTZ '2026-10-14 07:32:06+00', '98 Oak Ave'),
        (3, 'john@example.com',  'Jarom',   TIMESTAMPTZ '2026-10-15 10:16:52+00', '98 Oak Ave'),
        (4, 'sarah@example.com', 'Melissa', TIMESTAMPTZ '2026-10-15 14:22:15+00', '123 Main St')
), inserted AS (
    INSERT INTO orders (CustomerID, SalesRepID, OrderStatusID, OrderDate, ShippingAddress)
    SELECT c.CustomerID, sr.SalesRepID, os.StatusID, so.order_date, so.shipping_address
    FROM sample_orders so
    JOIN customers c ON c.CustomerEmail = so.customer_email
    JOIN sales_reps sr ON sr.SalesRepName = so.rep_name
    JOIN order_statuses os ON os.StatusName = 'Pending'
    ORDER BY so.sample_order_no
    RETURNING OrderID, CustomerID, SalesRepID, OrderDate, ShippingAddress
)
INSERT INTO seeded_order_ids (sample_order_no, order_id)
SELECT so.sample_order_no, i.OrderID
FROM inserted i
JOIN sample_orders so
    ON so.order_date = i.OrderDate
   AND so.shipping_address = i.ShippingAddress;

-- The supplied item data references orders 100, 103, 104, and 105, but
-- the four supplied order inserts do not create all of those IDs.
-- For a coherent four-order sample, the line items are assigned to sample
-- orders 1, 2, 3, and 4 respectively; see README for this adjustment.
WITH sample_items (sample_order_no, sku, quantity, unit_price) AS (
    VALUES
        (1, 'LAP-001', 2, 1999.99::numeric),
        (1, 'MOU-001', 2, 49.99::numeric),
        (1, 'MON-001', 2, 149.99::numeric),
        (2, 'LAP-001', 4, 1999.99::numeric),
        (3, 'LAP-001', 1, 1999.99::numeric),
        (3, 'MOU-001', 1, 49.99::numeric),
        (3, 'LAP-001', 1, 1499.99::numeric),
        (3, 'MON-001', 2, 149.99::numeric),
        (4, 'MOU-001', 2, 39.99::numeric)
)
INSERT INTO order_items (OrderID, ProductID, Quantity, UnitPrice)
SELECT so.order_id, p.ProductID, si.quantity, si.unit_price
FROM sample_items si
JOIN seeded_order_ids so ON so.sample_order_no = si.sample_order_no
JOIN products p ON p.SKU = si.sku;

-- The initial status for each seeded order is Pending. These are initial
-- history events; a trigger will be added later for subsequent changes.
INSERT INTO order_status_history (OrderID, StatusID, ChangedAt)
SELECT o.OrderID, o.OrderStatusID, o.OrderDate
FROM orders o
JOIN seeded_order_ids so ON so.order_id = o.OrderID;

COMMIT;
