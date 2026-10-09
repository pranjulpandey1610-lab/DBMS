-- Experiment 2: Relational Schema for E-commerce Platform

-- Drop tables if they exist (to allow re-running the script)
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS Customer_Order;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Customer_Phone;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Product_Clothing;
DROP TABLE IF EXISTS Product_Electronics;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Seller;
DROP TABLE IF EXISTS Category;

-- 1. Category Table
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 2. Seller Table
CREATE TABLE Seller (
    seller_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE
);

-- 3. Product Table (Base entity for specialization)
-- Includes Foreign Keys with ON DELETE SET NULL and ON DELETE CASCADE
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id INT,
    seller_id INT,
    product_type ENUM('Electronics', 'Clothing') NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id) ON DELETE CASCADE
);

-- 4. Product_Electronics (Specialization of Product)
CREATE TABLE Product_Electronics (
    product_id INT PRIMARY KEY,
    warranty_period_months INT,
    brand VARCHAR(100),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

-- 5. Product_Clothing (Specialization of Product)
CREATE TABLE Product_Clothing (
    product_id INT PRIMARY KEY,
    size VARCHAR(10),
    material VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

-- 6. Customer Table (Includes composite attributes components indirectly, or basic attributes)
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL
);

-- 7. Customer_Phone (Multi-valued attribute of Customer)
CREATE TABLE Customer_Phone (
    customer_id INT,
    phone_number VARCHAR(15),
    PRIMARY KEY (customer_id, phone_number),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- 8. Address (Weak entity dependent on Customer)
-- Primary key is a composite of partial key (address_id) and strong entity key (customer_id)
CREATE TABLE Address (
    address_id INT,
    customer_id INT,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    pincode VARCHAR(10) NOT NULL,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- 9. Customer_Order Table (Since Order is often a reserved keyword)
CREATE TABLE Customer_Order (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- 10. OrderItem Table (Association between Order and Product)
CREATE TABLE OrderItem (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Customer_Order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

-- 11. Payment Table
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE, -- 1-to-1 relationship with Order
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Customer_Order(order_id) ON DELETE CASCADE
);

-- 12. Delivery Table
CREATE TABLE Delivery (
    delivery_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE, -- 1-to-1 relationship with Order
    delivery_status VARCHAR(50) NOT NULL,
    expected_date DATE,
    FOREIGN KEY (order_id) REFERENCES Customer_Order(order_id) ON DELETE CASCADE
);
