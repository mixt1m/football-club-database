import psycopg2
from psycopg2.extras import execute_values
import random
from datetime import datetime, timedelta
import numpy as np
from faker import Faker
import json
from collections import defaultdict

fake = Faker(['en_US', 'ru_RU', 'uk_UA'])  # Поддерживаем несколько локалей

# Подключение к базе данных
conn = psycopg2.connect(
    dbname="football_club",
    user="app",
    password="secretpass",
    port="5433",
    host="localhost"
)
cur = conn.cursor()

# Словарь для хранения сгенерированных ID
ids = defaultdict(list)


def generate_zipf_distribution(n, alpha=1.5, size=None):
    """Генерация Zipf-подобного распределения"""
    if size is None:
        size = n
    # Используем распределение Ципфа для создания перекоса
    ranks = np.arange(1, n + 1)
    weights = ranks ** (-alpha)
    weights /= weights.sum()
    return np.random.choice(n, size=size, p=weights)


def generate_cities(n=100):
    """Генерация городов (низкая кардинальность)"""
    cities = []
    countries = ['Ukraine', 'Poland', 'Germany', 'Spain', 'Italy', 'France', 'England']

    for i in range(n):
        name = fake.city()
        country = random.choice(countries)
        cities.append((name, country))

    insert_query = """
        INSERT INTO football_club.cities (name, country) 
        VALUES %s RETURNING city_id;
    """

    ids['cities'] = []
    for city in cities:
        cur.execute(insert_query.replace('%s', '(%s, %s)'), city)
        ids['cities'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['cities'])} cities")


def generate_stadiums(n=100):
    """Генерация стадионов"""
    stadiums = []
    for i in range(n):
        name = f"{fake.company()} Stadium"
        capacity = random.choice([5000, 10000, 15000, 20000, 30000, 50000])
        address = fake.address()
        stadiums.append((name, capacity, address))

    insert_query = """
        INSERT INTO football_club.stadiums (name, capacity, address) 
        VALUES %s RETURNING staduim_id;
    """

    ids['stadiums'] = []
    for stadium in stadiums:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s)'), stadium)
        ids['stadiums'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['stadiums'])} stadiums")


def generate_owners(n=50):
    """Генерация владельцев (меньше чем клубов - некоторые владеют несколькими)"""
    owners = []
    for i in range(n):
        name = fake.name()
        nationality = random.choice(['Ukrainian', 'British', 'American', 'Russian', 'German', 'French', 'Spanish'])
        purchase_date = fake.date_between(start_date='-20y', end_date='today')
        owners.append((name, nationality, purchase_date))

    insert_query = """
        INSERT INTO football_club.owners (name, nationality, purchase_date) 
        VALUES %s RETURNING owner_id;
    """

    ids['owners'] = []
    for owner in owners:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s)'), owner)
        ids['owners'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['owners'])} owners")


def generate_football_clubs(n=100):
    """Генерация футбольных клубов"""
    clubs = []
    for i in range(n):
        name = fake.company() + " FC"
        country = random.choice(['Ukraine', 'Poland', 'Germany', 'Spain'])
        city = fake.city()
        owner_id = random.choice(ids['owners'])
        stadium_id = random.choice(ids['stadiums'])
        city_id = random.choice(ids['cities'])
        clubs.append((name, country, city, owner_id, stadium_id, city_id))

    insert_query = """
        INSERT INTO football_club.football_clubs 
        (name, country, city, owner_id, staduim_id, city_id) 
        VALUES %s RETURNING club_id;
    """

    ids['football_clubs'] = []
    for club in clubs:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s, %s, %s, %s)'), club)
        ids['football_clubs'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['football_clubs'])} football clubs")


