CREATE EXTENSION IF NOT EXISTS pageinspect;

SELECT pg_relation_filepath('football_club.cities');

DELETE FROM football_club.cities
WHERE name IN ('MVCC City', 'Deadlock City 1', 'Deadlock City 2');

INSERT INTO football_club.cities (name, country)
VALUES ('MVCC City', 'MVCC Country');

SELECT
    lp AS line_pointer,
    lp_off AS offset,
    lp_flags,
    t_xmin,
    t_xmax,
    t_field3,
    t_ctid,
    t_infomask,
    t_infomask2
FROM heap_page_items(get_raw_page('football_club.cities', 0));

SELECT
    lp,
    t_xmin,
    t_xmax,
    t_ctid,
    t_infomask,
    t_infomask2,
    raw_flags,
    combined_flags
FROM heap_page_items(get_raw_page('football_club.cities', 0))
CROSS JOIN LATERAL heap_tuple_infomask_flags(t_infomask, t_infomask2);

INSERT INTO football_club.cities (name, country)
VALUES ('Deadlock City 1', 'DL Country 1'),
       ('Deadlock City 2', 'DL Country 2');

SELECT ctid, xmin, xmax, city_id, name, country
FROM football_club.cities
WHERE name = 'MVCC City';

UPDATE football_club.cities
SET country = 'MVCC Country Updated'
WHERE name = 'MVCC City';

SELECT ctid, xmin, xmax, city_id, name, country
FROM football_club.cities
WHERE name = 'MVCC City';

SELECT
    lp,
    t_xmin,
    t_xmax,
    t_ctid,
    t_infomask,
    t_infomask2,
    raw_flags,
    combined_flags
FROM heap_page_items(get_raw_page('football_club.cities', 0))
CROSS JOIN LATERAL heap_tuple_infomask_flags(t_infomask, t_infomask2)
ORDER BY lp;

ROLLBACK;

-- session 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT ctid, xmin, xmax, city_id, name, country
FROM football_club.cities
WHERE name = 'MVCC City';

-- session 2
BEGIN;

UPDATE football_club.cities
SET country = 'MVCC Country Tx2'
WHERE name = 'MVCC City';

SELECT ctid, xmin, xmax, city_id, name, country
FROM football_club.cities
WHERE name = 'MVCC City';

COMMIT;

-- session 1
SELECT ctid, xmin, xmax, city_id, name, country
FROM football_club.cities
WHERE name = 'MVCC City';

COMMIT;

SELECT ctid, xmin, xmax, city_id, name, country
FROM football_club.cities
WHERE name = 'MVCC City';

SELECT
    lp,
    t_xmin,
    t_xmax,
    t_ctid,
    t_infomask,
    t_infomask2,
    raw_flags,
    combined_flags
FROM heap_page_items(get_raw_page('football_club.cities', 0))
CROSS JOIN LATERAL heap_tuple_infomask_flags(t_infomask, t_infomask2)
ORDER BY lp;

SELECT city_id, name
FROM football_club.cities
WHERE name IN ('Deadlock City 1', 'Deadlock City 2')
ORDER BY city_id;

-- session 1
BEGIN;

UPDATE football_club.cities
SET country = 'DL S1'
WHERE name = 'Deadlock City 1';

-- session 2
BEGIN;

UPDATE football_club.cities
SET country = 'DL S2'
WHERE name = 'Deadlock City 2';

UPDATE football_club.cities
SET country = 'DL S2 step 2'
WHERE name = 'Deadlock City 1';

-- session 1
UPDATE football_club.cities
SET country = 'DL S1 step 2'
WHERE name = 'Deadlock City 2';
