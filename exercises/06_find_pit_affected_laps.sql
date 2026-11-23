/*
SMALL WIN 06 — Find pit-affected laps (20–30 minutes)

Goal
Use a multi-column join to locate laps likely to distort pace averages.

Stakeholder question
Which recorded lap corresponds to each driver's published pit-stop lap?

Your task
Join pit_stops to lap_times using race_id, driver_id and lap_number, then join drivers. Return full_name, stop_number, lap_number, duration_seconds and lap_time_seconds. Order by lap_number and full_name.

Expected shape
45 rows | full_name | stop_number | lap_number | duration_seconds | lap_time_seconds

Success check
The join produces exactly one lap for every pit-stop record—45 rows, not more.

Analytical note
This flags the lap containing the published stop. In a later task you will decide how to treat the following lap as a possible out-lap.

Hint
Joining only on driver_id would match every stop to every lap for that driver. Use all three keys stated above.
*/

USE F1Silverstone;
GO

-- Write your query below this line.

SELECT CONCAT(drivers.given_name, ' ', drivers.family_name) AS full_name,
f1.pit_stops.stop_number,
f1.pit_stops.lap_number,
f1.pit_stops.duration_seconds,
f1.lap_times.lap_time_seconds
       FROM f1.pit_stops
       JOIN f1.lap_times
         ON pit_stops.race_id = lap_times.race_id
AND pit_stops.driver_id = lap_times.driver_id
AND pit_stops.lap_number = lap_times.lap_number

         JOIN f1.drivers
            ON pit_stops.driver_id = drivers.driver_id

    ORDER BY lap_number, full_name;
