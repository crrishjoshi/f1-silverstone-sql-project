# Silverstone 2024: F1 Race Performance Analysis with SQL

An entry-level SQL Server portfolio project analysing the 2024 British Grand Prix at Silverstone. The project is designed for a Business Information Systems student targeting Business Analyst and motorsport placement roles.

The point is not to pretend to be an F1 performance engineer. It is to demonstrate that I can turn a stakeholder question into structured data, write and validate SQL, recognise analytical limitations, and communicate evidence clearly.

## Current status

The SQL project is complete and has been verified against the local SQL Server database. A Tableau dashboard is planned as a separate next phase and is not included in this release.

## Business question

> How can a race-performance stakeholder compare driver pace and consistency without allowing pit-affected or unusually slow laps to distort the conclusion?

The documented cleaning rule:

- removes lap 1 because its standing-start conditions are not comparable with a normal racing lap;
- excludes each published pit-stop lap and the immediately following lap;
- retains laps no slower than 107% of that driver's quickest recorded lap; and
- treats the result as a comparison aid, not proof of driver ability.

The public data does not contain tyre compounds or reliable safety-car, traffic, fuel-load and damage context, so those factors are limitations rather than filters claimed by the analysis.
## Why this race

- One race is small enough to understand and explain confidently.
- Silverstone is relevant to the UK motorsport industry.
- The race contains meaningful differences in pace, finishing position and pit-stop patterns.
- The source provides 960 recorded driver-laps, 45 pit-stop records and 20 race results.

## Technology

- Microsoft SQL Server 2022 in Docker
- VS Code with the Microsoft MSSQL extension
- Python 3 standard library for a reproducible extract-and-transform step
- Public historical data from the Jolpica F1 API
- Tableau dashboard planned as the final presentation layer

## Project structure

```text
data/raw/             Source API responses kept for traceability
data/processed/       Six import-ready CSV files
data/import/          Generated UTF-16 copies for Linux SQL Server bulk import
docs/                 Project brief, ER diagram, data dictionary and plan
exercises/            Numbered tasks, each intended to take 30 minutes or less
portfolio/            Evidence log and LinkedIn drafting template
scripts/              Reproducible data download and local setup
sql/setup/            Database, table and load scripts
sql/checks/           Independent database quality checks
```

## Start here

1. Confirm Docker Desktop is running and the `sqlserver-express` container is healthy.
2. Open this folder in VS Code.
3. Run `./scripts/setup_local.sh` from the VS Code terminal if the database ever needs rebuilding. It uses the validated local snapshot, so it does not repeatedly call the public API.
4. Open `exercises/00_connection_check.sql`.
5. Select the **F1 Silverstone Docker** connection profile. The MSSQL extension will ask for the existing local SQL Server `sa` password; it is deliberately not stored in this project.
6. Complete the exercises in numerical order and tick each win in `PROGRESS.md`.

Before writing joins, review the [entity relationship diagram](docs/entity-relationship-diagram.md) to see the table keys and one-to-many relationships.

The database has already been created and checked locally. Re-running the setup script is safe for this dedicated practice database, but it recreates the project tables and reloads their data.

To deliberately retrieve the source again, run `python3 scripts/fetch_and_prepare.py --refresh`. Avoid repeated refreshes because Jolpica applies public rate limits.

## What counts as a good answer

- The query runs against `F1Silverstone` using SQL Server syntax.
- The output columns and row grain match the task.
- Joins do not silently duplicate records.
- `NULL` values and retired/non-starting drivers are handled deliberately.
- Any filtering rule is explained in plain English.
- A finding distinguishes evidence from interpretation.

Each numbered file retains its task description and completed learner query so the progression can be inspected. Equivalent correct solutions count; the important test is whether the output and reasoning meet the stated requirement.

## Responsible portfolio use

This is an independent, non-commercial educational project. It is not associated with, sponsored by or endorsed by Formula 1, the FIA, the British Grand Prix, Silverstone or any team. Do not describe the data as team telemetry or claim access to confidential motorsport information.

See [DATA_SOURCE.md](DATA_SOURCE.md) for provenance, licence and limitations.

