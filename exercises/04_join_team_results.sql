/*
SMALL WIN 04 — Add team context (20–25 minutes)

Goal
Use two joins while protecting the one-row-per-driver result grain.

Stakeholder question
Which team did each driver represent, and what were their finishing position and points?

Your task
Join race_results to drivers and constructors. Return full_name, constructor_name, finish_position and points. Order by constructor_name, then finish_position.

Expected shape
20 rows | full_name | constructor_name | finish_position | points

Success check
The output contains 20 drivers and 10 distinct constructors.

Hint
Both foreign keys needed for this task are already in f1.race_results.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT
    CONCAT(d.given_name, ' ', d.family_name) AS full_name,
    c.constructor_name,
    rr.finish_position,
    rr.points
FROM f1.race_results AS rr
INNER JOIN f1.drivers AS d
    ON d.driver_id = rr.driver_id
INNER JOIN f1.constructors AS c
    ON c.constructor_id = rr.constructor_id
ORDER BY c.constructor_name, rr.finish_position;
