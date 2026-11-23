/*
SMALL WIN 01 — Meet the data (15–20 minutes)

Goal
Understand the size and grain of the supplied tables before analysing them.

Your task
Return one row for each of these tables with table_name and row_count:
  races, drivers, constructors, race_results, lap_times, pit_stops.

Expected shape
6 rows | table_name | row_count

Success check
The six counts should be 1, 20, 10, 20, 960 and 45, matched to the right tables.

Why this matters
A Business Analyst should establish what one row represents and whether the load is complete before trusting a calculation.

Hint
Write six COUNT(*) queries and combine their result sets with UNION ALL.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT 'races' AS table_name, COUNT(*) AS row_count FROM f1.races
UNION ALL
SELECT 'drivers', COUNT(*) FROM f1.drivers
UNION ALL
SELECT 'constructors', COUNT(*) FROM f1.constructors
UNION ALL
SELECT 'race_results', COUNT(*) FROM f1.race_results
UNION ALL
SELECT 'lap_times', COUNT(*) FROM f1.lap_times
UNION ALL
SELECT 'pit_stops', COUNT(*) FROM f1.pit_stops;
