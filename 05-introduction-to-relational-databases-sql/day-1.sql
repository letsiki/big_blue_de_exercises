/*
1. Retrieve all information from the 'dataset' table.
2. Retrieve the title, imprint, rating, number of ratings, and language.
3. Which languages are present in the dataset table?
4. Find the books that have the word 'history' anywhere in their title.
5. Find the books in Spanish('hi)', Italian('it') and Greek('el')
6. Titles:
	a) Find the titles with the highest average ratings (rating = 5)
	b) Which title(s) from this set have above 20 rating counts?
7. Which editor (imprint) published the highest number of titles between 2010 and 2020?
8. Format
	a) Which is the most published format from MIT Press?
	b) Which editors publish in leather format?
	c) How many books are in each format?
9. Find the titles of the top 100 best sellers
10. Display the formats where the last characters are "back"
*/
-- 1
SELECT *
FROM dataset;

-- 2
SELECT title, imprint, rating_avg, rating_count, lang 
FROM dataset;

-- 3
SELECT DISTINCT lang
FROM dataset;

-- 4
SELECT title
FROM dataset
WHERE lang = 'el' OR lang = 'hi' OR lang = 'it';

-- 5
SELECT title
FROM dataset 
WHERE rating_avg = 5;

-- 6
SELECT title
FROM dataset
WHERE rating_count > 20;

-- 7
SELECT imprint, count(title)
FROM dataset 
WHERE (publication_date BETWEEN '2010' AND '2020') AND (imprint IS NOT NULL)
GROUP BY imprint
ORDER BY count(title) DESC
LIMIT 1;

-- 8a
SELECT f.format_name, count(ds.format) AS format_count
FROM dataset ds
JOIN formats f ON f.format_id = ds.format 
WHERE imprint = 'MIT Press'
GROUP BY f.format_name
ORDER BY format_count desc
LIMIT 1;

-- 8b
SELECT DISTINCT ds.imprint
FROM dataset ds
JOIN formats f ON f.format_id = ds.format 
WHERE f.format_name = 'Leather';

-- 8c
SELECT f.format_name, count(title)
FROM dataset ds
JOIN formats f ON f.format_id = ds.format
GROUP BY f.format_name;

-- 9
SELECT title
FROM dataset 
ORDER by bestsellers_rank
LIMIT 100;

-- 10
SELECT format_name
FROM formats
WHERE format_name LIKE '%back';
