
--  увеличиваем capacity, но откатываем фан-шоп после проверки
BEGIN;

    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Арена Север';

    -- Обновляем стадион «Арена Север» и оставляем значение в транзакции
    UPDATE football_club.stadiums
    SET capacity = capacity + 500
    WHERE name = 'Арена Север';

    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Арена Север';

    -- Сохраняем точку перед потенциально рискованной вставкой
    SAVEPOINT sp_insert_shop;

    SELECT fs.shop_id, fs.address
    FROM football_club.fun_shop AS fs
    JOIN football_club.football_clubs AS fc ON fc.club_id = fs.club_id
    WHERE fc.name = 'Челси';

    --Пробуем создать ещё один фан-шоп клуба
    INSERT INTO football_club.fun_shop (address, club_id)
    SELECT 'Москва', fc.club_id
    FROM football_club.football_clubs fc
    WHERE fc.name = 'Челси';

    SELECT fs.shop_id, fs.address
    FROM football_club.fun_shop AS fs
    JOIN football_club.football_clubs AS fc ON fc.club_id = fs.club_id
    WHERE fc.name = 'Челси';



    -- Бизнес-логика не прошла, откатываемся
    ROLLBACK TO sp_insert_shop;

    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Арена Север';

    SELECT fs.shop_id, fs.address
    FROM football_club.fun_shop AS fs
    JOIN football_club.football_clubs AS fc ON fc.club_id = fs.club_id
    WHERE fc.name = 'Челси';



COMMIT; -- увеличение capacity сохраняется


--две точки сохранения и поэтапный откат
BEGIN;
    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Нева Парк' OR name = 'Сантьяго Виста' ; 

    --  фиксируем первую точку
    SAVEPOINT sp_before_1;

    --  Увеличиваем Нева Парк
    UPDATE football_club.stadiums
    SET capacity = capacity + 100
    WHERE name = 'Нева Парк';


    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Нева Парк';
--  фиксируем вторую точку

    SAVEPOINT sp_before_2;

    --  Увеличиваем Сантьяго Виста
    UPDATE football_club.stadiums
    SET capacity = capacity + 200
    WHERE name = 'Сантьяго Виста';
   

    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Сантьяго Виста';


    -- Откатываемся к sp_before_2 
    ROLLBACK TO sp_before_1;

    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Нева Парк' OR name = 'Сантьяго Виста' ; 

    --  Откатываемся к sp_before_1 
    ROLLBACK TO sp_before_2;

    SELECT name, capacity
    FROM football_club.stadiums
    WHERE name = 'Нева Парк' OR name = 'Сантьяго Виста' ; 

COMMIT; -- финально изменений нет





-- единый спонсор-счёт
INSERT INTO football_club.sponsors(club_id, start_date, end_date, amount, type)
VALUES (1, '2024-01-01', '2025-01-01', 1000000::money, 'Serializable balance');


SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE type = 'Serializable balance';

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE sponsor_id = 50;
-- 1 000 000

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE sponsor_id = 50;
-- тоже 1 000 000


UPDATE football_club.sponsors
SET amount = amount + 200000::money
WHERE sponsor_id = 50;



UPDATE football_club.sponsors
SET amount = amount + 300000::money
WHERE sponsor_id = 50;



COMMIT;
-- обычно проходит нормально


COMMIT;