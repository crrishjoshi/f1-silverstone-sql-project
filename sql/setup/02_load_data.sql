USE F1Silverstone;
GO

BULK INSERT f1.races
FROM '/tmp/f1-silverstone/data/races.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

BULK INSERT f1.drivers
FROM '/tmp/f1-silverstone/data/drivers.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

BULK INSERT f1.constructors
FROM '/tmp/f1-silverstone/data/constructors.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

BULK INSERT f1.race_results
FROM '/tmp/f1-silverstone/data/race_results.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2, FIELDQUOTE = '"', KEEPNULLS, TABLOCK);

BULK INSERT f1.lap_times
FROM '/tmp/f1-silverstone/data/lap_times.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

BULK INSERT f1.pit_stops
FROM '/tmp/f1-silverstone/data/pit_stops.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2, FIELDQUOTE = '"', KEEPNULLS, TABLOCK);
GO

