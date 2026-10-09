# DBMS Lab Experiments

Course: DBMS Lab

This repository contains the completion of 6 DBMS Lab experiments. It encompasses ER modeling, relational schema design, advanced SQL queries, views, recursive CTEs, stored procedures, and triggers.

## Repository Structure

The project is structured inside the `experiments/` directory.

### Experiment 1: ER Diagram
**Description:** Design of an ER diagram for an Indian e-commerce platform incorporating weak entities, specializations (Product types), multi-valued attributes (Customer Phones), and participation constraints.
**Files:**
- `experiments/experiment_1_er_diagram.png`: The visual ER diagram.

### Experiment 2: Relational Schema & Constraints
**Description:** Conversion of the Experiment 1 ER diagram into a concrete relational schema using MySQL. It includes primary/foreign keys, uniqueness, and cascading deletes.
**Files:**
- `experiments/experiment_2_schema.sql`: Table creation scripts.
- `experiments/experiment_2_sample_data.sql`: Insertion of realistic test data.
- `experiments/experiment_2_referential_integrity.sql`: Demonstrations of constraint violations (commented out for smooth execution).

### Experiment 3: Employee-Department-Project Schema
**Description:** Creation of an organizational schema populated with 30 employees, 5 departments, and 8 projects. Demonstrates fundamental SQL operations such as selections, projections, grouping, aggregations, and CASE statements.
**Files:**
- `experiments/experiment_3_schema_and_queries.sql`: Table creation, data, and queries.

### Experiment 4: Advanced SQL Joins & Subqueries
**Description:** Expansion on the schema from Experiment 3 to demonstrate advanced SQL operations like INNER JOIN, LEFT JOIN, SELF JOIN, 3-way JOIN, correlated subqueries, EXISTS, and simulated set operations (INTERSECT/EXCEPT). Execution plans are analyzed via EXPLAIN.
**Files:**
- `experiments/experiment_4_joins_and_subqueries.sql`: Advanced join, subquery, and EXPLAIN implementations.

### Experiment 5: Views and Recursive CTEs
**Description:** Implementation of SQL views to summarize department salaries and depict an employee hierarchy. Demonstrates updatability of views and a recursive Common Table Expression (CTE) to track reporting chains.
**Files:**
- `experiments/experiment_5_views_and_recursive_cte.sql`: Definition of views, updatability tests, and CTEs.

### Experiment 6: Stored Procedures & Triggers
**Description:** Implementation of a stored procedure `transfer_employee(emp_id, new_dept_id)` with robust validation, transaction, and error handling. Incorporates triggers to validate salaries (preventing negative or absurd values) and to log salary/department changes to an audit table.
**Files:**
- `experiments/experiment_6_procedures_triggers_and_tests.sql`: Procedure, trigger, and test queries.

## How to Execute the SQL Files in MySQL

To execute these files in your MySQL environment:

1. Open your terminal or MySQL client.
2. Login to MySQL: `mysql -u root -p`
3. Create and select a database for the experiments:
   ```sql
   CREATE DATABASE dbms_lab;
   USE dbms_lab;
   ```
4. Source the files in order. Please refer to `experiments/README.md` for specific execution commands and validation details.

## Notes on Existing Files
The repository previously contained `Day-1.ipynb` and `ER Diagram for College Wesbsite.jpg` which have been preserved as they were originally present.
