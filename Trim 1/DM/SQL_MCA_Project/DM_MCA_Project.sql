-- Database creation
create database MarketingCampaignAnalysis;
use MarketingCampaignAnalysis;

-- Table creation

-- Table: Regions
CREATE TABLE Regions (
    region_id VARCHAR(10) PRIMARY KEY,
    region_name VARCHAR(100),
    country VARCHAR(100)
);
DESC Regions;


-- Table: Customers
CREATE TABLE Customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    gender VARCHAR(10),
    age INT,
    region_id VARCHAR(10),
    registration_date DATE,
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);
DESC Customers;


-- Table: Categories
CREATE TABLE Categories (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(100)
);
DESC Categories;

-- Table: Products
CREATE TABLE Products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category_id VARCHAR(10),
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);
DESC Products;

-- Table: Campaigns
CREATE TABLE Campaigns (
    campaign_id VARCHAR(10) PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    target_segment VARCHAR(100)
);
ALTER TABLE Campaigns ADD COLUMN status VARCHAR(20) DEFAULT 'Planned';
DESC Campaigns;


-- Table: Campaign_Channel
CREATE TABLE Campaign_Channel (
    campaign_id VARCHAR(10),
    channel VARCHAR(50),
    PRIMARY KEY (campaign_id, channel),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);
DESC Campaign_Channel;


-- Table: Purchases
CREATE TABLE Purchases (
    purchase_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    purchase_date DATE,
    total_amount DECIMAL(12,2),
    campaign_id VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);
DESC Purchases;


