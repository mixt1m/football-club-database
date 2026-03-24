BEGIN;
CREATE SCHEMA IF NOT EXISTS football_club;
CREATE TABLE IF NOT EXISTS football_club.cities
(
    city_id serial NOT NULL,
    name character varying(50) NOT NULL,
    country character varying(50) NOT NULL,
    CONSTRAINT cities_pkey PRIMARY KEY (city_id)
);
CREATE TABLE IF NOT EXISTS football_club.departments
(
    department_id serial NOT NULL,
    name character varying(50) NOT NULL,
    CONSTRAINT departments_pkey PRIMARY KEY (department_id),
    CONSTRAINT departments_name_key UNIQUE (name)
);
CREATE TABLE IF NOT EXISTS football_club.stadiums
(
    staduim_id serial NOT NULL,
    name character varying(100) NOT NULL,
    capacity integer NOT NULL,
    address character varying(100) NOT NULL,
    CONSTRAINT stadiums_pkey PRIMARY KEY (staduim_id)
);
CREATE TABLE IF NOT EXISTS football_club.owners
(
    owner_id serial NOT NULL,
    name character varying(100) NOT NULL,
    nationality character varying(50) NOT NULL,
    purchase_date date NOT NULL,
    CONSTRAINT owners_pkey PRIMARY KEY (owner_id)
);
CREATE TABLE IF NOT EXISTS football_club.league
(
    liague_id serial NOT NULL,
    name character varying(100) NOT NULL,
    country character varying(50) NOT NULL,
    tier integer NOT NULL,
    CONSTRAINT league_pkey PRIMARY KEY (liague_id)
);
CREATE TABLE IF NOT EXISTS football_club.tournament
(
    tournament_id serial NOT NULL,
    name character varying(100) NOT NULL,
    region character varying(50) NOT NULL,
    format character varying(20) NOT NULL,
    CONSTRAINT tournament_pkey PRIMARY KEY (tournament_id)
);
COMMIT;