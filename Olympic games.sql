
--- OLYMPIC GAMES DATASET
---EXPLORE THE Data, select top 10 rows
SELECT TOP 5 *
FROM athlete_events$	


--- 1. How many olympics games have been held?
SELECT COUNT (DISTINCT (Games)) AS Total_games_played
FROM athlete_events$

--- 2. List down all Olympics games held so far.
SELECT Games, Year, City
FROM athlete_events$

SELECT DISTINCT(NOC)
FROM athlete_events$

--- 3. Mention the total no of nations who participated in each olympics game?
SELECT Games, COUNT(DISTINCT(NOC)) AS number_nations_participated
FROM athlete_events$
GROUP BY Games
ORDER BY Games

--- 4. Which year saw the highest and lowest no of countries participating in olympics
'''
---WITH Participants(Year, NOC) AS
	(
	SELECT Year, COUNT(DISTINCT(NOC)) AS Total_participants
	FROM athlete_events$
	GROUP BY Year
	)
SELECT Year, MAX(NOC) AS Highest_particpants_year, MIN(NOC) AS lowest_participants_year
FROM Participants
GROUP BY Year

SELECT Year, MAX(COUNT(
	SELECT COUNT(DISTINCT(NOC))
	FROM athlete_events$)) AS highest_count
FROM athlete_event$
'''

