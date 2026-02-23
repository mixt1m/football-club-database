-- COUNT
SELECT COUNT(*) AS stadiums_count FROM football_club.stadiums;

SELECT country, COUNT(*) AS leagues_count FROM football_club.league 
GROUP BY country 
ORDER BY leagues_count DESC, country;

-- SUM
SELECT SUM(capacity) AS total_capacity FROM football_club.stadiums;

SELECT country, SUM(tier) AS sum_tier FROM football_club.league 
GROUP BY country 
ORDER BY sum_tier DESC, country;

-- AVG
SELECT AVG(capacity) AS avg_capacity FROM football_club.stadiums;

SELECT country, AVG(tier) AS avg_tier FROM football_club.league 
GROUP BY country 
ORDER BY avg_tier DESC, country;

-- MIN
SELECT MIN(capacity) AS min_capacity FROM football_club.stadiums;

SELECT country, MIN(tier) AS min_tier FROM football_club.league 
GROUP BY country
ORDER BY min_tier, country;

-- MAX
SELECT MAX(capacity) AS max_capacity FROM football_club.stadiums;

SELECT country, MAX(tier) AS max_tier FROM football_club.league 
GROUP BY country 
ORDER BY max_tier DESC, country;

-- STRING_AGG
SELECT country, STRING_AGG(name, ', ' ORDER BY name) AS leagues FROM football_club.league 
GROUP BY country 
ORDER BY country;

SELECT region, STRING_AGG(name, ' | ' ORDER BY name) AS tournaments 
FROM football_club.tournament 
GROUP BY region;

-- GROUP BY / HAVING
SELECT country, COUNT(*) AS leagues FROM football_club.league 
GROUP BY country;

SELECT country, COUNT(*) AS leagues FROM football_club.league 
WHERE tier >= 1 
GROUP BY country 
HAVING COUNT(*) >= 1;

-- GROUPING SETS
SELECT country, tier, COUNT(*) AS leagues FROM football_club.league 
GROUP BY GROUPING SETS ((country, tier), (country), (tier), ());

SELECT region, format, COUNT(*) AS tournaments FROM football_club.tournament 
GROUP BY GROUPING SETS ((region, format), (region), (format), ()) ;

-- ROLLUP
SELECT country, tier, COUNT(*) AS leagues 
FROM football_club.league 
GROUP BY ROLLUP (country, tier);

SELECT region, format, COUNT(*) AS tournaments FROM football_club.tournament 
GROUP BY ROLLUP (region, format) 
ORDER BY region NULLS LAST, format NULLS LAST;

-- CUBE
SELECT country, tier, COUNT(*) AS leagues FROM football_club.league 
GROUP BY CUBE (country, tier);

SELECT region, format, COUNT(*) AS tournaments FROM football_club.tournament 
GROUP BY CUBE (region, format);

-- SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY 
SELECT country, COUNT(*) AS leagues, AVG(tier) AS avg_tier 
FROM football_club.league 
WHERE tier >= 1 
GROUP BY country 
HAVING AVG(tier) >= 1;

SELECT region, COUNT(*) AS tournaments, STRING_AGG(DISTINCT format, ', ' ORDER BY format) AS formats 
FROM football_club.tournament 
WHERE format IS NOT NULL 
GROUP BY region 
HAVING COUNT(*) >= 1;

