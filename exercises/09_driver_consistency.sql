/*
SMALL WIN 09 — Measure consistency (20–30 minutes)

Goal
Recognise that pace has both a centre and a spread.

Stakeholder question
Among comparable clean laps, which drivers had the lowest variation in lap time?

Your task
Reuse the cleaning rule from exercise 08B. Return full_name, clean_laps, clean_average_seconds and lap_time_stddev. Use SQL Server's sample standard deviation function and round metrics to three decimals. Only keep drivers with at least 20 clean laps. Sort from lowest standard deviation upward.

Expected shape
One row per eligible driver | full_name | clean_laps | clean_average_seconds | lap_time_stddev

Success check
The fastest average and the lowest standard deviation do not have to belong to the same driver.

Hint
The SQL Server aggregate is STDEV(expression). Filter grouped results with HAVING.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
WITH personal_best AS (
    SELECT driver_id,

        MIN(lap_time_seconds) best_lap_second
        FROM f1.lap_times
        GROUP BY driver_id

 ) ,

pit_affected_lap AS (
SELECT
lt.driver_id,
lt.lap_time_seconds,
lt.lap_number
FROM f1.lap_times lt
WHERE lt.lap_number > 1

AND NOT EXISTS(
 SELECT 1
 FROM f1.pit_stops ps
  WHERE ps.race_id=lt.race_id
  AND ps.driver_id=lt.driver_id
  AND ps.lap_number IN (
    lt.lap_number,
    lt.lap_number - 1
  )
)
)
SELECT CONCAT(drivers.given_name, ' ', drivers.family_name) AS full_name,
COUNT (*) clean_laps,
ROUND(AVG(pit_affected_lap.lap_time_seconds),3) clean_average_seconds,
ROUND(STDEV(pit_affected_lap.lap_time_seconds),3)lap_time_stddev

FROM f1.drivers as drivers
JOIN personal_best as pb
ON pb.driver_id=drivers.driver_id
JOIN pit_affected_lap
ON pit_affected_lap.driver_id=drivers.driver_id
WHERE pit_affected_lap.lap_time_seconds<= pb.best_lap_second * 1.07
GROUP BY drivers.given_name,drivers.family_name
HAVING COUNT(*) >= 20
ORDER BY lap_time_stddev;
