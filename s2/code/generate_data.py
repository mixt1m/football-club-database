import psycopg2
from psycopg2.extras import execute_values
import random
from datetime import datetime, timedelta
import numpy as np
from faker import Faker
import json
import os

# Инициализация Faker
fake = Faker(['en_US', 'en_GB', 'de_DE', 'fr_FR', 'es_ES'])
Faker.seed(42)
random.seed(42)
np.random.seed(42)

# Параметры подключения к БД
DB_PARAMS = {
    'dbname': 'football_club',
    'user': 'app',
    'password': 'secretpass',
    'host': 'localhost',
    'port': '5433'
}

# Увеличенные объемы данных
TABLE_SIZES = {
    'cities': 5000,
    'owners': 3000,
    'stadiums': 3000,
    'league': 200,
    'tournament': 150,
    'departments': 30,
    'positions': 500,
    'football_clubs': 5000,
    'fun_shop': 15000,
    'players': 2_000_000,
    'staff': 800_000,
    'contracts': 1_800_000,
    'sponsors': 400_000,
    'participation': 700_000,
    'products': 2_500_000,
}

total = sum(TABLE_SIZES.values())
print(f"Total records to generate: {total:,}")

# ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ==========

def to_python_type(value):
    """Преобразование numpy типов в стандартные Python типы"""
    if value is None:
        return None
    elif isinstance(value, (np.integer, np.int64, np.int32)):
        return int(value)
    elif isinstance(value, (np.floating, np.float64, np.float32)):
        return float(value)
    elif isinstance(value, np.ndarray):
        return value.tolist()
    elif isinstance(value, np.bool_):
        return bool(value)
    elif isinstance(value, datetime):
        return value
    elif isinstance(value, date):
        return value
    else:
        return value

def normalize_weights(weights):
    """Нормализация весов, чтобы их сумма была равна 1"""
    weights = np.array(weights, dtype=float)
    total = weights.sum()
    if total == 0 or np.isnan(total) or np.isinf(total):
        return np.ones(len(weights)) / len(weights)
    return weights / total

def safe_choice(population, size=1, weights=None, replace=True):
    """Безопасный выбор с проверкой размеров"""
    if not population:
        return None
    
    if size == 0:
        return []
    
    if weights is not None:
        weights = normalize_weights(weights)
    
    if not replace and size > len(population):
        replace = True
    
    try:
        result = np.random.choice(population, size=size, p=weights, replace=replace)
        # Преобразуем результат в стандартный Python тип
        if size == 1:
            return to_python_type(result)
        else:
            return [to_python_type(x) for x in result]
    except:
        # В случае ошибки возвращаем случайный выбор с равномерным распределением
        if size == 1:
            return to_python_type(random.choice(population))
        else:
            return [to_python_type(random.choice(population)) for _ in range(size)]

def power_law_distribution(min_val, max_val, size, alpha=2.5):
    """Степенной закон с безопасной обработкой"""
    if size == 0:
        return []
    try:
        u = np.random.random(size)
        result = min_val * (1 - u) ** (-1/(alpha-1))
        result = np.clip(result, min_val, max_val)
        # Преобразуем в список стандартных типов
        return [to_python_type(x) for x in result]
    except:
        # В случае ошибки возвращаем равномерное распределение
        return [to_python_type(random.uniform(min_val, max_val)) for _ in range(size)]

# ========== ФУНКЦИИ ГЕНЕРАЦИИ ==========

def generate_cities(n):
    """Генерация городов"""
    cities = []
    countries = ['USA', 'UK', 'Germany', 'France', 'Spain', 'Italy', 'Brazil', 
                 'Argentina', 'Japan', 'China', 'Russia', 'Netherlands', 'Portugal']
    
    for i in range(n):
        city = {
            'name': fake.city(),
            'country': random.choice(countries)
        }
        cities.append(city)
    
    return cities

def generate_owners(n):
    """Генерация владельцев"""
    owners = []
    nationalities = ['USA', 'UK', 'Russia', 'China', 'Saudi Arabia', 'UAE', 'Qatar']
    
    for i in range(n):
        owner = {
            'name': fake.name(),
            'nationality': random.choice(nationalities),
            'purchase_date': fake.date_between(start_date='-30y', end_date='today')
        }
        owners.append(owner)
    
    return owners

