

### Вариант 1: добавить игрока и обновить клуб

```sql
BEGIN;

-- 2) Добавляем игрока в этот клуб
INSERT INTO football_club.players(first_name, date_of_birth, nationality, position, market_value, club_id)
VALUES ('Johnnn', '1985-05-12', 'Russia', 'Defender', 65000000, 1);

-- 3) Обновляем клуб 
UPDATE football_club.football_clubs
SET name = 'FC Renamed 2'
WHERE club_id = 1;

COMMIT;

```
![01](requests/201.jpg)
![01](requests/202.jpg)
![01](requests/203.jpg)
![01](requests/204.jpg)



### Вариант 2: добавить товар и обновить магазин
```sql
BEGIN;

-- 2) Добавляем продукт в этот фан-шоп
INSERT INTO football_club.products(name, type, price, count, shop_id, height, width, length)
VALUES ('Scarf', 'Merch', 25, 100, 1, 10, 5, 100);

-- 3) Обновляем фан-шоп
UPDATE football_club.fun_shop
SET address = 'Main street 2'
WHERE shop_id = 1;

COMMIT;

```
![01](requests/205.jpg)
![01](requests/206.jpg)
![01](requests/207.jpg)
![01](requests/208.jpg)




### Тот же запрос, но с ROLLBACK (2 варианта)
### Вариант 1: INSERT + UPDATE игроков, потом ROLLBACK
```sql
BEGIN;

INSERT INTO football_club.players(first_name, date_of_birth, nationality, position, market_value, club_id)
VALUES ('RolledBack', '2000-01-01', 'Spain', 'Midfielder', 500000, 1);

UPDATE football_club.football_clubs
SET name = 'Name that will be rolled back'
WHERE club_id = 1;

ROLLBACK;

```
![01](requests/209.jpg)
![01](requests/210.jpg)


## Игрока с именем RolledBack не будет.​Имя клуба останется таким, каким было до транзакции.​
---


### Вариант 2: INSERT товара + UPDATE шопа, потом ROLLBACK

```sql
BEGIN;

INSERT INTO football_club.products(name, type, price, count, shop_id, height, width, length)
VALUES ('Temporary Shirt', 'Merch', 50, 50, 1, 5, 5, 70);

UPDATE football_club.fun_shop
SET address = 'Temporary address'
WHERE shop_id = 1;

ROLLBACK;

```
![01](requests/211.jpg)
![01](requests/212.jpg)


## Продукта Temporary Shirt не будет в таблице.​Адрес фан-шопа останется прежним.​




### Вариант 1: INSERT игрока + ошибка деления на 0
```sql
BEGIN;

-- 1) Пытаемся добавить игрока
INSERT INTO football_club.players(first_name, date_of_birth, nationality, position, market_value, club_id)
VALUES ('ErrorPlayer', '1999-09-09', 'Italy', 'Defender', 300000, 1);

-- 2) Искусственно создаём ошибку
SELECT 1 / 0;

-- 3) Любые дальнейшие команды будут игнорироваться до ROLLBACK
UPDATE football_club.football_clubs
SET name = 'Should not be saved'
WHERE club_id = 1;

ROLLBACK;

```

![01](requests/213.jpg)
![01](requests/214.jpg)
![01](requests/209.jpg)
![01](requests/210.jpg)

## Игрока ErrorPlayer не будет, т.к. вся транзакция откатилась из‑за ошибки деления на 0.​Имя клуба не поменяется


### Вариант 2: INSERT товара + ошибка деления на 0
```sql
BEGIN;

INSERT INTO football_club.products(name, type, price, count, shop_id, height, width, length)
VALUES ('ErrorProduct', 'Merch', 99, 10, 1, 10, 10, 10);

-- Ошибка
SELECT 10 / 0;

-- Эта команда уже не выполнится корректно, т.к. транзакция в состоянии ошибки
UPDATE football_club.fun_shop
SET address = 'Should not be saved'
WHERE shop_id = 1;

ROLLBACK;

```
![01](requests/213.jpg)
![01](requests/214.jpg)
![01](requests/215.jpg)
![01](requests/216.jpg)


## Товара ErrorProduct не будет.​Адрес фан-шопа не изменится
---


## READ UNCOMMITTED / READ COMMITTED:


### 1.1. Попытка грязного чтения (UPDATE без COMMIT в T1, чтение в T2)
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE football_club.players
SET market_value = 2000000
WHERE player_id = 3;

-- Нет COMMIT / ROLLBACK

