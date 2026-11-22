/*
SMALL WIN 11 — Grid-to-finish movement (15–25 minutes)

Goal
Use CASE to handle an important domain exception.

Stakeholder question
Among drivers who reached the finish, who gained or lost positions from the starting grid to the classified finish?

Your task
Join results to drivers. Return full_name, grid_position, finish_position, status and positions_changed. Define positions_changed as grid_position - finish_position for statuses Finished or Lapped, but return NULL for Retired or Did not start because their classified position is not a like-for-like finish.

Expected shape
20 rows | full_name | grid_position | finish_position | status | positions_changed

Success check
Positive values mean positions gained and negative values mean positions lost. Exactly two drivers have NULL positions_changed because they did not reach the finish.

Hint
Use CASE WHEN status IN ('Finished', 'Lapped') THEN grid_position - finish_position ELSE NULL END.
*/

USE F1Silverstone;
GO

-- Write your query below this line.
SELECT CONCAT(d.given_name, ' ', d.family_name) AS full_name,
       rs.grid_position,
       rs.finish_position,
        CASE 
        WHEN rs.status IN ('Finished', 'Lapped')
        THEN CAST (rs.grid_position AS INT) - CAST (rs.finish_position as INT)
        ELSE NULL
        END AS positions_changed
    FROM f1.race_results rs 
    JOIN f1.drivers d 
    ON rs.driver_id=d.driver_id