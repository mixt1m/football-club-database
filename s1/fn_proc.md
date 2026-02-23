```sql
-- Процедуры
-- 1: обновить вместимость стадиона
CREATE OR REPLACE PROCEDURE update_stadium_capacity(p_stadium_id TEXT, p_delta INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE football_club.stadiums
    SET capacity = capacity + p_delta
    WHERE staduim_id = p_stadium_id;
END;
$$;
```
![01](fn_proc/1.png)
![01](fn_proc/2.png)
```sql
-- 2: добавить фан-шоп 
CREATE OR REPLACE PROCEDURE add_fun_shop(p_address TEXT, p_club_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO football_club.fun_shop (address, club_id)
    SELECT p_address, fc.club_id
    FROM football_club.football_clubs fc
    WHERE fc.club_id = p_club_id;
END;
$$;
```
![01](fn_proc/3.png)
```sql
-- 3: удалить спонсора по id
CREATE OR REPLACE PROCEDURE delete_sponsor(p_sponsor_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM football_club.sponsors WHERE sponsor_id = p_sponsor_id;
END;
$$;
```
![01](fn_proc/11.png)
![01](fn_proc/12.png)

![01](savepoint/111.jpg)

```sql
-- Функции
-- 1: объём спонсорских выплат клуба
CREATE OR REPLACE FUNCTION club_sponsors_total(p_club_id INT)
RETURNS INT
LANGUAGE sql
AS $$
    SELECT SUM(CAST(amount AS NUMERIC))
    FROM football_club.sponsors
    WHERE club_id = p_club_id;
$$;
```
![01](fn_proc/4.png)
```sql
-- 2: количество игроков клуба
CREATE OR REPLACE FUNCTION club_players_count(p_club_id INT)
RETURNS INT
LANGUAGE sql
AS $$
    SELECT COUNT(*) FROM football_club.players WHERE club_id = p_club_id;
$$;
```
![01](fn_proc/5.png)
```sql
-- 3: средняя зарплата по клубу
CREATE OR REPLACE FUNCTION club_avg_salary(p_club_id INT)
RETURNS INT
LANGUAGE sql
AS $$
    SELECT AVG(CAST(c.salary AS NUMERIC))
    FROM football_club.contracts c
    JOIN football_club.players p ON p.player_id = c.player_id
    WHERE p.club_id = p_club_id;
$$;
```
![01](fn_proc/6.png)
```sql
--4: сумма + количество по спонсорам клуба
CREATE OR REPLACE FUNCTION club_sponsor_report(p_club_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    total INT;
    count INT;
BEGIN
    SELECT SUM(CAST(amount AS NUMERIC)), COUNT(*)
    INTO total, count
    FROM football_club.sponsors sp
    JOIN football_club.football_clubs fc ON fc.club_id = sp.club_id
    WHERE fc.club_id = p_club_id;

    RETURN 'Спонсоров: ' || count ||', сумма: ' || total;
END;
$$;
```
![01](fn_proc/7.png)
```sql
-- 5: дата окончания последнего контракта игрока
CREATE OR REPLACE FUNCTION player_last_contract_end(p_player_name TEXT)
RETURNS DATE
LANGUAGE plpgsql
AS $$
DECLARE
    con_end DATE;
BEGIN
    SELECT MAX(end_date) INTO con_end
    FROM football_club.contracts c
    JOIN football_club.players p ON p.player_id = c.player_id
    WHERE p.first_name = p_player_name;
    RETURN con_end;
END;
$$;
```
![01](fn_proc/8.png)
```sql
-- 6:класс вместимости стадиона
CREATE OR REPLACE FUNCTION capacity_class(p_stadium_name TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    cap INT;
BEGIN
    SELECT capacity INTO cap
    FROM football_club.stadiums
    WHERE name = p_stadium_name;

    IF cap IS NULL THEN
        RETURN 'не найден';
    ELSIF cap >= 60000 THEN
        RETURN 'большой';
    ELSIF cap >= 40000 THEN
        RETURN 'средний';
    ELSE
        RETURN 'малый';
    END IF;
END;
$$;
```
![01](fn_proc/9.png)

![01](savepoint/222.jpg)

```sql
-- DO
-- 1: количество стадионов
DO $$
DECLARE
    cnt INT;
BEGIN
    SELECT COUNT(*) INTO cnt FROM football_club.stadiums;
    RAISE NOTICE 'Стадионов: %', cnt;
END;
$$;

-- 2: количество фан-шопов
DO $$
DECLARE
    cnt INT;
BEGIN
    SELECT COUNT(*) INTO cnt FROM football_club.fun_shop;
    RAISE NOTICE 'Фан-шопов: %', cnt;
END;
$$;

-- 3: 
DO $$
DECLARE
    total INT;
BEGIN
    SELECT SUM(CAST(amount AS NUMERIC)) INTO total
    FROM football_club.sponsors;
    RAISE NOTICE 'Общая сумма спонсорских: %', total;
END;
$$;
```
![01](fn_proc/101.png)

