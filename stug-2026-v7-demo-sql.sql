-- STUG FEB 2026 - Demo SQL Pack
-- Presenter: Raj Thakkar
-- Repo: https://github.com/directional-star/STUG-FEB-2026
-- Purpose:
--   Reusable SQL examples from the slide deck, grouped by topic.
-- Notes:
--   1) Some table names are illustrative; replace with your environment objects.
--   2) AI function availability depends on account/region/feature flags.

/* -------------------------------------------------------------------------- */
/* 01) QUALIFY - Top N per group without CTE                                   */
/* -------------------------------------------------------------------------- */

-- Traditional approach (CTE + ROW_NUMBER)
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 3;

-- Modern approach (QUALIFY)
SELECT *
FROM employees
QUALIFY ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) <= 3;

/* -------------------------------------------------------------------------- */
/* 02) GROUP BY ALL - avoid repeated grouping columns                          */
/* -------------------------------------------------------------------------- */

-- Traditional GROUP BY
SELECT
    department,
    role,
    location,
    COUNT(*) AS headcount,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department, role, location;

-- GROUP BY ALL
SELECT
    department,
    role,
    location,
    COUNT(*) AS headcount,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY ALL;

/* -------------------------------------------------------------------------- */
/* 03) Pipe Operator (- >>) examples                                           */
/* -------------------------------------------------------------------------- */

-- Before: SHOW + RESULT_SCAN
SHOW WAREHOUSES;

SELECT "name", "state", "type", "size"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID(-1)));

-- After: Pipe operator
SHOW WAREHOUSES
  ->> SELECT "name", "state", "type", "size" FROM $1;

-- Transaction chain with unified summary output
BEGIN TRANSACTION
  ->> INSERT INTO test_sql_pipe_dml VALUES (1, 2)
  ->> DELETE FROM test_sql_pipe_dml WHERE a = 1
  ->> UPDATE test_sql_pipe_dml SET b = 2
  ->> COMMIT
  ->> SELECT
        (SELECT $1 FROM $4) AS "Inserted rows",
        (SELECT $1 FROM $3) AS "Deleted rows",
        (SELECT $1 FROM $2) AS "Updated rows";

/* -------------------------------------------------------------------------- */
/* 04) MAX_BY / MIN_BY basics                                                  */
/* -------------------------------------------------------------------------- */

-- MAX returns scalar value only
SELECT MAX(salary) AS max_salary
FROM employees;

-- MAX_BY returns related row value
SELECT MAX_BY(name, salary) AS top_employee
FROM employees;

-- MAX_BY with object payload
SELECT MAX_BY(
         OBJECT_CONSTRUCT(
             'employee_id', employee_id,
             'name', name,
             'salary', salary
         ),
         salary
       ) AS top_employee_record
FROM employees;

/* -------------------------------------------------------------------------- */
/* 05) MAX_BY by department (AI usage)                                         */
/* -------------------------------------------------------------------------- */

-- Traditional CTE + rank pattern
WITH usage_rollup AS (
    SELECT
        department,
        employee_id,
        employee_name,
        SUM(tokens_used) AS total_tokens
    FROM employee_ai_usage
    GROUP BY department, employee_id, employee_name
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY department
               ORDER BY total_tokens DESC
           ) AS rn
    FROM usage_rollup
)
SELECT department, employee_id, employee_name, total_tokens
FROM ranked
WHERE rn = 1;

-- Compact MAX_BY pattern
SELECT
    department,
    MAX_BY(
        OBJECT_CONSTRUCT(
            'employee_id', employee_id,
            'employee_name', employee_name,
            'total_tokens', SUM(tokens_used)
        ),
        SUM(tokens_used)
    ) AS top_employee
FROM employee_ai_usage
GROUP BY ALL;

/* -------------------------------------------------------------------------- */
/* 06) CONCAT_WS - null-safe string composition                                */
/* -------------------------------------------------------------------------- */

-- Traditional COALESCE-heavy expression
SELECT
  TRIM(
    first_name || ' ' ||
    COALESCE(middle_name || ' ', '') ||
    last_name
  ) AS full_name
FROM employees;

