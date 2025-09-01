
-- Users
INSERT INTO Users (name, email, address) VALUES
('Alice Johnson', 'alice@example.com', 'New York, NY'),
('Bob Smith', 'bob@example.com', 'San Jose, CA'),
('Carol Lee', 'carol@example.com', 'Austin, TX'),
('David Kim', 'david@example.com', 'Seattle, WA'),
('Eva Brown', 'eva@example.com', 'Chicago, IL'),
('Frank Wilson', 'frank@example.com', 'Boston, MA'),
('Grace Miller', 'grace@example.com', 'Denver, CO'),
('Henry Davis', 'henry@example.com', 'Miami, FL'),
('Ivy Thompson', 'ivy@example.com', 'Phoenix, AZ'),
('Jack Garcia', 'jack@example.com', 'Dallas, TX');

-- Products
INSERT INTO Products (name, category, price) VALUES
('iPhone 15', 'Electronics', 999.99),                -- 1
('Running Shoes', 'Fashion', 59.99),                 -- 2
('Laptop Pro 14', 'Electronics', 1599.00),           -- 3
('Wireless Earbuds', 'Electronics', 129.99),         -- 4
('Coffee Maker', 'Home & Kitchen', 89.50),           -- 5
('Smartwatch', 'Electronics', 249.00),               -- 6
('Backpack', 'Accessories', 74.99),                  -- 7
('Mechanical Keyboard', 'Electronics', 119.00),      -- 8
('4K Monitor 27"', 'Electronics', 329.00),           -- 9
('Desk Lamp', 'Home & Kitchen', 39.99),              -- 10
('Yoga Mat', 'Sports', 24.99),                       -- 11
('External SSD 1TB', 'Electronics', 139.00),         -- 12
('Air Purifier', 'Home & Kitchen', 199.00),          -- 13
('Gaming Mouse', 'Electronics', 49.99),              -- 14
('Electric Kettle', 'Home & Kitchen', 34.99);        -- 15

-- Orders
-- Spread across months in 2025 to enable time-based analytics
INSERT INTO Orders (user_id, order_date, status) VALUES
(1, '2025-01-15 10:12:00', 'Completed'),  -- order_id 1
(2, '2025-02-02 14:30:00', 'Pending'),    -- order_id 2
(3, '2025-03-10 09:05:00', 'Completed'),  -- order_id 3
(4, '2025-03-28 17:40:00', 'Completed'),  -- order_id 4
(5, '2025-04-12 11:20:00', 'Completed'),  -- order_id 5
(6, '2025-05-05 13:55:00', 'Completed'),  -- order_id 6
(7, '2025-05-20 16:10:00', 'Completed'),  -- order_id 7
(8, '2025-06-18 19:25:00', 'Completed'),  -- order_id 8
(9, '2025-07-03 08:15:00', 'Cancelled'),  -- order_id 9 (will be refunded)
(10,'2025-07-22 20:05:00', 'Completed'),  -- order_id 10
(2, '2025-08-10 12:00:00', 'Completed'),  -- order_id 11 (same user 2 later)
(1, '2025-08-25 09:45:00', 'Completed');  -- order_id 12

-- Order Items
-- unit_price captured at time of purchase (copied from Products)
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
-- order 1
(1, 1, 1, 999.99),
(1, 4, 1, 129.99),

-- order 2
(2, 3, 1, 1599.00),

-- order 3
(3, 2, 2, 59.99),
(3, 7, 1, 74.99),

-- order 4
(4, 9, 1, 329.00),
(4, 8, 1, 119.00),

-- order 5
(5, 5, 1, 89.50),
(5, 10, 2, 39.99),

-- order 6
(6, 6, 1, 249.00),
(6, 12, 1, 139.00),

-- order 7
(7, 11, 3, 24.99),

-- order 8
(8, 14, 2, 49.99),
(8, 8, 1, 119.00),

-- order 9 (cancelled -> refunded)
(9, 13, 1, 199.00),
(9, 5, 1, 89.50),

-- order 10
(10, 15, 1, 34.99),
(10, 10, 1, 39.99),
(10, 7, 1, 74.99),

-- order 11
(11, 3, 1, 1599.00),
(11, 9, 2, 329.00),

-- order 12
(12, 1, 1, 999.99),
(12, 12, 2, 139.00),
(12, 4, 1, 129.99);

-- Payments
-- Amounts = SUM(quantity * unit_price) per order
-- order 1: 999.99 + 129.99 = 1129.98
-- order 2: 1599.00 (Pending)
-- order 3: 2*59.99 + 74.99 = 194.97
-- order 4: 329.00 + 119.00 = 448.00
-- order 5: 89.50 + 2*39.99 = 169.48
-- order 6: 249.00 + 139.00 = 388.00
-- order 7: 3*24.99 = 74.97
-- order 8: 2*49.99 + 119.00 = 218.98
-- order 9: 199.00 + 89.50 = 288.50 (Refunded)
-- order 10: 34.99 + 39.99 + 74.99 = 149.97
-- order 11: 1599.00 + 2*329.00 = 2257.00
-- order 12: 999.99 + 2*139.00 + 129.99 = 1407.98
INSERT INTO Payments (order_id, method, amount, status) VALUES
(1,  'Credit Card', 1129.98, 'Success'),
(2,  'PayPal',      NULL,    'Pending'),
(3,  'Credit Card', 194.97,  'Success'),
(4,  'Credit Card', 448.00,  'Success'),
(5,  'Credit Card', 169.48,  'Success'),
(6,  'Apple Pay',   388.00,  'Success'),
(7,  'Debit Card',  74.97,   'Success'),
(8,  'Credit Card', 218.98,  'Success'),
(9,  'Credit Card', 288.50,  'Refunded'),
(10, 'Credit Card', 149.97,  'Success'),
(11, 'PayPal',      2257.00, 'Success'),
(12, 'Apple Pay',   1407.98, 'Success');

-- Reviews
-- Users reviewing various products (1–5 stars)
INSERT INTO Reviews (user_id, product_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Fantastic performance and camera.', '2025-01-20'),
(2, 3, 4, 'Powerful laptop; battery could be better.', '2025-02-10'),
(3, 2, 4, 'Comfortable and good value.', '2025-03-15'),
(4, 9, 5, 'Crisp display for coding and gaming.', '2025-03-30'),
(5, 5, 4, 'Great coffee, easy to clean.', '2025-04-15'),
(6, 12, 5, 'Fast transfers, super compact.', '2025-05-07'),
(7, 11, 4, 'Good grip and thickness.', '2025-05-22'),
(8, 8, 5, 'Love the typing feel.', '2025-06-20'),
(9, 13, 3, 'Helps with allergies but a bit noisy.', '2025-07-05'),
(10,15,5, 'Boils water quickly.', '2025-07-25'),
(2, 9, 5, 'Perfect dual-monitor setup.', '2025-08-12'),
(1, 4, 4, 'Solid sound, fits well.', '2025-08-28'),
(6, 6, 5, 'Accurate tracking and sleek.', '2025-05-08'),
(3, 7, 4, 'Sturdy and spacious.', '2025-03-18'),
(8, 14, 5, 'Responsive for gaming.', '2025-06-19');