```sql
-- IF: проверка, дорогой ли игрок
CREATE OR REPLACE FUNCTION football_club.player_is_expensive(p_player_id INT)
LANGUAGE plpgsql
RETURNS TEXT AS $$
DECLARE
  v_val MONEY; 
BEGIN
  SELECT market_value INTO v_val
  FROM football_club.players
  WHERE player_id = p_player_id;

  IF v_val > 5000000::money THEN          
    RETURN 'expensive';
  ELSE
    RETURN 'normal';
  END IF;
END;
$$ 
SELECT football_club.player_is_expensive(1);

```
![01](savepoint/730.jpg)
```sql
-- CASE: категория стадиона по вместимости
CREATE OR REPLACE FUNCTION football_club.stadium_size(p_stadium_id INT)
RETURNS TEXT LANGUAGE plpgsql 
AS $$
DECLARE
  v_cap INT; 
BEGIN
  SELECT capacity INTO v_cap
  FROM football_club.stadiums
  WHERE stadium_id = p_stadium_id;

  RETURN CASE                          
    WHEN v_cap IS NULL  THEN 'unknown'
    WHEN v_cap < 10000  THEN 'small'
    WHEN v_cap <= 30000 THEN 'medium'
    ELSE 'large'
  END;
END;
$$ 
SELECT football_club.stadium_size(1);

```
![01](savepoint/731.jpg)
```sql
 -- цикл WHILE
CREATE OR REPLACE FUNCTION football_club.while_count_shops(p_club_id INT)
RETURNS INT LANGUAGE plpgsql 
AS $$
DECLARE
  i INT := 1;   
  max_id INT;       
  cnt INT := 0;   
BEGIN
  SELECT MAX(shop_id) INTO max_id
  FROM football_club.fun_shop;

  WHILE i <= max_id LOOP
    IF EXISTS (
      SELECT 1
      FROM football_club.fun_shop
      WHERE shop_id = i
        AND club_id = p_club_id
    ) THEN
      cnt := cnt + 1;
    END IF;

    i := i + 1;
  END LOOP;

  RETURN cnt;
END;
$$ 
SELECT shop_id, address, club_id
FROM football_club.fun_shop
WHERE club_id = 1
ORDER BY shop_id;
SELECT football_club.while_count_shops(1);

```
![01](savepoint/732.jpg)
![01](savepoint/733.jpg)
```sql


-- WHILE №2: 
CREATE OR REPLACE FUNCTION football_club.while_find_first_shop_by_address(
    p_club_id INT,
    p_address TEXT
)
RETURNS INT LANGUAGE plpgsql
 AS $$
DECLARE
  i      INT := 1;   
  max_id INT;        
BEGIN
  SELECT MAX(shop_id) INTO max_id
  FROM football_club.fun_shop;

  IF max_id = 0 THEN
    RETURN 0;  
  END IF;

  WHILE i <= max_id LOOP
    IF EXISTS (
      SELECT 1
      FROM football_club.fun_shop
      WHERE shop_id = i
        AND club_id = p_club_id
        AND address = p_address
    ) THEN
      RETURN i; 
    END IF;

    i := i + 1;
  END LOOP;

  RETURN 0;  
END;
$$ 
SELECT shop_id, address, club_id
FROM football_club.fun_shop
WHERE club_id = 1
ORDER BY shop_id;
SELECT football_club.while_find_first_shop_by_address(1, 'Main street 2');

```
![01](savepoint/734.jpg)
```sql

-- EXCEPTION №1: 
CREATE OR REPLACE FUNCTION football_club.ex_check_player_club(p_player_id INT)
RETURNS TEXT LANGUAGE plpgsql 
AS $$
DECLARE
  v_club_id INT;
BEGIN
  SELECT club_id
  INTO v_club_id
  FROM football_club.players
  WHERE player_id = p_player_id;

  IF v_club_id IS NULL THEN
    RAISE EXCEPTION 'player % has no club', p_player_id;
  END IF;

  RETURN 'ok';
END;
$$ 
SELECT player_id, club_id
FROM football_club.players
WHERE player_id = 1;

SELECT football_club.ex_check_player_club(1);

UPDATE football_club.players
SET club_id = NULL
WHERE player_id = 2;

SELECT football_club.ex_check_player_club(2);




```
![01](savepoint/736.jpg)
![01](savepoint/737.jpg)
```sql


-- EXCEPTION №2: 
CREATE OR REPLACE FUNCTION football_club.ex_get_staff_salary(p_staff_id INT)
RETURNS MONEY LANGUAGE plpgsql
AS $$
DECLARE
  v_salary MONEY;
BEGIN
  BEGIN
    SELECT salary INTO v_salary
    FROM football_club.staff
    WHERE staff_id = p_staff_id;

    IF NOT FOUND THEN           
      RAISE EXCEPTION 'staff not found';
    END IF;
  EXCEPTION
    WHEN others THEN      
      RAISE NOTICE 'error';
      RETURN NULL;
  END;

  RETURN v_salary;
END;
$$ 
SELECT staff_id, salary
FROM football_club.staff
LIMIT 3;

SELECT football_club.ex_get_staff_salary(1);
SELECT football_club.ex_get_staff_salary(9999);


```
![01](savepoint/738.jpg)
![01](savepoint/739.jpg)
```sql


-- RAISE №1: логгер по игроку
CREATE OR REPLACE FUNCTION football_club.debug_player(p_player_id INT)
RETURNS VOID LANGUAGE plpgsql
AS $$
DECLARE
  v_name TEXT;
BEGIN
  SELECT first_name INTO v_name
  FROM football_club.players
  WHERE player_id = p_player_id;

  RAISE NOTICE 'Player id=%, name=%', p_player_id, v_name; 
END;
$$ 
SELECT football_club.debug_player(1);

```

![01](savepoint/740.jpg)
![01](savepoint/741.jpg)

```sql
CREATE OR REPLACE FUNCTION football_club.debug_club(p_club_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_name  TEXT;
  v_city  INT;
BEGIN
  SELECT name, city_id
  INTO v_name, v_city
  FROM football_club.football_clubs
  WHERE club_id = p_club_id;

  RAISE NOTICE 'Club id=%, name=%, city_id=%',
               p_club_id, v_name, v_city;
END;
$$;
SELECT football_club.debug_club(1);


```
![01](savepoint/742.jpg)