# Entity relationship diagram

This diagram shows the six tables in the `f1` schema and how their primary and foreign keys connect. It deliberately shows the main analytical fields rather than every column; the complete definitions are in [the data dictionary](data-dictionary.md) and [`01_create_tables.sql`](../sql/setup/01_create_tables.sql).

```mermaid
erDiagram
    RACES ||--o{ RACE_RESULTS : has
    DRIVERS ||--o{ RACE_RESULTS : receives
    CONSTRUCTORS ||--o{ RACE_RESULTS : enters
    RACES ||--o{ LAP_TIMES : contains
    DRIVERS ||--o{ LAP_TIMES : records
    RACES ||--o{ PIT_STOPS : contains
    DRIVERS ||--o{ PIT_STOPS : makes

    RACES {
        int race_id PK
        smallint season
        tinyint round_number
        nvarchar race_name
        date race_date
        varchar circuit_id
    }

    DRIVERS {
        varchar driver_id PK
        smallint permanent_number
        char driver_code
        nvarchar given_name
        nvarchar family_name
        nvarchar nationality
    }

    CONSTRUCTORS {
        varchar constructor_id PK
        nvarchar constructor_name
        nvarchar nationality
    }

    RACE_RESULTS {
        int race_id PK, FK
        varchar driver_id PK, FK
        varchar constructor_id FK
        tinyint grid_position
        tinyint finish_position
        decimal points
        tinyint laps_completed
        int fastest_lap_time_ms
    }

    LAP_TIMES {
        int race_id PK, FK
        varchar driver_id PK, FK
        tinyint lap_number PK
        tinyint position_at_lap
        int lap_time_ms
        decimal lap_time_seconds
    }

    PIT_STOPS {
        int race_id PK, FK
        varchar driver_id PK, FK
        tinyint stop_number PK
        tinyint lap_number
        time pit_clock_time
        int duration_ms
        decimal duration_seconds
    }
```

## How to read it

- `||` means exactly one parent row.
- `o{` means zero or many related child rows.
- `PK` identifies a primary-key column.
- `FK` identifies a foreign-key column.
- A column marked `PK, FK` is part of a composite primary key and also links to a parent table.

For example, one driver can have many lap-time rows, but each lap-time row belongs to exactly one driver. The combination of `race_id`, `driver_id` and `lap_number` uniquely identifies a lap.
