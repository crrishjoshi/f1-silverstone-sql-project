/*
SMALL WIN 03 — Join drivers to results (20–25 minutes)

Goal
Replace technical driver IDs with names without duplicating results.

Stakeholder question
What was every driver's grid position and classified finishing position?

Your task
INNER JOIN f1.race_results to f1.drivers. Return a full_name made from given_name and family_name, plus grid_position, finish_position and status. Order by finish_position.

Expected shape
20 rows | full_name | grid_position | finish_position | status

Success check
There must still be exactly 20 rows after the join.

Hint
The matching column is driver_id. CONCAT() can create full_name.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT
    CONCAT(d.given_name, ' ', d.family_name) AS full_name,
    rr.grid_position,
    rr.finish_position,
    rr.status
FROM f1.race_results AS rr
INNER JOIN f1.drivers AS d
    ON d.driver_id = rr.driver_id
ORDER BY rr.finish_position ASC;
