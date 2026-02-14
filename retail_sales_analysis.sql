# “Using SQL to analyze retail transactional data.”

# Created a dedicated SQL database to store and analyze retail transactional data.
create database project;
# Selected the database to begin data operations.
USE project;

CREATE TABLE retail_data (
order_id VARCHAR(50),
order_date VARCHAR(50),
ship_date VARCHAR(50),
ship_mode VARCHAR(50),
customer_id VARCHAR(50),
customer_name VARCHAR(50),
segment VARCHAR(50),
country VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
postal_code VARCHAR(50),
region VARCHAR(50),
product_id VARCHAR(50),
category VARCHAR(50),
sub_category VARCHAR(50),
product_name VARCHAR(255),
sales DECIMAL(5,2),
quantity VARCHAR(50),
discount DECIMAL(5,2),
profit DECIMAL(5,2),
profit_margin DECIMAL(5,2)
);

SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore_csv.csv'
INTO TABLE retail_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM retail_data;

# Reviewed table structure to understand column names and datatypes.
describe retail_data;    

# Updated column datatype after successful conversion.
ALTER TABLE retail_data
MODIFY COLUMN order_date DATE,
MODIFY COLUMN ship_date DATE;

# 
ALTER TABLE retail_data
MODIFY COLUMN quantity INT;

# created a surrogate primary key using AUTO_INCREMENT to ensure row-level uniqueness.
ALTER TABLE retail_data
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;

# Created an index on order_date to accelerate time-based queries.
CREATE INDEX idx_order_date
ON retail_data(order_date);

# Created an index on customer_id .
CREATE INDEX idx_custid
ON retail_data(customer_id);

# Created an index on product_id .
CREATE INDEX idx_product_id
ON retail_data(product_id);

# enforcing NOT NULL on critical transactional fields
ALTER TABLE retail_data
MODIFY sales DECIMAL(10,2) NOT NULL,
MODIFY quantity INT NOT NULL,
MODIFY order_date DATE NOT NULL,
MODIFY customer_id VARCHAR(50) NOT NULL;



#Checking Data

# Checking duplicate primary keys
SELECT order_id, product_id, COUNT(*)
FROM retail_data
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

# Checking negative sales
SELECT *
FROM retail_data
WHERE sales < 0;

# Checking Profit Margin Logic
SELECT *
FROM retail_data
WHERE profit_margin > 1;

# Date Sanity Check
SELECT *
FROM retail_data
WHERE ship_date < order_date;
# 1708 rows detected where ship_date < order_date.

# Checking percentage
SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_data)
FROM retail_data
WHERE ship_date < order_date;

#Creating a filtered table using VIEW.
CREATE VIEW retail_final AS
SELECT *
FROM retail_data
WHERE ship_date >= order_date;

SELECT count(*) FROM retail_final;


#Q1. Which category brings the most money to the company?
SELECT 
	category,
    sum(sales) as total_revenue
FROM retail_final
GROUP BY category
ORDER BY total_revenue DESC;
#Insight : Furniture Category give highest revenue.

#Q2. Most PROFITABLE Category
SELECT 
	category,
    sum(PROFIT) as total_profit
FROM retail_final
GROUP BY category
ORDER BY total_profit DESC;
#Insight : Technology Category makes highest profit.

/* While Furniture drives top-line revenue, Technology contribute 
more effectively to profitability, indicating stronger margins. */

# To check Discount given in each category 
SELECT 
    category,
    ROUND(AVG(discount),2) AS avg_discount
FROM retail_final
GROUP BY category
ORDER BY avg_discount DESC;
# Discount difference is marginal — root cause must be elsewhere.

# PROFIT MARGIN by Category
SELECT 
    category,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_margin
FROM retail_final
GROUP BY category
ORDER BY profit_margin DESC;

/* Technology demonstrate superior operational efficiency with the 
highest profit margin, while Furniture shows margin pressure despite generating revenue.
This shows despite of having higher sales, Profit Margin of Furniture is very low. Need to be considered. */

# LOSS MAKING Products
SELECT 
    product_name,
    category,
    ROUND(SUM(profit),2) AS total_profit
FROM retail_final
GROUP BY product_name, category
HAVING total_profit < 0
ORDER BY total_profit;

# To check whether high discount makes more loss.
SELECT 
    product_name,
    category,
    ROUND(AVG(discount),2) AS avg_discount,
    ROUND(SUM(profit),2) AS total_profit
