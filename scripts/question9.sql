
-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT Max (year) AS latest, MIN(year) AS earliest
FROM homegames





--1871-2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namefirst,namelast,namegiven, height,g_all,teamid
FROM people as p
JOIN appearances AS a
USING (playerid)
ORDER BY height ASC
LIMIT 1

"Eddie"	"Gaedel"	"Edward Carl"	43	1	"SLA"

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- Find all players in the database who played at Vanderbilt University. 
SELECT namefirst, namelast,schoolname
FROM people
JOIN collegeplaying
USING (playerid)
JOIN schools
USING (schoolid)
WHERE schoolname LIKE 'Vanderbilt%'
ORDER BY schoolname DESC

-- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues
SELECT schoolname AS school,namefirst, namelast,SUM(salary) AS total_salary
FROM people AS p
JOIN collegeplaying AS cp
USING (playerid)
JOIN schools AS s
USING (schoolid)
JOIN salaries AS sa
USING (playerid)
WHERE schoolname LIKE 'Vanderbilt%' 
GROUP BY namefirst,namelast,s.schoolname,salary
ORDER BY salary DESC

--Which Vanderbilt player earned the most money in the majors?
SELECT schoolname AS school,namefirst, namelast,SUM(salary) AS total_salary 
FROM people AS p
JOIN collegeplaying AS cp
USING (playerid)
JOIN schools AS s
USING (schoolid)
JOIN salaries AS sa
USING (playerid)
WHERE schoolname LIKE 'Vanderbilt%' 
GROUP BY namefirst,namelast,s.schoolname
-- ANSWER: "Vanderbilt University"	"David"	"Price"	$245553888




-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(po) AS putouts,
	 CASE 
		WHEN pos='SS' OR pos='1B' OR pos='2B' OR pos='3B' THEN 'Infield'
		WHEN pos='P' THEN 'Battery'
		WHEN pos='C' THEN 'Battery'
		ELSE 'Outfield'
		END AS positions
FROM fielding
GROUP BY positions

	
	
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   

SELECT
	 CASE 
		WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
		WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
		WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
		WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
		WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
		WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
		WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
		WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
		WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
		WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
		END AS decade,
		ROUND(AVG(so),2)AS avg_strikeout, ROUND(AVG(hr),2 )AS avg_homeruns	
FROM teams
GROUP BY decade
ORDER BY decade ASC

--Factor in games
with cte AS (
	SELECT (sum(teams.g)/2)AS games_played,
		yearid,so
	FROM teams
	GROUP BY teams.g,yearid,so)

SELECT so/games_played AS avg_so_per_game,
	(SELECT
	 CASE 
		WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
		WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
		WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
		WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
		WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
		WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
		WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
		WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
		WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
		WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
		END AS decade,
		ROUND(AVG(so),2)AS avg_strikeout, ROUND(AVG(hr),2 )AS avg_homeruns,SUM(teams.g)
	FROM teams
	GROUP BY decade
	ORDER BY decade ASC)
so/games_played AS avg_so_per_game
FROM cte
--(SELECT
-- 	 CASE 
-- 		WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
-- 		WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
-- 		WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
-- 		WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
-- 		WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
-- 		WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
-- 		WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
-- 		WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
-- 		WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
-- 		WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
-- 		END AS decade,
-- 		ROUND(AVG(so),2)AS avg_strikeout, ROUND(AVG(hr),2 )AS avg_homeruns,SUM(teams.g)
-- FROM teams
-- GROUP BY decade
-- ORDER BY decade ASC)
--
with cte AS (
	SELECT (sum(teams.g)/2)AS games_played,
		yearid,so,hr
	FROM teams
	GROUP BY teams.g,yearid,so,hr)

SELECT so/games_played AS avg_so_per_game,hr/games_played AS hrs_per_game,yearid
FROM cte 


--FINAL ANSWER
--New idea
SELECT ROUND(sum(so)/(sum(teams.g)/2) :: numeric,2) AS avg_so_per_game,
		ROUND (sum(hr)/(sum(teams.g)/2):: numeric,2) AS avg_hr_per_game,
	 (SELECT
	  CASE 
		WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
		WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
		WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
		WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
		WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
		WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
		WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
		WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
		WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
		WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
		END AS decade)
