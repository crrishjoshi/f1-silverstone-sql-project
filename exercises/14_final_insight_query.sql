/*
SMALL WIN 14 — Answer your own stakeholder question (30 minutes)

Goal
Move from following instructions to making one justified analytical decision.

Choose ONE question
A. Which driver combined strong cleaned pace with high consistency?
- Lando Norris — SQL 09 and SQL 13
B. Which constructor had the strongest two-driver cleaned pace?
- McLaren — SQL 10
C. Which drivers' raw averages changed most after removing affected laps?
- Guanyu Zhou — comparison of SQL 05 with SQL 08B
D. Write your own question that this dataset can genuinely answer.

Your task
Write one final query whose output directly supports the chosen question. Above the query, add SQL comments containing:
  - the selected question;
  - the grain of one output row;
  - the filters or assumptions used;
  - one limitation that prevents overclaiming.

Expected shape
You define it, but every column must help answer the question.

Success check
You can explain every join, filter, grouping and calculated field without reading a generated answer.

Portfolio step
Record the resulting evidence and a careful interpretation in portfolio/insight-log.md. Do not publish a claim until its query has been checked.
*/

USE F1Silverstone;
GO

-- Write your documented final query below this line.
-- Selected question: Which driver combined strong cleaned pace with high consistency?
-- Row grain: One row per driver.
-- Filters: Lap 1, pit-stop laps, laps immediately after pit stops and laps slower than 107% of each driver's quickest lap are excluded.
-- Assumption: A lower average indicates stronger pace, while a lower standard deviation indicates greater consistency.
-- Limitation: The data does not control for tyres, traffic, fuel load, tow, weather, damage or strategy.

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
ORDER BY lap_time_stddev;
