/*
SMALL WIN 08B — Add the pace threshold (20–30 minutes)

Goal
Add one driver-specific threshold to the filtered laps from exercise 08A.

Final cleaning rule for this project
Start with the laps retained in exercise 08A, then keep only durations no more than 107% of that driver's quickest recorded lap.

Your task
Reuse your personal_best CTE from exercise 07 and your pit-affected-lap filter from 08A. Return full_name, clean_laps and clean_average_seconds, ordered by the lowest cleaned average. Round the average to three decimals.

Expected shape
19 rows | full_name | clean_laps | clean_average_seconds

Success check
Every driver with recorded laps has at least 20 clean laps in this dataset, and clean_laps is never greater than the count from 08A.

Required explanation
Add a short SQL comment stating why this rule improves comparability and why it still cannot prove which driver performed best.

Hint
Join each retained lap to the one-row-per-driver personal_best result before applying best_lap_seconds * 1.07.
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
ROUND(AVG(pit_affected_lap.lap_time_seconds),3) clean_average_seconds

FROM f1.drivers as drivers
JOIN personal_best as pb
ON pb.driver_id=drivers.driver_id
JOIN pit_affected_lap 
ON pit_affected_lap.driver_id=drivers.driver_id
WHERE pit_affected_lap.lap_time_seconds<= pb.best_lap_second * 1.07
GROUP BY drivers.given_name,drivers.family_name