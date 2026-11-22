USE F1Silverstone;
GO

IF SCHEMA_ID(N'f1') IS NULL
    EXEC(N'CREATE SCHEMA f1');
GO

DROP TABLE IF EXISTS f1.pit_stops;
DROP TABLE IF EXISTS f1.lap_times;
DROP TABLE IF EXISTS f1.race_results;
DROP TABLE IF EXISTS f1.constructors;
DROP TABLE IF EXISTS f1.drivers;
DROP TABLE IF EXISTS f1.races;
GO

CREATE TABLE f1.races (
    race_id        INT           NOT NULL PRIMARY KEY,
    season         SMALLINT      NOT NULL,
    round_number   TINYINT       NOT NULL,
    race_name      NVARCHAR(100) NOT NULL,
    race_date      DATE          NOT NULL,
    circuit_id     VARCHAR(50)   NOT NULL,
    circuit_name   NVARCHAR(100) NOT NULL,
    locality       NVARCHAR(100) NOT NULL,
    country        NVARCHAR(100) NOT NULL
);

CREATE TABLE f1.drivers (
    driver_id         VARCHAR(50)   NOT NULL PRIMARY KEY,
    permanent_number  SMALLINT      NULL,
    driver_code       CHAR(3)       NULL,
    given_name        NVARCHAR(100) NOT NULL,
    family_name       NVARCHAR(100) NOT NULL,
    date_of_birth     DATE          NOT NULL,
    nationality       NVARCHAR(50)  NOT NULL
);

CREATE TABLE f1.constructors (
    constructor_id    VARCHAR(50)   NOT NULL PRIMARY KEY,
    constructor_name  NVARCHAR(100) NOT NULL,
    nationality       NVARCHAR(50)  NOT NULL
);

CREATE TABLE f1.race_results (
    race_id                 INT           NOT NULL,
    driver_id               VARCHAR(50)   NOT NULL,
    constructor_id          VARCHAR(50)   NOT NULL,
    car_number              SMALLINT      NOT NULL,
    grid_position           TINYINT       NOT NULL,
    finish_position         TINYINT       NOT NULL,
    position_text           VARCHAR(10)   NOT NULL,
    points                  DECIMAL(5, 1) NOT NULL,
    laps_completed          TINYINT       NOT NULL,
    status                  NVARCHAR(100) NOT NULL,
    race_time_ms            INT           NULL,
    race_time_text          VARCHAR(20)   NULL,
    fastest_lap_rank        TINYINT       NULL,
    fastest_lap_number      TINYINT       NULL,
    fastest_lap_time_ms     INT           NULL,
    fastest_lap_speed_kph   DECIMAL(7, 3) NULL,
    CONSTRAINT PK_race_results PRIMARY KEY (race_id, driver_id),
    CONSTRAINT FK_race_results_race FOREIGN KEY (race_id) REFERENCES f1.races(race_id),
    CONSTRAINT FK_race_results_driver FOREIGN KEY (driver_id) REFERENCES f1.drivers(driver_id),
    CONSTRAINT FK_race_results_constructor FOREIGN KEY (constructor_id) REFERENCES f1.constructors(constructor_id)
);

CREATE TABLE f1.lap_times (
    race_id          INT           NOT NULL,
    driver_id        VARCHAR(50)   NOT NULL,
    lap_number       TINYINT       NOT NULL,
    position_at_lap  TINYINT       NOT NULL,
    lap_time_ms      INT           NOT NULL,
    lap_time_seconds DECIMAL(7, 3) NOT NULL,
    CONSTRAINT PK_lap_times PRIMARY KEY (race_id, driver_id, lap_number),
    CONSTRAINT FK_lap_times_race FOREIGN KEY (race_id) REFERENCES f1.races(race_id),
    CONSTRAINT FK_lap_times_driver FOREIGN KEY (driver_id) REFERENCES f1.drivers(driver_id),
    CONSTRAINT CK_lap_times_positive CHECK (lap_time_ms > 0 AND lap_time_seconds > 0)
);

CREATE TABLE f1.pit_stops (
    race_id          INT           NOT NULL,
    driver_id        VARCHAR(50)   NOT NULL,
    stop_number      TINYINT       NOT NULL,
    lap_number       TINYINT       NOT NULL,
    pit_clock_time   TIME(0)       NOT NULL,
    duration_ms      INT           NULL,
    duration_seconds DECIMAL(7, 3) NULL,
    CONSTRAINT PK_pit_stops PRIMARY KEY (race_id, driver_id, stop_number),
    CONSTRAINT FK_pit_stops_race FOREIGN KEY (race_id) REFERENCES f1.races(race_id),
    CONSTRAINT FK_pit_stops_driver FOREIGN KEY (driver_id) REFERENCES f1.drivers(driver_id),
    CONSTRAINT CK_pit_stops_positive CHECK (
        (duration_ms IS NULL AND duration_seconds IS NULL)
        OR (duration_ms > 0 AND duration_seconds > 0)
    )
);

CREATE INDEX IX_lap_times_driver ON f1.lap_times(driver_id, lap_number);
CREATE INDEX IX_pit_stops_driver_lap ON f1.pit_stops(driver_id, lap_number);
GO