-- Table: Purchase_Items
CREATE TABLE Purchase_Items (
    purchase_item_id VARCHAR(10) PRIMARY KEY,
    purchase_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (purchase_id) REFERENCES Purchases(purchase_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
DESC Purchase_Items;

-- Table: Customer_Feedback
CREATE TABLE Customer_Feedback (
    feedback_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    campaign_id VARCHAR(10),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    feedback_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);
DESC Customer_Feedback;

-- Table: Campaign_Responses
CREATE TABLE Campaign_Responses (
    response_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    campaign_id VARCHAR(10),
    response_type VARCHAR(50),
    response_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);
DESC Campaign_Responses;

-- Value Insertion - Done via loading the csv files into MySQL

-- Queries

-- For table Regions:
-- Basic SELECT
SELECT * FROM Regions;

-- WHERE condition
SELECT * FROM Regions WHERE country = 'India';

-- Arithmetic (count regions by length of name, example)
SELECT region_id, region_name, LENGTH(region_name) + 2 AS adjusted_length FROM Regions;

-- Logical operators
SELECT * FROM Regions
WHERE country = 'India' OR country = 'Nepal';

-- LIKE, IN, LIMIT
SELECT * FROM Regions
WHERE country LIKE 'I%' OR country IN ('India', 'Nepal')
LIMIT 5;

-- GROUP BY
SELECT country, COUNT(region_id) AS total_regions
FROM Regions
GROUP BY country;

-- GROUP BY with HAVING
SELECT country, COUNT(region_id) AS total_regions
FROM Regions
GROUP BY country
HAVING total_regions > 1;

-- INNER JOIN: Regions with customers
SELECT R.region_name, C.first_name, C.last_name
FROM Regions R
INNER JOIN Customers C ON R.region_id = C.region_id;

-- LEFT JOIN: All regions, even without customers
SELECT R.region_name, C.first_name
FROM Regions R
LEFT JOIN Customers C ON R.region_id = C.region_id;

-- RIGHT JOIN: All customers, with their regions
SELECT C.first_name, R.region_name
FROM Customers C
RIGHT JOIN Regions R ON R.region_id = C.region_id;

-- Subquery: Regions with more than 5 customers
SELECT region_name
FROM Regions
WHERE region_id IN (
    SELECT region_id
    FROM Customers
    GROUP BY region_id
    HAVING COUNT(customer_id) > 5
);


-- For table Customers
-- SELECT
SELECT first_name, last_name, age FROM Customers;

-- WHERE condition
SELECT * FROM Customers WHERE age > 30;

-- Arithmetic (age next year)
SELECT first_name, age, age + 1 AS age_next_year FROM Customers;

-- Logical operators
SELECT * FROM Customers
WHERE age BETWEEN 25 AND 35 AND gender = 'Female';

-- LIKE, IN, LIMIT
SELECT * FROM Customers
WHERE first_name LIKE 'A%' OR region_id IN (1, 3)
LIMIT 10;

-- GROUP BY
SELECT gender, COUNT(customer_id) AS total_customers
FROM Customers
GROUP BY gender;

-- GROUP BY with HAVING
SELECT gender, COUNT(customer_id) AS total_customers
FROM Customers
GROUP BY gender
HAVING total_customers > 30;

-- INNER JOIN: Customers with their purchases
SELECT C.first_name, P.purchase_id, P.total_amount
FROM Customers C
INNER JOIN Purchases P ON C.customer_id = P.customer_id;

-- LEFT JOIN: All customers, even if no purchase
SELECT C.first_name, P.purchase_id
FROM Customers C
LEFT JOIN Purchases P ON C.customer_id = P.customer_id;

-- RIGHT JOIN: Purchases ensuring all purchase records
SELECT P.purchase_id, C.first_name
FROM Purchases P
RIGHT JOIN Customers C ON C.customer_id = P.customer_id;

-- Subquery: Customers who spent above average total
SELECT first_name, last_name
FROM Customers
WHERE customer_id IN (
    SELECT customer_id
    FROM Purchases
    GROUP BY customer_id
    HAVING SUM(total_amount) > (
        SELECT AVG(total_amount) FROM Purchases
    )
);


-- For table Categories
-- SELECT
SELECT category_id, category_name FROM Categories;

-- WHERE condition
SELECT * FROM Categories WHERE category_name = 'Electronics';

-- Arithmetic (example ID+10)
SELECT category_id, category_name, category_id + 10 AS new_id FROM Categories;

-- Logical operators
SELECT * FROM Categories
WHERE category_name = 'Electronics' OR category_name = 'Clothing';

-- LIKE, IN, LIMIT
SELECT * FROM Categories
WHERE category_name LIKE '%wear%' OR category_id IN (2, 4)
LIMIT 5;

-- GROUP BY
SELECT category_name, COUNT(category_id) AS category_count
FROM Categories
GROUP BY category_name;

-- GROUP BY with HAVING
SELECT category_name, COUNT(category_id) AS category_count
FROM Categories
GROUP BY category_name
HAVING category_count > 1;

-- INNER JOIN: Categories with products
SELECT Cat.category_name, P.product_name
FROM Categories Cat
INNER JOIN Products P ON Cat.category_id = P.category_id;

-- LEFT JOIN: All categories, even without products
SELECT Cat.category_name, P.product_name
FROM Categories Cat
LEFT JOIN Products P ON Cat.category_id = P.category_id;

-- RIGHT JOIN: All products and their categories
SELECT P.product_name, Cat.category_name
FROM Products P
RIGHT JOIN Categories Cat ON Cat.category_id = P.category_id;

-- Subquery: Categories with more than 3 products
SELECT category_name
FROM Categories
WHERE category_id IN (
    SELECT category_id
    FROM Products
    GROUP BY category_id
    HAVING COUNT(product_id) > 3
);


-- For table Products
-- SELECT
SELECT product_name, price FROM Products;

-- WHERE condition
SELECT * FROM Products WHERE price > 2000;

-- Arithmetic
SELECT product_name, price, price * 1.18 AS price_with_gst FROM Products;

-- Logical operators
SELECT * FROM Products
WHERE price BETWEEN 1500 AND 3000 AND category_id = 2;

-- LIKE, IN, LIMIT
SELECT * FROM Products
WHERE product_name LIKE '%Phone%' OR category_id IN (1, 3)
LIMIT 8;

-- GROUP BY
SELECT category_id, AVG(price) AS avg_price
FROM Products
GROUP BY category_id;

-- GROUP BY with HAVING
SELECT category_id, AVG(price) AS avg_price
FROM Products
GROUP BY category_id
HAVING avg_price > 2500;

-- INNER JOIN: Products with purchase items
SELECT P.product_name, PI.quantity
FROM Products P
INNER JOIN Purchase_Items PI ON P.product_id = PI.product_id;

-- LEFT JOIN: All products, even if never purchased
SELECT P.product_name, PI.quantity
FROM Products P
LEFT JOIN Purchase_Items PI ON P.product_id = PI.product_id;

-- RIGHT JOIN: All purchase items with their product names
SELECT PI.purchase_item_id, P.product_name
FROM Purchase_Items PI
RIGHT JOIN Products P ON P.product_id = PI.product_id;

-- Subquery: Products with price above category average
SELECT product_name, price
FROM Products
WHERE price > (
    SELECT AVG(price)
    FROM Products
);


-- For table Campaigns
-- SELECT
SELECT campaign_name, start_date, end_date FROM Campaigns;

-- WHERE
SELECT * FROM Campaigns WHERE budget > 50000;

-- Arithmetic
SELECT campaign_name, budget, budget * 1.05 AS adjusted_budget FROM Campaigns;

-- Logical operators
SELECT * FROM Campaigns
WHERE budget > 50000 AND target_segment = 'Premium Customers';

-- LIKE, IN, LIMIT
SELECT * FROM Campaigns
WHERE campaign_name LIKE '%Sale%' OR campaign_id IN (1, 4)
LIMIT 5;

-- GROUP BY
SELECT target_segment, COUNT(campaign_id) AS total_campaigns
FROM Campaigns
GROUP BY target_segment;

-- GROUP BY with HAVING
SELECT target_segment, COUNT(campaign_id) AS total_campaigns
FROM Campaigns
GROUP BY target_segment
HAVING total_campaigns > 1;

-- INNER JOIN: Campaigns with purchases
SELECT Camp.campaign_name, P.purchase_id, P.total_amount
FROM Campaigns Camp
INNER JOIN Purchases P ON Camp.campaign_id = P.campaign_id;

-- LEFT JOIN: All campaigns, even without purchases
SELECT Camp.campaign_name, P.purchase_id
FROM Campaigns Camp
LEFT JOIN Purchases P ON Camp.campaign_id = P.campaign_id;

-- RIGHT JOIN: All purchases, ensuring campaign match
SELECT P.purchase_id, Camp.campaign_name
FROM Purchases P
RIGHT JOIN Campaigns Camp ON Camp.campaign_id = P.campaign_id;

-- Subquery: Campaigns that generated more than ₹50,000
SELECT campaign_name
FROM Campaigns
WHERE campaign_id IN (
    SELECT campaign_id
    FROM Purchases
    GROUP BY campaign_id
    HAVING SUM(total_amount) > 50000
);


-- For table Campaign_Channel
-- SELECT
SELECT campaign_id, channel FROM Campaign_Channel;

-- WHERE
SELECT * FROM Campaign_Channel WHERE channel = 'Email';

-- Arithmetic (example id+5)
SELECT campaign_id, channel, campaign_id + 5 AS next_id FROM Campaign_Channel;

-- Logical operators
SELECT * FROM Campaign_Channel
WHERE channel = 'Email' OR channel = 'Social Media';

-- LIKE, IN, LIMIT
SELECT * FROM Campaign_Channel
WHERE channel LIKE '%Media%' OR campaign_id IN (1, 3)
LIMIT 4;

-- GROUP BY
SELECT channel, COUNT(campaign_id) AS campaigns_using_channel
FROM Campaign_Channel
GROUP BY channel;

-- GROUP BY with HAVING
SELECT channel, COUNT(campaign_id) AS campaigns_using_channel
FROM Campaign_Channel
GROUP BY channel
HAVING campaigns_using_channel > 2;

-- INNER JOIN: Campaigns with channels
SELECT Camp.campaign_name, CC.channel
FROM Campaigns Camp
INNER JOIN Campaign_Channel CC ON Camp.campaign_id = CC.campaign_id;

-- LEFT JOIN: All campaigns, even without channels
SELECT Camp.campaign_name, CC.channel
FROM Campaigns Camp
LEFT JOIN Campaign_Channel CC ON Camp.campaign_id = CC.campaign_id;

-- RIGHT JOIN: All channels, ensuring campaign exists
SELECT CC.channel, Camp.campaign_name
FROM Campaign_Channel CC
RIGHT JOIN Campaigns Camp ON Camp.campaign_id = CC.campaign_id;

-- Subquery: Channels used by more than 2 campaigns
SELECT channel
FROM Campaign_Channel
WHERE campaign_id = (
    SELECT campaign_id
    FROM Purchases
    GROUP BY campaign_id
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
);


-- For table Purchases
-- SELECT
SELECT purchase_id, total_amount FROM Purchases;

-- WHERE
SELECT * FROM Purchases WHERE total_amount > 3000;

-- Arithmetic
SELECT purchase_id, total_amount, total_amount * 0.9 AS discounted_amount FROM Purchases;

-- Logical operators
SELECT * FROM Purchases
WHERE total_amount > 2000 AND campaign_id = 'CMP001';

-- LIKE, IN, LIMIT
SELECT * FROM Purchases
WHERE purchase_id LIKE 'PUR%' OR campaign_id IN (1, 2)
LIMIT 10;

-- GROUP BY
SELECT campaign_id, SUM(total_amount) AS revenue
FROM Purchases
GROUP BY campaign_id;

-- GROUP BY with HAVING
SELECT campaign_id, SUM(total_amount) AS revenue
FROM Purchases
GROUP BY campaign_id
HAVING revenue > 1000000;

-- INNER JOIN: Purchases with customers
SELECT P.purchase_id, C.first_name, P.total_amount
FROM Purchases P
INNER JOIN Customers C ON P.customer_id = C.customer_id;

-- LEFT JOIN: All purchases, even without campaigns
SELECT P.purchase_id, Camp.campaign_name
FROM Purchases P
LEFT JOIN Campaigns Camp ON P.campaign_id = Camp.campaign_id;

-- RIGHT JOIN: All campaigns, ensuring purchase record
SELECT Camp.campaign_name, P.purchase_id
FROM Campaigns Camp
RIGHT JOIN Purchases P ON P.campaign_id = Camp.campaign_id;

-- Subquery: Purchases above campaign average
SELECT purchase_id, total_amount
FROM Purchases
WHERE total_amount > (
    SELECT AVG(total_amount) FROM Purchases
);


-- For table Purchase_Items
-- SELECT
SELECT purchase_item_id, quantity, price FROM Purchase_Items;

-- WHERE
SELECT * FROM Purchase_Items WHERE quantity >= 2;

-- Arithmetic
SELECT purchase_item_id, quantity, price, quantity * price AS total_price FROM Purchase_Items;

-- Logical operators
SELECT * FROM Purchase_Items
WHERE quantity > 2 AND price > 1000;

-- LIKE, IN, LIMIT
SELECT * FROM Purchase_Items
WHERE purchase_id LIKE 'PUR%' OR product_id IN (1, 5)
LIMIT 8;

-- GROUP BY
SELECT product_id, SUM(quantity) AS total_quantity
FROM Purchase_Items
GROUP BY product_id;

-- GROUP BY with HAVING
SELECT product_id, SUM(quantity) AS total_quantity
FROM Purchase_Items
GROUP BY product_id
HAVING total_quantity > 50;

-- INNER JOIN: Purchase items with products
SELECT PI.purchase_item_id, P.product_name, PI.quantity
FROM Purchase_Items PI
INNER JOIN Products P ON PI.product_id = P.product_id;

-- LEFT JOIN: All purchase items, even without product match
SELECT PI.purchase_item_id, P.product_name
FROM Purchase_Items PI
LEFT JOIN Products P ON PI.product_id = P.product_id;

-- RIGHT JOIN: All products, ensuring purchase item record
SELECT P.product_name, PI.purchase_item_id
FROM Products P
RIGHT JOIN Purchase_Items PI ON PI.product_id = P.product_id;

-- Subquery: Items with quantity above average
SELECT purchase_item_id, quantity
FROM Purchase_Items
WHERE quantity > (
    SELECT AVG(quantity) FROM Purchase_Items
);


-- For table Customer_Feedback
-- SELECT
SELECT feedback_id, rating, comments FROM Customer_Feedback;

-- WHERE
SELECT * FROM Customer_Feedback WHERE rating = 5;

-- Arithmetic
SELECT feedback_id, rating, rating + 1 AS adjusted_rating FROM Customer_Feedback;

-- Logical operators
SELECT * FROM Customer_Feedback
WHERE rating >= 4 AND campaign_id = 'CMP002';

-- LIKE, IN, LIMIT
SELECT * FROM Customer_Feedback
WHERE comments LIKE '%fast%' OR customer_id IN (1, 4)
LIMIT 6;

-- GROUP BY
SELECT campaign_id, AVG(rating) AS avg_rating
FROM Customer_Feedback
GROUP BY campaign_id;

-- GROUP BY with HAVING
SELECT campaign_id, AVG(rating) AS avg_rating
FROM Customer_Feedback
GROUP BY campaign_id
HAVING avg_rating > 3;

-- INNER JOIN: Feedback with campaigns
SELECT F.feedback_id, C.campaign_name, F.rating
FROM Customer_Feedback F
INNER JOIN Campaigns C ON F.campaign_id = C.campaign_id;

-- LEFT JOIN: All feedback, even without campaign match
SELECT F.feedback_id, C.campaign_name
FROM Customer_Feedback F
LEFT JOIN Campaigns C ON F.campaign_id = C.campaign_id;

-- RIGHT JOIN: All campaigns, ensuring feedback record
SELECT C.campaign_name, F.feedback_id
FROM Campaigns C
RIGHT JOIN Customer_Feedback F ON F.campaign_id = C.campaign_id;

-- Subquery: Feedback ratings above overall average
SELECT feedback_id, rating
FROM Customer_Feedback
WHERE rating > (
    SELECT AVG(rating) FROM Customer_Feedback
);


-- For table Campaign_Responses
-- SELECT
SELECT response_id, response_type FROM Campaign_Responses;

-- WHERE
SELECT * FROM Campaign_Responses WHERE response_type = 'Clicked Ad';

-- Arithmetic (id+100)
SELECT 
    response_id,
    response_type,
    (LENGTH(response_type) * 10) + campaign_id AS priority_score
FROM Campaign_Responses;

-- Logical operators
SELECT * FROM Campaign_Responses
WHERE response_type = 'Clicked Ad' OR response_type = 'Opened Email';

-- LIKE, IN, LIMIT
SELECT * FROM Campaign_Responses
WHERE response_type LIKE '%ed' OR campaign_id IN (1, 3)
LIMIT 5;

-- GROUP BY
SELECT response_type, COUNT(response_id) AS total_responses
FROM Campaign_Responses
GROUP BY response_type;

-- GROUP BY with HAVING
SELECT response_type, COUNT(response_id) AS total_responses
FROM Campaign_Responses
GROUP BY response_type
HAVING total_responses > 50;

-- INNER JOIN: Campaign responses with customers
SELECT CR.response_id, C.first_name, CR.response_type
FROM Campaign_Responses CR
INNER JOIN Customers C ON CR.customer_id = C.customer_id;

-- LEFT JOIN: All responses, even without customer match
SELECT CR.response_id, C.first_name
FROM Campaign_Responses CR
LEFT JOIN Customers C ON CR.customer_id = C.customer_id;

-- RIGHT JOIN: All customers, ensuring response record
SELECT C.first_name, CR.response_id
FROM Customers C
RIGHT JOIN Campaign_Responses CR ON CR.customer_id = C.customer_id;

-- Subquery: Campaigns with 'Clicked Ad' responses
SELECT campaign_id
FROM Campaign_Responses
WHERE campaign_id IN (
    SELECT campaign_id
    FROM Campaign_Responses
    WHERE response_type = 'Clicked Ad'
);


-- Advance Queries for business insights

-- ROI calculation per campaign
SELECT
    C.campaign_name,
    C.budget,
    SUM(P.total_amount) AS revenue,
    (SUM(P.total_amount) - C.budget) / C.budget * 100 AS roi_percentage
FROM Campaigns C
LEFT JOIN Purchases P ON C.campaign_id = P.campaign_id
GROUP BY C.campaign_id, C.campaign_name, C.budget
ORDER BY roi_percentage DESC;

-- Calculate total revenue by campaign
SELECT C.campaign_name, SUM(P.total_amount) AS campaign_revenue
FROM Purchases P
JOIN Campaigns C ON P.campaign_id = C.campaign_id
GROUP BY C.campaign_name
ORDER BY campaign_revenue DESC;

-- Top 5 most purchased products
SELECT P.product_name, COUNT(PI.product_id) AS times_purchased
FROM Purchase_Items PI
JOIN Products P ON PI.product_id = P.product_id
GROUP BY P.product_name
ORDER BY times_purchased DESC
LIMIT 5;

-- Top 5 most valuable customers
SELECT C.customer_id, C.first_name, C.last_name, SUM(P.total_amount) AS total_spent
FROM Customers C
JOIN Purchases P ON C.customer_id = P.customer_id
GROUP BY C.customer_id, C.first_name, C.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- Most profitable product category
SELECT Cat.category_name, SUM(PI.quantity * PI.price) AS total_sales
FROM Purchase_Items PI
JOIN Products P ON PI.product_id = P.product_id
JOIN Categories Cat ON P.category_id = Cat.category_id
GROUP BY Cat.category_name
ORDER BY total_sales DESC
LIMIT 1;

-- Conversion rate per campaign
SELECT 
    C.campaign_name, 
    COUNT(DISTINCT CR.customer_id) AS responded_customers,
    (SELECT COUNT(*) FROM Customers) AS targeted_customers,
    (COUNT(DISTINCT CR.customer_id) / (SELECT COUNT(*) FROM Customers)) * 100 AS conversion_rate
FROM Campaigns C
LEFT JOIN Campaign_Responses CR 
       ON C.campaign_id = CR.campaign_id
GROUP BY C.campaign_name
ORDER BY conversion_rate DESC;

-- Most responsive marketing channel
SELECT CC.channel, COUNT(DISTINCT CR.customer_id) AS total_responses
FROM Campaign_Channel CC
JOIN Campaign_Responses CR ON CC.campaign_id = CR.campaign_id
GROUP BY CC.channel
ORDER BY total_responses DESC;

-- Feedback-based campaign ranking
SELECT C.campaign_name, 
       AVG(F.rating) AS avg_rating,
       COUNT(F.feedback_id) AS total_feedbacks
FROM Campaigns C
LEFT JOIN Customer_Feedback F ON C.campaign_id = F.campaign_id
GROUP BY C.campaign_name
ORDER BY avg_rating DESC, total_feedbacks DESC;

-- Products that drive the most revenue
SELECT P.product_name, SUM(PI.quantity * PI.price) AS product_revenue
FROM Purchase_Items PI
JOIN Products P ON PI.product_id = P.product_id
GROUP BY P.product_name
ORDER BY product_revenue DESC
LIMIT 5;

-- Gender-wise revenue contribution
SELECT C.gender, SUM(P.total_amount) AS total_revenue
FROM Customers C
JOIN Purchases P ON C.customer_id = P.customer_id
GROUP BY C.gender
ORDER BY total_revenue DESC;

-- Regions generating the highest revenue
SELECT R.region_name, R.country, SUM(P.total_amount) AS total_revenue
FROM Regions R
JOIN Customers C ON R.region_id = C.region_id
JOIN Purchases P ON C.customer_id = P.customer_id
GROUP BY R.region_name, R.country
ORDER BY total_revenue DESC;

-- Average purchase size (per transaction)
SELECT AVG(total_amount) AS avg_purchase_value
FROM Purchases;

-- Customers who purchased from multiple campaigns
SELECT customer_id, COUNT(DISTINCT campaign_id) AS campaigns_participated
FROM Purchases
GROUP BY customer_id
HAVING campaigns_participated > 1;

-- Average order value by marketing channel
SELECT CC.channel, AVG(P.total_amount) AS avg_order_value
FROM Campaign_Channel CC
JOIN Campaigns C ON CC.campaign_id = C.campaign_id
JOIN Purchases P ON C.campaign_id = P.campaign_id
GROUP BY CC.channel
ORDER BY avg_order_value DESC;

-- Best day of the week for purchases
SELECT DAYNAME(purchase_date) AS purchase_day, SUM(total_amount) AS total_revenue
FROM Purchases
GROUP BY purchase_day
ORDER BY total_revenue DESC;
