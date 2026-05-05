# Redis homework


## 1. Счётчик просмотров

Ключ:

```redis
article:10:views
```

Увеличить несколько раз:

```redis
INCR article:10:views
INCR article:10:views
INCR article:10:views
INCR article:10:views
```

Получить текущее значение:

```redis
GET article:10:views
```

## 2. Рейтинг статей

Добавить статьи в leaderboard:

```redis
ZADD articles:leaderboard 120 article:1 95 article:2 210 article:3 150 article:4
```

Топ-3 без количества просмотров:

```redis
ZREVRANGE articles:leaderboard 0 2
```

Топ-3 с количеством просмотров:

```redis
ZREVRANGE articles:leaderboard 0 2 WITHSCORES
```

Добавить большой прирост просмотров, например для `article:2`:

```redis
ZINCRBY articles:leaderboard 300 article:2
```

Новый топ-3:

```redis
ZREVRANGE articles:leaderboard 0 2 WITHSCORES
```

## 3. Ограничение действий пользователя

Ключ:

```redis
user:42:likes
```

Увеличить значение несколько раз:

```redis
INCR user:42:likes
INCR user:42:likes
INCR user:42:likes
INCR user:42:likes
INCR user:42:likes
```

Задать TTL 60 секунд:

```redis
EXPIRE user:42:likes 60
```

Проверить текущее значение:

```redis
GET user:42:likes
```

Проверить, сколько секунд осталось:

```redis
TTL user:42:likes
```

Если нужно показать превышение лимита:

```redis
INCR user:42:likes
GET user:42:likes
TTL user:42:likes
```
