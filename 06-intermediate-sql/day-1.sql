--Dataset: NBA games

--1.a Find all allstar MVP players.
SELECT DISTINCT p.full_name
FROM allstar_mvps m
JOIN players p ON p.id = m.player_id;
-- SELECT distinct award FROM player_awards

--1.b Find all players born in New York.
SELECT full_name, birth_place  
FROM players
WHERE birth_place LIKE '%New York%';


--1.c Which players born in New York hold a MVP title?
SELECT full_name, birth_place  
FROM players
WHERE birth_place LIKE '%New York%' 
AND id IN
		(
		SELECT player_id FROM allstar_mvps	
		);
-- OR
SELECT DISTINCT p.full_name, p.birth_place  
FROM players p
JOIN allstar_mvps a ON p.id = a.player_id
WHERE birth_place LIKE '%New York%';


--2. Which players have the same height?
SELECT p1.full_name, p2.full_name, height
FROM players p1
JOIN players p2 USING (height)
WHERE p1.full_name < p2.full_name;

--3. List the top 10 of the players having the most “Player of the Month” Awards.
SELECT p.id, p.full_name, count(a.id) award_count
FROM players p
JOIN monthly_player_awards a ON p.id = a.player_id
WHERE a.award_type = 'Player of the Month'
GROUP BY p.id, p.full_name
ORDER BY count(a.id) DESC
LIMIT 10;


--4. Using table teams, create a new column that writes the messages "More than 2000 wins", 
--"2000 wins" or "Less than 2000 wins" depending the number of wins it has, and also print 
--the name and the number of wins for each team.

SELECT team_name, total_wins,
CASE 
	WHEN total_wins > 2000 THEN 'More than 2000 wins'
	WHEN total_wins = 2000 THEN '2000 wins'
	ELSE 'Less than 2000 wins'
	END AS win_group
FROM teams;
