/*
SMALL WIN 05 — Calculate raw average lap time (20–25 minutes)

Goal
Combine a join with GROUP BY and AVG.

Stakeholder question
What is each driver's average recorded lap duration before any cleaning?

Your task
Join lap_times to drivers. Return full_name, recorded_laps and raw_average_seconds. Round the average to three decimal places. Sort from lowest average to highest.

Expected shape
19 rows | full_name | recorded_laps | raw_average_seconds

Success check
There are 19 rather than 20 drivers because one classified driver has no recorded racing lap. Your explanation should identify why an INNER JOIN from lap_times naturally produces that result.

Important
This is a baseline, not yet a fair measure of representative race pace.

Hint
Use COUNT(*) and AVG(lap_time_seconds), then group by the name fields.
*/

USE F1Silverstone;
GO

-- Write your query below this line.

SELECT COUNT(*) AS recorded_laps, 
    CONCAT(drivers.given_name, ' ', drivers.family_name) AS full_name,
       AVG(lap_time_seconds) AS raw_average_seconds
FROM f1.lap_times AS lap_times
INNER JOIN f1.drivers AS drivers
ON lap_times.driver_id = drivers.driver_id
GROUP BY drivers.given_name, drivers.family_name
ORDER BY raw_average_seconds ASC;