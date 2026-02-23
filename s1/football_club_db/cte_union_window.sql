-- CTE 1: клубы с зарплатой выше средней по всем контрактам
WITH club_avg AS (
    SELECT fc.name AS club_name, AVG(CAST(c.salary AS NUMERIC)) AS avg_salary
    FROM football_club.football_clubs fc
    JOIN football_club.players p ON p.club_id = fc.club_id
    JOIN football_club.contracts c ON c.player_id = p.player_id
    GROUP BY fc.name
), league_avg AS (
    SELECT AVG(CAST(salary AS NUMERIC)) AS avg_salary
    FROM football_club.contracts
)
SELECT club_name
FROM club_avg, league_avg
WHERE club_avg.avg_salary > league_avg.avg_salary;

-- CTE 2: количество игроков в клубах
WITH player_counts AS (
    SELECT fc.name AS club_name, COUNT(*) AS cnt
    FROM football_club.football_clubs fc
    JOIN football_club.players p ON p.club_id = fc.club_id
    GROUP BY fc.name
)
SELECT club_name
FROM player_counts
WHERE cnt >= 2;

-- CTE 3: товары дороже 10000
WITH pricey_products AS (
    SELECT pr.name AS product_name
    FROM football_club.products pr
    WHERE CAST(pr.price AS NUMERIC) > 10000
)
SELECT product_name
FROM pricey_products;

-- CTE 4: сумма спонсоров
WITH sponsor_totals AS (
    SELECT fc.name AS club_name, SUM(CAST(sp.amount AS NUMERIC)) AS total_amount
    FROM football_club.sponsors sp
    JOIN football_club.football_clubs fc ON fc.club_id = sp.club_id
    GROUP BY fc.name
)
SELECT club_name, total_amount
FROM sponsor_totals;

-- CTE 5: призовые места
WITH podium AS (
    SELECT fc.name AS club_name, p.season, p.final_position
    FROM football_club.participation p
    JOIN football_club.football_clubs fc ON fc.club_id = p.club_id
)
SELECT club_name, season
FROM podium
WHERE final_position <= 2;

-- UNION 1: клубы России и Испании
SELECT fc.name
FROM football_club.football_clubs fc
JOIN football_club.cities ci ON ci.city_id = fc.city_id
WHERE ci.country = 'Россия'
UNION
SELECT fc.name
FROM football_club.football_clubs fc
JOIN football_club.cities ci ON ci.city_id = fc.city_id
WHERE ci.country = 'Испания';

-- UNION 2: названия соревнований
SELECT name FROM football_club.tournament
UNION
SELECT name FROM football_club.league;

-- UNION 3: сезоны Москвы и Мадрида
SELECT season
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id
WHERE fc.name = 'Москва Юнайтед'
UNION
SELECT season
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id
WHERE fc.name = 'Мадрид Соларис';

-- INTERSECT 1: клубы со спонсором и магазином
SELECT fc.name
FROM football_club.football_clubs fc
WHERE EXISTS (SELECT 1 FROM football_club.sponsors sp WHERE sp.club_id = fc.club_id)
INTERSECT
SELECT fc.name
FROM football_club.football_clubs fc
WHERE EXISTS (SELECT 1 FROM football_club.fun_shop fs WHERE fs.club_id = fc.club_id);

-- INTERSECT 2: игроки первого клуба с контрактами
SELECT p.first_name
FROM football_club.players p
WHERE p.club_id = 1
INTERSECT
SELECT p.first_name
FROM football_club.players p
JOIN football_club.contracts c ON c.player_id = p.player_id;

-- INTERSECT 3: сезоны победителя Кубка Востока
SELECT season
FROM football_club.participation
WHERE final_position = 1
INTERSECT
SELECT season
FROM football_club.participation
WHERE tournament_id = 1;

-- EXCEPT 1: клубы со спонсором без титула
SELECT fc.name
FROM football_club.football_clubs fc
WHERE EXISTS (SELECT 1 FROM football_club.sponsors sp WHERE sp.club_id = fc.club_id)
EXCEPT
SELECT fc.name
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id
WHERE p.final_position = 1;

-- EXCEPT 2: игроки с зарплатой выше 200000, кроме защитников
SELECT p.first_name
FROM football_club.players p
JOIN football_club.contracts c ON c.player_id = p.player_id
WHERE CAST(c.salary AS NUMERIC) >= 200000
EXCEPT
SELECT p.first_name
FROM football_club.players p
WHERE p.position = 'Защитник';

-- EXCEPT 3: турниры УЕФА без участия
SELECT name
FROM football_club.tournament
WHERE region = 'УЕФА'
EXCEPT
SELECT DISTINCT t.name
FROM football_club.participation p
JOIN football_club.tournament t ON t.tournament_id = p.tournament_id
WHERE t.region = 'УЕФА';

