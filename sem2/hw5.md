```
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'pass';
GRANT CONNECT ON DATABASE postgres TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
```

Что произойдет если попробовать вставить данные на реплике?

ERROR:  cannot execute INSERT in a read-only transaction