FROM retail_final
GROUP BY product_name, category
HAVING total_profit < 0
ORDER BY total_profit;

/* 
Losses can result from poor pricing strategy, high logistics cost,
low demand, or structurally unprofitable products — even when discounts are minimal.  */

# Which region is more profitable?
SELECT 
    region,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales),2) AS profit_margin
FROM retail_data
GROUP BY region
ORDER BY total_profit DESC;

/* West region demonstrates the strongest 
financial performance with the highest profit and margin,
making it an ideal candidate for expansion.

Central region generates strong sales but underperforms in profitability, 
indicating potential cost inefficiencies or aggressive discounting 
strategies that require investigation. */

# Top 10 Customers by Revenue
SELECT 
    customer_name,
    ROUND(SUM(sales),2) AS total_spent
FROM retail_data
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;
/* Revenue is moderately concentrated among top customers, 
indicating the importance of high-value client retention. 
Losing a few key customers could significantly impact overall sales, 
making customer relationship management a strategic priority. */

# To check whether high revenue customer also making high profit?
SELECT 
    customer_name,
    ROUND(SUM(sales),2) AS revenue,
    ROUND(SUM(profit),2) AS profit
FROM retail_data
GROUP BY customer_name
ORDER BY profit DESC
LIMIT 10;
/* While several customers generate strong revenue, not all contribute equally to profitability. */

# Loss-making customers
SELECT 
    customer_name,
    ROUND(SUM(sales),2) AS revenue,
    ROUND(SUM(profit),2) AS profit
FROM retail_data
GROUP BY customer_name
HAVING profit < 0
ORDER BY profit;

/* The analysis reveals several loss-making customers, 
indicating pricing inefficiencies or excessive discounting.

The business should reassess discount strategies, shipping policies, or 
minimum order thresholds to prevent margin erosion. */

# Subcategory that destroying profit.
SELECT 
    sub_category,
    ROUND(SUM(sales),2) AS revenue,
    ROUND(SUM(profit),2) AS profit
FROM retail_data
GROUP BY sub_category
ORDER BY profit;

/* The Tables sub-category is significantly impacting 
profitability, generating negative profit despite contributing revenue.

This suggests structural issues such as high logistics costs, 
aggressive discounting, or poor pricing strategy.

The business should immediately review pricing, shipping policies, 
and supplier costs for this category. */

# Are Tables heavily discounted?
SELECT 
    sub_category,
    ROUND(AVG(discount),2) AS avg_discount
FROM retail_data
GROUP BY sub_category
ORDER BY avg_discount DESC;

/*The Tables sub-category is generating losses despite 
not being heavily discounted, indicating potential pricing 
inefficiencies or elevated operational costs.

This suggests a structural profitability issue rather than a 
promotional one, requiring immediate strategic review. */

# Are Table buyers purchasing OTHER profitable products?
SELECT 
    customer_id,
    COUNT(DISTINCT sub_category) AS categories_bought
FROM retail_data
WHERE customer_id IN (
    SELECT customer_id
    FROM retail_data
    WHERE sub_category = 'Tables'
)
GROUP BY customer_id
ORDER BY categories_bought DESC;

/* YES !
Tables might be acting as a gateway product.
NOT useless.
VERY strategic. */

# Splitting tables:-
# Create Customers Table
CREATE TABLE customers AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    city,
    state,
    country,
    region
FROM retail_data;

# Create Products Table
CREATE TABLE products AS
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM retail_data;

#Orders Table
CREATE TABLE orders AS
SELECT
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
FROM retail_data;

# Are there customers who never placed an order?
SELECT 
    c.customer_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
/* The analysis shows no inactive customers, 
indicating strong conversion rates and effective customer acquisition strategies. 
Every registered customer has completed at least one transaction. */


#Top customers in each region.
SELECT *
FROM (
    SELECT 
        c.customer_name,
        c.region,
        ROUND(SUM(o.sales),2) AS total_sales,
        RANK() OVER (
            PARTITION BY c.region 
            ORDER BY SUM(o.sales) DESC
        ) AS rnk
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_name, c.region
) t
WHERE rnk = 1;

# Top Customers BUT by PROFIT
SELECT *
FROM (
    SELECT 
        c.customer_name,
        c.region,
        ROUND(SUM(o.profit),2) AS total_profit,
        RANK() OVER (
            PARTITION BY c.region 
            ORDER BY SUM(o.profit) DESC
        ) AS rnk
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_name, c.region
) t
WHERE rnk = 1;

