CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replpass';

CREATE TABLE IF NOT EXISTS test_data (
    id BIGSERIAL PRIMARY KEY,
    payload TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS no_pk_table (
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE PUBLICATION app_publication FOR TABLE test_data, no_pk_table;
