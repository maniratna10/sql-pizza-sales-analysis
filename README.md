# 🍕 Pizza Shop SQL Analysis Project

## 📌 Project Overview
This project focuses on analyzing a Pizza Shop database using SQL.  
The goal is to extract meaningful business insights related to sales, revenue, customer behavior, and product performance.

This project is ideal for demonstrating SQL skills such as:
- Data querying
- Joins
- Aggregations
- Subqueries
- Business problem solving

---

## 🗄️ Database Details
The database contains tables related to:
- Orders
- Order details
- Pizzas
- Pizza types
- Categories

---

## 🛠️ Tools Used
- MySQL
- SQL
- GitHub

---

## 📂 Project Structure
- **database/** → Database schema & data files  
- **queries/** → SQL queries categorized by difficulty  
- **insights/** → Business insights derived from analysis  
- **screenshots/** → Output screenshots (optional)

---

## 📊 Key Analysis Performed
- Total revenue calculation
- Top-selling pizzas
- Category-wise sales analysis
- Order trends
- Customer purchasing patterns

---

## 👤 Author
**Mani Ratna**  
Aspiring Data Analyst | SQL | Excel | Data Analysis

---

/*
====================================================
File Name   : sales_analysis.sql
Project     : Pizza Shop SQL Analysis
Description : This file contains Basic, Intermediate,
              and Advanced SQL queries to analyze
              pizza sales, revenue, customer ordering
              patterns, and product performance.
Database    : MySQL
Author      : Mani Ratna
====================================================
*/


/* =========================
   BASIC QUERIES
   ========================= */

-- 1. Retrieve the total number of orders placed
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales
SELECT ROUND(SUM(o.quantity * p.price), 2) AS total_sales
FROM order_details o
JOIN pizzas p 
ON o.pizza_id = p.pizza_id;

-- 3. Identify the highest-priced pizza
SELECT t.name AS pizza_name, p.price
FROM pizza_types t
JOIN pizzas p 
ON t.pizza_type_id = p.pizza_type_id
WHERE p.price = (SELECT MAX(price) FROM pizzas);

-- 4. Identify the most common pizza size ordered
SELECT p.size, COUNT(o.order_details_id) AS order_count
FROM order_details o
JOIN pizzas p 
ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types with quantities
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


/* =========================
   INTERMEDIATE QUERIES
   ========================= */

-- 6. Total quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 7. Distribution of orders by hour of the day
SELECT HOUR(order_time) AS order_hour, COUNT(order_id) AS orders_count
FROM orders
GROUP BY order_hour
ORDER BY orders_count DESC;

-- Category-wise distribution of pizzas
SELECT category, COUNT(pizza_type_id) AS pizza_count
FROM pizza_types
GROUP BY category
ORDER BY pizza_count DESC;

-- 8. Average number of pizzas ordered per day
SELECT ROUND(AVG(total_quantity), 0) AS avg_orders_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS total_quantity
    FROM orders o
    JOIN order_details od 
    ON o.order_id = od.order_id
    GROUP BY o.order_date
) daily_orders;

-- 9. Top 3 most ordered pizza types based on revenue
SELECT pt.name, ROUND(SUM(od.quantity * p.price), 0) AS total_revenue
FROM order_details od
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


/* =========================
   ADVANCED QUERIES
   ========================= */

-- 10. Percentage contribution of each pizza category to total revenue
SELECT 
    pt.category,
    CONCAT(
        ROUND(
            (SUM(od.quantity * p.price) /
            (SELECT SUM(o.quantity * p2.price)
             FROM order_details o
             JOIN pizzas p2 ON o.pizza_id = p2.pizza_id)
            ) * 100, 2
        ), '%'
    ) AS revenue_percentage
FROM order_details od
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;

-- 11. Cumulative revenue generated over time
SELECT 
    order_date,
    revenue,
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        o.order_date,
        ROUND(SUM(od.quantity * p.price), 2) AS revenue
    FROM orders o
    JOIN order_details od 
    ON od.order_id = o.order_id
    JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) daily_revenue;

-- 12. Top 3 pizza types by revenue within each category
WITH revenue_cte AS (
    SELECT 
        pt.category,
        pt.name,
        ROUND(SUM(od.quantity * p.price), 0) AS revenue
    FROM order_details od
    JOIN pizzas p 
    ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt 
    ON pt.pizza_type_id = p.pizza_type_id
    GROUP BY pt.category, pt.name
),
rank_cte AS (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_no
    FROM revenue_cte
)
SELECT category, name, revenue
FROM rank_cte
WHERE rank_no <= 3;


