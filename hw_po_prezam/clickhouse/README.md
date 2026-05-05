# ClickHouse homework

В каталоге лежит готовое решение задания:

- `docker-compose.yml` поднимает ClickHouse в Docker
- `sql/01_create_table.sql` создает БД `homework` и таблицу `trips`
- `sql/02_load_data.sql` вставляет 1 000 000 строк чистым SQL через `numbers(1000000)`
- `sql/03_analytics.sql` содержит агрегирующий запрос
- `scripts/generate_trips_csv.py` генерирует CSV, если нужен вариант с отдельными данными

## Быстрый запуск

Из папки `clickhouse`:

```powershell
docker compose up -d
```

Подключиться к ClickHouse и выполнить загрузку данных:

```powershell
docker exec -it clickhouse_hw clickhouse-client --queries-file /opt/homework/sql/02_load_data.sql
```

Запустить аналитический запрос:

```powershell
docker exec -it clickhouse_hw clickhouse-client --queries-file /opt/homework/sql/03_analytics.sql
```

## Вариант с генерацией CSV

Если нужен отдельный файл с данными:

```powershell
python .\scripts\generate_trips_csv.py
```

После этого можно загрузить CSV вручную:

```powershell
docker cp .\data\trips.csv clickhouse_hw:/tmp/trips.csv
docker exec -it clickhouse_hw clickhouse-client --query "INSERT INTO homework.trips FORMAT CSVWithNames" < .\data\trips.csv
```
