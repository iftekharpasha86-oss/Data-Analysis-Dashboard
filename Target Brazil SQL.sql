
#Structure_characteristics
SELECT * FROM customers LIMIT 5;
SELECT COUNT(*) FROM customers;


#Data_types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customers';

#Order_time_range
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM orders;

#Cities & states
Select count(DISTINCT customer_city) AS City_count,
count(Distinct customer_state) as state_count
from customers

#Yearly trend
SELECT EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
       COUNT(*) AS total_orders
FROM orders
GROUP BY year
ORDER BY year;

#monthly trend
Select to_char(order_purchase_timestamp::timestamp, 'YYYY-MM') as month,
count(*) total_orders
from orders
group by month
order by month ASC


#Time_of_day
Select 
Case 
when extract (Hour from order_purchase_timestamp::timestamp) < 6 then 'Dawn'
when extract (Hour from order_purchase_timestamp::timestamp) < 12 then 'Morning'
when extract (Hour from order_purchase_timestamp::timestamp) < 18 then 'evening'
else 'night'
end as time_of_day,
count (*) as order_count
from orders
group by time_of_day


#Orders_by_state/month
Select customer_state,
to_char(order_purchase_timestamp::timestamp, 'YYYY-MM') as month,
count (*) as total_order
from orders
Join customers using(customer_id)
group by customer_state, month
order by month 

#Customer_distribution
select customer_state, count (*) as customer_count
from customers
group by customer_state
order by customer_count Desc


#Total/avg prices and freight by_state
SELECT
  customer_state,
  SUM(price::numeric) AS total_price,
  ROUND(AVG(price::numeric),2) AS avg_price,
  SUM(freight_value::numeric) AS total_freight,
  ROUND (AVG(freight_value::numeric), 2) AS avg_freight 
FROM orders
JOIN order_item USING(order_id)
JOIN customers USING(customer_id)
GROUP BY customer_state;


#% increase_in_cost_(2017 vs 2018, Jan–Aug)
WITH price_by_year AS (
  SELECT EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
         SUM(price::numeric) AS total_price
  FROM orders
  JOIN order_item USING(order_id)
  WHERE EXTRACT(MONTH FROM order_purchase_timestamp::timestamp) <= 8
  GROUP BY year
)
SELECT
  Round((b.total_price - a.total_price) / a.total_price * 100,2) AS percent_increase
FROM price_by_year a
JOIN price_by_year b ON a.year = 2017 AND b.year = 2018;

#Total & Average per_State
SELECT
  c.customer_state,
  SUM(oi.price::numeric) AS total_price,
  ROUND(AVG(oi.price::numeric), 2) AS avg_price,
  SUM(oi.freight_value::numeric) AS total_freight,
  ROUND(AVG(oi.freight_value::numeric), 2) AS avg_freight
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY c.customer_state;

#delivery time & delay
-- Create a view or CTE
SELECT
  customer_state,
  DATE_PART('day', order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp) AS delivery_time,
  DATE_PART('day', order_estimated_delivery_date::timestamp - order_delivered_customer_date::timestamp) AS delivery_delay
FROM orders
JOIN customers USING(customer_id)
WHERE order_delivered_customer_date IS NOT NULL;


#top5_AVG_Fright_values

SELECT customer_state, ROUND(AVG(freight_value::numeric),2) AS avg_freight
FROM orders
JOIN order_item USING(order_id)
JOIN customers USING(customer_id)
GROUP BY customer_state
ORDER BY avg_freight DESC
LIMIT 5;


#States with fastest delivery vs estimated

SELECT customer_state, AVG(order_estimated_delivery_date::timestamp - order_delivered_customer_date::timestamp) AS early_days
FROM orders
JOIN customers USING(customer_id)
WHERE order_delivered_customer_date < order_estimated_delivery_date
GROUP BY customer_state
ORDER BY early_days DESC
LIMIT 5;

#Highest & lowest Average Delivery Times
SELECT
  c.customer_state,
  ROUND(AVG(DATE_PART('day', o.order_delivered_customer_date::timestamp - o.order_purchase_timestamp::timestamp))::numeric, 2) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC
LIMIT 5;

#Highest & lowest Average Freight_values
SELECT
  c.customer_state,
  ROUND(AVG(oi.freight_value::numeric), 2) AS avg_freight
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY avg_freight DESC
LIMIT 5;


#Monthly payment type usage
SELECT
  payment_type,
  TO_CHAR(order_purchase_timestamp::timestamp, 'YYYY-MM') AS month,
  COUNT(*) AS order_count
FROM payments
JOIN orders USING(order_id)
GROUP BY payment_type, month
ORDER BY month;

#Installments
SELECT payment_installments, COUNT(*) AS order_count
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