-- Cleaner CONCAT_WS form
SELECT
  CONCAT_WS(' ', first_name, middle_name, last_name) AS full_name
FROM employees;

/* -------------------------------------------------------------------------- */
/* 07) AI_EXTRACT (Inbuilt OCR)                                                */
/* -------------------------------------------------------------------------- */

SELECT AI_EXTRACT(
    file => TO_FILE('@DEMO_AUS_DB.BRONZE.call_recordings_stage', 'stug-2026-v5.pdf'),
    responseFormat => {
        'title': 'What is the title of the presentation?',
        'pages': 'how many pages in the presentation?',
        'presenter': 'what is the name of the presenter?'
    }
) AS extracted;

/* -------------------------------------------------------------------------- */
/* 08) AI_REDACT (Inbuilt heavy black marker)                                  */
/* -------------------------------------------------------------------------- */

SELECT AI_REDACT(
    'Contact John Smith at john@email.com or 0412 345 678',
    ['NAME', 'EMAIL', 'PHONE_NUMBER']
) AS sanitized;

/* -------------------------------------------------------------------------- */
/* 09) AI_COMPLETE (Inbuilt ChatGPT)                                           */
/* -------------------------------------------------------------------------- */

-- Graph analysis
SELECT AI_COMPLETE(
    'claude-sonnet-4-6',
    PROMPT(
        'Analyze this sales graph. Describe the trends, key insights, and any notable patterns.',
        TO_FILE('@DEMO_AUS_DB.BRONZE.YOUR_STAGE', 'sales_graph.png')
    )
) AS analysis;

-- Guided question set
SELECT AI_COMPLETE(
    'claude-sonnet-4-6',
    PROMPT(
        'Look at this sales graph and answer:
         1. What is the overall trend (growing, declining, flat)?
         2. Which period had the highest sales?
         3. Are there any seasonal patterns?
         4. What recommendations would you make based on this data?',
        TO_FILE('@DEMO_AUS_DB.BRONZE.YOUR_STAGE', 'sales_graph.png')
    )
) AS detailed_analysis;

-- Structured JSON response
SELECT AI_COMPLETE(
    'claude-sonnet-4-6',
    PROMPT(
        'Analyze this sales chart and return a JSON with: trend, peak_period, low_period, growth_rate_estimate, key_observations',
        TO_FILE('@DEMO_AUS_DB.BRONZE.YOUR_STAGE', 'sales_graph.png')
    ),
    {'response_format': {'type': 'json'}}
) AS structured_analysis;

/* -------------------------------------------------------------------------- */
/* 10) AI_TRANSCRIBE (Inbuild speech-to-text engine)                           */
/* -------------------------------------------------------------------------- */

SELECT
    month,
    AI_TRANSCRIBE(TO_FILE(audio_file)) AS transcript
FROM DEMO_AUS_DB.BRONZE.call_recordings
WHERE customer_id = 'CUST001';

/* -------------------------------------------------------------------------- */
/* 11) Lighting Round snippets                                                 */
/* -------------------------------------------------------------------------- */

-- CREATE OR ALTER
CREATE OR ALTER TABLE employee_dim (
    id NUMBER,
    name STRING
);

-- EXCLUDE
SELECT * EXCLUDE (raw_payload, pii_email)
FROM employee_360;

-- DIV0
SELECT DIV0(total_cost, total_revenue) AS ratio
FROM kpi_daily;

-- SEQ / GENERATOR
CREATE TABLE load_test AS
SELECT
    SEQ8() AS id,
    UUID_STRING() AS guid,
    RANDOM() AS random_val
FROM TABLE(GENERATOR(ROWCOUNT => 10000000));

-- SOUNDEX / JAROWINKLER_SIMILARITY
SELECT
    name,
    SOUNDEX(name) AS name_soundex,
    JAROWINKLER_SIMILARITY(name, 'Jon Smyth') AS score
FROM contacts;

-- AI_SUMMARIZE_AGG
SELECT AI_SUMMARIZE_AGG(review_text) AS summary
FROM customer_reviews;

-- SQL dad joke generator
SELECT AI_COMPLETE('llama3-70b', 'Generate a classic SQL Dad Joke.') AS sql_dad_joke;