```
## Сейчас в T1 у IsoPlayer value = 2 000 000, но изменение ещё не зафиксировано.
## T1 увидит 2 000 000, потому что транзакция видит свои незакоммиченные изменения.
### T2 (окно 2): пробуем прочитать то же (псевдо READ UNCOMMITTED)
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT player_id, first_name, market_value
FROM football_club.players
WHERE player_id = 3;

```
## В T2  старое значение, а не 2 000 000.​
## Это показывает, что грязные данные не читаются, даже если указать READ UNCOMMITTED.


![01](requests/221.jpg)
![01](requests/222.jpg)


### 1.2. То же самое, но явно READ COMMITTED в обеих сессиях

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE football_club.players
SET market_value = 3000000
WHERE player_id = 6;
-- без COMMIT


```

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT player_id, first_name, market_value
FROM football_club.players
WHERE player_id = 6;

COMMIT;


```
## T2 снова увидит старое значение (120 000 000), хотя T1 уже изменил строку, но ещё не закоммитил.



![01](requests/227.jpg)
![01](requests/228.jpg)





## 2. READ COMMITTED

### 2.1. Non-repeatable read: изменение market_value игрока
### T1 (окно 1): первый SELECT
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT player_id, first_name, market_value
FROM football_club.players
WHERE player_id = 4; 

```

### T2 (окно 2): UPDATE + COMMIT
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE football_club.players
SET market_value = 5000000
WHERE player_id = 4;

COMMIT;

```
## Изменение теперь зафиксировано.​T1: второй SELECT в той же транзакции
```sql
SELECT player_id, first_name, market_value
FROM football_club.players
WHERE player_id = 4;   -- ожидание: 5 000 000

COMMIT;

```
## Результат: первый SELECT в T1 увидел 45 000 000, второй — 5 000 000 в рамках одной и той же транзакции на уровне READ COMMITTED, что и есть неповторяющееся чтение.


![01](requests/223.jpg)
![01](requests/224.jpg)



## 2. READ COMMITTED

### 2.1. Non-repeatable read: изменение market_value игрока
### T1 (окно 1): первый SELECT
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE sponsor_id = 5;   -- 1 000 000


```

### T2 (окно 2): UPDATE + COMMIT
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE football_club.sponsors
SET amount = 2000000
WHERE sponsor_id = 5;

COMMIT;


```
## Изменение теперь зафиксировано.​T1: второй SELECT в той же транзакции
```sql
SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE sponsor_id = 5;   -- 2 000 000

COMMIT;


```


![01](requests/225.jpg)
![01](requests/226.jpg)



## REPEATABLE READ: T1 не видит изменения T2


### T1 (окно 1)
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT player_id, first_name, market_value
FROM football_club.players
WHERE first_name = 'Кевин';

```
### T2 (окно 2)
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE football_club.players
SET market_value = 5000000
WHERE first_name = 'Кевин';

COMMIT;


```


### T1 (окно 1)
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT player_id, first_name, market_value
FROM football_club.players
WHERE first_name = 'Кевин';

```

## Оба запроса в T1 дают одно и то же значение, несмотря на UPDATE в T2: классическое поведение REPEATABLE READ


![01](requests/301.jpg)


## Вариант 2: спонсор sponsors (UPDATE в T2 не виден)


### T1 (окно 1)
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE type = 'МТС';


```
### T2 (окно 2)
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE football_club.sponsors
SET amount = 3000000
WHERE type = 'МТС';

COMMIT;

```


### T1 (окно 1)
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE type = 'МТС';
```

### T1 второй раз видит те же данные, что и в первый раз, изменения T2 не попадают в его снимок.


![01](requests/302.jpg)




## REPEATABLE READ: «фантомное» чтение через INSERT в T2


### Вариант 1: продукты products (INSERT в T2, T1 не видит новый товар) T1

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT product_id, name, price
FROM football_club.products
WHERE type = 'CategoryA';

```
### T2 (окно 2)
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

INSERT INTO football_club.products(name, type, price, count, shop_id, height, width, length)
VALUES ('Scarf R3', 'CategoryA', 30, 7, 1, 15, 6, 120);

COMMIT;


```


### T1 (окно 1)
```sql
SELECT product_id, name, price
FROM football_club.products
WHERE type = 'CategoryA';

```

### Хотя в базе теперь 3 товара с CategoryA, T1 в пределах своей транзакции видит только те 2, которые были на момент первого чтения: фантомов нет


![01](requests/303.jpg)