def generate_stadiums(n):
    """Генерация стадионов"""
    stadiums = []
    capacities = power_law_distribution(5000, 120000, n)
    
    for i in range(n):
        stadium = {
            'name': f"{fake.company()} {random.choice(['Stadium', 'Arena', 'Park'])}",
            'capacity': int(capacities[i]) if i < len(capacities) else 30000,
            'address': fake.address().replace('\n', ', ').replace('\r', '')
        }
        stadiums.append(stadium)
    
    return stadiums

def generate_league(n):
    """Генерация лиг"""
    leagues = []
    countries = ['England', 'Spain', 'Germany', 'Italy', 'France']
    league_names = ['Premier League', 'La Liga', 'Bundesliga', 'Serie A', 'Ligue 1']
    
    for i in range(n):
        league = {
            'name': league_names[i % len(league_names)],
            'country': countries[i % len(countries)],
            'tier': (i % 3) + 1
        }
        leagues.append(league)
    
    return leagues

def generate_tournament(n):
    """Генерация турниров"""
    tournaments = []
    regions = ['Europe', 'South America', 'World', 'Domestic']
    formats = ['Group + Knockout', 'Knockout', 'Round Robin']
    tournament_names = [
        'Champions League', 'Europa League', 'World Cup', 
        'FA Cup', 'Copa del Rey', 'Copa Libertadores'
    ]
    
    for i in range(n):
        tournament = {
            'name': tournament_names[i % len(tournament_names)],
            'region': regions[i % len(regions)],
            'format': formats[i % len(formats)]
        }
        tournaments.append(tournament)
    
    return tournaments

def generate_departments(n):
    """Генерация департаментов"""
    department_names = [
        'Coaching Staff', 'Medical', 'Scouting', 'Youth Academy',
        'Marketing', 'Finance', 'Operations', 'Legal', 'Media'
    ]
    departments = [{'name': name} for name in department_names[:min(n, len(department_names))]]
    return departments

def generate_positions(n, departments):
    """Генерация позиций"""
    positions = []
    if not departments:
        return positions
        
    dept_ids = list(range(1, len(departments) + 1))
    salaries = power_law_distribution(25000, 300000, n)
    
    for i in range(n):
        position = {
            'department_id': random.choice(dept_ids),
            'title': fake.job(),
            'base_salary': float(salaries[i]) if i < len(salaries) else 50000.0
        }
        positions.append(position)
    
    return positions

def generate_football_clubs(n, cities, owners, stadiums):
    """Генерация футбольных клубов"""
    clubs = []
    if not cities or not stadiums:
        return clubs
    
    for i in range(n):
        city = random.choice(cities)
        
        club = {
            'name': f"{city['name']} {random.choice(['FC', 'United', 'City'])}",
            'country': city['country'],
            'city': city['name'],
            'owner_id': random.randint(1, len(owners)) if owners and random.random() < 0.9 else None,
            'staduim_id': random.randint(1, len(stadiums)) if stadiums else 1,
            'city_id': i + 1  # временный ID
        }
        clubs.append(club)
    
    return clubs

def generate_players(n, clubs):
    """Генерация игроков"""
    players = []
    if not clubs:
        return players
        
    positions = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward']
    nationalities = ['England', 'Spain', 'Germany', 'France', 'Italy', 'Brazil', 'Argentina']
    
    market_values = power_law_distribution(50000, 200000000, n, alpha=2.2)
    
    for i in range(n):
        try:
            if random.random() < 0.10:
                nationality = None
            else:
                nationality = random.choice(nationalities)
                
            if random.random() < 0.12:
                position = None
            else:
                position = random.choice(positions)
            
            tags = []
            if random.random() < 0.7:
                possible_tags = ['captain', 'young', 'experienced', 'injury_prone', 
                               'national', 'star', 'homegrown']
                tags = random.sample(possible_tags, min(random.randint(1, 3), len(possible_tags)))
            
            player = {
                'first_name': fake.first_name(),
                'date_of_birth': fake.date_of_birth(minimum_age=16, maximum_age=40),
                'nationality': nationality,
                'position': position,
                'market_value': float(market_values[i]) if i < len(market_values) else 100000.0,
                'club_id': random.randint(1, len(clubs)) if random.random() < 0.92 else None,
                'tags': tags
            }
            players.append(player)
        except Exception as e:
            print(f"Error generating player {i}: {e}")
            continue
        
        if i % 500000 == 0 and i > 0:
            print(f"  Generated {i:,} players")
    
    return players

