CREATE SCHEMA football_club;

CREATE TABLE football_club.cities (
    city_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE football_club.owners(
    owner_id SERIAL PRIMARY KEY,
    name varchar(100) NOT NULL,
    nationality varchar(50) NOT NULL,
    purchase_date DATE NOT NULL
);

CREATE TABLE football_club.stadiums(
    staduim_id SERIAL PRIMARY KEY,
    name varchar(100) NOT NULL,
    capacity INT NOT NULL CHECK(capacity > 0),
    address varchar(100) NOT NULL
);

CREATE TABLE football_club.football_clubs(
    club_id SERIAL PRIMARY KEY, 
    name varchar(100) NOT NULL,
    city_id INT REFERENCES football_club.cities(city_id),
    owner_id INT REFERENCES football_club.owners(owner_id),
    staduim_id INT REFERENCES football_club.stadiums(staduim_id)
);


CREATE TABLE football_club.sponsors(
    sponsor_id SERIAL PRIMARY KEY,
    club_id INT REFERENCES football_club.football_clubs(club_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    amount MONEY NOT NULL,
    type varchar(100) NOT NULL
);

CREATE TABLE football_club.fun_shop(
    shop_id SERIAL PRIMARY KEY,
    address varchar(100) NOT NULL,
    club_id INT REFERENCES football_club.football_clubs(club_id)
);

CREATE TABLE football_club.products(
    product_id SERIAL PRIMARY KEY,
    name varchar(100) NOT NULL,
    type varchar(50),
    price MONEY NOT NULL,
    size varchar(20) NOT NULL,
    count INT NOT NULL CHECK(count >= 0), 
    shop_id INT REFERENCES football_club.fun_shop(shop_id)
);

CREATE TABLE football_club.tournament(
    tournament_id SERIAL PRIMARY KEY,
    name varchar(100) NOT NULL,
    region varchar(50) NOT NULL,
    format varchar(20) NOT NULL
);

CREATE TABLE football_club.league(
    liague_id SERIAL PRIMARY KEY,
    name varchar(100) NOT NULL,
    country varchar(50) NOT NULL,
    tier INT NOT NULL CHECK(tier >= 1)
);

CREATE TABLE football_club.participation(
    participation_id SERIAL PRIMARY KEY,
    club_id INT REFERENCES football_club.football_clubs(club_id),
    tournament_id INT REFERENCES football_club.tournament(tournament_id),
    liague_id INT REFERENCES football_club.league(liague_id),
    season varchar(10) NOT NULL,
    final_position INT NOT NULL CHECK(final_position >= 1) 
);

CREATE TABLE football_club.players(
    player_id SERIAL PRIMARY KEY,
    first_name varchar(30) NOT NULL,
    date_of_birth DATE NOT NULL,
    nationality varchar(30),
    position varchar(20),
    market_value MONEY,
    club_id INT REFERENCES football_club.football_clubs(club_id)
);

CREATE TABLE football_club.contracts(
    contract_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES football_club.players(player_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    salary MONEY NOT NULL
);


CREATE TABLE football_club.departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE football_club.positions (
    position_id SERIAL PRIMARY KEY,
    department_id INT REFERENCES football_club.departments(department_id),
    title VARCHAR(100) NOT NULL,
    base_salary MONEY NOT NULL
);

CREATE TABLE football_club.staff(
    staff_id SERIAL PRIMARY KEY,
    first_name varchar(30) NOT NULL,
    date_of_birth DATE NOT NULL,
    salary MONEY NOT NULL,
    position_id INT REFERENCES football_club.positions(position_id),
    club_id INT REFERENCES football_club.football_clubs(club_id)
);
