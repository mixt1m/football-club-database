# Qdrant homework


## 1. Создать коллекцию `articles` с размерностью `384`

```powershell
Invoke-RestMethod -Method Put -Uri "http://localhost:6333/collections/articles" -ContentType "application/json" -Body '{"vectors":{"size":384,"distance":"Cosine"}}'
```

## 2. Вставить 5-10 статей

Сначала создаём простые 384-мерные векторы:

```powershell
$vSport = @(1..384 | ForEach-Object { 0.90 })
$vTech  = @(1..384 | ForEach-Object { 0.70 })
$vNews  = @(1..384 | ForEach-Object { 0.40 })
$vMix1  = @(1..384 | ForEach-Object { if ($_ % 2 -eq 0) { 0.85 } else { 0.65 } })
$vMix2  = @(1..384 | ForEach-Object { if ($_ % 3 -eq 0) { 0.88 } else { 0.55 } })
```

Потом вставляем статьи:

```powershell
$body = @{
  points = @(
    @{ id = 1; vector = $vTech; payload = @{ title = "Vector Databases 101"; content = "Basics of vector search and embeddings"; author = "Alice"; category = "tech";  published_at = "2024-02-10T10:00:00Z"; views = 1800; rating = 4.7 } },
    @{ id = 2; vector = $vSport; payload = @{ title = "Running for Beginners"; content = "How to start running and train safely"; author = "Bob"; category = "sport"; published_at = "2024-03-01T09:00:00Z"; views = 3200; rating = 4.5 } },
    @{ id = 3; vector = $vNews; payload = @{ title = "Morning City News"; content = "Daily news summary and local events"; author = "Clara"; category = "news";  published_at = "2023-12-20T08:00:00Z"; views = 900;  rating = 3.8 } },
    @{ id = 4; vector = $vMix1; payload = @{ title = "AI in Sports Analytics"; content = "Technology and sport data analysis"; author = "Dan"; category = "tech";  published_at = "2024-05-10T12:00:00Z"; views = 4100; rating = 4.8 } },
    @{ id = 5; vector = $vMix2; payload = @{ title = "Best Marathon Shoes"; content = "Sport gear for running and marathon"; author = "Eva"; category = "sport"; published_at = "2024-04-15T07:30:00Z"; views = 2600; rating = 4.2 } },
    @{ id = 6; vector = $vTech; payload = @{ title = "Neural Search Trends"; content = "Modern retrieval and semantic ranking"; author = "Frank"; category = "tech"; published_at = "2024-06-01T15:00:00Z"; views = 5200; rating = 4.9 } }
  )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Method Put -Uri "http://localhost:6333/collections/articles/points?wait=true" -ContentType "application/json" -Body $body
```

## 3. Поиск

Запрос для "бег и спорт":

```powershell
$qSport = @(1..384 | ForEach-Object { 0.92 })
```

Простой поиск, топ 3:

```powershell
$body = @{ query = $qSport; limit = 3; with_payload = $true } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
```

Поиск с фильтром по категории `tech` и рейтингом `>= 4.0`:

```powershell
$body = @{
  query = $qSport
  limit = 5
  with_payload = $true
  filter = @{
    must = @(
      @{ key = "category"; match = @{ value = "tech" } },
      @{ key = "rating"; range = @{ gte = 4.0 } }
    )
  }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
```

Поиск с диапазоном дат: после `2024-01-01` и `views > 1000`:

```powershell
$body = @{
  query = $qSport
  limit = 5
  with_payload = $true
  filter = @{
    must = @(
      @{ key = "published_at"; range = @{ gt = "2024-01-01T00:00:00Z" } },
      @{ key = "views"; range = @{ gt = 1000 } }
    )
  }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
```

Сложный фильтр:
- категория `sport` ИЛИ `tech`
- рейтинг `>= 3.5`
- просмотры `500..5000`
- сортировка по релевантности идёт по `score` автоматически

```powershell
$body = @{
  query = $qSport
  limit = 10
  with_payload = $true
  filter = @{
    must = @(
      @{
        should = @(
          @{ key = "category"; match = @{ value = "sport" } },
          @{ key = "category"; match = @{ value = "tech" } }
        )
      },
      @{ key = "rating"; range = @{ gte = 3.5 } },
      @{ key = "views"; range = @{ gte = 500; lte = 5000 } }
    )
  }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
```

## 4. Payload-индексы

```powershell
Invoke-RestMethod -Method Put -Uri "http://localhost:6333/collections/articles/index?wait=true" -ContentType "application/json" -Body '{"field_name":"category","field_schema":"keyword"}'
Invoke-RestMethod -Method Put -Uri "http://localhost:6333/collections/articles/index?wait=true" -ContentType "application/json" -Body '{"field_name":"rating","field_schema":"float"}'
Invoke-RestMethod -Method Put -Uri "http://localhost:6333/collections/articles/index?wait=true" -ContentType "application/json" -Body '{"field_name":"published_at","field_schema":"datetime"}'
Invoke-RestMethod -Method Put -Uri "http://localhost:6333/collections/articles/index?wait=true" -ContentType "application/json" -Body '{"field_name":"views","field_schema":"integer"}'
```

Проверить время до и после индексов:

```powershell
Measure-Command {
  Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
}
```

На таком маленьком наборе разница может быть почти незаметна, но на больших данных фильтрация должна работать быстрее.

## 5. Для умных: пагинация

Первая страница:

```powershell
$body = @{ query = $qSport; limit = 2; offset = 0; with_payload = $true } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
```

Вторая страница:

```powershell
$body = @{ query = $qSport; limit = 2; offset = 2; with_payload = $true } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method Post -Uri "http://localhost:6333/collections/articles/points/query" -ContentType "application/json" -Body $body
```

## 6. Honorable mention

Если нужны реальные embeddings, их можно сгенерировать отдельно через:

```python
from sentence_transformers import SentenceTransformer
```
