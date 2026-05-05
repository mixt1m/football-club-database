# Elasticsearch homework



## 1. Создать индекс `products`

Запрос:

```http
PUT http://localhost:9200/products
```

Тело JSON:

```json
{
  "mappings": {
    "properties": {
      "name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "category": { "type": "keyword" },
      "price": { "type": "float" },
      "stock": { "type": "integer" }
    }
  }
}
```

## 2. Заполнить индекс тестовыми данными

Вставка 1:

```http
POST http://localhost:9200/products/_doc
```

```json
{
  "name": "Laptop Pro 14",
  "category": "electronics",
  "price": 1299.99,
  "stock": 15
}
```

Вставка 2:

```http
POST http://localhost:9200/products/_doc
```

```json
{
  "name": "Wireless Headphones Max",
  "category": "audio",
  "price": 249.99,
  "stock": 40
}
```

Вставка 3:

```http
POST http://localhost:9200/products/_doc
```

```json
{
  "name": "Office Chair Comfort",
  "category": "furniture",
  "price": 299.99,
  "stock": 12
}
```

## 3. Операции с документами

Создать документ:

```http
POST http://localhost:9200/products/_doc
```

```json
{
  "name": "Smartphone Lite",
  "category": "electronics",
  "price": 499.99,
  "stock": 25
}
```

Добавить документ с id:

```http
PUT http://localhost:9200/products/_doc/101
```

```json
{
  "name": "Gaming Mouse Pro",
  "category": "peripherals",
  "price": 89.99,
  "stock": 30
}
```

Обновить документ:

```http
POST http://localhost:9200/products/_update/101
```

```json
{
  "doc": {
    "price": 79.99,
    "stock": 35
  }
}
```

Удалить документ:

```http
DELETE http://localhost:9200/products/_doc/101
```

## 4. Поисковые запросы

Поиск по названию товара:

```http
POST http://localhost:9200/products/_search
```

```json
{
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

`match`:

```http
POST http://localhost:9200/products/_search
```

```json
{
  "query": {
    "match": {
      "name": "wireless headphones"
    }
  }
}
```

`term`:

```http
POST http://localhost:9200/products/_search
```

```json
{
  "query": {
    "term": {
      "category": "audio"
    }
  }
}
```

`range`:

```http
POST http://localhost:9200/products/_search
```

```json
{
  "query": {
    "range": {
      "price": {
        "gte": 200,
        "lte": 1000
      }
    }
  }
}
```

`bool`:

```http
POST http://localhost:9200/products/_search
```

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "pro" } }
      ],
      "filter": [
        { "term": { "category": "electronics" } },
        { "range": { "price": { "lte": 1500 } } }
      ]
    }
  }
}
```
