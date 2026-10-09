-- Experiment 2: Referential Integrity Violations

-- 1. Primary Key Violation
-- This will fail because seller_id 101 already exists.
-- Error: Duplicate entry '101' for key 'seller.PRIMARY'
-- INSERT INTO Seller (seller_id, name, email) VALUES (101, 'Another Seller', 'another@seller.com');

-- 2. Foreign Key Violation (Insertion)
-- This will fail because customer_id 999 does not exist in Customer table.
-- Error: Cannot add or update a child row: a foreign key constraint fails
-- INSERT INTO Customer_Order (order_id, customer_id) VALUES (5003, 999);

-- 3. UNIQUE Constraint Violation
-- This will fail because the email is already used by Seller 101.
-- Error: Duplicate entry 'contact@techcloud.com' for key 'seller.email'
-- INSERT INTO Seller (seller_id, name, email) VALUES (103, 'New Seller', 'contact@techcloud.com');

-- 4. NOT NULL Constraint Violation
-- This will fail because first_name cannot be null.
-- Error: Column 'first_name' cannot be null
-- INSERT INTO Customer (customer_id, first_name, email) VALUES (3, NULL, 'test@test.com');

-- 5. ON DELETE CASCADE Demonstration
-- Deleting a customer will automatically delete their orders, phones, and addresses.
-- DELETE FROM Customer WHERE customer_id = 1;
-- If we run this, order 5001, phones of customer 1, and address of customer 1 will be deleted.
-- OrderItem, Payment, and Delivery related to order 5001 will also be deleted due to CASCADE.

-- 6. ON DELETE SET NULL Demonstration
-- Deleting a category will set the category_id to NULL for all products in that category.
-- DELETE FROM Category WHERE category_id = 1;
-- If we run this, product 1001 will have its category_id set to NULL, rather than being deleted.
