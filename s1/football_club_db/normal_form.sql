CREATE TABLE football_club.cities (
    city_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
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

DROP TABLE football_club.administrative_staff CASCADE;
DROP TABLE football_club.coaching_staff CASCADE;
DROP TABLE football_club.medical_staff CASCADE;
DROP TABLE football_club.staff CASCADE;

CREATE TABLE football_club.staff(
    staff_id SERIAL PRIMARY KEY,
    first_name varchar(30) NOT NULL,
    date_of_birth DATE NOT NULL,
    salary MONEY NOT NULL,
    position_id INT REFERENCES football_club.positions(position_id),
    club_id INT REFERENCES football_club.football_clubs(club_id)
);




ALTER TABLE football_club.contracts DROP COLUMN club_id;


ALTER TABLE football_club.football_clubs ADD COLUMN city_id INT REFERENCES football_club.cities(city_id);