FROM teams
GROUP BY  decade
ORDER BY decade
--Home runs have only gone up about one point over the time period but strikeouts have increased almost by almost ten. 

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
with cte AS (
	SELECT sb,cs,playerid, (sb+cs)::numeric AS stolen_base_attempts
	FROM batting
	WHERE yearid = 2016)
	
	SELECT playerid,stolen_base_attempts::numeric,sb::numeric,ROUND((sb/stolen_base_attempts)*100 :: numeric,2) AS sb_success,
	(SELECT namegiven
									 FROM people
									 WHERE playerid='owingch01')
	FROM cte
	WHERE stolen_base_attempts >= 20
	ORDER BY sb_success DESC
	LIMIT 1
	
-- 	SELECT playerid,stolen_base_attempts::numeric,sb::numeric,(sb/stolen_base_attempts)*100 :: numeric AS sb_success
-- 	SELECT playerid,stolen_base_attempts::numeric,sb::numeric,(sb/stolen_base_attempts)*100 :: numeric AS sb_success
-- 	SELECT stolen_base_attempts
-- 	FROM batting
-- 	WHERE stolen_base_attempts >= 20

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--Do Not aggregate wins, think of ORDER BY

--  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
SELECT teamid,w,divwin,wcwin,lgwin,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin ='N'
ORDER BY w DESC 
--ANSWER SEA with 116 wins regular season one win in post season for 117 wins

-- What is the smallest number of wins for a team that did win the world series?
SELECT teamid,w,divwin,wcwin,lgwin,wswin,yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin ='Y'
ORDER BY w ASC
--ANSWER LAN with 63 regular season wins and two post seasons wins and one world series win, there was a 1981 players strike in the MLB that year

-- Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
SELECT teamid,w,divwin,wcwin,lgwin,wswin,yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016  '1981' AND wswin ='Y'
ORDER BY w ASC

How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?

SELECT teamid,w,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016


--  How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?

WITH cte AS(SELECT MAX(w) AS max_wins,yearid-- MAX wins rach year
			FROM teams
		   WHERE yearid BETWEEN 1970 AND 2016
		   GROUP BY yearid
		   ORDER BY yearid),

 cte2 AS (
	SELECT wswin,teamid
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016)

SELECT teams.teamid, teams.wswin, cte.max_wins,yearid
FROM teams
INNER JOIN cte
USING (yearid)
INNER JOIN cte2
USING (teamid)
ORDER BY yearid
WHERE cte = TRUE

-- with cte.2 AS (
-- 	SELECT wswin,teamid
-- FROM teams
-- WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016)

-- WITH cte AS(SELECT MAX(w) AS max, yearid --MAX wins each year 
-- 		   FROM teams
-- 		   WHERE yearid BETWEEN 1970 AND 2016
-- 		   GROUP BY yearid
-- 		   ORDER BY yearid),
-- 	cte2 AS (
-- 		SELECT wswin,teamid
-- 		FROM teams
-- 		WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016)
	
-- SELECT teamid, teams.wswin, COUNT(teams.wswin)
-- FROM teams
-- INNER JOIN cte
-- USING (yearid)
-- INNER JOIN cte2
-- USING (teamid)
-- WHERE teams.wswin='Y'
-- GROUP BY teams.teamid, teams.wswin;
-- -- new cte

-- SELECT teamid, MAX(W) AS max_wins
--   FROM teams
--   WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='Y'
--   GROUP BY teamid
  
--   --
--   WITH champ_wins AS (
--   SELECT teamid, MAX(W) AS max_wins
--   FROM teams
--   WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='Y'
--   GROUP BY teamid
-- ), non_champ_wins AS (
--   SELECT MAX(W) AS max_wins
--   FROM teams
--   WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='N'
-- )
-- SELECT COUNT(*) AS num_champs, 
--   COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT yearID) :: numeric
-- 					  FROM teams WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='Y') AS percentage
-- FROM champ_wins
-- JOIN non_champ_wins ON champ_wins.max_wins = non_champ_wins.max_wins;

WITH cte AS(SELECT MAX(w) AS max, yearid --MAX wins each year 
		   FROM teams
		   WHERE yearid BETWEEN 1970 AND 2016
		   GROUP BY yearid
		   ORDER BY yearid),
	cte2 AS (
		SELECT wswin,teamid
		FROM teams
		WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016)
