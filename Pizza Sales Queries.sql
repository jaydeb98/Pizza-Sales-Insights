-- Basic
-- 1. Retrieve the Total Number of Order Placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- 2. Calculate the Total Revenue Generated from Pizza Sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_Revenue_Generated
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
-- 3. Identify the Highest Priced Pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 4. Identify the Most Common Size Pizza Ordered.

SELECT 
    p.size AS Pizza_Size,
    COUNT(o.order_details_id) AS Order_Times
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY COUNT(o.order_details_id) DESC;

-- 5. List the Top 5 Most Ordered Pizza Types Along with Their Quantities.

SELECT 
    pt.name, SUM(od.quantity) AS Order_Count
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY Order_Count DESC
LIMIT 5;

-- Intermediate
-- 6. Join the Necessary Tables to Find the Total Quantity of Each Pizza Category Ordered.

SELECT 
    pt.category, SUM(od.quantity) AS Total_Quantity_Ordered
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY Total_Quantity_Ordered DESC;

-- 7. Determine the Distribution of Orders by Hour of the Day.

SELECT 
    HOUR(order_time) AS Order_Hour,
    COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY Order_Hour
ORDER BY Order_Count DESC; 

-- 8. Join Relevant Tables to Find the Category-Wise Distribution of Pizzas.

SELECT 
    category, COUNT(name) AS Available_Pizza_Types
FROM
    pizza_types 
    
GROUP BY category
ORDER BY Available_Pizza_Types DESC;

-- 9. Group the Orders by Date and Calculate the Average Number of Pizzas Ordered Per Day.

SELECT 
    ROUND(AVG(quantity)) AS average_order_quantity
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.order_date) AS total_orders_per_day;
    
-- 10. Determine the Top 3 Most Ordered Pizza Types Based on Revenue.

SELECT 
    pt.name,
    SUM(od.quantity * p.price) AS Total_Revenue_Generated
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Total_Revenue_Generated DESC
LIMIT 3;

-- Advanced
-- 11. Calculate the Percentage Contribution of Each Pizza Type to Total Revenue.

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue_generated
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id) * 100,
            2) AS revenue_percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category;

-- 12. Analyze the Cumulative Revenue Generated Over Time.

SELECT 
    order_date, 
    ROUND(SUM(revenue) OVER (ORDER BY order_date)) AS cumulative_revenue
FROM (
    SELECT 
        o.order_date, 
        SUM(od.quantity * p.price) AS revenue
    FROM 
        pizzas p
    JOIN 
        order_details od 
        ON p.pizza_id = od.pizza_id
    JOIN 
        orders o 
        ON o.order_id = od.order_id
    GROUP BY 
        o.order_date
) AS sales;

-- 13. Determine the Top 3 Most Ordered Pizza Types Based on Revenue for Each Pizza Category.

WITH ranked_pizza AS (
    SELECT 
        pt.name, 
        pt.category, 
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS sales_rank
    FROM 
        pizza_types pt 
    JOIN 
        pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN 
        order_details od ON od.pizza_id = p.pizza_id 
    GROUP BY 
        pt.name, pt.category
)
SELECT 
    category, 
    name, 
    revenue, 
    sales_rank
FROM 
    ranked_pizza
WHERE 
    sales_rank <= 3;
