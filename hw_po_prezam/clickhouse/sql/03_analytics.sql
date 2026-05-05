SELECT
    city,
    round(avg(distance_km), 2) AS avg_distance,
    count() AS trip_count,
    max(dateDiff('second', start_time, end_time)) AS max_duration_sec
FROM homework.trips
GROUP BY city
ORDER BY city;
