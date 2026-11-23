# Data source, licence and limitations

## Source

Data was retrieved from the volunteer-run [Jolpica F1 API](https://github.com/jolpica/jolpica-f1), the open-source successor to the Ergast API.

Retrieval date: **6 November 2026**

Endpoints:

- `https://api.jolpi.ca/ergast/f1/2024/12/results/?limit=100`
- `https://api.jolpi.ca/ergast/f1/2024/12/laps/?limit=100&offset=0` through offset `900`
- `https://api.jolpi.ca/ergast/f1/2024/12/pitstops/?limit=100`

The raw JSON responses are retained in `data/raw/`. Jolpica caps the lap endpoint at 100 timing records per response, so the preparation script retrieves ten pages, verifies every `(lap_number, driver_id)` pair is unique, and assembles 960 records before conversion. The script converts the nested responses into six relational CSV files without changing the source measurements.

Normal database rebuilds use the validated local raw snapshot. A deliberate API refresh requires the script's `--refresh` flag, which avoids unnecessary requests to the volunteer-run service.

The readable processed CSVs are UTF-8. During setup, the same rows are also written as generated UTF-16 files in `data/import/`, allowing SQL Server on Linux to use its supported `widechar` bulk-import mode without corrupting names containing extended characters.

## Licence and attribution

Jolpica makes its API data available for non-commercial use under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence](https://creativecommons.org/licenses/by-nc-sa/4.0/). Use of the API is also subject to the [Jolpica terms](https://github.com/jolpica/jolpica-f1/blob/main/TERMS.md).

Required attribution for any GitHub repository, dashboard or LinkedIn post:

> Race timing, result and pit-stop data: Jolpica F1 API, used under CC BY-NC-SA 4.0. Independent educational analysis; not affiliated with Formula 1 or any team.

If the project later becomes commercial, do not assume this data licence still permits that use; obtain appropriate permission or replace the source.

## Important limitations

- Jolpica states that it does not guarantee complete accuracy or uninterrupted availability.
- This extract contains published lap timing, results and pit-stop records—not confidential team telemetry.
- It does not include tyre compound, weather, fuel load, traffic, safety-car state or car damage.
- One of the 45 pit-stop records has a blank source duration. The record is retained and its numeric duration is loaded as `NULL`.
- A slow lap is not automatically poor driver performance. It may reflect traffic, changing conditions, race control or strategy.
- Average lap time alone is a weak performance measure. The project therefore compares raw averages with a clearly defined cleaned-lap method.
- Drivers completed different numbers of laps, and some retired or did not start. Results must be interpreted in context.
- Average lap times can be skewed when drivers record a small number of quick laps before retiring.
- Lap times may be affected by a tow, traffic or wheel-to-wheel racing.
- Published timing may not reveal every deleted lap or track-limits decision.

These limitations should appear in the final portfolio write-up. Identifying them is part of the analysis, not a weakness to hide.

