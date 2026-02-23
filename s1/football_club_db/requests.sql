SELECT * FROM football_club.players;

SELECT * FROM football_club.football_clubs;

SELECT first_name FROM football_club.players;

SELECT capacity, name FROM football_club.stadiums;

SELECT player_id, first_name
FROM football_club.players
WHERE CAST(market_value AS NUMERIC) >= 10000000;

SELECT address, capacity
FROM football_club.stadiums
WHERE capacity > 56000;

SELECT s.staduim_id,
       s.name,
       s.capacity,
       CASE
         WHEN s.capacity >= 60000 THEN 'Очень большой'
         WHEN s.capacity >= 40000 THEN 'Большой'
         WHEN s.capacity >= 20000 THEN 'Средний'
         ELSE 'Малый'
       END AS capacity_class
FROM football_club.stadiums AS s;

SELECT sp.sponsor_id,
       sp.club_id,
       sp.amount,
       CASE
         WHEN CAST(sp.amount AS NUMERIC) >= 70000000 THEN 'Премиум'
         WHEN CAST(sp.amount AS NUMERIC) >= 20000000 THEN 'Крупный'
         WHEN CAST(sp.amount AS NUMERIC) > 0 THEN 'Стандарт'
         ELSE 'Не указан'
       END AS sponsor_tier
FROM football_club.sponsors AS sp;

SELECT name FROM football_club.stadiums
WHERE capacity BETWEEN 40000 AND 50000;

SELECT name FROM football_club.league
WHERE tier BETWEEN 1 AND 2;

SELECT name FROM football_club.products
WHERE name LIKE 'Ш%';

SELECT name FROM football_club.products
WHERE name LIKE '_____';

SELECT DISTINCT name FROM football_club.products;

SELECT c.club_id, c.name AS club_name, o.name AS owner_name, o.nationality AS owner_nationality
FROM football_club.football_clubs AS c
INNER JOIN football_club.owners AS o ON o.owner_id = c.owner_id;

SELECT p.player_id, p.first_name, p.position,
       ct.start_date, ct.end_date, ct.salary
FROM football_club.players AS p
INNER JOIN football_club.contracts AS ct ON ct.player_id = p.player_id;

SELECT c.club_id, c.name AS club_name,
       sp.start_date, sp.end_date, sp.amount, sp.type
FROM football_club.football_clubs AS c
LEFT JOIN football_club.sponsors AS sp ON sp.club_id = c.club_id;

SELECT p.player_id, p.first_name, p.position,
       ct.start_date, ct.end_date, ct.salary
FROM football_club.players AS p
LEFT JOIN football_club.contracts AS ct ON ct.player_id = p.player_id;

SELECT c.club_id, c.name AS club_name,
       sp.sponsor_id, sp.amount, sp.type
FROM football_club.football_clubs AS c
RIGHT JOIN football_club.sponsors AS sp ON sp.club_id = c.club_id;

SELECT p.player_id, p.first_name,
       ct.contract_id, ct.start_date, ct.end_date, ct.salary
FROM football_club.players AS p
RIGHT JOIN football_club.contracts AS ct ON ct.player_id = p.player_id;

SELECT t.name  AS tournament_name,
       l.name  AS league_name,
       t.region, t.format, l.country, l.tier
FROM football_club.tournament AS t
CROSS JOIN football_club.league AS l;

SELECT o.name AS owner_name, o.nationality,
       s.name AS stadium_name, s.capacity
FROM football_club.owners AS o
CROSS JOIN football_club.stadiums AS s;

SELECT c.club_id, c.name AS club_name,
       sp.sponsor_id, sp.amount, sp.type
FROM football_club.football_clubs AS c
FULL OUTER JOIN football_club.sponsors AS sp ON sp.club_id = c.club_id;

SELECT p.player_id, p.first_name,
       ct.contract_id, ct.start_date, ct.end_date, ct.salary
FROM football_club.players AS p
FULL OUTER JOIN football_club.contracts AS ct ON ct.player_id = p.player_id;