def generate_staff(n, positions, clubs):
    """Генерация персонала"""
    staff_list = []
    if not clubs or not positions:
        return staff_list
    
    salaries = power_law_distribution(20000, 800000, n, alpha=2.3)
    
    for i in range(n):
        try:
            staff = {
                'first_name': fake.name(),
                'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=70),
                'salary': float(salaries[i]) if i < len(salaries) else 50000.0,
                'position_id': random.randint(1, len(positions)),
                'club_id': random.randint(1, len(clubs)) if random.random() < 0.9 else None
            }
            staff_list.append(staff)
        except Exception as e:
            print(f"Error generating staff {i}: {e}")
            continue
        
        if i % 200000 == 0 and i > 0:
            print(f"  Generated {i:,} staff")
    
    return staff_list

def generate_contracts(n, players):
    """Генерация контрактов"""
    contracts = []
    if not players:
        return contracts
    
    salaries = power_law_distribution(50000, 40000000, n, alpha=2.3)
    
    for i in range(n):
        try:
            contract_length = random.choices([1, 2, 3, 4, 5], weights=[0.1, 0.2, 0.35, 0.25, 0.1])[0]
            start_date = fake.date_between(start_date='-8y', end_date='today')
            end_date = start_date + timedelta(days=365 * contract_length)
            
            attributes = {}
            if random.random() < 0.6:
                attributes = {
                    'agent': fake.name() if random.random() < 0.7 else None,
                    'bonus_type': random.choice(['goals', 'appearances', 'trophies']),
                    'release_clause': bool(random.choice([True, False])),
                    'renewal': random.choice(['club', 'player']) if random.random() < 0.3 else None
                }
            
            contract = {
                'player_id': random.randint(1, len(players)),
                'start_date': start_date,
                'end_date': end_date,
                'salary': float(salaries[i]) if i < len(salaries) else 100000.0,
                'attributes': json.dumps(attributes) if attributes else '{}'
            }
            contracts.append(contract)
        except Exception as e:
            print(f"Error generating contract {i}: {e}")
            continue
        
        if i % 500000 == 0 and i > 0:
            print(f"  Generated {i:,} contracts")
    
    return contracts

def generate_sponsors(n, clubs):
    """Генерация спонсоров"""
    sponsors = []
    if not clubs:
        return sponsors
        
    types = ['Kit', 'Shirt', 'Sleeve', 'Partner', 'Stadium']
    amounts = power_law_distribution(100000, 50000000, n, alpha=2.1)
    
    for i in range(n):
        try:
            details = {}
            if random.random() < 0.5:
                details = {
                    'industry': random.choice(['Sportswear', 'Airlines', 'Banking', 'Tech']),
                    'global': bool(random.random() < 0.3)
                }
            
            sponsor = {
                'club_id': random.randint(1, len(clubs)),
                'start_date': fake.date_between(start_date='-10y', end_date='-1y'),
                'end_date': fake.date_between(start_date='today', end_date='+5y'),
                'amount': float(amounts[i]) if i < len(amounts) else 1000000.0,
                'type': random.choice(types),
                'details': json.dumps(details) if details else '{}'
            }
            sponsors.append(sponsor)
        except Exception as e:
            print(f"Error generating sponsor {i}: {e}")
            continue
    
    return sponsors

