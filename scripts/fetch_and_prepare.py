#!/usr/bin/env python3
"""Download and normalise the 2024 British Grand Prix Jolpica data.

Uses only the Python standard library so the extract is easy to reproduce.
The script intentionally fails if the source identity or expected record totals
change, preventing a partial API response from becoming a plausible-looking load.
"""

from __future__ import annotations

import argparse
import csv
import copy
import json
from pathlib import Path
from typing import Any, Iterable
from urllib.request import Request, urlopen


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
IMPORT_DIR = PROJECT_ROOT / "data" / "import"
BASE_URL = "https://api.jolpi.ca/ergast/f1/2024/12"
ENDPOINTS = {
    "results": f"{BASE_URL}/results/?limit=100",
    "pitstops": f"{BASE_URL}/pitstops/?limit=100",
}
EXPECTED_TOTALS = {"results": 20, "laps": 960, "pitstops": 45}
RACE_ID = 202412


def fetch_json(url: str) -> dict[str, Any]:
    request = Request(url, headers={"User-Agent": "Crrish-Joshi-SQL-Portfolio/1.0"})
    with urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def source_race(payload: dict[str, Any]) -> dict[str, Any]:
    races = payload["MRData"]["RaceTable"]["Races"]
    if len(races) != 1:
        raise ValueError(f"Expected one race, received {len(races)}")
    race = races[0]
    if race.get("season") != "2024" or race.get("round") != "12":
        raise ValueError("Source is not 2024 round 12")
    if race.get("raceName") != "British Grand Prix":
        raise ValueError(f"Unexpected race name: {race.get('raceName')!r}")
    return race


def validate_total(name: str, payload: dict[str, Any]) -> None:
    actual = int(payload["MRData"]["total"])
    expected = EXPECTED_TOTALS[name]
    if actual != expected:
        raise ValueError(
            f"{name}: expected source total {expected}, received {actual}. "
            "Review the API response before updating EXPECTED_TOTALS."
        )


def validate_combined_laps(payload: dict[str, Any]) -> None:
    validate_total("laps", payload)
    race = source_race(payload)
    keys = [
        (int(lap["number"]), timing["driverId"])
        for lap in race["Laps"]
        for timing in lap["Timings"]
    ]
    if len(keys) != EXPECTED_TOTALS["laps"] or len(set(keys)) != len(keys):
        raise ValueError(
            f"Cached laps must contain {EXPECTED_TOTALS['laps']} unique records; "
            f"received {len(keys)} records and {len(set(keys))} unique keys"
        )


def fetch_all_laps(refresh: bool) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    cached_path = RAW_DIR / "laps.json"
    if cached_path.exists() and not refresh:
        cached = json.loads(cached_path.read_text(encoding="utf-8"))
        validate_combined_laps(cached)
        print("Using validated cached lap data")
        return cached, []

    first_page = fetch_json(f"{BASE_URL}/laps/?limit=100&offset=0")
    validate_total("laps", first_page)
    source_race(first_page)

    total = int(first_page["MRData"]["total"])
    page_size = int(first_page["MRData"]["limit"])
    pages: list[dict[str, Any]] = []
    timings_by_lap: dict[int, list[dict[str, Any]]] = {}
    seen_keys: set[tuple[int, str]] = set()

    for offset in range(0, total, page_size):
        page = first_page if offset == 0 else fetch_json(
            f"{BASE_URL}/laps/?limit={page_size}&offset={offset}"
        )
        validate_total("laps", page)
        race = source_race(page)
        if int(page["MRData"]["offset"]) != offset:
            raise ValueError(f"Expected lap offset {offset}, received {page['MRData']['offset']}")
        pages.append(page)

        for lap in race["Laps"]:
            lap_number = int(lap["number"])
            for timing in lap["Timings"]:
                key = (lap_number, timing["driverId"])
                if key in seen_keys:
                    raise ValueError(f"Duplicate paginated lap timing: {key}")
                seen_keys.add(key)
                timings_by_lap.setdefault(lap_number, []).append(timing)

    if len(seen_keys) != total:
        raise ValueError(f"Expected {total} unique lap timings, assembled {len(seen_keys)}")

    combined = copy.deepcopy(first_page)
    combined["MRData"]["limit"] = str(total)
    combined["MRData"]["offset"] = "0"
    combined_race = combined["MRData"]["RaceTable"]["Races"][0]
    combined_race["Laps"] = [
        {
            "number": str(lap_number),
            "Timings": sorted(timings, key=lambda item: int(item["position"])),
        }
        for lap_number, timings in sorted(timings_by_lap.items())
    ]
    validate_combined_laps(combined)
    return combined, pages


