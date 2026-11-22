USE F1Silverstone;
GO
SET NOCOUNT ON;

DECLARE @failures TABLE (check_name NVARCHAR(100), observed_value INT, expected_value INT);

INSERT INTO @failures
SELECT 'races row count', COUNT(*), 1 FROM f1.races HAVING COUNT(*) <> 1;
INSERT INTO @failures
SELECT 'drivers row count', COUNT(*), 20 FROM f1.drivers HAVING COUNT(*) <> 20;
INSERT INTO @failures
SELECT 'constructors row count', COUNT(*), 10 FROM f1.constructors HAVING COUNT(*) <> 10;
INSERT INTO @failures
SELECT 'race_results row count', COUNT(*), 20 FROM f1.race_results HAVING COUNT(*) <> 20;
INSERT INTO @failures
SELECT 'lap_times row count', COUNT(*), 960 FROM f1.lap_times HAVING COUNT(*) <> 960;
INSERT INTO @failures
SELECT 'pit_stops row count', COUNT(*), 45 FROM f1.pit_stops HAVING COUNT(*) <> 45;

INSERT INTO @failures
SELECT 'lap_times orphan drivers', COUNT(*), 0
FROM f1.lap_times lt
LEFT JOIN f1.drivers d ON d.driver_id = lt.driver_id
WHERE d.driver_id IS NULL
HAVING COUNT(*) <> 0;

INSERT INTO @failures
SELECT 'pit_stops orphan drivers', COUNT(*), 0
FROM f1.pit_stops ps
LEFT JOIN f1.drivers d ON d.driver_id = ps.driver_id
WHERE d.driver_id IS NULL
HAVING COUNT(*) <> 0;

INSERT INTO @failures
SELECT 'implausible lap durations', COUNT(*), 0
FROM f1.lap_times
WHERE lap_time_seconds < 60 OR lap_time_seconds > 300
HAVING COUNT(*) <> 0;

INSERT INTO @failures
SELECT 'missing pit-stop durations', COUNT(*), 1
FROM f1.pit_stops
WHERE duration_seconds IS NULL
HAVING COUNT(*) <> 1;

INSERT INTO @failures
SELECT 'invalid reported pit-stop durations', COUNT(*), 0
FROM f1.pit_stops
WHERE duration_seconds IS NOT NULL AND duration_seconds <= 0
HAVING COUNT(*) <> 0;

INSERT INTO @failures
SELECT 'UTF-8 driver name', COUNT(*), 1
FROM f1.drivers
WHERE driver_id = 'hulkenberg' AND family_name = N'Hülkenberg'
HAVING COUNT(*) <> 1;

IF EXISTS (SELECT 1 FROM @failures)
BEGIN
    SELECT * FROM @failures ORDER BY check_name;
    THROW 51000, 'F1Silverstone database quality checks failed.', 1;
END;

SELECT 'PASS' AS quality_status, 'All database checks passed' AS detail;

SELECT 'races' AS table_name, COUNT_BIG(*) AS row_count FROM f1.races
UNION ALL SELECT 'drivers', COUNT_BIG(*) FROM f1.drivers
UNION ALL SELECT 'constructors', COUNT_BIG(*) FROM f1.constructors
UNION ALL SELECT 'race_results', COUNT_BIG(*) FROM f1.race_results
UNION ALL SELECT 'lap_times', COUNT_BIG(*) FROM f1.lap_times
UNION ALL SELECT 'pit_stops', COUNT_BIG(*) FROM f1.pit_stops;
GO

