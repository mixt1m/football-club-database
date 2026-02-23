### 1. Игроки и средняя зарплата по лиге
```sql
SELECT first_name, salary, 
       (SELECT AVG(salary) FROM football_club.contracts) as avg_league_salary
FROM football_club.players p
JOIN football_club.contracts c ON p.player_id = c.player_id;
```
![01](requests/101.jpg)

### 2. Клубы и количество их игроков
```sql
SELECT name, 
       (SELECT COUNT(*) FROM football_club.players WHERE club_id = fc.club_id) as player_count
FROM football_club.football_clubs fc;
```
![01](requests/102.jpg)
### 3. Продукты и максимальная цена в их магазине
```sql
SELECT name, price,
       (SELECT MAX(price) FROM football_club.products WHERE shop_id = p.shop_id) as max_shop_price
FROM football_club.products p;
```
![01](requests/103.jpg)
---

## Подзапросы в FROM

### 1. Средняя зарплата по клубам
```sql
SELECT club_name, avg_salary
FROM (SELECT fc.name as club_name, AVG(c.salary) as avg_salary
      FROM football_club.football_clubs fc
      JOIN football_club.players p ON fc.club_id = p.club_id
      JOIN football_club.contracts c ON p.player_id = c.player_id
      GROUP BY fc.name) as club_salaries;
```
![01](requests/104.jpg)
### 2. Игроки дороже 30 млн
```sql
SELECT first_name, market_value
FROM (SELECT first_name, market_value 
      FROM football_club.players 
      WHERE market_value::numeric > 30000000) as expensive_players;
```
![01](requests/105.jpg)
### 3. Стадионы большой вместимости
```sql
SELECT name, capacity
FROM (SELECT name, capacity 
      FROM football_club.stadiums 
      WHERE capacity > 50000) as big_stadiums;
```
![01](requests/106.jpg)
---

## Подзапросы в WHERE

### 1. Игроки с зарплатой выше средней
```sql
SELECT first_name, salary
FROM football_club.players p
JOIN football_club.contracts c ON p.player_id = c.player_id
WHERE c.salary > (SELECT AVG(salary) FROM football_club.contracts);
```
![01](requests/107.jpg)
### 2. Продукты дороже среднего
```sql
SELECT name, price
FROM football_club.products
WHERE price::numeric > (SELECT AVG(price::numeric) FROM football_club.products);
```
![01](requests/108.jpg)
### 3. Стадионы больше среднего
```sql
SELECT name, capacity
FROM football_club.stadiums
WHERE capacity > (SELECT AVG(capacity) FROM football_club.stadiums);
```
![01](requests/109.jpg)
---

## Подзапросы с HAVING

### 1. Клубы с зарплатой выше средней по лиге
```sql
SELECT fc.name, AVG(c.salary) as avg_salary
FROM football_club.football_clubs fc
JOIN football_club.players p ON fc.club_id = p.club_id
JOIN football_club.contracts c ON p.player_id = c.player_id
GROUP BY fc.name
HAVING AVG(c.salary) > (SELECT AVG(salary) FROM football_club.contracts);
```
![01](requests/110.jpg)
### 2. Позиции с зарплатой выше средней
```sql
SELECT position, AVG(c.salary) as avg_salary
FROM football_club.players p
JOIN football_club.contracts c ON p.player_id = c.player_id
GROUP BY position
HAVING AVG(c.salary) > (SELECT AVG(salary) FROM football_club.contracts);
```
![01](requests/111.jpg)
### 3. Магазины с количеством товаров больше среднего
```sql
SELECT shop_id, COUNT(*) as product_count
FROM football_club.products
GROUP BY shop_id
HAVING COUNT(*) > (SELECT AVG(product_count) 
                   FROM (SELECT COUNT(*) as product_count 
                         FROM football_club.products 
                         GROUP BY shop_id) as counts);
```
![01](requests/112.jpg)
---

## Подзапросы с ALL

### 1. Игроки с самой высокой зарплатой
```sql
SELECT first_name, salary
FROM football_club.players p
JOIN football_club.contracts c ON p.player_id = c.player_id
WHERE c.salary >= ALL (SELECT salary FROM football_club.contracts);
```
![01](requests/113.jpg)
### 2. Самые дорогие продукты
```sql
SELECT name, price
FROM football_club.products
WHERE price >= ALL (SELECT price FROM football_club.products);
```
![01](requests/114.jpg)
### 3. Самые вместительные стадионы
```sql
SELECT name, capacity
FROM football_club.stadiums
WHERE capacity >= ALL (SELECT capacity FROM football_club.stadiums);
```
![01](requests/115.jpg)
---

## Подзапросы с IN

### 1. Игроки из английских клубов
```sql
SELECT first_name, position
FROM football_club.players
WHERE club_id IN (SELECT club_id 
                  FROM football_club.football_clubs fc
                  JOIN football_club.cities c ON fc.city_id = c.city_id
                  WHERE c.country = 'Англия');
```
![01](requests/116.jpg)
### 2. Продукты из магазинов Челси
```sql
SELECT name, price
FROM football_club.products
WHERE shop_id IN (SELECT shop_id 
                  FROM football_club.fun_shop 
                  WHERE club_id = 1);
```
![01](requests/117.jpg)
### 3. Сотрудники тренерского штаба
```sql
SELECT first_name, salary
FROM football_club.staff
WHERE position_id IN (SELECT position_id 
                      FROM football_club.positions 
                      WHERE department_id = 5);
```
![01](requests/118.jpg)
---

