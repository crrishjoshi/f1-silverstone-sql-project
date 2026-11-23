/*
SMALL WIN 13 — Rank a driver-level measure (20–30 minutes)

Goal
Use one basic SQL Server window function after producing the correct aggregation grain.

Stakeholder question
What rank does each driver receive on cleaned average lap time?

Your task
Reuse your driver-level cleaned pace result from exercise 08B. Return full_name, clean_laps, clean_average_seconds and pace_rank. Give the lowest clean average rank 1, allowing equal values to share a rank.

Expected shape
One row per driver with usable clean laps | full_name | clean_laps | clean_average_seconds | pace_rank

Success check
The first row has pace_rank = 1, and ranking occurs after—not inside—the per-lap cleaning step.

Hint
Use RANK() OVER (ORDER BY clean_average_seconds). You may need one CTE for cleaned laps and another for the driver-level average.
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
RANK() over (ORDER BY ROUND(AVG(pit_affected_lap.lap_time_seconds),3) ASC) as pace_rank

FROM f1.drivers as drivers
JOIN personal_best as pb
ON pb.driver_id=drivers.driver_id
JOIN pit_affected_lap
ON pit_affected_lap.driver_id=drivers.driver_id
WHERE pit_affected_lap.lap_time_seconds<= pb.best_lap_second * 1.07
GROUP BY drivers.given_name,drivers.family_name
ORDER BY pace_rank;
