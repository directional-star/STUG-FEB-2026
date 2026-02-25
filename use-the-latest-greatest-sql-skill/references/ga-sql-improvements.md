# Snowflake GA SQL shortlist (validated on February 24, 2026)

Use this shortlist to prefer concise, generally available SQL constructs.

## High-impact GA features for leaner SQL

1. `DIRECTED` keyword in `JOIN` is generally available (October 2025).
2. `ORDER BY ALL` for sorting by the full SELECT list (July 2025 SQL improvement).
3. `UNION [ALL] BY NAME` for name-based column matching (June 2025 SQL improvement).
4. Pipe operator `->>` for chaining dependent statements (May 2025 SQL improvement; flow operators reference).
5. `MERGE` with `UPDATE ALL BY NAME` and `INSERT ALL BY NAME` (September/October 2025 SQL updates).
6. `SEARCH` and `SEARCH_IP` full-text/IPv4 search are generally available (November 2024).
7. Higher-order functions `FILTER`, `TRANSFORM`, and `REDUCE` for concise semi-structured transforms (`REDUCE` called out in October 2024 SQL improvements).
8. `ASOF JOIN` for time-series nearest-match join logic (May 2024 SQL improvement).
9. `GREATEST_IGNORE_NULLS` and `LEAST_IGNORE_NULLS` for null-tolerant min/max across expressions (March 2024).

## GA caveats

- `RESAMPLE` is still marked as a Preview Feature in SQL reference. Do not use by default.
- If account edition/region/rollout lags, provide a fallback statement.

## Verification rule for this skill

Before using any feature not listed above:
1. Check docs.snowflake.com release notes or SQL reference.
2. Confirm it is GA or not marked preview.
3. If uncertain, do not use by default.
