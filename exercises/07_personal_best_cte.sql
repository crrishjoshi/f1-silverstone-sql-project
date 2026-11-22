/*
SMALL WIN 07 — Build one focused CTE (20–30 minutes)

Goal
Calculate a driver-specific comparison threshold.

Stakeholder question
What is each driver's quickest recorded lap and the 107% threshold above it?

Your task
Create a CTE named personal_best that returns one row per driver_id with best_lap_seconds. Select from it and add threshold_107_seconds = best_lap_seconds * 1.07. Join drivers so the final output uses full_name. Round both values to three decimals.

Expected shape
19 rows | full_name | best_lap_seconds | threshold_107_seconds

Success check
Every threshold is greater than its best lap, and every driver with lap data appears once.

Why 107%?
It is a transparent project rule for identifying unusually slow laps relative to each driver's own best. It is not claimed to be an official race-pace standard.

Hint
The CTE needs MIN(lap_time_seconds) grouped by driver_id.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
WITH personal_best AS (
    SELECT driver_id,
        MIN(lap_time_seconds) best_lap_second
        FROM f1.lap_times
        GROUP BY driver_id
    
)
SELECT CONCAT(drivers.given_name, ' ', drivers.family_name) AS full_name,
        pb.best_lap_second,
        threshold_107_seconds = ROUND(pb.best_lap_second *1.07,3)
    
    FROM f1.drivers AS drivers
    JOIN personal_best AS pb
    ON drivers.driver_id = pb.driver_id
