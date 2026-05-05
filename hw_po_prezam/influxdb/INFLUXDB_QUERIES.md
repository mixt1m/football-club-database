# InfluxDB homework

## Запуск



## 1. Получить admin token

Запрос:

```bash
curl -X POST "http://localhost:8181/api/v3/configure/token/admin"
```


## 2. Создать bucket `mydb`


```bash
curl -X POST "http://localhost:8181/api/v3/configure/database" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  --data-raw "{\"db\":\"mydb\"}"
```


## 3. Вставить несколько записей через Line Protocol

```bash
curl -X POST "http://localhost:8181/api/v3/write_lp?db=mydb" \
  -H "Authorization: Bearer TOKEN" \
  --data-raw "temperature,location=room1 value=23
temperature,location=room1 value=24
temperature,location=room2 value=21
temperature,location=room2 value=22"
```

## 4. Сделать SELECT


```bash
curl -G "http://localhost:8181/api/v3/query_sql" \
  -H "Authorization: Bearer TOKEN" \
  --data-urlencode "db=mydb" \
  --data-urlencode "q=SELECT * FROM temperature IN mydb" \
  --data-urlencode "format=pretty"
```

## 5. Выбрать данные за последние 5 минут



```bash
curl -G "http://localhost:8181/api/v3/query_sql" \
  -H "Authorization: Bearer TOKEN" \
  --data-urlencode "db=mydb" \
  --data-urlencode "q=SELECT * FROM temperature IN mydb WHERE time >= now() - interval '5 minutes'" \
  --data-urlencode "format=pretty"
```

## 6. Сгруппировать по тегу `location`


```bash
curl -G "http://localhost:8181/api/v3/query_sql" \
  -H "Authorization: Bearer TOKEN" \
  --data-urlencode "db=mydb" \
  --data-urlencode "q=SELECT location, avg(value) FROM temperature IN mydb WHERE time >= now() - interval '5 minutes' GROUP BY location" \
  --data-urlencode "format=pretty"
```
