--DATASET : Parch-posey

--4e. What day of the week was the last entry made? (0=Sunday)
SELECT date_part('dow', max(occurred_at)) AS day_of_week FROM orders o;
SELECT to_char(max(occurred_at), 'DAY') AS day_of_week FROM orders o;
SELECT concat(substring(day_of_week FROM 1 FOR 1), lower(substring(day_of_week FROM 2))) AS day from
(SELECT to_char(max(occurred_at), 'DAY') AS day_of_week FROM orders o) AS l;

--5a. It takes half an hour to register an order in the system. Calculate the time the orders were truly placed, 
--30 minutes earlier.
SELECT *, occurred_at - INTERVAL '30 minutes' AS time_placed FROM orders o;

--5b. Also, expected delivery is in 4 days at most. Create a column for latest delivery date (no time info needed)
SELECT *, REGEXP_REPLACE(date_trunc('day', occurred_at + INTERVAL '4 days')::varchar, 
								 ' .*', '') AS deliver_by FROM orders o;
--5c. Create two new columns(qty, amt) for non-standard paper (gloss+poster) orders as 'other' and create a view of 
--this table
--(columns : orders.id, accounts.name, orders.occurred_at, orders.standard_qty, orders.gloss_qty, orders.poster_qty, 
--orders.total, orders.standard_amt_usd, orders.gloss_amt_usd, orders.poster_amt_usd, orders.total_amt_usd + 2 new ones)
CREATE VIEW orders_plus_other_aa as
SELECT orders.id, accounts.name, orders.occurred_at, orders.standard_qty, orders.gloss_qty, orders.poster_qty, 
orders.total, orders.standard_amt_usd, orders.gloss_amt_usd, orders.poster_amt_usd,
orders.total_amt_usd, gloss_qty + poster_qty AS other_qty, gloss_amt_usd + poster_amt_usd AS other_amt_usd 
FROM orders
JOIN accounts ON accounts.id = orders.account_id;

SELECT * FROM orders_plus_other_aa

--6a. How much standard and other quantity and amount were sold per year
SELECT date_part('year', occurred_at)::varchar AS year, 
	   sum(standard_qty) AS total_standard_qty, 
	   sum(standard_amt_usd) AS total_amt_usd, 
	   sum(other_qty) AS total_other_qty, 
	   sum(other_amt_usd) AS total_other_amt
FROM orders_plus_other_aa
GROUP BY date_part('year', occurred_at)
ORDER BY YEAR;

--6b. How much standard and other quantity and amount were sold during 2015 and 2016 to Walmart and Apple?
SELECT name,
	   -- date_part('year', occurred_at)::varchar AS year, 
	   sum(standard_qty) AS total_standard_qty, 
	   sum(standard_amt_usd) AS total_amt_usd, 
	   sum(other_qty) AS total_other_qty, 
	   sum(other_amt_usd) AS total_other_amt
FROM orders_plus_other_aa
WHERE date_part('year', occurred_at) BETWEEN 2015 AND 2016 AND name IN ('Apple', 'Walmart')
GROUP BY name --date_part('year', occurred_at), name
ORDER BY name;

--7a. Which month has the highest sales of paper in total quantity? Can you possibly give an explanation?
WITH total_paper_sold AS (
SELECT date_part('month', occurred_at) AS month, sum(total) AS total_paper_qty
FROM orders_plus_other_aa
GROUP BY date_part('month', occurred_at)
)
SELECT * 
FROM total_paper_sold
WHERE total_paper_qty = (SELECT max(total_paper_qty) FROM total_paper_sold);
-- It's Christmas


--7b. Which client ordered the biggest quantity of paper during December 2016?
WITH total_paper_sold AS (
SELECT name, sum(total) AS total_paper_qty
FROM orders_plus_other_aa
WHERE date_part('year', occurred_at) = 2016 AND date_part('month', occurred_at) = 12
GROUP BY name
)
SELECT * 
FROM total_paper_sold
WHERE total_paper_qty = (SELECT max(total_paper_qty) FROM total_paper_sold);

-- 7c. How many orders are made per week on average, how much paper is sold on average
--SELECT date_part('week', occurred_at) AS wk, count(id) AS orders_nr, avg(total) AS avg_amt_per_order
--FROM orders_plus_other_aa
--GROUP BY date_part('week', occurred_at)
--ORDER BY wk;

