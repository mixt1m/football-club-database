
Используйте таблицу `booking_slots`.

Откройте две сессии к базе данных: `A` и `B`.

В сессии `A` выполните:

```sql
BEGIN;
SELECT * FROM booking_slots WHERE id = 1 FOR KEY SHARE;
```

В сессии `B` выполните:

```sql
DELETE FROM booking_slots
WHERE id = 1;
```

После наблюдения результата завершите сессию `A`:

```sql
ROLLBACK;
```

Затем повторите эксперимент.

В сессии `A` выполните:

```sql
BEGIN;
SELECT * FROM booking_slots WHERE id = 1 FOR NO KEY UPDATE;
```

В сессии `B` выполните:

```sql
UPDATE booking_slots
SET reserved_count = reserved_count + 1
WHERE id = 1;
```

После наблюдения результата завершите сессию `A`:

```sql
ROLLBACK;
```

Что нужно сделать:

```text
1. Опишите, что происходит с DELETE и UPDATE в сессии B в двух экспериментах.
2. Объясните, чем FOR KEY SHARE отличается от FOR NO KEY UPDATE по смыслу и по силе блокировки.
3. Укажите, почему обычный SELECT без FOR KEY SHARE/FOR NO KEY UPDATE ведет себя иначе.
4. Кратко поясните, где в прикладных сценариях может использоваться FOR NO KEY UPDATE.
```

-- 1. 1)DELETE в сессии B блокируется Удаление невозможно, пока не завершится сессия A
-- 2) UPDATE в сессии B блокируется (ожидает) Обновление невозможно, пока не завершится сессия A
