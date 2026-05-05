CREATE DATABASE IF NOT EXISTS homework;

CREATE TABLE IF NOT EXISTS homework.trips
(
    trip_id UInt32,
    start_time DateTime,
    end_time DateTime,
    distance_km Float32,
    city String
)
ENGINE = MergeTree
ORDER BY trip_id;
