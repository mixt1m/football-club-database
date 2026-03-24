CREATE INDEX gin_clubs_search ON football_club.football_clubs USING GIN (search_vector);
CREATE INDEX gin_players_search ON football_club.players USING GIN (search_vector);
CREATE INDEX gin_players_tags ON football_club.players USING GIN (tags);
CREATE INDEX gin_products_tags ON football_club.products USING GIN (tags);
CREATE INDEX gin_products_attrs ON football_club.products USING GIN (attributes);


CREATE INDEX gist_products_dims ON football_club.products USING GIST (dimensions);
CREATE INDEX gist_contracts_start ON football_club.contracts USING GIST (start_date);
CREATE INDEX gist_contracts_end ON football_club.contracts USING GIST (end_date);
CREATE INDEX gist_players_birth ON football_club.players USING GIST (date_of_birth);
CREATE INDEX gist_owners_purchase ON football_club.owners USING GIST (purchase_date);

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.football_clubs 
WHERE search_vector @@ to_tsquery('simple', 'Real');

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.players 
WHERE search_vector @@ to_tsquery('simple', 'Lionel & Messi');

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.players 
WHERE tags @> ARRAY['forward'];

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.products 
WHERE attributes @> '{"color": "red"}';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT *, ts_rank(search_vector, to_tsquery('simple', 'Madrid | Barcelona')) as rank
FROM football_club.football_clubs 
WHERE search_vector @@ to_tsquery('simple', 'Madrid | Barcelona');


EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.products 
WHERE dimensions <@ box(point(0,0), point(100,100));


EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.contracts 
WHERE start_date >= '2026-01-01' AND start_date <= '2026-01-31';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.contracts 
WHERE end_date >= '2026-06-01';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.players 
WHERE date_of_birth > '1990-01-01' AND date_of_birth < '2000-01-01';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM football_club.owners 
WHERE purchase_date >= '2020-01-01';



EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT c.name AS club, pl.first_name, pl.position, con.salary, con.start_date
FROM football_club.football_clubs c 
JOIN football_club.players pl ON c.club_id = pl.club_id 
JOIN football_club.contracts con ON pl.player_id = con.player_id 
WHERE c.name ILIKE '%Real%';


EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT o.name AS owner, c.name AS club, s.name AS stadium, s.capacity
FROM football_club.owners o 
JOIN football_club.football_clubs c ON o.owner_id = c.owner_id 
JOIN football_club.stadiums s ON c.staduim_id = s.staduim_id 
WHERE s.capacity > 50000;


EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT s.address AS shop, p.name AS product, p.price, p.count, c.name AS club
FROM football_club.fun_shop s 
JOIN football_club.products p ON s.shop_id = p.shop_id 
JOIN football_club.football_clubs c ON s.club_id = c.club_id 
WHERE p.price < 100::money AND p.count > 0 ;


EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT l.name AS league, t.name AS tournament, c.name AS club, part.final_position
FROM football_club.league l 
JOIN football_club.participation part ON l.liague_id = part.liague_id 
JOIN football_club.tournament t ON part.tournament_id = t.tournament_id 
JOIN football_club.football_clubs c ON part.club_id = c.club_id 
WHERE part.season = '2025/26';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT st.first_name, pos.title, d.name AS department, c.name AS club, st.salary
FROM football_club.staff st 
JOIN football_club.positions pos ON st.position_id = pos.position_id 
JOIN football_club.departments d ON pos.department_id = d.department_id 
JOIN football_club.football_clubs c ON st.club_id = c.club_id 
WHERE st.salary > 50000::money;
