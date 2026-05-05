INSERT INTO homework.trips
SELECT
    number + 1 AS trip_id,
    start_time,
    start_time + duration_sec AS end_time,
    distance_km,
    city
FROM
(
    SELECT
        number,
        toDateTime('2024-01-01 00:00:00') + (number % 31536000) AS start_time,
        300 + (number * 37 % 7200) AS duration_sec,
        round(toFloat32(1 + ((number * 17) % 5000) / 100.0), 2) AS distance_km,
        arrayElement(
            ['Moscow', 'Saint Petersburg', 'Kazan', 'Novosibirsk', 'Yekaterinburg', 'Sochi', 'Vladivostok'],
            (number % 7) + 1
        ) AS city
    FROM numbers(1000000)
);
