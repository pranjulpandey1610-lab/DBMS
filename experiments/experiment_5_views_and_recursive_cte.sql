-- Experiment 5: Views, view updatability, and recursive reporting chains
-- Prerequisite: run experiment_3_schema_and_queries.sql first.

USE dbms_lab;

DROP VIEW IF EXISTS v_department_salary_summary;
DROP VIEW IF EXISTS v_employee_hierarchy;
DROP VIEW IF EXISTS v_employee_directory;

-- An aggregate view is intentionally read-only in MySQL.
CREATE VIEW v_department_salary_summary AS
SELECT d.department_id,
       d.department_name,
       COUNT(e.emp_id) AS employee_count,
       COALESCE(SUM(e.salary), 0) AS total_salary,
       COALESCE(ROUND(AVG(e.salary), 2), 0) AS average_salary,
       COALESCE(MIN(e.salary), 0) AS minimum_salary,
       COALESCE(MAX(e.salary), 0) AS maximum_salary
FROM departments AS d
LEFT JOIN employees AS e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- Hierarchy view exposes every employee with their immediate manager.
CREATE VIEW v_employee_hierarchy AS
SELECT e.emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
       e.department_id,
       CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
       e.manager_id
FROM employees AS e
LEFT JOIN employees AS m ON m.emp_id = e.manager_id;

SELECT *
FROM v_department_salary_summary
ORDER BY department_id;

SELECT *
FROM v_employee_hierarchy
ORDER BY emp_id;

-- Updatability test:
-- v_department_salary_summary is not updatable because it uses GROUP BY and aggregates.
-- This statement is deliberately left commented: MySQL will reject it if executed.
-- UPDATE v_department_salary_summary SET total_salary = 0 WHERE department_id = 1;

-- A single-table view is updatable. Update a controlled test value and restore it.
CREATE VIEW v_employee_directory AS
SELECT emp_id, first_name, last_name, email, department_id
FROM employees;

SELECT emp_id, email AS email_before
FROM v_employee_directory
WHERE emp_id = 30;

UPDATE v_employee_directory
SET email = 'zoya.mirza+view-test@example.com'
WHERE emp_id = 30;

SELECT emp_id, email AS email_after_update
FROM employees
WHERE emp_id = 30;

UPDATE v_employee_directory
SET email = 'zoya.mirza@example.com'
WHERE emp_id = 30;

-- Recursive CTE: one row per employee, with the complete manager-to-employee path.
WITH RECURSIVE reporting_chain AS (
    SELECT e.emp_id,
           e.manager_id,
           CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
           CAST(CONCAT(e.first_name, ' ', e.last_name) AS CHAR(1000)) AS reporting_path,
           0 AS hierarchy_level
    FROM employees AS e
    WHERE e.manager_id IS NULL

    UNION ALL

    SELECT child.emp_id,
           child.manager_id,
           CONCAT(child.first_name, ' ', child.last_name) AS employee_name,
           CONCAT(chain.reporting_path, ' -> ', child.first_name, ' ', child.last_name) AS reporting_path,
           chain.hierarchy_level + 1
    FROM employees AS child
    JOIN reporting_chain AS chain ON chain.emp_id = child.manager_id
)
SELECT emp_id, employee_name, hierarchy_level, reporting_path
FROM reporting_chain
ORDER BY reporting_path;

-- Recursive CTE focused on the reporting chain for a single employee (employee 30).
WITH RECURSIVE manager_chain AS (
    SELECT e.emp_id,
           e.manager_id,
           CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
           0 AS distance_from_employee
    FROM employees AS e
    WHERE e.emp_id = 30

    UNION ALL

    SELECT manager.emp_id,
           manager.manager_id,
           CONCAT(manager.first_name, ' ', manager.last_name) AS employee_name,
           chain.distance_from_employee + 1
    FROM employees AS manager
    JOIN manager_chain AS chain ON manager.emp_id = chain.manager_id
)
SELECT emp_id, employee_name, distance_from_employee
FROM manager_chain
ORDER BY distance_from_employee DESC;
