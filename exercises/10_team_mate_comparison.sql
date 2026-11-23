/*
SMALL WIN 10 — Compare team-mates (25–30 minutes)

Goal
Make a cautious within-team comparison using the cleaned measure.

Stakeholder question
How do the two drivers from each constructor compare on cleaned average lap time?

Your task
Build or reuse a driver-level cleaned pace result, join it to race_results and constructors, then return constructor_name, full_name, clean_laps and clean_average_seconds. Order by constructor_name and clean_average_seconds.

Expected shape
Normally two rows per constructor, with one possible exception if a driver has no usable laps.

Success check
Each driver appears at most once. Explain why comparing team-mates can control for some car differences but not strategy, damage, traffic or race circumstances.

Hint
Finish the cleaned aggregation at one row per driver_id before joining it to the team tables.
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
-- Team-mate comparison controls for some car differences, but not strategy, damage, traffic or race circumstances.
SELECT c.constructor_name,
CONCAT(drivers.given_name, ' ', drivers.family_name) AS full_name,
COUNT (*) clean_laps,
ROUND(AVG(pit_affected_lap.lap_time_seconds),3) clean_average_seconds
FROM f1.drivers as drivers
JOIN personal_best as pb
ON pb.driver_id=drivers.driver_id
JOIN pit_affected_lap
ON pit_affected_lap.driver_id=drivers.driver_id
JOIN f1.race_results as rs
ON rs.driver_id = drivers.driver_id
JOIN f1.constructors AS c
    ON c.constructor_id = rs.constructor_id
WHERE pit_affected_lap.lap_time_seconds<= pb.best_lap_second * 1.07
GROUP BY c.constructor_name, drivers.given_name,drivers.family_name
ORDER BY c.constructor_name,clean_average_seconds;
