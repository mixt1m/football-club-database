CREATE ROLE admin WITH LOGIN PASSWORD 'admin';
GRANT CONNECT ON DATABASE football_club TO admin;
GRANT ALL ON SCHEMA football_club TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA football_club TO admin;

CREATE ROLE manager WITH LOGIN PASSWORD 'manager';
GRANT CONNECT ON DATABASE football_club TO manager;
GRANT USAGE ON SCHEMA football_club TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON 
    football_club.players,
    football_club.staff,
    football_club.contracts,
    football_club.participation
    TO manager;

CREATE ROLE viewer WITH LOGIN PASSWORD 'viewer';
GRANT CONNECT ON DATABASE football_club TO viewer;
GRANT USAGE ON SCHEMA football_club TO viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA football_club TO viewer;


