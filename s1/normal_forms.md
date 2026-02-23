# Проблема с городами (3 нф)

## Аномалии:

### Дублирование: один и тот же город повторяется для разных клубов.

### Удаление: если удалить клуб, то теряется информация о городе.

## Решение:
```sql 
CREATE TABLE football_club.cities (
    city_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);
```
# Таблица stuff (3 нф)

## Аномалии удаления, вставки, обновления

### Нельзя было добавить новую должность, пока не наняли сотрудника

## Решение:
```sql
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
```
# Проблема с контрактом у игрока(Бойса-Кодда)

## Аномалии:

### В contracts было club_id, дублирующее данные о клубе игрока, что создавало транзитивную зависимость

## Решение: Переносим club_id в таблицу players, а в contracts оставляем только ссылку на player_id.

