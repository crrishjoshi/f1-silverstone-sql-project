/*
SMALL WIN 08A — Remove pit-affected laps (20–30 minutes)

Goal
Build one reusable filtered lap set without adding the pace threshold yet.

Rule for this step
Keep a lap only when:
  1. lap_number is greater than 1;
  2. it is not a published pit-stop lap;
  3. it is not the lap immediately after a published pit stop.

Your task
Apply the rule and return driver_id plus usable_laps_after_pit_filter, ordered from the highest count to the lowest.

Expected shape
19 rows | driver_id | usable_laps_after_pit_filter

Success check
Every count is lower than or equal to that driver's recorded lap count from exercise 05.

Hints
- NOT EXISTS is useful for excluding a matching stop without multiplying lap rows.
- For a current lap L, remove a stop whose lap_number is L or L - 1.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT
lt.driver_id,

COUNT(*) AS usable_laps_after_pit_filter
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
GROUP BY lt.driver_id
ORDER BY usable_laps_after_pit_filter DESC;
