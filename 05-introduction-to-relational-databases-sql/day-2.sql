/*
DATASET: Bookdepository
1. What is the format name from the users table that has the minimum count (display the minimum also)?
2. Find the descriptions (from dataset) with publication date in 2019 (sort them from 1st January until the end of the year)
3. Find how many descriptions (from dataset) doesn't have rating

DATASET: HR database
1. Sort the employees by their last name, their salary and their hire date
2. How many employees are there? How many departments and job specialties? (give a name to the new columns)
3a. What is the average salary of all employees? How much is the company paying for salaries in total?
3b. Who is getting the highest and who the lowest salary?
4a. How many employees are working in each department? find the five departments with the most of them.
4b. Find the five specialties with the most employees, too.
4c. Find how many employees were hired per department from 1990 to the end of 1995.

BONUS
5. How many employees does each manager supervise and what are the total salaries they manage?  We are interested only in managers with at least 2 employees.
6a.what is the lowest and highest salary for departments which have more than two employees?
6b. What is each specialty's average salary with more than one employees?
6c. What about each department's average salary and total budget? sort them by average
6d. filter the last question for departments with more than two employees and average salary higher than 6000.
7. Print the departments' names alongside the rest of the info.
*/
-- DATASET: Bookdepository

-- 1.
SELECT format_name, count
FROM users
WHERE count = (
	SELECT min(count)
FROM users);

-- 2.
SELECT description, publication_date
FROM dataset
WHERE publication_date LIKE '2019%'
ORDER BY
	publication_date;

-- 3.
SELECT count(description)
FROM dataset
WHERE rating_count IS NOT NULL;


SELECT description, rating_count
FROM dataset;

--DATASET: HR database

-- 1.
SELECT employee_id , first_name, last_name
FROM employees
ORDER BY
	last_name, salary, hire_date;

-- 2. 
SELECT count(employee_id) AS employees_nr
FROM employees;

SELECT count(department_id) AS departments_nr
FROM departments;

SELECT count(DISTINCT job_title) AS distinct_specialties_nr
FROM jobs;

-- 3a.
SELECT avg(salary) AS avg_salary
FROM employees;

SELECT sum(salary) AS total_salaries
FROM employees;

-- 3b.
SELECT employeed_id, first_name, last_name
FROM employees
ORDER BY
	salary
LIMIT 1;

SELECT employeed_id, first_name, last_name
FROM employees
ORDER BY
	salary DESC
LIMIT 1

-- 4a.
SELECT count(employee_id) AS employee_count,(
	SELECT department_name
FROM departments
WHERE department_id = employees.department_id
)
FROM employees
GROUP BY
	department_id
ORDER BY
	count(employee_id) DESC
LIMIT 5;

-- 4b.
SELECT (SELECT job_title
		FROM jobs j
		WHERE j.job_id = employees.job_id
), count(employee_id) AS employee_count
FROM employees
GROUP BY
	job_id
ORDER BY
	count(employee_id) DESC
LIMIT 5;

SELECT count(employee_id) AS employee_count,(
	SELECT department_name
FROM departments
WHERE department_id = employees.department_id
)
FROM employees
WHERE hire_date BETWEEN '1990-01-01' AND '1995-12-31'
GROUP BY
	department_id
ORDER BY
	count(employee_id) DESC;

-- 5.
SELECT(SELECT concat(first_name, ' ', last_name) AS manager_name
FROM employees e2
WHERE e2.employee_id = e1.manager_id), count(manager_id)
FROM employees e1
GROUP BY manager_id
HAVING count(manager_id) >= 2;

SELECT(SELECT concat(first_name, ' ', last_name) AS manager_name
FROM employees e2
WHERE e2.employee_id = e1.manager_id), sum(e1.salary)
FROM employees e1
GROUP BY manager_id
HAVING count(manager_id) >= 2;

-- 6a.
SELECT(SELECT department_name
FROM departments d
WHERE d.department_id = e.department_id), min(salary) AS min_salary
FROM employees e
GROUP BY department_id
HAVING count(employee_id) > 2;

SELECT(SELECT department_name
FROM departments d
WHERE d.department_id = e.department_id), max(salary) AS max_salary
FROM employees e
GROUP BY department_id
HAVING count(employee_id) > 2;

-- 6b. 
SELECT(SELECT job_title
FROM jobs j
WHERE j.job_id = e.job_id), round(avg(salary))
FROM employees e
GROUP BY job_id
HAVING count(employee_id) > 1;

-- 6c.
SELECT(SELECT department_name
FROM departments d
WHERE d.department_id = e.department_id), round(avg(salary)) AS avg_salary, sum(salary) AS budget
FROM employees e
GROUP BY department_id;

-- 6d.
SELECT(SELECT department_name
FROM departments d
WHERE d.department_id = e.department_id), round(avg(salary)) AS avg_salary, sum(salary) AS budget
FROM employees e
GROUP BY department_id
HAVING count(e.employee_id) > 2
AND avg(salary) > 6000;

-- 7. Already done
-- Extra--για οποιον έχει τελειώσει, χρειάζομαι το employee_id και το salary
--για οσους υπαλλήλους έχουν μισθό πάνω απο το μέσο μισθό όλων των υπαλλήλων.
SELECT employee_id, salary
FROM employees
WHERE salary > (
SELECT avg(salary)
FROM employees e2
)
