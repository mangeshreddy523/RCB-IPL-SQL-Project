CREATE DATABASE RCB_IPL_Project;
USE RCB_IPL_Project;

select * from  clean_fixtures;
select * from clean_matches;
select * from clean_players;
select * from clean_points_table;
select * from clean_rcb_matches;

describe clean_fixtures;
describe clean_matches;
describe clean_players;
describe clean_points_table;
describe clean_rcb_matches;

-- checking date type of my all data 

select date from clean_fixtures limit 10;
select date from clean_matches limit 10;

-- changing data type of all data

-- clean_fixtues
ALTER TABLE clean_fixtures
MODIFY COLUMN match_number INT,
MODIFY COLUMN date DATE,
MODIFY COLUMN venue VARCHAR(100),
MODIFY COLUMN team_1 VARCHAR(100),
MODIFY COLUMN team_2 VARCHAR(100);

-- clean matches
ALTER TABLE clean_matches
MODIFY COLUMN cricsheet_match_id BIGINT,
MODIFY COLUMN match_number INT,
MODIFY COLUMN date DATE,
MODIFY COLUMN venue VARCHAR(100),
MODIFY COLUMN team_1 VARCHAR(100),
MODIFY COLUMN team_2 VARCHAR(100),
MODIFY COLUMN toss_winner VARCHAR(100),
MODIFY COLUMN toss_decision VARCHAR(20),
MODIFY COLUMN winner VARCHAR(100),
MODIFY COLUMN result VARCHAR(50),
MODIFY COLUMN win_by_runs INT,
MODIFY COLUMN win_by_wickets INT;

-- clean players
ALTER TABLE clean_players
MODIFY COLUMN Player VARCHAR(100),
MODIFY COLUMN Team VARCHAR(100),
MODIFY COLUMN Role VARCHAR(50),
MODIFY COLUMN Matches INT;

-- clean point table
ALTER TABLE clean_points_table
MODIFY COLUMN position INT,
MODIFY COLUMN team VARCHAR(100),
MODIFY COLUMN played INT,
MODIFY COLUMN won INT,
MODIFY COLUMN lost INT,
MODIFY COLUMN no_result INT,
MODIFY COLUMN net_run_rate DOUBLE,
MODIFY COLUMN points INT;

-- clean rcb matches
ALTER TABLE clean_rcb_matches
MODIFY COLUMN `Date` DATE,
MODIFY COLUMN Stage VARCHAR(50),
MODIFY COLUMN Opponent VARCHAR(100),
MODIFY COLUMN Team VARCHAR(100),
MODIFY COLUMN `Opponent Score` VARCHAR(30),
MODIFY COLUMN `RCB Score` VARCHAR(30),
MODIFY COLUMN Winner VARCHAR(100),
MODIFY COLUMN Result VARCHAR(50);

-- Questions for my project

-- 1. How many matches are there?
select COUNT(*) as total_matches
from clean_matches;

-- 2. List all teams
-- If your columns are team1 and team2:
select team_1 from clean_matches
	union
	select team_2 from clean_matches;
    
-- 3.Count matches won by each team
select winner, COUNT(*) AS wins
FROM clean_matches
WHERE winner is not null
group by winner
order by wins desc;

-- 4. Find the most successful team
SELECT winner, COUNT(*) AS wins
FROM clean_matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY wins DESC
LIMIT 1;

-- 5.Find matches won by RCB
SELECT *
FROM clean_matches
WHERE winner = 'Royal Challengers Bengaluru';

-- 6. Total wins across teams.
-- AVG() — calculate average
SELECT AVG(net_run_rate) AS avg_nrr
FROM clean_points_table;

-- 7. Converts text to uppercase
SELECT UPPER(team) AS team_name
FROM clean_points_table;

-- 8. check lenght of all player name
SELECT player, LENGTH(player) AS name_length
FROM clean_players;

-- 9. join teams using the concat
SELECT CONCAT(team_1, 'vs' , team_2) AS match_name
FROM clean_matches;

