BEGIN;
CREATE TABLE IF NOT EXISTS football_club.fun_shop
(
    shop_id serial NOT NULL,
    address character varying(100) NOT NULL,
    club_id integer,
    CONSTRAINT fun_shop_pkey PRIMARY KEY (shop_id)
);
CREATE TABLE IF NOT EXISTS football_club.products
(
    product_id serial NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(50),
    price money NOT NULL,
    count integer NOT NULL,
    shop_id integer,
    height smallint,
    width smallint,
    length smallint,
    CONSTRAINT products_pkey PRIMARY KEY (product_id)
);
CREATE TABLE IF NOT EXISTS football_club.sponsors
(
    sponsor_id serial NOT NULL,
    club_id integer,
    start_date date NOT NULL,
    end_date date NOT NULL,
    amount money NOT NULL,
    type character varying(100) NOT NULL,
    CONSTRAINT sponsors_pkey PRIMARY KEY (sponsor_id)
);
CREATE TABLE IF NOT EXISTS football_club.participation
(
    participation_id serial NOT NULL,
    club_id integer,
    tournament_id integer,
    liague_id integer,
    season character varying(10) NOT NULL,
    final_position integer NOT NULL,
    CONSTRAINT participation_pkey PRIMARY KEY (participation_id)
);
ALTER TABLE IF EXISTS football_club.football_clubs
    ADD CONSTRAINT football_clubs_city_id_fkey FOREIGN KEY (city_id)
    REFERENCES football_club.cities (city_id);
ALTER TABLE IF EXISTS football_club.football_clubs
    ADD CONSTRAINT football_clubs_owner_id_fkey FOREIGN KEY (owner_id)
    REFERENCES football_club.owners (owner_id);
ALTER TABLE IF EXISTS football_club.football_clubs
    ADD CONSTRAINT football_clubs_staduim_id_fkey FOREIGN KEY (staduim_id)
    REFERENCES football_club.stadiums (staduim_id);
ALTER TABLE IF EXISTS football_club.players
    ADD CONSTRAINT players_club_id_fkey FOREIGN KEY (club_id)
    REFERENCES football_club.football_clubs (club_id);
ALTER TABLE IF EXISTS football_club.contracts
    ADD CONSTRAINT contracts_player_id_fkey FOREIGN KEY (player_id)
    REFERENCES football_club.players (player_id);
ALTER TABLE IF EXISTS football_club.positions
    ADD CONSTRAINT positions_department_id_fkey FOREIGN KEY (department_id)
    REFERENCES football_club.departments (department_id);
ALTER TABLE IF EXISTS football_club.staff
    ADD CONSTRAINT staff_club_id_fkey FOREIGN KEY (club_id)
    REFERENCES football_club.football_clubs (club_id);
ALTER TABLE IF EXISTS football_club.staff
    ADD CONSTRAINT staff_position_id_fkey FOREIGN KEY (position_id)
    REFERENCES football_club.positions (position_id);
ALTER TABLE IF EXISTS football_club.fun_shop
    ADD CONSTRAINT fun_shop_club_id_fkey FOREIGN KEY (club_id)
    REFERENCES football_club.football_clubs (club_id);
ALTER TABLE IF EXISTS football_club.products
    ADD CONSTRAINT products_shop_id_fkey FOREIGN KEY (shop_id)
    REFERENCES football_club.fun_shop (shop_id);
ALTER TABLE IF EXISTS football_club.sponsors
    ADD CONSTRAINT sponsors_club_id_fkey FOREIGN KEY (club_id)
    REFERENCES football_club.football_clubs (club_id);
ALTER TABLE IF EXISTS football_club.participation
    ADD CONSTRAINT participation_club_id_fkey FOREIGN KEY (club_id)
    REFERENCES football_club.football_clubs (club_id);
ALTER TABLE IF EXISTS football_club.participation
    ADD CONSTRAINT participation_liague_id_fkey FOREIGN KEY (liague_id)
    REFERENCES football_club.league (liague_id);
ALTER TABLE IF EXISTS football_club.participation
    ADD CONSTRAINT participation_tournament_id_fkey FOREIGN KEY (tournament_id)
    REFERENCES football_club.tournament (tournament_id);
COMMIT;