# Data dictionary

All tables use the `f1` schema in the `F1Silverstone` SQL Server database.

## `f1.races`

One row per race. `race_id` is a project key built as `season * 100 + round_number`; this extract contains `202412`.

## `f1.drivers`

One row per driver appearing in the race result. `driver_id` is Jolpica's stable text identifier.

## `f1.constructors`

One row per constructor appearing in the race result.

## `f1.race_results`

One row per driver result for the race. It contains grid position, classified finish, completed laps, status, points and the published fastest-lap fields where available.

`race_time_ms` is the total recorded elapsed time when supplied. Do not compare this field blindly for drivers who completed different lap counts.

## `f1.lap_times`

One row per recorded driver-lap. Its composite primary key is `race_id + driver_id + lap_number`.

- `position_at_lap`: published position at the end of that lap
- `lap_time_ms`: lap duration in milliseconds
- `lap_time_seconds`: the same duration in decimal seconds for readable calculations

## `f1.pit_stops`

One row per published pit-stop record. Its composite primary key is `race_id + driver_id + stop_number`.

- `lap_number`: lap associated with the stop
- `pit_clock_time`: published clock time
- `duration_ms` / `duration_seconds`: published duration converted into numeric forms

The duration field should be described as the source's published pit-stop duration. Do not label it stationary tyre-change time without further evidence.

One source record—Yuki Tsunoda's lap 27 stop—has no published duration. It is retained with `NULL` duration fields rather than removed or estimated.

## Relationships

For the complete visual map with key fields and a legend, open the [entity relationship diagram](entity-relationship-diagram.md).

```text
races 1 ───< race_results >─── 1 drivers
                  │
                  └─────────── 1 constructors

races 1 ───< lap_times >────── 1 drivers
races 1 ───< pit_stops >────── 1 drivers
```

