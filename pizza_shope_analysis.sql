-- Basic:

-- 1 Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders FROM orders;

-- 2 Calculate the total revenue generated from pizza sales.

SELECT round(sum(o.quantity * p.price),2) AS total_sales 
FROM order_details o
JOIN pizzas p ON o.pizza_id = p.pizza_id;

-- 3 Identify the highest-priced pizza.

SELECT t.name, p.price
FROM pizza_types t
JOIN pizzas p ON t.pizza_type_id = p.pizza_type_id
where p.price = (SELECT MAX(price) FROM pizzas);

-- 4 Identify the most common pizza size ordered.

SELECT p.size, COUNT(order_details_id) AS order_count
FROM order_details o
JOIN pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
limit 1;

-- 5 List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
order by total_quantity DESC
limit 5;


-- Intermediate:

-- 6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantaty
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantaty DESC;

-- 7 Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS hours, count(order_id) AS orders_count
FROM orders
GROUP BY hours
ORDER BY orders_count DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, count(pizza_type_id) AS pizza_count
FROM pizza_types
GROUP BY category
ORDER BY pizza_count DESC;

-- 8 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(total_quantaty),0) AS avg_orders_per_day FROM 
(SELECT o.order_date, sum(od.quantity) AS total_quantaty
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY order_date) AS total_orders_by_date;

-- 9 Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, (ROUND(SUM(od.quantity * p.price),0)) AS total_revenu
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenu DESC
LIMIT 3;


-- Advanced:

-- 10 Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category, CONCAT(ROUND(((ROUND(SUM(od.quantity * p.price),0)) / (SELECT round(sum(o.quantity * p.price),2) AS total_sales 
FROM order_details o
JOIN pizzas p ON o.pizza_id = p.pizza_id)) * 100,2),"%")  AS total_revenu
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_revenu DESC;

-- OR same with views
                                            
SELECT pt.category, concat(ROUND(((ROUND(SUM(od.quantity * p.price)))/ MAX(ts.total_sales)) * 100,2),"%") AS total_revenu
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
JOIN total_sales_view ts
GROUP BY pt.category
ORDER BY total_revenu DESC;                                            

-- 11 Analyze the cumulative revenue generated over time.

SELECT order_date, revenu, SUM(revenu) OVER(ORDER BY order_date) AS cumulating_revenu
FROM
(SELECT o.order_date, ROUND(SUM(od.quantity * p.price),2) as revenu
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id 
group by o.order_date) as total_revenu_by_date;

-- 12 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH revenu_category_cte AS (
SELECT pt.category, pt.name, ROUND(SUM(od.quantity * p.price),0) AS revenu
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category,pt.name
ORDER BY revenu DESC),
rank_cte as(
SELECT category, name, revenu, RANK() OVER(PARTITION BY category ORDER BY revenu DESC) AS ranks
FROM revenu_category_cte
)
SELECT category, name, revenu
FROM rank_cte
where ranks <=3 ;
