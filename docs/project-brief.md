# Project brief

## Scenario

This is an independent practice scenario. A fictional race-performance stakeholder wants a repeatable view of driver pace and consistency from public 2024 British Grand Prix timing data.

## Business problem

Raw average lap time can mislead because pit-affected and unusually slow laps inflate the result. The stakeholder needs a transparent method that keeps the source data intact, states its assumptions and allows drivers or team-mates to be compared cautiously.

## Users

- Primary: fictional race-performance stakeholder
- Secondary: placement recruiter reviewing the candidate's analytical process
- Analyst: Crrish Joshi, BIS student

## Desired outcomes

1. Reproducibly load a public race dataset into SQL Server.
2. Compare raw and cleaned lap-time measures.
3. Examine consistency, pit-stop records and grid-to-finish movement.
4. Produce three findings whose evidence can be traced to SQL.
5. Explain limitations and avoid claiming causation that the data cannot prove.

## Scope

Included: the 2024 British Grand Prix race, drivers, constructors, final results, lap timings and pit stops.

Excluded: qualifying sessions, telemetry, tyre compounds, weather, radio, confidential strategy data, predictive modelling and live data.

## Acceptance criteria

- The `F1Silverstone` database is available in the existing local SQL Server Docker container.
- Six related tables load with expected row counts: 1 race, 20 drivers, 10 constructors, 20 results, 960 lap timings and 45 pit stops.
- No orphaned driver or race references exist.
- VS Code contains a password-free local MSSQL connection profile.
- Every learner exercise has one main outcome and is scoped to 30 minutes or less.
- Data source, retrieval date, licence, transformations and limitations are documented.
- Portfolio wording identifies the work as independent and unofficial.

