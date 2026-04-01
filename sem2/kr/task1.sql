EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';

-- Использован seq scan 
-- сущ индексы не помогли, потому что они не на sold_at. кроме индекса на id, создается автоматически

CREATE INDEX idx_store_checks_sold_at ON store_checks (sold_at);

-- Изменилась скорость выполнения в лучшую сторону и тип сканирования на bitmap heap scan
-- измения типа сканирования изменило скорость в лучшую сторону из-за того, что ему стало легче

-- всего надо анализировать запросы после добавления индексов для проверки результатов, не сдалали мы хуже

