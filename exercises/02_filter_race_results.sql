/*
SMALL WIN 02 — Filter and order results (15–20 minutes)

Goal
Practise SELECT, WHERE and ORDER BY on a real race table.

Stakeholder question
Which drivers finished in the points-paying top ten, and how many points did each score?

Your task
Use only f1.race_results. Return driver_id, finish_position, points, laps_completed and status for finish positions 1–10, ordered from first to tenth.

Expected shape
10 rows | driver_id | finish_position | points | laps_completed | status

Success check
Every returned finish_position is between 1 and 10 and appears once.

Hint
Filter the numeric finish_position column, not position_text.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT
    driver_id,
    finish_position,
    points,
    laps_completed,
    status
FROM f1.race_results
WHERE finish_position BETWEEN 1 AND 10
ORDER BY finish_position ASC;