--- 4. Which year saw the highest and lowest no of countries participating in olympics
      with all_countries as
              (select oh.Games, nr.region
              from athlete_events$ oh
              join noc_regions$ nr 
			  ON nr.NOC=oh.NOC
              group by oh.Games, nr.region),
          tot_countries as
              (select Games, count(1) as total_countries
              from all_countries
              group by Games)
      select distinct
      concat(first_value(Games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;

---WITH cte AS(
---		SELECT Games, COUNT(DISTINCT(NOC)) AS countries_participated
---		FROM athlete_events$
---		GROUP BY Games)
---(first_value(games) over(order by total_countries)
---SELECT TOP 1 first_value(Games) over(ORDER BY countries_participated) AS lowest_paricipation_year	
---FROM cte

---HDA
---WITH country_count AS (
---			SELECT Games, COUNT(DISTINCT(NOC)) AS count_y
---			FROM athlete_events$
---			GROUP BY Games)
---SELECT CONCAT('Highest', ' ','-', ' ', MAX(count_y)) AS highest_attendance, 
---	   CONCAT('Lowest attendance', ' ', '-', ' ', MIN(count_y)) AS minimum_attendance
---FROM country_count

---5. Which nation has participated in all of the olympic games
---//Count the number of Olympic Games
---SELECT COUNT(DISTINCT(Games)) AS Total_games_held
---FROM athlete_events$

---SELECT r.region, COUNT(DISTINCT(e.Games)) AS gamess
---FROM noc_regions$ AS r
---FULL JOIN athlete_events$ AS e
---ON r.NOC = e.NOC
---WHERE gamess = 51 
---GROUP BY r.region

WITH tot_games AS(
		SELECT COUNT(DISTINCT(Games)) AS Total_games
		FROM athlete_events$),
	countries AS(
		SELECT e.Games, r.region AS country
		FROM athlete_events$ e
		JOIN noc_regions$ r
		ON e.NOC = r.NOC),
	countries_participated AS(
		SELECT country, COUNT(DISTINCT(Games)) AS total_participants
		FROM countries
		GROUP BY country)
SELECT DISTINCT(c.country) AS Country, cp.total_participants
FROM countries AS c
JOIN countries_participated AS cp
ON c.country = cp.country
JOIN tot_games AS tg
ON tg.Total_games = cp.total_participants

WITH tot_games AS
		(SELECT COUNT(DISTINCT Games) AS total_games
		FROM athlete_events$),
	countries AS
		(SELECT Games, nr.region AS country
		FROM athlete_events$ oh
		JOIN noc_regions$ nr 
		ON nr.noc=oh.noc
		GROUP BY Games, nr.region),
	countries_participated AS
		(SELECT country, COUNT(1) AS total_participated_games
		FROM countries
		GROUP BY country)
SELECT cp.*
FROM countries_participated cp
JOIN tot_games tg 
ON tg.total_games = cp.total_participated_games
ORDER BY 1;


-- 6. Identify the sport which was played in all summer olympics.
--First identify the sports which were played in the summer Olympics
--Group the games played by each summer olympics event
--Select the sports that were played in all the games
SELECT  DISTINCT(Sport)
FROM athlete_events$

WITH t1 AS (
		SELECT COUNT(DISTINCT(Games)) as total_games
		FROM athlete_events$
		WHERE Season = 'Summer'),
	games_sports AS (
		SELECT DISTINCT Games, Sport
		FROM athlete_events$
		WHERE Season = 'Summer'),
	selected AS (
		SELECT Sport, COUNT(1) AS games_played
		FROM games_sports
		GROUP BY Sport)
SELECT *
FROM selected 
JOIN t1 
ON t1.total_games = selected.games_played;

---7. Which Sports were just played only once in the olympics.
---# get the total number of games each was played
---# get sport and the games it was played
---# slect the number of games each sport was played
WITH gamess AS(
		SELECT DISTINCT Games, Sport
		FROM athlete_events$),
	sports_games AS (
		SELECT Sport, COUNT(1) AS no_of_games
		FROM gamess
		GROUP BY Sport)
SELECT sg.*, g.Games
FROM sports_games AS sg
JOIN gamess AS g
ON sg.Sport = g.Sport
WHERE sg.no_of_games=1
ORDER BY Games

----8. Fetch the total no of sports played in each olympic games.
SELECT Games, COUNT(DISTINCT(Sport)) AS total_sports
FROM athlete_events$
GROUP BY Games
ORDER BY 2 DESC

SELECT *
FROM athlete_events$

---9. Fetch oldest athletes to win a gold medal
WITH gold_medalists AS (
		SELECT Name, Medal, Age, Sex, Team, Games, City, Event
		FROM athlete_events$
		WHERE Medal = 'Gold' AND Age=64),
	old_gold AS (
		SELECT Medal, MAX(Age) AS oldest_gold_winner
		FROM athlete_events$
		GROUP BY Medal)

SELECT gm.Name, gm.Medal, gm.Age, gm.Sex, gm.Team, gm.Games, gm.Event, gm.Event
FROM gold_medalists AS gm
INNER JOIN old_gold AS og
ON gm.Age=og.oldest_gold_winner

---10. Find the Ratio of male and female athletes participated in all olympic games.
---1.Find the gender of all the athletes
---2.Count the numbers by gender
---3. Get the ratio

WITH female_count AS (
		SELECT Sex, COUNT(Sex) AS female_number
		FROM athlete_events$
		WHERE Sex = 'F'
		GROUP BY Sex),
	male_count AS (
		SELECT Sex, COUNT(Sex) AS male_number
		FROM athlete_events$
		WHERE Sex = 'M'
		GROUP BY Sex)
SELECT m.male_number/f.female_number AS ratio
FROM male_count AS m
JOIN female_count AS f
ON m.Sex = f.Sex
---# not sure what wrong I have done there --brings no output and no error

--11. Fetch the top 5 athletes who have won the most gold medals.
--- 1. Get the athletes and their medals
--- 2. Filter the medals be gold
---3. Get the top five

WITH gold_medalists AS (
		SELECT Name, Team, Sport, COUNT(Medal) As medals
		FROM athlete_events$
		WHERE Medal = 'Gold' 
		GROUP BY Name, Sport,Team),
	order_d AS (
		SELECT *,
		DENSE_RANK() OVER (ORDER BY medals DESC) AS ranking
		FROM gold_medalists)
SELECT Name, Team, Sport, medals
FROM order_d
WHERE ranking <=5

---12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH gold_medalists AS (
		SELECT Name, Team, COUNT(Medal) As medals
		FROM athlete_events$
		GROUP BY Name,Team),
	order_d AS (
		SELECT *,
		DENSE_RANK() OVER (ORDER BY medals DESC) AS ranking
		FROM gold_medalists)
SELECT Name, Team, medals
FROM order_d
WHERE ranking <=5

---13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH nation_medals AS (
		SELECT nr.region, COUNT(ae.Medal) AS No_of_medals
		FROM noc_regions$ nr
		JOIN athlete_events$ ae
		ON nr.NOC = ae.NOC
		WHERE Medal <> 'NA' ---remove the NA medals
		GROUP BY nr.region),
	rankings AS (
		SELECT *, DENSE_RANK() OVER( ORDER BY No_of_medals DESC) AS nation_medals_rank
		FROM nation_medals
		)
SELECT *
FROM rankings
WHERE nation_medals_rank <=5

---14. List down total gold, silver and bronze medals won by each country.
WITH gold_medals AS (
		SELECT nr.region AS Country, COUNT(ae.Medal) AS gold_medals_won
		FROM noc_regions$ AS nr
		JOIN athlete_events$ AS ae
		ON nr.NOC = ae.NOC
		WHERE ae.Medal='Gold'
		GROUP BY nr.region),
	silver_medals AS (
		SELECT nr.region AS Country, COUNT(ae.Medal) AS silver_medals_won
		FROM noc_regions$ AS nr
		JOIN athlete_events$ AS ae
		ON nr.NOC = ae.NOC
		WHERE ae.Medal='Silver'
		GROUP BY nr.region),
	bronze_medals AS (
		SELECT nr.region AS Country, COUNT(ae.Medal) AS bronze_medals_won
		FROM noc_regions$ AS nr
		JOIN athlete_events$ AS ae
		ON nr.NOC = ae.NOC
		WHERE ae.Medal='Bronze'
		GROUP BY nr.region)
SELECT TOP 10 g.Country, g.gold_medals_won, s.silver_medals_won, b.bronze_medals_won
FROM gold_medals AS g
JOIN silver_medals AS s
ON g.Country = s.Country
JOIN bronze_medals AS b
ON s.Country = b.Country
ORDER BY g.gold_medals_won DESC

---15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
WITH golden_medals AS (
		SELECT ae.Games, nr.region AS country, COUNT(ae.Medal) AS gold_medals_won
		FROM noc_regions$ AS nr
		JOIN athlete_events$ AS ae
		ON nr.NOC = ae.NOC
		WHERE ae.Medal='Gold'
		GROUP BY ae.Games, nr.region),
	silvery_medals AS (
		SELECT ae.Games, nr.region AS country, COUNT(ae.Medal) AS silver_medals_won
		FROM noc_regions$ AS nr
		JOIN athlete_events$ AS ae
		ON nr.NOC = ae.NOC
		WHERE ae.Medal='Silver'
		GROUP BY ae.Games, nr.region),
	bronze_medals AS (
		SELECT ae.Games, nr.region AS country, COUNT(ae.Medal) AS bronze_medals_won
		FROM noc_regions$ AS nr
		JOIN athlete_events$ AS ae
		ON nr.NOC = ae.NOC
		WHERE ae.Medal='Bronze'
		GROUP BY ae.Games, nr.region)
SELECT gm.Games AS Olympic_Games,
	   gm.country,
	   gm.gold_medals_won,
	   sm.silver_medals_won,
	   bm.bronze_medals_won
FROM golden_medals AS gm
JOIN silvery_medals AS sm
ON gm.country = sm.country
JOIN bronze_medals AS bm
ON sm.country = bm.country
ORDER BY Olympic_Games, country
--## return to this query later

-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
---17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
---18. Which countries have never won gold medal but have won silver/bronze medals?
---19. In which Sport/event, India has won highest medals.
---20. Break down all olympic games where Kenya won medal for Hockey and how many medals in each olympic games
----https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset