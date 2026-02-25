---
name: use-the-latest-greatest-sql-skill
description: Use this skill when writing or refactoring Snowflake SQL to reduce query complexity with the latest generally available SQL functions and commands from docs.snowflake.com, including modern SELECT constructs, joins, MERGE simplifications, and higher-order functions.
---

# What This Skill Provides

This skill enforces a GA-first approach for Snowflake SQL modernisation so queries become shorter, easier to maintain, and less error-prone.

It includes:
- A GA-only shortlist of modern SQL features in `references/ga-sql-improvements.md`.
- A repeatable refactor workflow to replace verbose patterns with leaner syntax.
- Guardrails to avoid preview-only syntax unless the user explicitly asks for preview features.

# Instructions

1. Confirm target context.
- Confirm Snowflake SQL is the target dialect.
- Confirm account compatibility if a feature was released recently.

2. Apply GA-only filtering.
- Use only features that are generally available.
- Exclude features explicitly marked preview in docs/release notes unless the user requests preview.
- If GA status is unclear, treat it as unknown and propose a safe fallback.

3. Refactor toward simpler SQL first.
- Prioritise constructs that remove boilerplate and repeated column lists.
- Prefer name-based semantics over position-based semantics when combining sets or merging tables.
- Prefer built-in higher-order and text-search functions over manual UDF-style rewrites when equivalent.

4. Use these simplification patterns by default.
- Replace long `ORDER BY col1, col2, ...` with `ORDER BY ALL` when valid.
- Replace position-sensitive unions with `UNION BY NAME` where schemas vary by order.
- Replace verbose `MERGE` column mapping with `UPDATE ALL BY NAME` / `INSERT ALL BY NAME` when column names align.
- Replace multi-step `RESULT_SCAN` pipelines with pipe operator (`->>`) chains for dependent statements.
- Use `FILTER`, `TRANSFORM`, and `REDUCE` for array/object transformations instead of repeated flatten-and-reaggregate patterns where it improves readability.
- Use `SEARCH`/`SEARCH_IP` for full-text and IPv4 search rather than custom tokenisation logic.

5. Show safe fallbacks.
- If a modern construct is not available in the target environment, output an equivalent legacy SQL fallback.
- Keep both versions brief and explain trade-offs in one sentence.

6. Output style.
- Return:
  - Refactored SQL.
  - A short "why this is leaner" note.
  - A "GA check" note listing which features were used and their GA status source.

# Best Practices

- Prefer deterministic readability over cleverness.
- Avoid preview syntax by default.
- Keep rewrites behaviour-preserving unless the user asks for semantic changes.
- Call out assumptions explicitly (column-name parity, null handling, ordering guarantees).

# Common Patterns

## Pattern 1: MERGE boilerplate reduction

Before:
```sql
MERGE INTO tgt t
USING src s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  t.c1 = s.c1,
  t.c2 = s.c2,
  t.c3 = s.c3
WHEN NOT MATCHED THEN INSERT (id, c1, c2, c3)
VALUES (s.id, s.c1, s.c2, s.c3);
```

After:
```sql
MERGE INTO tgt
USING src
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE ALL BY NAME
WHEN NOT MATCHED THEN INSERT ALL BY NAME;
```

Use only when source and target have the same column names and count.

## Pattern 2: Dependency chains with pipe operator

Before:
```sql
SHOW TABLES IN SCHEMA demo.raw;
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
```

After:
```sql
SHOW TABLES IN SCHEMA demo.raw
->> SELECT * FROM $1;
```

Use to reduce fragile query-id coupling and keep multi-step logic readable.

## Pattern 3: Name-safe set union

Before:
```sql
SELECT a, b, c FROM t1
UNION ALL
SELECT c, a, b FROM t2;
```

After:
```sql
SELECT a, b, c FROM t1
UNION ALL BY NAME
SELECT c, a, b FROM t2;
```

Use when column names match but column order differs.

# Examples

## Example 1: Basic usage
User: `$use-the-latest-greatest-sql-skill simplify this merge statement`
Assistant: rewrites to `ALL BY NAME` if safe, otherwise keeps explicit mappings and explains why.

## Example 2: Advanced usage
User: `$use-the-latest-greatest-sql-skill refactor @etl.sql and avoid preview features`
Assistant: updates SQL using GA constructs only, annotates each change with GA source notes, and provides fallbacks where needed.