SELECT teamid, teams.wswin
FROM teams
INNER JOIN cte
USING (yearid)
INNER JOIN cte2
USING (teamid)
WHERE teams.wswin='Y'
GROUP BY teams.teamid, teams.wswin;
-- From Brandylyn
-- WITH max_wins AS (
--   SELECT MAX(w) AS max_wins, yearid
--   FROM teams
--   WHERE yearid BETWEEN 1970 AND 2016
--   GROUP BY yearid
-- )
-- SELECT 
--   COUNT(*) AS num_champs, 
--   COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT yearid) FROM teams WHERE yearid BETWEEN 1970 AND 2016) AS percentage
-- FROM (
--   SELECT teams.teamid, teams.yearid
--   FROM teams
--   INNER JOIN max_wins
--   ON teams.yearid = max_wins.yearid AND teams.w = max_wins.max_wins
--   WHERE teams.wswin = 'Y'
-- ) AS champ_wins;
WITH cte1 AS
(SELECT
	yearid,
	teamid,
	w,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin='Y'
GROUP BY yearid, teamid, w, wswin),
--Returns 46 fields covering WS winners 1970-2016
cte2 AS
(SELECT
	yearid,
	MAX(W) AS max_w
FROM TEAMS
GROUP BY yearid
ORDER BY yearid)
--Returns 1 field per year
SELECT
	COUNT(c2.max_w) AS max_win_w_wswin,
	ROUND(COUNT(c2.*)::NUMERIC / COUNT(c1.*)::NUMERIC,4)*100 AS max_w_win_prcnt
FROM teams AS t1
LEFT JOIN cte1 AS c1
ON t1.yearid=c1.yearid AND t1.w=c1.w
LEFT JOIN cte2 AS c2
ON t1.yearid=c2.yearid AND t1.w=c2.max_w
WHERE t1.yearid BETWEEN 1970 AND 2016
AND t1.wswin='Y';
-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
--HIGHest
SELECT park_name, t.name, (h.attendance/h.games) AS avg_attendance
FROM homegames AS h
JOIN parks AS p
USING (park)
JOIN teams AS t
ON h.team = t.teamid AND h.year = t.yearid
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

--WIth team name and park name Lowest
SELECT park_name, t.name, (h.attendance/h.games) AS avg_attendance
FROM homegames AS h
JOIN parks AS p
USING (park)
JOIN teams AS t
ON h.team = t.teamid AND h.year = t.yearid
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance ASC
LIMIT 5;


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--COUNT of DISTINCT Leagues OVER 1, AL and NL gives count 2, before 1985 it was awarded to AL and NL, might not have to do that part



SELECT playerid,awardid,am.yearid,am.lgid,teamid
FROM awardsmanagers AS am
JOIN managers AS m
USING (playerid)
WHERE am.lgid LIKE 'NL' AND awardid LIKE 'TSN Manager of the Year'

SELECT  playerid,awardid,yearid,lgid,COUNT(DISTINCT lgid)AS award_count
FROM awardsmanagers
WHERE awardid LIKE 'TSN Manager of the Year'
GROUP BY playerid, awardid,yearid,lgid 


