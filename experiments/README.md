# DBMS Experiments 3–6

These scripts are a self-contained **MySQL 8.0+** implementation of the Employee–Department–Project assignment. MySQL was selected because the repository did not contain an existing database setup or dialect; the scripts use MySQL's `SIGNAL`, delimiter, trigger, stored-procedure, recursive-CTE, and `EXPLAIN` syntax.

## Before you begin

- Use MySQL 8.0 or newer. Recursive CTEs require MySQL 8.0.
- The scripts create and use the dedicated database `dbms_lab`.
- The Experiment 3 script drops and recreates the three demo tables in `dbms_lab`. Do not run it against a database that contains work you need to keep.

## Run order

From the repository root, run the files in this order:

```bash
mysql -u <user> -p < experiments/experiment_3_schema_and_queries.sql
mysql -u <user> -p < experiments/experiment_4_joins_and_subqueries.sql
mysql -u <user> -p < experiments/experiment_5_views_and_recursive_cte.sql
mysql -u <user> -p < experiments/experiment_6_procedures_triggers_and_tests.sql
```

Alternatively, open each file in MySQL Workbench and execute them in the same sequence.

## What each script demonstrates

| Script | Coverage |
| --- | --- |
| `experiment_3_schema_and_queries.sql` | Normalized Employee–Department–Project schema, 30 employees, 5 departments, 8 projects, selection, projection, aggregate functions, `GROUP BY`, `HAVING`, `CASE`, and `ORDER BY`. |
| `experiment_4_joins_and_subqueries.sql` | Inner/left/self/three-way joins, correlated subquery, `EXISTS`, MySQL-compatible `INTERSECT`/`EXCEPT` simulations, and comparable `EXPLAIN` plans. |
| `experiment_5_views_and_recursive_cte.sql` | Department salary and reporting-hierarchy views, read-only aggregate view explanation, a tested updatable single-table view, and recursive reporting chains. |
| `experiment_6_procedures_triggers_and_tests.sql` | Transactional employee transfers, validation with `SIGNAL`, salary checks, transfer audit log, and expected-error edge-case tests. |

## Expected validation result

Experiment 6 executes `run_experiment_6_tests()` automatically. It reports `PASS` for:

1. A valid transfer and restoration of employee 30.
2. A transfer to the employee's current department being rejected.
3. A nonexistent employee being rejected.
4. A nonexistent destination department being rejected.
5. An attempted salary below 25,000 being rejected by the trigger.

It also displays the two valid transfer audit records for employee 30. Re-running Experiment 6 recreates the audit table and tests from a clean state.
