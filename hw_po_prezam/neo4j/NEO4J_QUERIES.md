# Neo4j homework



## 2. Вставка

Добавить категорию:

```cypher
CREATE (:Category {categoryID: "Databases", title: "Databases"});
```

Добавить статью:

```cypher
MATCH (c:Category {categoryID: "Databases"})
CREATE (a:Article {articleID: "Intro to Neo4j", title: "Intro to Neo4j"})
CREATE (a)-[:IS_IN]->(c);
```

Добавить читателя и связи с 3-5 статьями:

```cypher
MATCH (c:Category {categoryID: "Databases"})
CREATE (:Article {articleID: "Cypher Basics", title: "Cypher Basics"})-[:IS_IN]->(c)
CREATE (:Article {articleID: "Graph Modeling", title: "Graph Modeling"})-[:IS_IN]->(c)
CREATE (:Article {articleID: "Neo4j Tips", title: "Neo4j Tips"})-[:IS_IN]->(c);

CREATE (r:Reader {readerID: "ivanov", nickname: "Ivan", email: "ivanov@example.com"});

MATCH (r:Reader {readerID: "ivanov"}), (a:Article)
WHERE a.articleID IN ["Intro to Neo4j", "Cypher Basics", "Graph Modeling", "Neo4j Tips"]
CREATE (r)-[:READ]->(a);
```

## 3. Запросы

Все пользователи, статьи и связи между ними:

```cypher
MATCH (n)
OPTIONAL MATCH (n)-[r]-()
RETURN n, r;
```

Выбрать пользователя и найти категории, которые он читает:

```cypher
MATCH (:Reader {readerID: "ivanov"})-[:READ]->(:Article)-[:IS_IN]->(c:Category)
RETURN DISTINCT c.title;
```

Найти самых активных читателей:

```cypher
MATCH (r:Reader)-[:READ]->(a:Article)
RETURN r.readerID AS reader, count(a) AS articles_read
ORDER BY articles_read DESC;
```

Выбрать статью и найти похожие статьи:

```cypher
MATCH (a:Article {articleID: "Intro to Neo4j"})<-[:READ]-(r:Reader)-[:READ]->(similar:Article)
WHERE similar.articleID <> a.articleID
RETURN similar.articleID AS article, count(r) AS common_readers
ORDER BY common_readers DESC;
```

Рекомендации по категориям:

```cypher
MATCH (r:Reader {readerID: "ivanov"})-[:READ]->(:Article)-[:IS_IN]->(c:Category)
WITH r, collect(DISTINCT c) AS categories
MATCH (recommended:Article)-[:IS_IN]->(c:Category)
WHERE c IN categories
  AND NOT EXISTS {
    MATCH (r)-[:READ]->(recommended)
  }
RETURN DISTINCT recommended.articleID AS article, c.title AS category;
```