def generate_league(n=10):
    """Генерация лиг (низкая кардинальность)"""
    leagues = []
    leagues_data = [
        ('Premier League', 'England', 1),
        ('La Liga', 'Spain', 1),
        ('Bundesliga', 'Germany', 1),
        ('Serie A', 'Italy', 1),
        ('Ligue 1', 'France', 1),
        ('Ukrainian Premier League', 'Ukraine', 1),
        ('Championship', 'England', 2),
        ('Segunda Division', 'Spain', 2),
        ('2. Bundesliga', 'Germany', 2),
    ]

    for name, country, tier in leagues_data[:n]:
        leagues.append((name, country, tier))

    insert_query = """
        INSERT INTO football_club.league (name, country, tier) 
        VALUES %s RETURNING liague_id;
    """

    ids['league'] = []
    for league in leagues:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s)'), league)
        ids['league'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['league'])} leagues")


def generate_tournament(n=20):
    """Генерация турниров"""
    tournaments = []
    tournament_data = [
        ('Champions League', 'Europe', 'group+playoff'),
        ('Europa League', 'Europe', 'group+playoff'),
        ('Conference League', 'Europe', 'group+playoff'),
        ('National Cup', 'National', 'playoff'),
        ('Super Cup', 'National', 'single match'),
    ]

    for name, region, format_ in tournament_data:
        tournaments.append((name, region, format_))

    for i in range(n - len(tournaments)):
        name = f"{fake.word().capitalize()} Cup"
        region = random.choice(['Europe', 'Asia', 'Africa', 'America', 'National'])
        format_ = random.choice(['group', 'playoff', 'group+playoff', 'single match'])
        tournaments.append((name, region, format_))

    insert_query = """
        INSERT INTO football_club.tournament (name, region, format) 
        VALUES %s RETURNING tournament_id;
    """

    ids['tournament'] = []
    for tournament in tournaments:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s)'), tournament)
        ids['tournament'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['tournament'])} tournaments")


def generate_departments():
    """Генерация департаментов (фиксированный набор)"""
    departments = [
        ('Coaching Staff',),
        ('Medical Department',),
        ('Scouting Department',),
        ('Administration',),
        ('Marketing',),
        ('Youth Academy',),
        ('Analytics Department',),
        ('Physical Training',),
    ]

    insert_query = """
        INSERT INTO football_club.departments (name) 
        VALUES %s RETURNING department_id;
    """

    ids['departments'] = []
    for dept in departments:
        cur.execute(insert_query.replace('%s', '(%s)'), dept)
        ids['departments'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['departments'])} departments")


def generate_positions():
    """Генерация позиций сотрудников"""
    positions_data = [
        (ids['departments'][0], 'Head Coach', 50000),
        (ids['departments'][0], 'Assistant Coach', 30000),
        (ids['departments'][1], 'Team Doctor', 40000),
        (ids['departments'][1], 'Physiotherapist', 25000),
        (ids['departments'][2], 'Chief Scout', 35000),
        (ids['departments'][2], 'Regional Scout', 20000),
        (ids['departments'][3], 'General Manager', 45000),
        (ids['departments'][3], 'Secretary', 15000),
        (ids['departments'][4], 'Marketing Director', 40000),
        (ids['departments'][4], 'Social Media Manager', 20000),
    ]

    positions = []
    for dept_id, title, salary in positions_data:
        positions.append((dept_id, title, salary))

    insert_query = """
        INSERT INTO football_club.positions (department_id, title, base_salary) 
        VALUES %s RETURNING position_id;
    """

    ids['positions'] = []
    for position in positions:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s::money)'), position)
        ids['positions'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['positions'])} positions")


def generate_staff(n=100):
    """Генерация персонала"""
    staff_list = []
    positions = ids['positions']
    clubs = ids['football_clubs']

    # Низкая кардинальность для позиций (некоторые позиции встречаются чаще)
    position_weights = generate_zipf_distribution(len(positions), size=n)

    for i in range(n):
        first_name = fake.first_name()
        date_of_birth = fake.date_of_birth(minimum_age=20, maximum_age=70)
        salary = random.randint(1000, 50000)
        position_id = positions[position_weights[i] % len(positions)]
        club_id = random.choice(clubs) if random.random() > 0.1 else None  # 10% NULL
        staff_list.append((first_name, date_of_birth, salary, position_id, club_id))

    insert_query = """
        INSERT INTO football_club.staff 
        (first_name, date_of_birth, salary, position_id, club_id) 
        VALUES %s RETURNING staff_id;
    """

    ids['staff'] = []
    for staff in staff_list:
        cur.execute(insert_query.replace('%s', '(%s, %s, %s::money, %s, %s)'), staff)
        ids['staff'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['staff'])} staff members")


