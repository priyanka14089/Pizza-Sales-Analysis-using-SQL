create database pizzastore;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );


-- Basic Queries

-- Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders
FROM orders;


-- Calculate the total revenue generated from pizza sales.

SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza.

SELECT p.pizza_id, pt.name, p.size, p.price
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT p.size, COUNT(*) AS total_orders
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Intermediate Queries

-- Find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS order_hour, COUNT(order_id) AS total_orders
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_hour;


 -- Find the category-wise distribution of pizzas.

SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;


-- Group orders by date and calculate the average number of pizzas ordered per day.

SELECT order_date, AVG(pizza_count) AS avg_pizzas_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS pizza_count
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) daily_orders
GROUP BY order_date;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

 -- Advanced Queries

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.name,
       ROUND(SUM(od.quantity * p.price) * 100.0 /
       (SELECT SUM(od2.quantity * p2.price)
        FROM order_details od2
        JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 2) AS revenue_percentage
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;


-- Analyze the cumulative revenue generated over time.

SELECT order_date,
       SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date, SUM(od.quantity * p.price) AS daily_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) revenue_by_date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue
FROM (
    SELECT pt.category, pt.name,
           SUM(od.quantity * p.price) AS revenue,
           ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked
WHERE rn <= 3;



