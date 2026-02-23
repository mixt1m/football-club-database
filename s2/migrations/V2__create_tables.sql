BEGIN;
CREATE TABLE IF NOT EXISTS football_club.football_clubs
(
    club_id serial NOT NULL,
    name character varying(100) NOT NULL,
    country character varying(50) NOT NULL,
    city character varying(50) NOT NULL,
    owner_id integer,
    staduim_id integer,
    city_id integer,
    CONSTRAINT football_clubs_pkey PRIMARY KEY (club_id)
);
CREATE TABLE IF NOT EXISTS football_club.players
(
    player_id serial NOT NULL,
    first_name character varying(30) NOT NULL,
    date_of_birth date NOT NULL,
    nationality character varying(30),
    "position" character varying(20),
    market_value money,
    club_id integer,
    CONSTRAINT players_pkey PRIMARY KEY (player_id)
);
CREATE TABLE IF NOT EXISTS football_club.staff
(
    staff_id serial NOT NULL,
    first_name character varying(30) NOT NULL,
    date_of_birth date NOT NULL,
    salary money NOT NULL,
    position_id integer,
    club_id integer,
    CONSTRAINT staff_pkey PRIMARY KEY (staff_id)
);
CREATE TABLE IF NOT EXISTS football_club.positions
(
    position_id serial NOT NULL,
    department_id integer,
    title character varying(100) NOT NULL,
    base_salary money NOT NULL,
    CONSTRAINT positions_pkey PRIMARY KEY (position_id)
);
CREATE TABLE IF NOT EXISTS football_club.contracts
(
    contract_id serial NOT NULL,
    player_id integer,
    start_date date NOT NULL,
    end_date date NOT NULL,
    salary money NOT NULL,
    CONSTRAINT contracts_pkey PRIMARY KEY (contract_id)
);
COMMIT;