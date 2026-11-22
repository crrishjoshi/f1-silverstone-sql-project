# F1 Silverstone SQL Project Implementation Plan

> **Execution:** Implement natively in this session. The user authorised implementation after reviewing the interpreted scope.

**Goal:** Build a reproducible SQL Server learning project from public 2024 British Grand Prix data, with exercises that each take no more than 30 minutes.

**Architecture:** A standard-library Python script downloads three versioned Jolpica responses and transforms them into six relational CSVs. SQL Server setup scripts create a dedicated database and bulk-load those CSVs into normalised tables. Learner files contain prompts rather than completed answers, while independent checks verify the supplied environment.

**Tech Stack:** Python 3, Microsoft SQL Server 2022, Docker, VS Code MSSQL extension, T-SQL, Markdown

**Spec:** `docs/project-brief.md`

## Global constraints

- Preserve all pre-existing files in `/Users/crrishjoshi/Documents/SQL`.
- Use the existing `sqlserver-express` container and its persistent volume.
- Store no database password in the project.
- Use only public non-commercial data with attribution.
- Keep each learner exercise to one main outcome and at most 30 minutes.
- Do not include complete solutions beside learner prompts.

## Review focus

- API pagination or nested-shape changes must fail with a clear validation error rather than silently load partial data.
- Re-running setup must affect only the dedicated `F1Silverstone` project tables.
- CSV numeric and `NULL` values must load without locale-dependent conversion.
- Foreign keys and row-count checks must detect incomplete imports.
- Portfolio copy must not imply employment, endorsement or confidential F1 access.

---

### Task 1: Data acquisition and provenance

**Files:** `scripts/fetch_and_prepare.py`, `DATA_SOURCE.md`, `data/raw/*`, `data/processed/*`

- [ ] Download results, laps and pit stops from fixed 2024 round 12 endpoints.
- [ ] Validate race identity and expected source record totals.
- [ ] Preserve raw JSON and create six import-ready CSVs.
- [ ] Document retrieval, transformation, licence, attribution and limitations.

### Task 2: SQL Server database

**Files:** `sql/setup/*.sql`, `scripts/setup_local.sh`, `sql/checks/01_database_quality.sql`

- [ ] Create the dedicated database and `f1` schema.
- [ ] Create six related tables with keys and numeric data types.
- [ ] Copy generated CSVs into the container and bulk-load them.
- [ ] Verify row counts, uniqueness, foreign keys and duration ranges.

### Task 3: Bite-sized learning path

**Files:** `exercises/00_connection_check.sql` through `exercises/14_final_insight_query.sql`, including split exercises 08A/08B, plus `PROGRESS.md`

- [ ] Progress from connection and table exploration through filters, joins and aggregation.
- [ ] Split pace cleaning into separate pit-lap, personal-best and combined-filter exercises.
- [ ] Add consistency, team-mate, outcome, pit and window-function tasks.
- [ ] State output shape, success checks and hints without publishing answers.

### Task 4: VS Code and portfolio hand-off

**Files:** `.vscode/*`, `README.md`, `portfolio/*`

- [ ] Add the local password-free MSSQL connection profile.
- [ ] Open the project in VS Code and verify SQL Server connectivity.
- [ ] Provide an evidence log and LinkedIn template with guarded claims.

### Task 5: End-to-end verification

- [ ] Run the preparation script from a clean generated-data state.
- [ ] Run the local setup script twice to prove repeatability.
- [ ] Execute the independent SQL quality checks.
- [ ] Confirm all exercise files contain a single scoped outcome and no completed solution.

