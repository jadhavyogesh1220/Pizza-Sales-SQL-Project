-- Retrieve the total number of orders placed.

SELECT * FROM orders;
SELECT count(order_id) as TotalOrders FROM orders;

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(price*quantity),2) AS TotalSales FROM order_details a 
JOIN pizzas b ON a.pizza_id = b.pizza_id;

-- Identify the highest-priced pizza.

SELECT a.pizza_type_id, name,category,price FROM pizza_types a 
JOIN pizzas b ON a.pizza_type_id = b.pizza_type_id ORDER BY price DESC LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT size, count(a.order_details_id) as order_count FROM order_details a 
JOIN pizzas b ON a.pizza_id = b.pizza_id GROUP BY size ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities

SELECT name,sum(quantity) as TQuantity FROM pizza_types a
JOIN pizzas b ON a.pizza_type_id = b.pizza_type_id
JOIN order_details c ON c.pizza_id = b.pizza_id GROUP BY name ORDER BY TQuantity DESC LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT category,sum(quantity) as TQuantity FROM pizza_types a
JOIN pizzas b ON a.pizza_type_id = b.pizza_type_id
JOIN order_details c ON c.pizza_id = b.pizza_id GROUP BY category ;


-- Determine the distribution of orders by hour of the day.

select hour(time),count(order_id) from orders GROUP BY hour(time);

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(category) from pizza_types GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantitybydate),2) from
(select date, count(quantity) as  quantitybydate from orders a
JOIN order_details b ON a.order_id = b.order_id group by date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select name, ROUND(sum(quantity*price),2) as TotalRevenue  from pizza_types a 
JOIN pizzas b ON a.pizza_type_id = b.pizza_type_id 
JOIN order_details c ON c.pizza_id = b.pizza_id GROUP BY name ORDER BY TotalRevenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select category, 
ROUND((sum(quantity*price)/(SELECT SUM(price*quantity)as totalsales FROM order_details a 
JOIN pizzas b ON a.pizza_id = b.pizza_id)) *100,2) as percentage
from pizza_types a 
JOIN pizzas b ON a.pizza_type_id = b.pizza_type_id 
JOIN order_details c ON c.pizza_id = b.pizza_id GROUP BY category;

-- Analyze the cumulative revenue generated over time.

select date, sum(revenue) over(order by date) from
 (select date, sum(quantity*price) as  revenue from orders a
JOIN order_details b ON a.order_id = b.order_id
JOIN pizzas c ON b.pizza_id = c.pizza_id group by date ) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as ranking from 
(select category,name, sum(quantity*price) as revenue from pizzas a 
JOIN order_details b ON a.pizza_id = b.pizza_id
JOIN pizza_types c ON a.pizza_type_id = c.pizza_type_id 
group by category,name order by category )as a) as b where ranking<=3 ;