def lap_time_to_ms(value: str) -> int:
    minutes_text, seconds_text = value.split(":", maxsplit=1)
    return round((int(minutes_text) * 60 + float(seconds_text)) * 1000)


def seconds_to_ms(value: str) -> int | None:
    if value == "":
        return None
    return round(float(value) * 1000)


def write_csv(path: Path, fieldnames: list[str], rows: Iterable[dict[str, Any]]) -> int:
    row_list = list(rows)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            extrasaction="raise",
            quoting=csv.QUOTE_MINIMAL,
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(row_list)
    return len(row_list)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--refresh",
        action="store_true",
        help="Ignore the validated raw snapshot and download the API responses again.",
    )
    args = parser.parse_args()

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    IMPORT_DIR.mkdir(parents=True, exist_ok=True)

    payloads: dict[str, dict[str, Any]] = {}
    for name, url in ENDPOINTS.items():
        raw_path = RAW_DIR / f"{name}.json"
        if raw_path.exists() and not args.refresh:
            payload = json.loads(raw_path.read_text(encoding="utf-8"))
            print(f"Using validated cached {name} data")
        else:
            payload = fetch_json(url)
        validate_total(name, payload)
        source_race(payload)
        payloads[name] = payload
        raw_path.write_text(
            json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    laps_payload, lap_pages = fetch_all_laps(args.refresh)
    payloads["laps"] = laps_payload
    (RAW_DIR / "laps.json").write_text(
        json.dumps(laps_payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    pages_dir = RAW_DIR / "lap-pages"
    pages_dir.mkdir(exist_ok=True)
    for page in lap_pages:
        offset = int(page["MRData"]["offset"])
        (pages_dir / f"laps_offset_{offset:04d}.json").write_text(
            json.dumps(page, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    race = source_race(payloads["results"])
    circuit = race["Circuit"]
    location = circuit["Location"]
    results = race["Results"]

    drivers: dict[str, dict[str, Any]] = {}
    constructors: dict[str, dict[str, Any]] = {}
    result_rows: list[dict[str, Any]] = []

    for result in results:
        driver = result["Driver"]
        constructor = result["Constructor"]
        drivers[driver["driverId"]] = {
            "driver_id": driver["driverId"],
            "permanent_number": driver.get("permanentNumber", ""),
            "driver_code": driver.get("code", ""),
            "given_name": driver["givenName"],
            "family_name": driver["familyName"],
            "date_of_birth": driver["dateOfBirth"],
            "nationality": driver["nationality"],
        }
        constructors[constructor["constructorId"]] = {
            "constructor_id": constructor["constructorId"],
            "constructor_name": constructor["name"],
            "nationality": constructor["nationality"],
        }

        fastest_lap = result.get("FastestLap", {})
        fastest_time = fastest_lap.get("Time", {}).get("time", "")
        result_rows.append(
            {
                "race_id": RACE_ID,
                "driver_id": driver["driverId"],
                "constructor_id": constructor["constructorId"],
                "car_number": result.get("number", ""),
                "grid_position": result.get("grid", ""),
                "finish_position": result.get("position", ""),
                "position_text": result.get("positionText", ""),
                "points": result.get("points", ""),
                "laps_completed": result.get("laps", ""),
                "status": result.get("status", ""),
                "race_time_ms": result.get("Time", {}).get("millis", ""),
                "race_time_text": result.get("Time", {}).get("time", ""),
                "fastest_lap_rank": fastest_lap.get("rank", ""),
                "fastest_lap_number": fastest_lap.get("lap", ""),
                "fastest_lap_time_ms": lap_time_to_ms(fastest_time) if fastest_time else "",
                "fastest_lap_speed_kph": fastest_lap.get("AverageSpeed", {}).get("speed", ""),
            }
        )

    lap_race = source_race(payloads["laps"])
    lap_rows: list[dict[str, Any]] = []
    for lap in lap_race["Laps"]:
        for timing in lap["Timings"]:
            lap_ms = lap_time_to_ms(timing["time"])
            lap_rows.append(
                {
                    "race_id": RACE_ID,
                    "driver_id": timing["driverId"],
                    "lap_number": lap["number"],
                    "position_at_lap": timing["position"],
                    "lap_time_ms": lap_ms,
                    "lap_time_seconds": f"{lap_ms / 1000:.3f}",
                }
            )

    pit_race = source_race(payloads["pitstops"])
    pit_rows: list[dict[str, Any]] = []
    for pit in pit_race["PitStops"]:
        duration_ms = seconds_to_ms(pit["duration"])
        pit_rows.append(
            {
                "race_id": RACE_ID,
                "driver_id": pit["driverId"],
                "stop_number": pit["stop"],
                "lap_number": pit["lap"],
                "pit_clock_time": pit["time"],
                "duration_ms": duration_ms if duration_ms is not None else "",
                "duration_seconds": f"{duration_ms / 1000:.3f}" if duration_ms is not None else "",
            }
        )

    counts = {
        "races": write_csv(
            PROCESSED_DIR / "races.csv",
            [
                "race_id",
                "season",
                "round_number",
                "race_name",
                "race_date",
                "circuit_id",
                "circuit_name",
                "locality",
                "country",
            ],
            [
                {
                    "race_id": RACE_ID,
                    "season": race["season"],
                    "round_number": race["round"],
                    "race_name": race["raceName"],
                    "race_date": race["date"],
                    "circuit_id": circuit["circuitId"],
                    "circuit_name": circuit["circuitName"],
                    "locality": location["locality"],
                    "country": location["country"],
                }
            ],
        ),
        "drivers": write_csv(
            PROCESSED_DIR / "drivers.csv",
            [
                "driver_id",
                "permanent_number",
                "driver_code",
                "given_name",
                "family_name",
                "date_of_birth",
                "nationality",
            ],
            sorted(drivers.values(), key=lambda row: row["driver_id"]),
        ),
        "constructors": write_csv(
            PROCESSED_DIR / "constructors.csv",
            ["constructor_id", "constructor_name", "nationality"],
            sorted(constructors.values(), key=lambda row: row["constructor_id"]),
        ),
        "race_results": write_csv(
            PROCESSED_DIR / "race_results.csv",
            [
                "race_id",
                "driver_id",
                "constructor_id",
                "car_number",
                "grid_position",
                "finish_position",
                "position_text",
                "points",
                "laps_completed",
                "status",
                "race_time_ms",
                "race_time_text",
                "fastest_lap_rank",
                "fastest_lap_number",
                "fastest_lap_time_ms",
                "fastest_lap_speed_kph",
            ],
            sorted(result_rows, key=lambda row: int(row["finish_position"])),
        ),
        "lap_times": write_csv(
            PROCESSED_DIR / "lap_times.csv",
            [
                "race_id",
                "driver_id",
                "lap_number",
                "position_at_lap",
                "lap_time_ms",
                "lap_time_seconds",
            ],
            lap_rows,
        ),
        "pit_stops": write_csv(
            PROCESSED_DIR / "pit_stops.csv",
            [
                "race_id",
                "driver_id",
                "stop_number",
                "lap_number",
                "pit_clock_time",
                "duration_ms",
                "duration_seconds",
            ],
            pit_rows,
        ),
    }

    expected_counts = {
        "races": 1,
        "drivers": 20,
        "constructors": 10,
        "race_results": 20,
        "lap_times": EXPECTED_TOTALS["laps"],
        "pit_stops": EXPECTED_TOTALS["pitstops"],
    }
    if counts != expected_counts:
        raise ValueError(f"Processed counts differ: expected {expected_counts}, received {counts}")

    for source_path in sorted(PROCESSED_DIR.glob("*.csv")):
        source_text = source_path.read_text(encoding="utf-8")
        with (IMPORT_DIR / source_path.name).open(
            "w", encoding="utf-16", newline=""
        ) as import_handle:
            import_handle.write(source_text)

    print("Prepared Silverstone 2024 data:")
    for name, count in counts.items():
        print(f"  {name}: {count}")


if __name__ == "__main__":
    main()

