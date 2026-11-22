#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINER_NAME="${F1_SQL_CONTAINER:-sqlserver-express}"
CONTAINER_STAGE="/tmp/f1-silverstone"

if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "Docker container '$CONTAINER_NAME' was not found." >&2
  exit 1
fi

if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME")" != "true" ]; then
  echo "Docker container '$CONTAINER_NAME' is not running." >&2
  exit 1
fi

python3 "$PROJECT_DIR/scripts/fetch_and_prepare.py"

docker exec "$CONTAINER_NAME" mkdir -p "$CONTAINER_STAGE/data" "$CONTAINER_STAGE/sql"
docker cp "$PROJECT_DIR/data/import/." "$CONTAINER_NAME:$CONTAINER_STAGE/data/"
docker cp "$PROJECT_DIR/sql/setup/." "$CONTAINER_NAME:$CONTAINER_STAGE/sql/"
docker cp "$PROJECT_DIR/sql/checks/." "$CONTAINER_NAME:$CONTAINER_STAGE/sql/checks/"

run_sql_file() {
  local file_name="$1"
  docker exec "$CONTAINER_NAME" bash -lc \
    '/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -i '"$CONTAINER_STAGE/sql/$file_name"
}

run_sql_file "00_create_database.sql"
run_sql_file "01_create_tables.sql"
run_sql_file "02_load_data.sql"
docker exec "$CONTAINER_NAME" bash -lc \
  '/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -i '"$CONTAINER_STAGE/sql/checks/01_database_quality.sql"

echo "F1Silverstone is loaded and verified in $CONTAINER_NAME."