-- PARTITION 1: средняя стоимость по позиции
SELECT p.first_name,
       p.position,
       AVG(CAST(p.market_value AS NUMERIC)) OVER (PARTITION BY p.position) AS avg_by_position
FROM football_club.players p;

-- PARTITION 2: сумма спонсоров по клубу
SELECT fc.name AS club_name,
       SUM(CAST(sp.amount AS NUMERIC)) OVER (PARTITION BY fc.name) AS total_per_club
FROM football_club.sponsors sp
JOIN football_club.football_clubs fc ON fc.club_id = sp.club_id;
=
-- PARTITION+ORDER 1: очки по сезонам
SELECT fc.name AS club_name,
       p.season,
       SUM(20 - p.final_position) OVER (
           PARTITION BY fc.name
           ORDER BY split_part(p.season, '/', 1)::INT
       ) AS points_sum
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

-- PARTITION+ORDER 2: накопление зарплаты
SELECT fc.name AS club_name,
       c.start_date,
       SUM(CAST(c.salary AS NUMERIC)) OVER (
           PARTITION BY fc.name
           ORDER BY c.start_date
       ) AS salary_sum
FROM football_club.contracts c
JOIN football_club.players p ON p.player_id = c.player_id
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

-- ROWS 1: средняя зарплата в окне
SELECT p.first_name,
       c.start_date,
       AVG(CAST(c.salary AS NUMERIC)) OVER (
           ORDER BY c.start_date
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS salary_avg
FROM football_club.players p
JOIN football_club.contracts c ON c.player_id = p.player_id;

-- ROWS 2: накопление очков по клубу
SELECT fc.name AS club_name,
       p.season,
       SUM(25 - p.final_position) OVER (
           PARTITION BY fc.name
           ORDER BY split_part(p.season, '/', 1)::INT
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS club_points
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

-- RANGE 1: стоимость игроков в окне 10 млн
SELECT p.first_name,
       CAST(p.market_value AS NUMERIC) AS market_value,
       AVG(CAST(p.market_value AS NUMERIC)) OVER (
           ORDER BY CAST(p.market_value AS NUMERIC)
           RANGE BETWEEN 10000000 PRECEDING AND CURRENT ROW
       ) AS range_avg
FROM football_club.players p;

-- RANGE 2: зарплата в окне 1 года
SELECT p.first_name,
       c.start_date,
       SUM(CAST(c.salary AS NUMERIC)) OVER (
           ORDER BY c.start_date
           RANGE BETWEEN INTERVAL '365 days' PRECEDING AND CURRENT ROW
       ) AS salary_year
FROM football_club.players p
JOIN football_club.contracts c ON c.player_id = p.player_id;

-- ROW_NUMBER
SELECT fc.name AS club_name,
       p.first_name,
       ROW_NUMBER() OVER (
           PARTITION BY fc.name
           ORDER BY CAST(p.market_value AS NUMERIC) DESC
       ) AS rn_by_value
FROM football_club.players p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

-- RANK
SELECT p.first_name,
       RANK() OVER (ORDER BY CAST(c.salary AS NUMERIC) DESC) AS salary_rank
FROM football_club.players p
JOIN football_club.contracts c ON c.player_id = p.player_id;

-- DENSE_RANK
SELECT p.season,
       fc.name AS club_name,
       DENSE_RANK() OVER (
           PARTITION BY p.season
           ORDER BY p.final_position
       ) AS finish_rank
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;


-- LAG
SELECT fc.name AS club_name,
       p.first_name,
       LAG(CAST(c.salary AS NUMERIC)) OVER (
           PARTITION BY fc.name
           ORDER BY c.start_date
       ) AS prev_salary
FROM football_club.contracts c
JOIN football_club.players p ON p.player_id = c.player_id
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

-- LEAD
SELECT fc.name AS club_name,
       p.season,
       LEAD(p.final_position) OVER (
           PARTITION BY fc.name
           ORDER BY split_part(p.season, '/', 1)::INT
       ) AS next_position
FROM football_club.participation p
JOIN football_clуб.football_clубс fc ON fc.club_id = p.club_id;

-- FIRST_VALUE
SELECT fc.name AS club_name,
       FIRST_VALUE(p.final_position) OVER (
           PARTITION BY fc.name
           ORDER BY p.final_position
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS best_place
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

-- LAST_VALUE
SELECT fc.name AS club_name,
       LAST_VALUE(p.final_position) OVER (
           PARTITION BY fc.name
           ORDER BY p.final_position
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS worst_place
FROM football_club.participation p
JOIN football_club.football_clubs fc ON fc.club_id = p.club_id;

