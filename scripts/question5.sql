
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

WITH max_wins AS (
  SELECT MAX(w) AS max_wins, yearid
  FROM teams
  WHERE yearid BETWEEN 1970 AND 2016
  GROUP BY yearid
)
SELECT 
  COUNT(*) AS num_champs, 
  COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT yearid) FROM teams WHERE yearid BETWEEN 1970 AND 2016) AS percentage
FROM (
  SELECT teams.teamid, teams.yearid
  FROM teams
  INNER JOIN max_wins
  ON teams.yearid = max_wins.yearid AND teams.w = max_wins.max_wins
  WHERE teams.wswin = 'Y'
) AS champ_wins;

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
--COUNT of DISTINCT Leagues OVER 1, AL and NL gives count 2, before 1985 it was awarded to AL and NL, might not have to do that part
-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
