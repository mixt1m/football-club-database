-- скрины: screenshots/indeces

--1

CREATE INDEX ON football_club.players (market_value);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM football_club.players
WHERE market_value > 10000000::money;

--2
CREATE INDEX ON football_club.contracts (player_id);

DROP INDEX football_club.contracts_player_id_idx;

CREATE INDEX ON football_club.contracts USING HASH (player_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM football_club.contracts
WHERE player_id = 50000;

--3

CREATE INDEX ON football_club.contracts (end_date);

DROP INDEX football_club.contracts_end_date_idx;

CREATE INDEX ON football_club.contracts USING HASH (end_date);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM football_club.contracts
WHERE end_date IN ('2026-06-10', '2027-05-12');

--4

CREATE INDEX ON football_club.players (first_name);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM football_club.players
WHERE first_name LIKE 'Алек%';

--5

CREATE INDEX ON football_club.participation (final_position);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM football_club.participation
WHERE final_position < 4;