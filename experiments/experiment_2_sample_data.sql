-- Insert Sample Data for Experiment 2

-- Category
INSERT INTO Category (category_id, name, description) VALUES
(1, 'Mobiles', 'Smartphones and accessories'),
(2, 'Laptops', 'Laptops and computers'),
(3, 'Men Clothing', 'Men apparel and fashion');

-- Seller
INSERT INTO Seller (seller_id, name, email, phone) VALUES
(101, 'Tech Cloud', 'contact@techcloud.com', '9876543210'),
(102, 'Fashion Hub', 'sales@fashionhub.in', '9123456789');

-- Product
INSERT INTO Product (product_id, name, price, stock, category_id, seller_id, product_type) VALUES
(1001, 'Smartphone X', 29999.00, 50, 1, 101, 'Electronics'),
(1002, 'Gaming Laptop', 85000.00, 15, 2, 101, 'Electronics'),
(1003, 'Cotton T-Shirt', 499.00, 100, 3, 102, 'Clothing');

-- Product Specializations
INSERT INTO Product_Electronics (product_id, warranty_period_months, brand) VALUES
(1001, 12, 'BrandX'),
(1002, 24, 'GamerZ');

INSERT INTO Product_Clothing (product_id, size, material) VALUES
(1003, 'L', 'Cotton');

-- Customer
INSERT INTO Customer (customer_id, first_name, last_name, email) VALUES
(1, 'Rahul', 'Sharma', 'rahul.s@example.com'),
(2, 'Priya', 'Singh', 'priya.singh@example.com');

-- Customer_Phone
INSERT INTO Customer_Phone (customer_id, phone_number) VALUES
(1, '9998887776'),
(1, '9998887777'),
(2, '8887776665');

-- Address
INSERT INTO Address (address_id, customer_id, street, city, state, pincode) VALUES
(1, 1, '12 MG Road', 'Bangalore', 'Karnataka', '560001'),
(1, 2, '45 Park Street', 'Kolkata', 'West Bengal', '700016');

-- Customer_Order
INSERT INTO Customer_Order (order_id, customer_id, total_amount) VALUES
(5001, 1, 30498.00),
(5002, 2, 85000.00);

-- OrderItem
INSERT INTO OrderItem (order_id, product_id, quantity, price_at_purchase) VALUES
(5001, 1001, 1, 29999.00),
(5001, 1003, 1, 499.00),
(5002, 1002, 1, 85000.00);

-- Payment
INSERT INTO Payment (payment_id, order_id, payment_method, payment_status, amount) VALUES
(9001, 5001, 'Credit Card', 'Completed', 30498.00),
(9002, 5002, 'UPI', 'Pending', 85000.00);

-- Delivery
INSERT INTO Delivery (delivery_id, order_id, delivery_status, expected_date) VALUES
(8001, 5001, 'Dispatched', '2023-11-05'),
(8002, 5002, 'Processing', '2023-11-07');