def generate_players(n=250000):  # Для 250k записей
    """Генерация игроков с различными распределениями"""
    players = []
    positions = ['Goalkeeper', 'Right Back', 'Left Back', 'Center Back',
                 'Defensive Midfielder', 'Central Midfielder', 'Attacking Midfielder',
                 'Right Winger', 'Left Winger', 'Striker']

    clubs = ids['football_clubs']

    # Сильно неравномерное распределение клубов (70% игроков в 10% клубов)
    top_clubs = clubs[:len(clubs) // 10]  # 10% топ клубов
    other_clubs = clubs[len(clubs) // 10:]

    # Zipf распределение для позиций
    position_indices = generate_zipf_distribution(len(positions), alpha=1.2, size=n)

    # Zipf распределение для клубов (перекос)
    club_weights = []
    if random.random() < 0.7:  # 70% игроков
        club_weights = [random.choice(top_clubs) for _ in range(int(n * 0.7))]
    else:
        club_weights = [random.choice(other_clubs) for _ in range(int(n * 0.3))]

    # Добиваем до n
    while len(club_weights) < n:
        club_weights.append(random.choice(other_clubs))
    random.shuffle(club_weights)

    # Высокая кардинальность для имен
    # Диапазонные значения для возраста
    # NULL для некоторых полей (5-20%)

    for i in range(n):
        first_name = fake.first_name()
        date_of_birth = fake.date_of_birth(minimum_age=16, maximum_age=40)
        nationality = random.choice(['Ukrainian', 'Brazilian', 'Argentine', 'Spanish',
                                     'German', 'French', 'Italian', 'English'])

        # NULL для позиции (10%)
        position = positions[position_indices[i]] if random.random() > 0.1 else None

        # Рыночная стоимость с Zipf распределением
        market_value_base = int(np.random.zipf(1.5)) * 100000
        market_value = min(market_value_base, 100000000)  # Ограничиваем 100M

        club_id = club_weights[i] if random.random() > 0.05 else None  # 5% NULL

        players.append((first_name, date_of_birth, nationality, position,
                        market_value, club_id))

    # Вставка батчами для производительности
    batch_size = 10000
    ids['players'] = []

    for i in range(0, len(players), batch_size):
        batch = players[i:i + batch_size]
        values = []
        for p in batch:
            if p[4] is not None:
                values.append((p[0], p[1], p[2], p[3], f"{p[4]}", p[5]))
            else:
                values.append((p[0], p[1], p[2], p[3], None, p[5]))

        insert_query = """
            INSERT INTO football_club.players 
            (first_name, date_of_birth, nationality, position, market_value, club_id) 
            VALUES %s RETURNING player_id;
        """

        # Используем execute_values для батч-вставки
        with conn.cursor() as batch_cur:
            execute_values(
                batch_cur,
                "INSERT INTO football_club.players (first_name, date_of_birth, nationality, position, market_value, club_id) VALUES %s RETURNING player_id",
                [tuple(x) for x in values],
                page_size=batch_size
            )
            for row in batch_cur.fetchall():
                ids['players'].append(row[0])

        print(f"Generated {len(ids['players'])} players so far...")

    print(f"Total generated {len(ids['players'])} players")


def generate_contracts(n=250000):  # Контракты для игроков
    """Генерация контрактов"""
    contracts = []
    players = ids['players']

    # Разные сроки контрактов
    for i, player_id in enumerate(players):
        start_date = fake.date_between(start_date='-5y', end_date='today')
        end_date = start_date + timedelta(days=random.choice([365, 730, 1095, 1460, 1825]))
        # Зарплата с перекосом
        salary_base = int(np.random.zipf(1.5)) * 10000
        salary = min(salary_base, 500000)
        contracts.append((player_id, start_date, end_date, salary))

    batch_size = 10000
    for i in range(0, len(contracts), batch_size):
        batch = contracts[i:i + batch_size]
        values = [(p_id, s_date, e_date, f"{salary}") for p_id, s_date, e_date, salary in batch]

        with conn.cursor() as batch_cur:
            execute_values(
                batch_cur,
                "INSERT INTO football_club.contracts (player_id, start_date, end_date, salary) VALUES %s",
                [tuple(x) for x in values],
                page_size=batch_size
            )

        print(f"Generated {min(i + batch_size, len(contracts))} contracts...")


def generate_participation(n=300000):
    """Генерация участия в турнирах"""
    participations = []
    clubs = ids['football_clubs']
    tournaments = ids['tournament']
    leagues = ids['league']

    seasons = [f"{year}/{year + 1}" for year in range(2015, 2024)]

    # Zipf распределение для позиций в турнире
    for i in range(n):
        club_id = random.choice(clubs)
        # 70% участия в лигах, 30% в турнирах
        if random.random() < 0.7:
            tournament_id = None
            liague_id = random.choice(leagues)
        else:
            tournament_id = random.choice(tournaments)
            liague_id = None

        season = random.choice(seasons)
        # Позиция с перекосом (больше команд в середине таблицы)
        final_position = int(np.random.normal(10, 5))
        final_position = max(1, min(20, final_position))  # Ограничиваем

        participations.append((club_id, tournament_id, liague_id, season, final_position))

    batch_size = 10000
    for i in range(0, len(participations), batch_size):
        batch = participations[i:i + batch_size]

        with conn.cursor() as batch_cur:
            execute_values(
                batch_cur,
                "INSERT INTO football_club.participation (club_id, tournament_id, liague_id, season, final_position) VALUES %s",
                [tuple(x) for x in batch],
                page_size=batch_size
            )

        print(f"Generated {min(i + batch_size, len(participations))} participations...")


def generate_fun_shops(n=50):
    """Генерация магазинов"""
    shops = []
    clubs = ids['football_clubs']

    # Не у всех клубов есть магазины
    clubs_with_shops = random.sample(clubs, min(n, len(clubs)))

    for club_id in clubs_with_shops:
        address = fake.address()
        shops.append((address, club_id))

    insert_query = """
        INSERT INTO football_club.fun_shop (address, club_id) 
        VALUES %s RETURNING shop_id;
    """

    ids['fun_shop'] = []
    for shop in shops:
        cur.execute(insert_query.replace('%s', '(%s, %s)'), shop)
        ids['fun_shop'].append(cur.fetchone()[0])

    print(f"Generated {len(ids['fun_shop'])} fun shops")


def generate_products(n=1000):
    """Генерация товаров с JSONB и массивами"""
    products = []
    shops = ids['fun_shop']

    product_types = ['Jersey', 'Scarf', 'Cap', 'Mug', 'Poster', 'Keychain',
                     'Jacket', 'T-shirt', 'Souvenir', 'Flag']

    # Размеры для разных товаров
    sizes = ['S', 'M', 'L', 'XL', 'XXL']

    for i in range(n):
        name = fake.word().capitalize() + " " + random.choice(product_types)
        product_type = random.choice(product_types)
        price = random.randint(10, 200)

        # Перекос в количестве (некоторые товары очень популярны)
        if random.random() < 0.3:  # Популярные товары
            count = random.randint(100, 1000)
        else:
            count = random.randint(1, 100)

        shop_id = random.choice(shops) if random.random() > 0.1 else None

        # Геометрические размеры
        height = random.randint(10, 100) if product_type in ['Poster', 'Flag'] else random.randint(5, 30)
        width = random.randint(10, 100) if product_type in ['Poster', 'Flag'] else random.randint(5, 30)
        length = random.randint(1, 10) if product_type in ['Keychain', 'Mug'] else random.randint(10, 50)

        # JSONB с дополнительной информацией
        attributes = json.dumps({
            'color': fake.color_name(),
            'material': random.choice(['Cotton', 'Polyester', 'Wool', 'Plastic', 'Ceramic']),
            'sizes_available': random.sample(sizes, random.randint(1, len(sizes))) if random.random() > 0.5 else [],
            'is_limited': random.choice([True, False]),
            'season': random.choice(['Summer', 'Winter', 'All Season']),
            'tags': fake.words(nb=random.randint(1, 5))
        })

        # Полнотекстовые данные в названии и описании
        # Используем JSONB поле для хранения дополнительной информации

        products.append((name, product_type, price, count, shop_id,
                         height, width, length, attributes))

    batch_size = 100
    for i in range(0, len(products), batch_size):
        batch = products[i:i + batch_size]
        values = [(name, ptype, f"{price}", cnt, shop, h, w, l, attr)
                  for name, ptype, price, cnt, shop, h, w, l, attr in batch]

        with conn.cursor() as batch_cur:
            execute_values(
                batch_cur,
                "INSERT INTO football_club.products (name, type, price, count, shop_id, height, width, length, attributes) VALUES %s",
                [tuple(x) for x in values],
                page_size=batch_size
            )

        print(f"Generated {min(i + batch_size, len(products))} products...")


def generate_sponsors(n=200):
    """Генерация спонсоров"""
    sponsors = []
    clubs = ids['football_clubs']

    sponsor_types = ['Main Sponsor', 'Technical Sponsor', 'Official Partner',
                     'Broadcasting Partner', 'Commercial Partner']

    # Перекос: у топ-клубов больше спонсоров
    for i in range(n):
        if random.random() < 0.4:  # 40% спонсоров уходят топ-клубам
            club_id = random.choice(clubs[:len(clubs) // 5])
        else:
            club_id = random.choice(clubs)

        start_date = fake.date_between(start_date='-5y', end_date='today')
        end_date = start_date + timedelta(days=random.choice([365, 730]))
        amount = random.randint(100000, 10000000)
        sponsor_type = random.choice(sponsor_types)

        sponsors.append((club_id, start_date, end_date, amount, sponsor_type))

    batch_size = 100
    for i in range(0, len(sponsors), batch_size):
        batch = sponsors[i:i + batch_size]
        values = [(club, s_date, e_date, f"{amount}", stype)
                  for club, s_date, e_date, amount, stype in batch]

        with conn.cursor() as batch_cur:
            execute_values(
                batch_cur,
                "INSERT INTO football_club.sponsors (club_id, start_date, end_date, amount, type) VALUES %s",
                [tuple(x) for x in values],
                page_size=batch_size
            )

        print(f"Generated {min(i + batch_size, len(sponsors))} sponsors...")


def main():
    """Основная функция"""
    try:
        # Сначала генерируем небольшие таблицы
        generate_cities(50)  # Города
        generate_stadiums(30)  # Стадионы
        generate_owners(25)  # Владельцы

        generate_football_clubs(30)  # Клубы

        generate_league(10)  # Лиги
        generate_tournament(15)  # Турниры

        generate_departments()  # Департаменты
        generate_positions()  # Позиции

        generate_staff(200)  # Персонал

        generate_fun_shops(20)  # Магазины

        generate_products(1000)  # Товары

        generate_sponsors(150)  # Спонсоры

        # Большие таблицы
        print("\n=== Генерация больших таблиц ===")
        generate_players(300000)  # 300k игроков
        conn.commit()

        generate_contracts(300000)  # Контракты для игроков
        conn.commit()

        generate_participation(400000)  # 400k записей участия
        conn.commit()

        print("\nВсе данные успешно сгенерированы!")

    except Exception as e:
        conn.rollback()
        print(f"Ошибка: {e}")
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()