WITH weekly_orders AS (
	SELECT date_part('week', occurred_at) AS "week",
		   count(id) AS orders_count,
		   sum(total) AS total_paper
FROM orders_plus_other_aa
GROUP BY date_part('week', occurred_at)
)
SELECT round(avg(orders_count)) AS weekly_orders,
       round(avg(total_paper)) AS weekly_paper
       FROM weekly_orders;
	   


SELECT round(avg(orders_count)) AS weekly_orders,
       round(avg(total_paper)) AS weekly_paper
       FROM (
			SELECT date_part('week', occurred_at) AS "week",
		   		   count(id) AS orders_count,
		           sum(total) AS total_paper
			FROM orders_plus_other_aa
			GROUP BY date_part('week', occurred_at)
	   ) sub;


--8a. How many orders are made per day of the week?
SELECT date_part('dow', occurred_at) AS weekday, count(id) AS orders_nr
FROM orders_plus_other_aa
GROUP BY date_part('dow', occurred_at)
ORDER BY weekday;

--8b. Which client company has made the most orders during weekends?
SELECT name, count(id) order_nr
FROM orders_plus_other_aa
WHERE date_part('dow', occurred_at) IN (0, 6)
GROUP BY name
ORDER BY order_nr DESC
LIMIT 1;

--8c. How many orders have been placed between 00:00 and 06:00?
SELECT count(id) AS order_count
FROM orders_plus_other_aa
WHERE occurred_at::time BETWEEN '00:00' AND '06:00';

SELECT count(id) AS order_count
FROM orders_plus_other_aa
WHERE date_part('hour', occurred_at) BETWEEN 0 AND 5;

--9a. How many orders are placed per client on Mondays and what are these orders' ids. Which client has the most?
SELECT name, 
	   id AS order_id, 
	   occurred_at::date AS order_date,
	   count(id) over(PARTITION BY name) as client_total_count
FROM orders_plus_other_aa
WHERE date_part('dow', occurred_at) = 1
ORDER BY client_total_count DESC, name, order_date


--9b. Rank order ids based on total quantity and amount_usd sold to Supervalu during 2016. Do the RANKs of qty 
--and amt correspond?
WITH rankings AS (
SELECT id AS order_id,
	   occurred_at::date AS order_date,
	   total AS quantity, 
	   total_amt_usd AS order_amt,
	   rank() over(ORDER BY total desc) AS quantity_rank,
	   rank() over(ORDER BY total_amt_usd desc) AS amt_rank
FROM orders_plus_other_aa
WHERE name = 'Supervalu' AND date_part('year', occurred_at) = 2016
ORDER BY quantity_rank
)
SELECT *, CASE
			WHEN quantity_rank = amt_rank THEN 'YES'
			ELSE 'NO'
			END AS does_qty_rank_match_amt_rank
FROM rankings;


SELECT *, CASE
			WHEN quantity_rank = amt_rank THEN 'YES'
			ELSE 'NO'
			END AS does_qty_rank_match_amt_rank
FROM (
	SELECT id AS order_id,
		   occurred_at::date AS order_date,
		   total AS quantity, 
		   total_amt_usd AS order_amt,
		   rank() over(ORDER BY total desc) AS quantity_rank,
		   rank() over(ORDER BY total_amt_usd desc) AS amt_rank
	FROM orders_plus_other_aa
	WHERE name = 'Supervalu' AND date_part('year', occurred_at) = 2016
	ORDER BY quantity_rank
	) sub;

--9c. What is the difference in paper sales (usd total amount) month to month for  Coca-Cola and Walmart 
--for the year 2016?
WITH coca_walmart AS (
SELECT name, 
	   date_part('month', occurred_at) AS "month",
	   sum(total_amt_usd) AS monthly_sales
FROM orders_plus_other_aa
WHERE date_part('year', occurred_at) = 2016 AND name IN ('Coca-Cola', 'Walmart')
GROUP BY name, date_part('month', occurred_at)
)
SELECT *,
	   monthly_sales - (LAG(monthly_sales, 1) OVER(PARTITION BY name ORDER BY month)) AS monthly_diff 
FROM coca_walmart
ORDER BY name, MONTH;


SELECT *,
	   monthly_sales - (LAG(monthly_sales, 1) OVER(PARTITION BY name ORDER BY month)) AS monthly_diff 
FROM (
	SELECT name, 
		   date_part('month', occurred_at) AS "month",
		   sum(total_amt_usd) AS monthly_sales
	FROM orders_plus_other_aa
	WHERE date_part('year', occurred_at) = 2016 AND name IN ('Coca-Cola', 'Walmart')
	GROUP BY name, date_part('month', occurred_at)
) sub
ORDER BY name, MONTH;




