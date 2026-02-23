ALTER TABLE football_club.products DROP COLUMN size;

ALTER TABLE football_club.products ADD COLUMN height SMALLINT CHECK(height > 0);
ALTER TABLE football_club.products ADD COLUMN width SMALLINT CHECK(width > 0);
ALTER TABLE football_club.products ADD COLUMN length SMALLINT CHECK(height > 0);


