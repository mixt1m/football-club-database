
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

UPDATE warehouse_items
SET stock = stock - 2
WHERE id = 1;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

DELETE FROM warehouse_items
WHERE id = 3;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;


Что нужно сделать:

```text
1. Опишите, что изменилось после UPDATE с точки зрения xmin, xmax и ctid.
2. Объясните, почему в модели MVCC UPDATE не является простым "перезаписыванием" строки.
3. Объясните, что произошло после DELETE и почему строка исчезла из обычного SELECT.
4. Кратко сравните:
   - VACUUM;
   - autovacuum;
   - VACUUM FULL.
5. Отдельно укажите, какой из этих механизмов может полностью блокировать таблицу.
```

-- 1. создалась новая сторока с актуальным xmin, а в прошлой строке xmax стал равняется id транзакции 
-- 2. потому что он помечяет прошлую строку удаленной и как бы делает insert, это удобно для бд чтобы делать откаты 
-- 3. после delete xmax стал равняется id транзакции, а его не видно потому что когда делается селект бд видит это и понимает что удаленная строка это
-- 4. vacuum сканирует таблицу и удаляет старые строки не блокируя
 -- удаляет в фоне сам
 -- vacuum full блокирует таблицу и все очищает
 -- 5. vacuum full