-- 10. Name the teams perormance equal or more than 7 win team mark as strong and other need to improvement
SELECT
    team,
    won,
    IF(won >= 7, 'Strong', 'Needs Improvement') AS performance
FROM clean_points_table;

-- 11. Find the number of matches played by each team.
SELECT team, COUNT(*) AS matches_played
FROM (
    SELECT team_1 AS team FROM clean_matches
    UNION ALL
    SELECT team_2 AS team FROM clean_matches
) AS teams
GROUP BY team
ORDER BY matches_played DESC;

-- 12.Find matches played at each venue.
SELECT venue, COUNT(*) AS total_matches
FROM clean_matches
GROUP BY venue
ORDER BY total_matches DESC;

-- 13.Find the Player of the Match who received the most awards.
SELECT player_of_match, COUNT(*) AS awards
FROM clean_matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY awards DESC
LIMIT 1;

-- Next Level — RCB Analysis
-- 14. How many matches did RCB play?
SELECT COUNT(*) AS rcb_matches
FROM clean_rcb_matches;

-- 15.Calculate RCB win percentage using case when 
SELECT
    ROUND(
        SUM(CASE  
            WHEN Winner = 'Royal Challengers Bengaluru' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS win_percentage
FROM clean_rcb_matches;

-- 16. Find the number of matches played in each month.
SELECT
    MONTH(date) AS month,
    COUNT(*) AS total_matches
FROM clean_matches
GROUP BY MONTH(date)
ORDER BY month;

-- 18. Rank teams according to their points.
SELECT
    team,
    points,net_run_rate ,
    RANK() OVER (ORDER BY points DESC) AS team_rank
FROM clean_points_table;

-- 19.Give every team a unique row number based on points.
SELECT
    team,
    points, net_run_rate,
    ROW_NUMBER() OVER (ORDER BY points DESC) AS row_num
FROM clean_points_table;

-- 20. Find the team with the highest points using a subquery.
SELECT *
FROM clean_points_table
WHERE points = (
    SELECT MAX(points)
    FROM clean_points_table
);

-- 21. Find teams whose points are above the average points.
SELECT
    team,
    points
FROM clean_points_table
WHERE points > (
    SELECT AVG(points)
    FROM clean_points_table
)
ORDER BY points DESC;

-- 22.Season-wise RCB wins
SELECT
    YEAR(Date) AS season,
    COUNT(*) AS wins
FROM clean_rcb_matches
WHERE Winner = 'Royal Challengers Bengaluru'
GROUP BY YEAR(Date)
ORDER BY season;

-- 23.Best NRR team
SELECT
    team,
    net_run_rate
FROM clean_points_table
ORDER BY net_run_rate DESC
LIMIT 1;
-- EER DAIGRAM 
ALTER TABLE clean_players
ADD COLUMN player_id INT AUTO_INCREMENT PRIMARY KEY FIRST;
ALTER TABLE clean_matches
ADD PRIMARY KEY (cricsheet_match_id);
ALTER TABLE clean_fixtures
ADD PRIMARY KEY (match_number);
ALTER TABLE clean_points_table
ADD COLUMN team_id INT FIRST;
UPDATE clean_points_table
SET team_id = position;ALTER TABLE clean_points_table
ADD PRIMARY KEY (team_id);


ALTER TABLE clean_rcb_matches
ADD COLUMN rcb_match_id INT AUTO_INCREMENT PRIMARY KEY FIRST;



ALTER TABLE clean_matches
ADD COLUMN player_id INT;
UPDATE clean_matches m
JOIN clean_players p
ON m.player_of_match = p.Player
SET m.player_id = p.player_id;
SELECT player_of_match, player_id
FROM clean_matches;
ALTER TABLE clean_matches
ADD FOREIGN KEY (player_id)
REFERENCES clean_players(player_id);

ALTER TABLE clean_matches
ADD COLUMN team_id INT;
UPDATE clean_matches m
JOIN clean_points_table p
ON m.winner = p.team
SET m.team_id = p.team_id;
ALTER TABLE clean_matches
ADD FOREIGN KEY (team_id)
REFERENCES clean_points_table(team_id);
