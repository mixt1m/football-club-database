DROP TABLE IF EXISTS football_club.test_wal;

CREATE TABLE football_club.test_wal
(
    id serial PRIMARY KEY,
    val text NOT NULL
);

DROP TABLE IF EXISTS temp_wal_lsn;

CREATE TEMP TABLE temp_wal_lsn
(
    stage text PRIMARY KEY,
    lsn pg_lsn
);

INSERT INTO temp_wal_lsn(stage, lsn)
VALUES ('before_insert', pg_current_wal_lsn());

SELECT stage, lsn
FROM temp_wal_lsn
WHERE stage = 'before_insert';

INSERT INTO football_club.test_wal (val)
VALUES ('hello wal');

INSERT INTO temp_wal_lsn(stage, lsn)
VALUES ('after_insert', pg_current_wal_lsn());

SELECT stage, lsn
FROM temp_wal_lsn
WHERE stage IN ('before_insert', 'after_insert')
ORDER BY stage;

SELECT
    a.lsn AS lsn_before,
    b.lsn AS lsn_after,
    pg_wal_lsn_diff(b.lsn, a.lsn) AS bytes_between
FROM temp_wal_lsn a
JOIN temp_wal_lsn b
    ON a.stage = 'before_insert'
   AND b.stage = 'after_insert';

SELECT pg_current_wal_lsn() AS lsn_before_commit;
SELECT pg_current_wal_insert_lsn() AS wal_insert_before_commit;
SELECT pg_walfile_name(pg_current_wal_lsn()) AS wal_file_before_commit;

BEGIN;

INSERT INTO football_club.test_wal (val)
VALUES ('before commit row 1'),
       ('before commit row 2'),
       ('before commit row 3');

SELECT pg_current_wal_lsn() AS lsn_in_transaction;
SELECT pg_current_wal_insert_lsn() AS wal_insert_in_transaction;
SELECT pg_walfile_name(pg_current_wal_lsn()) AS wal_file_in_transaction;

COMMIT;

SELECT pg_current_wal_lsn() AS lsn_after_commit;
SELECT pg_current_wal_insert_lsn() AS wal_insert_after_commit;
SELECT pg_walfile_name(pg_current_wal_lsn()) AS wal_file_after_commit;


-- 3. Анализ WAL размера после массовой операции

INSERT INTO temp_wal_lsn(stage, lsn)
VALUES ('before_mass_insert', pg_current_wal_lsn())
ON CONFLICT (stage) DO UPDATE
SET lsn = excluded.lsn;

INSERT INTO football_club.test_wal (val)
SELECT md5(random()::text)
FROM generate_series(1, 100000);

INSERT INTO temp_wal_lsn(stage, lsn)
VALUES ('after_mass_insert', pg_current_wal_lsn())
ON CONFLICT (stage) DO UPDATE
SET lsn = excluded.lsn;

SELECT
    a.lsn AS lsn_before,
    b.lsn AS lsn_after,
    pg_size_pretty(pg_wal_lsn_diff(b.lsn, a.lsn)) AS wal_generated,
    pg_wal_lsn_diff(b.lsn, a.lsn) AS wal_generated_bytes
FROM temp_wal_lsn a
JOIN temp_wal_lsn b
    ON a.stage = 'before_mass_insert'
   AND b.stage = 'after_mass_insert';

SELECT count(*) AS inserted_rows
FROM football_club.test_wal;


INSERT INTO football_club.departments (department_id, name)
VALUES
    (1001, 'Administration'),
    (1002, 'Coaching'),
    (1003, 'Medical')
ON CONFLICT (department_id) DO NOTHING;

INSERT INTO football_club.cities (city_id, name, country)
VALUES
    (1001, 'Manchester', 'England'),
    (1002, 'Madrid', 'Spain'),
    (1003, 'Munich', 'Germany')
ON CONFLICT (city_id) DO NOTHING;