## Подзапросы с ANY

### 1. Игроки с зарплатой больше любой в России
```sql
SELECT first_name, salary
FROM football_club.players p
JOIN football_club.contracts c ON p.player_id = c.player_id
WHERE c.salary > ANY (SELECT c2.salary
                      FROM football_club.contracts c2
                      JOIN football_club.players p2 ON c2.player_id = p2.player_id
                      WHERE p2.nationality = 'Русский');
```
![01](requests/119.jpg)
### 2. Продукты дороже любого шарфа
```sql
SELECT name, price
FROM football_club.products
WHERE price > ANY (SELECT price 
                   FROM football_club.products 
                   WHERE type = 'Аксессуар');
```
![01](requests/120.jpg)
### 3. Стадионы больше любого в России
```sql
SELECT name, capacity
FROM football_club.stadiums
WHERE capacity > ANY (SELECT s.capacity
                      FROM football_club.stadiums s
                      JOIN football_club.football_clubs fc ON s.stadium_id = fc.stadium_id
                      JOIN football_club.cities c ON fc.city_id = c.city_id
                      WHERE c.country = 'Россия');
```
![01](requests/121.jpg)
---

## Подзапросы с EXISTS

### 1. Клубы у которых есть спонсоры
```sql
SELECT name
FROM football_club.football_clubs fc
WHERE EXISTS (SELECT 1 
              FROM football_club.sponsors s 
              WHERE s.club_id = fc.club_id);
```
![01](requests/122.jpg)
### 2. Игроки с контрактами
```sql
SELECT first_name
FROM football_club.players p
WHERE EXISTS (SELECT 1 
              FROM football_club.contracts c 
              WHERE c.player_id = p.player_id);
```
![01](requests/123.jpg)
### 3. Магазины с товарами
```sql
SELECT address
FROM football_club.fun_shop fs
WHERE EXISTS (SELECT 1 
              FROM football_club.products p 
              WHERE p.shop_id = fs.shop_id);
```
![01](requests/124.jpg)
---

## Сравнение по нескольким столбцам

### 1. Игроки с такой же позицией и национальностью
```sql
SELECT first_name, position, nationality
FROM football_club.players p1
WHERE (position, nationality) IN (SELECT position, nationality 
                                  FROM football_club.players p2 
                                  WHERE p2.player_id = 1);
```
![01](requests/125.jpg)
### 2. Продукты того же типа и цены
```sql
SELECT name, type, price
FROM football_club.products pr1
WHERE (type, price) IN (SELECT type, price 
                        FROM football_club.products pr2 
                        WHERE pr2.product_id = 1);
```
![01](requests/126.jpg)
### 3. Сотрудники с той же должностью и зарплатой
```sql
SELECT first_name, salary
FROM football_club.staff s1
WHERE (position_id, salary) IN (SELECT position_id, salary 
                                FROM football_club.staff s2 
                                WHERE s2.staff_id = 1);
```
![01](requests/127.jpg)
---

## Коррелированные подзапросы

### 1. Игроки с зарплатой выше средней в их клубе
```sql
SELECT first_name, salary
FROM football_club.players p
JOIN football_club.contracts c ON p.player_id = c.player_id
WHERE c.salary > (SELECT AVG(c2.salary)
                  FROM football_club.contracts c2
                  JOIN football_club.players p2 ON c2.player_id = p2.player_id
                  WHERE p2.club_id = p.club_id);
```
![01](requests/128.jpg)
### 2. Продукты дороже среднего в их магазине
```sql
SELECT name, price
FROM football_club.products pr1
WHERE pr1.price::numeric > (SELECT AVG(pr2.price::numeric)
                            FROM football_club.products pr2
                            WHERE pr2.shop_id = pr1.shop_id);
```
![01](requests/129.jpg)
### 3. Сотрудники с зарплатой выше средней по их должности
```sql
SELECT first_name, salary
FROM football_club.staff s1
WHERE s1.salary::numeric > (SELECT AVG(s2.salary::numeric)
                            FROM football_club.staff s2
                            WHERE s2.position_id = s1.position_id);
```
![01](requests/130.jpg)
### 4. Игроки старше среднего возраста в их позиции
```sql
SELECT first_name, date_of_birth
FROM football_club.players p1
WHERE EXTRACT(YEAR FROM AGE(date_of_birth)) > 
      (SELECT AVG(EXTRACT(YEAR FROM AGE(p2.date_of_birth)))
       FROM football_club.players p2
       WHERE p2.position = p1.position);
```
![01](requests/131.jpg)
### 5. Спонсоры с суммой больше средней в их клубе
```sql
SELECT type, amount
FROM football_club.sponsors s1
WHERE s1.amount::numeric > (SELECT AVG(s2.amount::numeric)
                            FROM football_club.sponsors s2
                            WHERE s2.club_id = s1.club_id);
```
![01](requests/132.jpg)