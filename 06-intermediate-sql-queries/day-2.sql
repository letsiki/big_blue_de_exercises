--Dataset: NBA games

--5.a  Create a view with the team id, team name and number of championships.
CREATE VIEW team_championships_view AS	
SELECT t.team_id, t.team_name, count(c.season) AS championships
FROM teams t
LEFT JOIN champions c USING (team_id)
GROUP BY t.team_id, t.team_name;

--5.b Print from the view all the teams from Miami or Milwaukee that have a championship.
SELECT * FROM team_championships_view
WHERE team_name LIKE '%Miami%' OR team_name LIKE '%Milwaukee%' AND championships > 0;

--5.c Update view with total wins and total loses.
CREATE OR REPLACE VIEW team_championships_view AS	
SELECT t.team_id, t.team_name, count(c.season) AS championships, t.total_wins, t.total_losses
FROM teams t
LEFT JOIN champions c USING (team_id)
GROUP BY t.team_id, t.team_name, total_wins, total_losses;

SELECT * FROM team_championships_view;

--6. Find all players that have both awards and other awards and print the name of the award as well.
SELECT p.id, p.name, string_agg(a.award, ', ') AS awards, string_agg(o.award, ',') AS other_awards
FROM players p
RIGHT JOIN player_awards a on p.id = a.player_id 
RIGHT JOIN other_player_awards o ON o.payer_id = a.player_id
GROUP BY p.id, p.name
;


--Dataset: lahman2017
--In our field sometimes we have to seek domain knowledge to answer specific questions. 
--The difficulty in the following dataset is to understand the columns and look around for 
--information to better understand the questions (check wikipedia and other websites for baseball terminology)

--From lahman2017 baseball database answer the following:
--1. Which player hit the most home runs in 2002?
SELECT playerid , namefirst, namelast, sum(hr) AS hr_total
FROM batting 
JOIN master USING (playerid)
WHERE yearid = 2002
GROUP BY playerid , namefirst, namelast
ORDER BY hr_total DESC 
LIMIT 1;

--2. Which team spent the most/least money on player salaries in 2002?
(SELECT t.name, sum(s.salary) AS salary_budget
FROM salaries s
JOIN teams t USING (teamid, yearid)
WHERE yearid = 2002
GROUP BY t.name
ORDER BY salary_budget DESC
LIMIT 1)
UNION
(SELECT t.name, sum(s.salary) AS salary_budget
FROM salaries s
JOIN teams t USING (teamid)
WHERE s.yearid = 2002 AND t.yearid = 2002
GROUP BY t.name
ORDER BY salary_budget
LIMIT 1);

--3. Which player averaged the fewest at bats between home runs in 2002?
SELECT playerid, namefirst, namelast, avg(ab/hr) AS avg_at_bats
FROM batting
JOIN master USING (playerid)
WHERE yearid = 2002 and hr <> 0
GROUP BY playerid, namefirst, namelast
ORDER BY avg_at_bats
LIMIT 1;

--4. Which player in 2002 had the highest on-base percentage?
SELECT m.namefirst, m.namelast, avg((h + bb + hbp) / (ab + bb + hbp + sf)) * 100 AS ob_prc
FROM batting
JOIN master m using (playerid)
WHERE (ab + bb + hbp + sf) <> 0
GROUP BY m.namefirst, m.namelast
ORDER BY ob_prc DESC
LIMIT 1;

--5. Which Yankees pitcher had the most wins in a season in the 00’s?
SELECT m.playerid, m.namefirst, m.namelast, p.yearid, max(w) AS wins_2000
FROM pitching p
JOIN master m USING (playerid)
WHERE (p.yearid BETWEEN 2000 AND 2009) AND teamid  = 'NYA'
GROUP BY m.playerid, m.namefirst, m.namelast, p.yearid
ORDER BY wins_2000 desc;


--6. Which Yankees pitcher had the most wins between 1999 and 2009?
SELECT m.playerid, m.namegiven, p.yearid, sum(w) AS wins_2000
FROM pitching p
JOIN master m USING (playerid)
WHERE (p.yearid BETWEEN 1999 AND 2009) AND teamid  = 'NYA'
GROUP BY m.playerid, m.namegiven, p.yearid
ORDER BY wins_2000 desc;

--7. In the 2000’s, did the Yankees draw more or fewer walks (Base-on-Balls or BB) as the decade went on?
SELECT teamid, yearid, bb
FROM teams
WHERE yearid BETWEEN 2000 AND 2009 AND teamid = 'NYA'
ORDER BY yearid;
