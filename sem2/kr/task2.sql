EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';

-- использован hash join 
-- потому что есть join на равенство 
-- слабо полезный индекс на id который создается автоматически 

CREATE INDEX idx_club_visits_member_id ON club_visits (member_id);
CREATE INDEX idx_club_members_member_level ON club_members (member_level);

-- создал индексы на member_level для более быстрого поиска и на member_id, что бы быстрее был join
-- преобладает shared hit потому что все в кэше

