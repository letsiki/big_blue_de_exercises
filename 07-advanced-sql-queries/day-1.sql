DATASET : Parch-posey


--1a. Look for companies which have the word 'group' anywhere in their names (case insensitive search)
SELECT name 
FROM accounts
WHERE name ILIKE '%group%';

--1b. Remove (replace) the 'www.' and '.com' FROM the website column
SELECT name, REPLACE(replace(website, 'www.', ''), '.com', '') AS website
FROM accounts

--2a. Find the position of ' ' (space) in the representatives' names
SELECT name, position(' ' IN name) AS space_position
FROM sales_reps sr;

--2b. Now create two columns for the first and last names of the representatives
SELECT substring(name FROM 1 for position(' ' IN name) - 1) AS first_name,
substring(name FROM position(' ' IN name) + 1) AS last_name
FROM sales_reps;

--3a. Create a column 'client_representative' in alphabetical order combining 
-- the name of the client company and the name of the representative.
SELECT concat(a.name, ' ', s.name) AS client_representative
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id  = s.id
ORDER BY client_representative;

--3b. How many clients does each representative have?
SELECT sr.name, count(a.name) AS client_nr
FROM accounts a 
JOIN sales_reps sr ON a.sales_rep_id = sr.id
GROUP BY sr.name
ORDER BY client_nr desc

--4a. Create a column coordinates combining latitude and longitude separated with a comma
SELECT concat(long::varchar, ', ', lat::varchar) AS coordinates 
FROM accounts a;

--4b. Create a column 'location' for each client combining latitude, longitude and the region each 
-- representative is appointed at, separated with a comma.
SELECT a.name, concat(long::varchar, ', ', lat::varchar, ' ', r."name") AS coordinates 
FROM accounts a
JOIN sales_reps sr ON a.sales_rep_id = sr.id
JOIN region r ON sr.region_id = r.id;

--4c. When was the last entry of an order?
SELECT occurred_at   
FROM orders
ORDER BY occurred_at desc
LIMIT 1;

--4d. How long since this last entry?
SELECT age(now(), (SELECT occurred_at   
				   FROM orders
				   ORDER BY occurred_at desc
				   LIMIT 1)
		  );