INSERT INTO football_club.stadiums (staduim_id, name, capacity, address)
VALUES
    (1001, 'North Arena', 55000, 'North street 1'),
    (1002, 'Royal Stadium', 70000, 'Royal avenue 10'),
    (1003, 'Bavaria Park', 68000, 'Bavaria platz 7')
ON CONFLICT (staduim_id) DO NOTHING;

INSERT INTO football_club.owners (owner_id, name, nationality, purchase_date)
VALUES
    (1001, 'John Smith', 'English', DATE '2020-01-01'),
    (1002, 'Carlos Diaz', 'Spanish', DATE '2021-06-15'),
    (1003, 'Hans Muller', 'German', DATE '2019-09-10')
ON CONFLICT (owner_id) DO NOTHING;

INSERT INTO football_club.football_clubs (club_id, name, country, city, owner_id, staduim_id, city_id)
VALUES
    (1001, 'North City FC', 'England', 'Manchester', 1001, 1001, 1001),
    (1002, 'Royal Club', 'Spain', 'Madrid', 1002, 1002, 1002),
    (1003, 'Bavaria FC', 'Germany', 'Munich', 1003, 1003, 1003)
ON CONFLICT (club_id) DO NOTHING;

INSERT INTO football_club.players (player_id, first_name, date_of_birth, nationality, "position", market_value, club_id)
VALUES
    (1001, 'Alex', DATE '2000-05-10', 'English', 'Forward', '1000000', 1001),
    (1002, 'Diego', DATE '1998-03-21', 'Spanish', 'Midfielder', '1200000', 1002),
    (1003, 'Lukas', DATE '1999-11-03', 'German', 'Defender', '900000', 1003)
ON CONFLICT (player_id) DO NOTHING;

INSERT INTO football_club.departments (name)
SELECT 'Analytics'
WHERE NOT EXISTS
(
    SELECT 1
    FROM football_club.departments
    WHERE name = 'Analytics'
);

INSERT INTO football_club.positions (position_id, department_id, title, base_salary)
VALUES
    (1001, 1001, 'Director', '5000'),
    (1002, 1002, 'Head Coach', '7000'),
    (1003, 1003, 'Doctor', '4500')
ON CONFLICT (position_id) DO NOTHING;

INSERT INTO football_club.staff (staff_id, first_name, date_of_birth, salary, position_id, club_id)
VALUES
    (1001, 'Michael', DATE '1980-02-14', '4800', 1001, 1001),
    (1002, 'Roberto', DATE '1975-08-30', '6900', 1002, 1002),
    (1003, 'Thomas', DATE '1984-12-19', '4300', 1003, 1003)
ON CONFLICT (staff_id) DO NOTHING;

INSERT INTO football_club.contracts (contract_id, player_id, start_date, end_date, salary)
VALUES
    (1001, 1001, DATE '2024-07-01', DATE '2027-06-30', '15000'),
    (1002, 1002, DATE '2024-07-01', DATE '2028-06-30', '18000'),
    (1003, 1003, DATE '2024-07-01', DATE '2026-06-30', '12000')
ON CONFLICT (contract_id) DO NOTHING;



INSERT INTO football_club.departments (department_id, name)
VALUES (1001, 'Administration')
ON CONFLICT (department_id) DO NOTHING;

INSERT INTO football_club.cities (city_id, name, country)
VALUES (1001, 'Manchester', 'England')
ON CONFLICT (city_id) DO NOTHING;

INSERT INTO football_club.departments (name)
SELECT 'Analytics'
WHERE NOT EXISTS
(
    SELECT 1
    FROM football_club.departments
    WHERE name = 'Analytics'
);

SELECT *
FROM football_club.departments
WHERE department_id IN (1001, 1002, 1003)
   OR name = 'Analytics'
ORDER BY department_id NULLS LAST, name;

SELECT *
FROM football_club.cities
WHERE city_id IN (1001, 1002, 1003)
ORDER BY city_id;

SELECT *
FROM football_club.football_clubs
WHERE club_id IN (1001, 1002, 1003)
ORDER BY club_id;
