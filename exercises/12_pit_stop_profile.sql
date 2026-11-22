/*
SMALL WIN 12 — Summarise pit-stop records (20–25 minutes)

Goal
Use grouping while preserving careful domain language.

Stakeholder question
How many published stops did each driver make, and what were their average and quickest published stop durations?

Your task
Join pit_stops to drivers. Return full_name, stop_count, durations_reported, average_duration_seconds and quickest_duration_seconds. Round averages to three decimals and order by stop_count descending, then average duration ascending.

Expected shape
One row per driver with at least one pit-stop record.

Success check
The sum of stop_count must equal 45, while the sum of durations_reported must equal 44. Explain why COUNT(*) and COUNT(duration_seconds) differ.

Wording rule
Call this field "published pit-stop duration". The dataset does not prove it is stationary tyre-change time.

Hint
Use COUNT(*), COUNT(duration_seconds), AVG(duration_seconds) and MIN(duration_seconds). SQL Server aggregates ignore NULL inputs except COUNT(*).
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT CONCAT (drv.given_name,' ',drv.family_name) as full_name,
COUNT (*) as stop_count,
COUNT(ps.duration_seconds) as durations_reported,
ROUND(AVG(ps.duration_seconds),3) as average_duration_seconds,
MIN(ps.duration_seconds) as quickest_duration_seconds
FROM f1.pit_stops as ps 
JOIN f1.drivers as drv
ON ps.driver_id=drv.driver_id
GROUP BY drv.given_name,drv.family_name
ORDER BY stop_count DESC, average_duration_seconds ASC;