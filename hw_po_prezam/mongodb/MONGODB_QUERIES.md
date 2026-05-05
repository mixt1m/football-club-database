# MongoDB homework

## 1. Создать коллекцию `books`

Выбрать БД:

```javascript
use mydb
```

Создать коллекцию:

```javascript
db.createCollection("books")
```

Добавить один документ:

```javascript
db.books.insertOne({
  title: "Clean Code",
  genre: "programming",
  price: 42.99,
  available: true,
  tags: ["code", "best-practices", "software"],
  author: {
    name: "Robert C. Martin",
    country: "USA"
  }
})
```

## 2. Простой поиск по одному условию

Все книги, которые есть в наличии:

```javascript
db.books.find({ available: true })
```

## 3. Добавить ещё несколько документов

```javascript
db.books.insertMany([
  {
    title: "Design Patterns",
    genre: "programming",
    price: 55.00,
    available: true,
    tags: ["patterns", "architecture", "software"],
    author: {
      name: "Erich Gamma",
      country: "Germany"
    }
  },
  {
    title: "The Pragmatic Programmer",
    genre: "programming",
    price: 48.50,
    available: false,
    tags: ["programming", "career", "practice"],
    author: {
      name: "Andrew Hunt",
      country: "USA"
    }
  },
  {
    title: "Dune",
    genre: "science fiction",
    price: 25.99,
    available: true,
    tags: ["classic", "space", "epic"],
    author: {
      name: "Frank Herbert",
      country: "USA"
    }
  },
  {
    title: "The Hobbit",
    genre: "fantasy",
    price: 19.99,
    available: false,
    tags: ["adventure", "classic", "middle-earth"],
    author: {
      name: "J. R. R. Tolkien",
      country: "United Kingdom"
    }
  }
])
```

## 4. Запрос посложнее

```javascript
db.books.find(
  {
    genre: "programming",
    price: { $gt: 40 },
    available: true
  },
  {
    _id: 0,
    title: 1,
    price: 1
  }
)
```