/*Top revenue-generating customers are not always the most profitable.
This highlights the importance of evaluating customer 
value based on profitability rather than sales alone. */

# Product having high sales but having low profit.
SELECT 
    p.product_name,
    ROUND(SUM(o.sales),2) AS revenue,
    ROUND(SUM(o.profit),2) AS profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
HAVING revenue > 1000
AND profit < 100
ORDER BY revenue DESC;

# Customer Segmentation
SELECT 
    customer_name,
    total_spent,
    CASE 
        WHEN total_spent > 3000 THEN 'High Value'
        WHEN total_spent BETWEEN 1000 AND 3000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM (
    SELECT 
        c.customer_name,
        ROUND(SUM(o.sales),2) AS total_spent
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_name
) t
ORDER BY total_spent DESC;

/* The business shows high customer concentration risk, 
with a significant portion of revenue driven by a single high-value customer.

This dependency increases revenue vulnerability, 
making customer retention strategies critical for long-term stability. */

# Is Clay Ludtke ALSO highly profitable?
SELECT 
    c.customer_name,
    ROUND(SUM(o.sales),2) AS revenue,
    ROUND(SUM(o.profit),2) AS profit,
    ROUND(SUM(o.profit)/SUM(o.sales),2) AS margin
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE c.customer_name = 'Clay Ludtke'
GROUP BY c.customer_name;
# Yes Clay Ludtke is also high profitable

# Repeated Customers
SELECT 
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM retail_data
GROUP BY customer_name
HAVING total_orders > 1
ORDER BY total_orders DESC;

#Top 5 Products Driving Revenue
SELECT 
    product_name,
    ROUND(SUM(sales),2) AS revenue
FROM retail_data
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 5;

# Customers Who Spend MORE Than Average Customer
WITH customer_avg AS
(
    SELECT 
        c.customer_id,
        SUM(o.sales) AS total_spent
    FROM orders o JOIN customers c on
    o.customer_id = c.customer_id
    GROUP BY customer_id
),

avg_spend AS
(
    SELECT AVG(total_spent) AS avg_value
    FROM customer_avg
)

SELECT *
FROM customer_avg
WHERE total_spent > (SELECT avg_value FROM avg_spend);

# Are customers coming back?
WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order
    FROM orders
    GROUP BY customer_id
),

repeat_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN first_purchase f
        ON o.customer_id = f.customer_id
    WHERE o.order_date > f.first_order
)

SELECT 
    COUNT(DISTINCT r.customer_id) * 100.0 /
    COUNT(DISTINCT f.customer_id) AS retention_rate
FROM first_purchase f
LEFT JOIN repeat_customers r
ON f.customer_id = r.customer_id;
# Retention Rate is : 97.48676
/* Evaluated customer retention to 
measure long-term revenue sustainability rather than one-time transactions. */

# Running Revenue Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(sales) AS monthly_revenue,
    SUM(SUM(sales)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) 
        AS running_revenue
FROM orders
GROUP BY month;
 /* I analyzed cumulative revenue to identify growth momentum and detect potential slowdowns early */
 
 # Where company is LOSING money.
 SELECT 
    category,
    sub_category,
    SUM(sales) AS revenue,
    SUM(profit) AS profit,
    ROUND(SUM(profit)/SUM(sales),2) AS margin
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY category, sub_category
HAVING margin < 0.05
ORDER BY margin;

/* I proactively identified low-margin 
segments to highlight profit leakage and support strategic pricing decisions. */

# Conclusion
/* Overall, the analysis reveals that while the business is 
generating strong revenue, profitability is uneven across categories, regions, and customers.

The Furniture category drives the highest sales but suffers from low profit margins, 
primarily due to structurally unprofitable sub-categories such as Tables. In contrast, 
Technology demonstrates superior 
profitability and operational efficiency, making it a strong candidate for focused growth and investment.

Regionally, the West region consistently 
outperforms others in both revenue and profit, 
indicating effective market penetration and cost control. However, the Central region shows signs of margin pressure despite healthy sales, suggesting potential pricing or logistics inefficiencies.

Customer analysis highlights a concentration risk, where a small group 
of high-value customers contributes a significant share of total revenue. 
While this strengthens short-term performance, it also increases dependency risk, 
emphasizing the need for customer retention and diversification strategies.

The business is revenue-strong but margin-weak in certain areas; 
improving profitability requires focusing on high-margin categories, 
fixing loss-making products, and reducing customer concentration risk.” */