### Вариант 2: турниры tournament (INSERT в T2, T1 не видит новый турнир)

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT tournament_id, name
FROM football_club.tournament
WHERE region = 'Europe';



```
### T2 (окно 2)
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

INSERT INTO football_club.tournament(name, region, format)
VALUES ('Repeat Cup 3', 'Europe', 'League');

COMMIT;



```


### T1 (окно 1)
```sql
SELECT tournament_id, name
FROM football_club.tournament
WHERE region = 'Europe';
-- снова только первые 2 строки, нового турнира нет



```

###T1 не видит «фантомного» турнирa, вставленного T2, хотя он уже закоммичен: поведение REPEATABLE READ без фантомов.


![01](requests/304.jpg)


### SERIALIZABLE
## T1
```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE sponsor_id = 9;


UPDATE football_club.sponsors
SET amount = amount + 200000::money
WHERE sponsor_id = 9;


```
### T2 (окно 2)
```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT sponsor_id, amount
FROM football_club.sponsors
WHERE sponsor_id = 9;


UPDATE football_club.sponsors
SET amount = amount + 300000::money
WHERE sponsor_id = 9;


```


### T1 (окно 1)
```sql
COMMIT;  -- T1: проходит успешно

```
### T2 (окно 2)
```sql
COMMIT;  -- T2: ожидаем ERROR: could not serialize access due to concurrent update

```

### T2 (окно 2)
```sql
ROLLBACK;  -- откат неуспешной транзакции

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE football_club.sponsors
SET amount = amount + 300000::money
WHERE sponsor_id = 50;
COMMIT;  -- теперь успешно

```




![01](requests/310.jpg)
![01](requests/311.jpg)
![01](requests/312.jpg)
































# изменение остаётся, вставка откатывается
```sql
--  увеличиваем capacity, но откатываем фан-шоп после проверки
BEGIN;
```
## До того как увеличили capacity
![01](savepoint/1.png)
```sql
    -- Обновляем стадион «Арена Север» и оставляем значение в транзакции
    UPDATE football_club.stadiums
    SET capacity = capacity + 500
    WHERE name = 'Арена Север';

```
## После того как увеличили capacity
![01](savepoint/2.png)
```sql
    -- Сохраняем точку перед потенциально рискованной вставкой
    SAVEPOINT sp_insert_shop;

```
## Фан шопы клуба до изменений
![01](savepoint/3.png)
```sql
    --Пробуем создать ещё один фан-шоп клуба
    INSERT INTO football_club.fun_shop (address, club_id)
    SELECT 'Москва', fc.club_id
    FROM football_club.football_clubs fc
    WHERE fc.name = 'Челси';

```
## Фан шопы клуба после изменений
![01](savepoint/4.png)
```sql
    -- Бизнес-логика не прошла, откатываемся
    ROLLBACK TO sp_insert_shop;
```
## Capacity после отката
![01](savepoint/5.png)
## фан щопы после отката
![01](savepoint/6.png)
```sql


COMMIT; -- увеличение capacity сохраняется

```
**Результат:** вместимость Арена Север выросла, запись о магазине откатили .

##две точки сохранения и поэтапный откат
```sql
   --две точки сохранения и поэтапный откат
BEGIN;
```
## До всех изменений
![01](savepoint/01.png)
```sql

    --  фиксируем первую точку
    SAVEPOINT sp_before_1;

    --  Увеличиваем Нева Парк
    UPDATE football_club.stadiums
    SET capacity = capacity + 100
    WHERE name = 'Нева Парк';

```
## После увелечения первого
![01](savepoint/03.png)
```sql
    --  фиксируем вторую точку
    SAVEPOINT sp_before_2;

    --  Увеличиваем Сантьяго Виста
    UPDATE football_club.stadiums
    SET capacity = capacity + 200
    WHERE name = 'Сантьяго Виста';
```
## После увелечения второго
![01](savepoint/04.png)
```sql
    -- Откатываемся к sp_before_2 
    ROLLBACK TO sp_before_2;

```
## После отката второго
![01](savepoint/05.png)
```sql
    --  Откатываемся к sp_before_1 
    ROLLBACK TO sp_before_1; 
```
## После отката первого
![01](savepoint/06.png)
```sql
COMMIT; -- финально изменений нет

```
# Если первым rollback вызвать sp_before_1, то никаких изменений не будет, но если после него еще вызвать sp_before_2 выйдет ошибка
![01](savepoint/02.png)
**Результат:** оба изменения отменены