def generate_participation(n, clubs, league, tournament):
    """Генерация участия в соревнованиях"""
    participations = []
    if not clubs:
        return participations
        
    seasons = [f"{y}-{y+1}" for y in range(2015, 2025)]
    
    for i in range(n):
        try:
            if random.random() < 0.7:
                final_pos = int(power_law_distribution(1, 20, 1, alpha=1.8)[0])
                participation = {
                    'club_id': random.randint(1, len(clubs)),
                    'tournament_id': None,
                    'liague_id': random.randint(1, len(league)) if league else None,
                    'season': random.choice(seasons),
                    'final_position': final_pos
                }
            else:
                final_pos = int(power_law_distribution(1, 32, 1, alpha=1.8)[0])
                participation = {
                    'club_id': random.randint(1, len(clubs)),
                    'tournament_id': random.randint(1, len(tournament)) if tournament else None,
                    'liague_id': None,
                    'season': random.choice(seasons),
                    'final_position': final_pos
                }
            participations.append(participation)
        except Exception as e:
            print(f"Error generating participation {i}: {e}")
            continue
    
    return participations

def generate_fun_shop(n, clubs):
    """Генерация магазинов"""
    shops = []
    if not clubs:
        return shops
    
    for i in range(n):
        try:
            shop = {
                'address': fake.address().replace('\n', ', ').replace('\r', ''),
                'club_id': random.randint(1, len(clubs))
            }
            shops.append(shop)
        except Exception as e:
            print(f"Error generating shop {i}: {e}")
            continue
    
    return shops

def generate_products(n, shops):
    """Генерация продуктов"""
    products = []
    if not shops:
        return products
        
    types = ['Jersey', 'Scarf', 'Cap', 'Mug', 'Poster', 'Keychain']
    colors = ['Red', 'Blue', 'White', 'Black', 'Green']
    prices = power_law_distribution(5, 300, n, alpha=2.2)
    
    for i in range(n):
        try:
            attributes = {}
            if random.random() < 0.5:
                attributes = {
                    'color': random.choice(colors),
                    'size': random.choice(['S', 'M', 'L', 'XL']) if random.random() < 0.7 else None
                }
            
            tags = []
            if random.random() < 0.6:
                possible_tags = ['new', 'sale', 'popular']
                tags = random.sample(possible_tags, min(random.randint(1, 2), len(possible_tags)))
            
            height = random.randint(10, 200) if random.random() < 0.8 else None
            width = random.randint(10, 200) if random.random() < 0.8 else None
            length = random.randint(10, 200) if random.random() < 0.8 else None
            
            product = {
                'name': f"{fake.word().title()} {random.choice(types)}",
                'type': random.choice(types),
                'price': float(prices[i]) if i < len(prices) else 50.0,
                'count': random.randint(1, 1000),
                'shop_id': random.randint(1, len(shops)),
                'height': height,
                'width': width,
                'length': length,
                'attributes': json.dumps(attributes) if attributes else None,
                'tags': tags
            }
            products.append(product)
        except Exception as e:
            print(f"Error generating product {i}: {e}")
            continue
        
        if i % 500000 == 0 and i > 0:
            print(f"  Generated {i:,} products")
    
    return products

# ========== ФУНКЦИИ ДЛЯ РАБОТЫ С БД ==========