SELECT playerid,awardid,yearid,lgid
FROM awardsmanagers
WHERE lgid LIKE 'NL' AND awardid LIKE 'TSN Manager of the Year'
GROUP BY playerid, awardid,yearid,lgid
--
WITH cte1 AS
	(SELECT
	playerid,
	awardid,
	yearid,
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML' AND lgid NOT LIKE 'NL'),
	 cte2 AS
	(SELECT
	playerid,
	awardid,
	--yearid,
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML' AND lgid NOT LIKE 'AL'),
	 cte3 AS
	 (SELECT
		playerid,
	 	CONCAT(namelast,', ',namefirst) AS name
	 FROM people),
	 cte4 AS
	 (SELECT
	 	yearid,
	 	lgid,
	 	name
	 FROM Teams)
SELECT
	 --cte1.yearid AS al_awd_year,
 	 --cte2.yearid AS nl_awd_year,
 	 cte1.lgid AS al_awd_win,
 	 cte2.lgid AS nl_awd_win,
	 cte3.name AS name,
	 cte4.name AS team
FROM awardsmanagers as am
LEFT JOIN cte1
ON am.playerid=cte1.playerid AND am.yearid=cte1.yearid
LEFT JOIN cte2
ON am.playerid=cte2.playerid --AND am.yearid=cte2.yearid
LEFT JOIN cte3
ON am.playerid=cte3.playerid
LEFT JOIN cte4
ON am.lgid=cte4.lgid AND am.yearid=cte4.yearid
WHERE cte1.playerid=cte2.playerid AND cte1.awardid=cte2.awardid
GROUP BY 
--WHERE cte1.lgid IS NOT NULL
--AND cte2.lgid IS NOT NULL,

SELECT a.playerid, COUNT(DISTINCT a.lgid), b.yearid,
	(SELECT name
	FROM team
	WHERE name.teamid = managers.teamid)
		FROM awardsmanagers AS a
		LEFT JOIN awardsmanagers as b
		USING (playerid)
		WHERE a.awardid = 'TSN Manager of the Year'
			AND a.lgid <> 'ML'
		GROUP BY a.playerid, b.yearid
		HAVING COUNT(DISTINCT a.lgid)>=2
-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- SELECT sum(hr),playerid,yearid
-- FROM batting
-- WHERE hr > 0 
SELECT yearid,
	   playerid,
	  hr
FROM batting
WHERE hr >0
GROUP BY ROLLUP(yearid, playerid,hr)
ORDER BY playerid,yearid

--max hr with at least 10 years
SELECT 
  playerID, 
  MAX(HR) AS career_high_hr
FROM 
  Batting
WHERE 
  HR > 0
GROUP BY 
  playerID
HAVING 
  COUNT(DISTINCT yearID) >= 10;
  
SELECT GREATEST(hr), playerid,yearid
FROM batting

  
  
-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  

Attachment SQL_Cheat_Sheet.pdf added.None selected 

Skip to content
Using Gmail with screen readers
Conversations
Amanda Partlow
Ad Hoc Topics Script
 - Hi! This is a little mishmash of requested topics to go over tonight. See you in a sec, Amanda -- You received this message because you are subscribed to the Google Groups "Nashville Software

-- Lag / Lead
-- Lag returns the previous year's hr for that player
-- Lead returns the next year's hr for that player
SELECT yearid,
	   playerid,
	   hr,
	   LAG(hr) OVER (PARTITION BY playerid ORDER BY yearid) AS prev_yr_hr,
	   LEAD(hr) OVER (PARTITION BY playerid ORDER BY yearid) AS next_yr_hr
FROM batting
ORDER BY playerid, yearid


-- Sliding Windows
-- Same concept as with lag and lead, except new keywords allow you to do aggregations on a certain number of rows before or after
-- SUM OVER PRECEDING allows us to get the sum of the two years earlier than that row for that player
-- SUM OVER FOLLOWING allows us to get the sum of the two years after that row for that player
SELECT yearid,
	   playerid,
	   hr,
	   SUM(hr) OVER (PARTITION BY playerid 
					 ORDER BY yearid
					ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) AS prev_2yr_hr,
	   SUM(hr) OVER (PARTITION BY playerid 
					 ORDER BY yearid
					 ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING) AS next_2yr_hr
FROM batting
ORDER BY playerid, yearid


-- GROUP BY ROLLUP
-- Same as a GROUP BY, except each group is followed by a total for that group and a grand total for multiple groups
-- The rollup means we will get a total for the sub group - so we have totals per year per team, the rollup adds the total as if we had also grouped by just year, followed by the total for the entire table

SELECT yearid,
	   teamid,
	   SUM(hr)
FROM batting
GROUP BY ROLLUP(yearid, teamid)
ORDER BY yearid, teamid


-- GROUP BY CUBE
-- Similar to ROLLUP, except instead of just giving us the totals for the larger group (which it still does at the end of each year as before), it also gives us the totals of the groups if they had been grouped the other way
-- So in this example, we get the totals by year as well as the totals by team
SELECT yearid,
	   teamid,
	   SUM(hr)
FROM batting
GROUP BY CUBE(yearid, teamid)
ORDER BY yearid, teamid


-- To make this easier to read, use coalesce to change the nulls to accurate labels
SELECT COALESCE(yearid :: text, 'All Years'),
	   COALESCE(teamid, 'All Teams'),
	   SUM(hr)
FROM batting
GROUP BY CUBE(yearid, teamid)
ORDER BY yearid, teamid
