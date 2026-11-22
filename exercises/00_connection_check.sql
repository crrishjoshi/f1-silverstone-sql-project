/*
SMALL WIN 00 — Connection check (5–10 minutes)

Goal
Prove that VS Code is connected to the local F1Silverstone database.

Your task
Write one SELECT statement that returns:
  1. the current database name as database_name;
  2. the SQL Server version as server_version;
  3. today's date as checked_on.

Expected shape
Exactly one row and three columns.

Success check
database_name must be F1Silverstone.

Hint
Search the course material for DB_NAME(), @@VERSION and CAST(GETDATE() AS date).
*/

USE F1Silverstone;
GO

-- Write your query below this line.