def test_connection():
    """Тестирование подключения к БД"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        print("✓ Database connection successful")
        conn.close()
        return True
    except Exception as e:
        print(f"✗ Database connection failed: {e}")
        return False

def prepare_value_for_db(val):
    """Подготовка значения для вставки в БД"""
    if val is None:
        return None
    elif isinstance(val, (list, dict)):
        return json.dumps(val)
    elif isinstance(val, (datetime, date)):
        return val
    elif isinstance(val, bool):
        return val
    elif isinstance(val, (int, float, str)):
        return val
    else:
        return str(val)

def insert_data(conn, table_name, data, columns):
    """Вставка данных в таблицу"""
    if not data:
        print(f"  No data to insert for {table_name}")
        return []
        
    cursor = conn.cursor()
    
    # Подготавливаем значения
    values = []
    for row in data:
        row_values = []
        for col in columns:
            val = row.get(col)
            row_values.append(prepare_value_for_db(val))
        values.append(tuple(row_values))
    
    # Формируем запрос
    query = f"INSERT INTO football_club.{table_name} ({', '.join(columns)}) VALUES %s"
    
    # Добавляем RETURNING если нужно получить ID
    if table_name in ['cities', 'owners', 'stadiums', 'league', 'tournament', 
                      'departments', 'football_clubs', 'positions', 'fun_shop', 'players']:
        id_column = table_name[:-1] + '_id' if table_name.endswith('s') else table_name + '_id'
        query += f" RETURNING {id_column}"
        fetch = True
    else:
        fetch = False
    
    batch_size = 50000
    all_ids = []
    
    total_batches = (len(values) + batch_size - 1) // batch_size
    for i in range(0, len(values), batch_size):
        batch = values[i:i+batch_size]
        try:
            if fetch:
                result = execute_values(cursor, query, batch, fetch=True)
                conn.commit()
                for row in result:
                    all_ids.append(row[0])
            else:
                execute_values(cursor, query, batch)
                conn.commit()
            
            print(f"  Inserted batch {i//batch_size + 1}/{total_batches} into {table_name}")
        except Exception as e:
            print(f"  Error inserting batch {i//batch_size + 1} into {table_name}: {e}")
            print(f"  Sample data: {batch[0] if batch else 'None'}")
            conn.rollback()
            raise
    
    print(f"  Completed: {len(data):,} records into {table_name}")
    return all_ids

def main():
    """Основная функция"""
    print("="*50)
    print("GENERATING DATA FOR FOOTBALL CLUB DATABASE")
    print("="*50)
    print(f"Total target: {total:,} records\n")

    # Тестируем подключение
    if not test_connection():
        print("\nPlease check your database connection parameters in DB_PARAMS")
        return
    
    try:
        conn = psycopg2.connect(**DB_PARAMS)
    except Exception as e:
        print(f"Failed to connect to database: {e}")
        return
    
    try:
        # Генерация всех данных
        print("\n1. Generating cities...")
        cities = generate_cities(TABLE_SIZES['cities'])
        print(f"   Generated {len(cities)} cities")
        
        print("2. Generating owners...")
        owners = generate_owners(TABLE_SIZES['owners'])
        print(f"   Generated {len(owners)} owners")
        
        print("3. Generating stadiums...")
        stadiums = generate_stadiums(TABLE_SIZES['stadiums'])
        print(f"   Generated {len(stadiums)} stadiums")
        
        print("4. Generating league...")
        league = generate_league(TABLE_SIZES['league'])
        print(f"   Generated {len(league)} leagues")
        
        print("5. Generating tournament...")
        tournament = generate_tournament(TABLE_SIZES['tournament'])
        print(f"   Generated {len(tournament)} tournaments")
        
        print("6. Generating departments...")
        departments = generate_departments(TABLE_SIZES['departments'])
        print(f"   Generated {len(departments)} departments")
        
        print("7. Generating positions...")
        positions = generate_positions(TABLE_SIZES['positions'], departments)
        print(f"   Generated {len(positions)} positions")
        
        print("8. Generating football clubs...")
        clubs = generate_football_clubs(TABLE_SIZES['football_clubs'], cities, owners, stadiums)
        print(f"   Generated {len(clubs)} clubs")
        
        print("9. Generating fun shops...")
        fun_shops = generate_fun_shop(TABLE_SIZES['fun_shop'], clubs)
        print(f"   Generated {len(fun_shops)} shops")
        
        print("10. Generating players (large table)...")
        players = generate_players(TABLE_SIZES['players'], clubs)
        print(f"   Generated {len(players):,} players")
        
        print("11. Generating staff...")
        staff = generate_staff(TABLE_SIZES['staff'], positions, clubs)
        print(f"   Generated {len(staff):,} staff")
        
        print("12. Generating contracts (large table)...")
        contracts = generate_contracts(TABLE_SIZES['contracts'], players)
        print(f"   Generated {len(contracts):,} contracts")
        
        print("13. Generating sponsors...")
        sponsors = generate_sponsors(TABLE_SIZES['sponsors'], clubs)
        print(f"   Generated {len(sponsors):,} sponsors")
        
        print("14. Generating participation...")
        participation = generate_participation(TABLE_SIZES['participation'], clubs, league, tournament)
        print(f"   Generated {len(participation):,} participations")
        
        print("15. Generating products (largest table)...")
        products = generate_products(TABLE_SIZES['products'], fun_shops)
        print(f"   Generated {len(products):,} products")
        
        # Вставка данных
        print("\n" + "="*50)
        print("INSERTING DATA INTO DATABASE")
        print("="*50)
        
        # Сначала таблицы без внешних ключей
        city_ids = insert_data(conn, 'cities', cities, ['name', 'country'])
        for i, city in enumerate(cities):
            city['city_id'] = city_ids[i] if i < len(city_ids) else i + 1
        
        owner_ids = insert_data(conn, 'owners', owners, ['name', 'nationality', 'purchase_date'])
        for i, owner in enumerate(owners):
            owner['owner_id'] = owner_ids[i] if i < len(owner_ids) else i + 1
        
        stadium_ids = insert_data(conn, 'stadiums', stadiums, ['name', 'capacity', 'address'])
        for i, stadium in enumerate(stadiums):
            stadium['staduim_id'] = stadium_ids[i] if i < len(stadium_ids) else i + 1
        
        league_ids = insert_data(conn, 'league', league, ['name', 'country', 'tier'])
        for i, l in enumerate(league):
            l['liague_id'] = league_ids[i] if i < len(league_ids) else i + 1
        
        tournament_ids = insert_data(conn, 'tournament', tournament, ['name', 'region', 'format'])
        for i, t in enumerate(tournament):
            t['tournament_id'] = tournament_ids[i] if i < len(tournament_ids) else i + 1
        
        dept_ids = insert_data(conn, 'departments', departments, ['name'])
        for i, dept in enumerate(departments):
            dept['department_id'] = dept_ids[i] if i < len(dept_ids) else i + 1
        
        # Таблицы с внешними ключами
        club_ids = insert_data(conn, 'football_clubs', clubs, ['name', 'country', 'city', 'owner_id', 'staduim_id', 'city_id'])
        for i, club in enumerate(clubs):
            club['club_id'] = club_ids[i] if i < len(club_ids) else i + 1
        
        position_ids = insert_data(conn, 'positions', positions, ['department_id', 'title', 'base_salary'])
        for i, pos in enumerate(positions):
            pos['position_id'] = position_ids[i] if i < len(position_ids) else i + 1
        
        shop_ids = insert_data(conn, 'fun_shop', fun_shops, ['address', 'club_id'])
        for i, shop in enumerate(fun_shops):
            shop['shop_id'] = shop_ids[i] if i < len(shop_ids) else i + 1
        
        # Основные большие таблицы
        player_ids = insert_data(conn, 'players', players, ['first_name', 'date_of_birth', 'nationality', 'position', 'market_value', 'club_id', 'tags'])
        for i, player in enumerate(players):
            player['player_id'] = player_ids[i] if i < len(player_ids) else i + 1
        
        insert_data(conn, 'staff', staff, ['first_name', 'date_of_birth', 'salary', 'position_id', 'club_id'])
        insert_data(conn, 'contracts', contracts, ['player_id', 'start_date', 'end_date', 'salary', 'attributes'])
        insert_data(conn, 'sponsors', sponsors, ['club_id', 'start_date', 'end_date', 'amount', 'type', 'details'])
        insert_data(conn, 'participation', participation, ['club_id', 'tournament_id', 'liague_id', 'season', 'final_position'])
        insert_data(conn, 'products', products, ['name', 'type', 'price', 'count', 'shop_id', 'height', 'width', 'length', 'attributes', 'tags'])
        
        print("\n" + "="*50)
        print("ALL DATA INSERTED SUCCESSFULLY!")
        print("="*50)
        
        # Статистика
        print("\nFINAL STATISTICS:")
        print(f"Total records: {total:,}")
        print("\nTable sizes:")
        for table, size in TABLE_SIZES.items():
            print(f"  {table:15s}: {size:10,d} records")
        
    except Exception as e:
        conn.rollback()
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()