-- Experiment 3: Employee-Department-Project schema and foundational queries
-- Dialect: MySQL 8.0+
-- Safe to re-run in the dedicated dbms_lab database. This recreates its demo data.

CREATE DATABASE IF NOT EXISTS dbms_lab;
USE dbms_lab;

-- Remove dependent lab objects as well, so Experiment 3 can reset a previous full run.
DROP VIEW IF EXISTS v_department_salary_summary;
DROP VIEW IF EXISTS v_employee_hierarchy;
DROP VIEW IF EXISTS v_employee_directory;
DROP PROCEDURE IF EXISTS run_experiment_6_tests;
DROP PROCEDURE IF EXISTS transfer_employee;
DROP TRIGGER IF EXISTS trg_employees_validate_salary_insert;
DROP TRIGGER IF EXISTS trg_employees_validate_salary_update;
DROP TRIGGER IF EXISTS trg_employees_audit_transfer;
DROP TABLE IF EXISTS employee_transfer_audit;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(80) NOT NULL UNIQUE,
    location VARCHAR(80) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    budget DECIMAL(12, 2) NOT NULL,
    start_date DATE NOT NULL,
    CONSTRAINT chk_project_budget CHECK (budget > 0),
    CONSTRAINT fk_project_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE = InnoDB;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    salary DECIMAL(12, 2) NOT NULL,
    department_id INT NOT NULL,
    project_id INT NOT NULL,
    manager_id INT NULL,
    CONSTRAINT chk_employee_salary CHECK (salary >= 25000),
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_employee_project
        FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
) ENGINE = InnoDB;

CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_project ON employees(project_id);
CREATE INDEX idx_employees_manager ON employees(manager_id);

INSERT INTO departments (department_id, department_name, location) VALUES
    (1, 'Engineering', 'Bengaluru'),
    (2, 'Human Resources', 'Mumbai'),
    (3, 'Finance', 'Pune'),
    (4, 'Sales', 'Delhi'),
    (5, 'Operations', 'Chennai');

INSERT INTO projects (project_id, project_name, department_id, budget, start_date) VALUES
    (1, 'Atlas Platform', 1, 500000.00, '2025-01-15'),
    (2, 'Mobile Refresh', 1, 300000.00, '2025-02-01'),
    (3, 'Talent Portal', 2, 120000.00, '2025-01-10'),
    (4, 'Wellness Initiative', 2, 80000.00, '2025-03-01'),
    (5, 'Forecast 2026', 3, 180000.00, '2025-01-20'),
    (6, 'Compliance Review', 3, 90000.00, '2025-02-15'),
    (7, 'Market Expansion', 4, 400000.00, '2025-01-05'),
    (8, 'Supply Optimisation', 5, 250000.00, '2025-02-10');

-- Managers are inserted before their reports so the self-referencing foreign key is valid.
INSERT INTO employees
    (emp_id, first_name, last_name, email, hire_date, salary, department_id, project_id, manager_id)
VALUES
    (1, 'Asha', 'Mehta', 'asha.mehta@example.com', '2018-01-10', 150000.00, 1, 1, NULL),
    (2, 'Rohan', 'Shah', 'rohan.shah@example.com', '2019-03-15', 110000.00, 1, 1, 1),
    (3, 'Meera', 'Iyer', 'meera.iyer@example.com', '2019-05-20', 95000.00, 2, 3, 1),
    (4, 'Kabir', 'Khan', 'kabir.khan@example.com', '2019-08-12', 105000.00, 3, 5, 1),
    (5, 'Nisha', 'Gupta', 'nisha.gupta@example.com', '2020-01-08', 100000.00, 4, 7, 1),
    (6, 'Arjun', 'Rao', 'arjun.rao@example.com', '2020-02-01', 85000.00, 1, 1, 2),
    (7, 'Priya', 'Nair', 'priya.nair@example.com', '2020-06-18', 78000.00, 1, 2, 2),
    (8, 'Vikram', 'Singh', 'vikram.singh@example.com', '2021-01-11', 72000.00, 1, 1, 2),
    (9, 'Sneha', 'Patel', 'sneha.patel@example.com', '2021-04-03', 69000.00, 1, 2, 2),
    (10, 'Dev', 'Malhotra', 'dev.malhotra@example.com', '2022-07-22', 62000.00, 1, 1, 2),
    (11, 'Ishita', 'Sen', 'ishita.sen@example.com', '2020-03-19', 72000.00, 2, 3, 3),
    (12, 'Karan', 'Verma', 'karan.verma@example.com', '2021-02-08', 65000.00, 2, 4, 3),
    (13, 'Riya', 'Bose', 'riya.bose@example.com', '2021-09-14', 61000.00, 2, 3, 3),
    (14, 'Manav', 'Joshi', 'manav.joshi@example.com', '2022-05-29', 58000.00, 2, 4, 3),
    (15, 'Tanya', 'Das', 'tanya.das@example.com', '2023-01-17', 52000.00, 2, 3, 3),
    (16, 'Aditya', 'Kulkarni', 'aditya.kulkarni@example.com', '2020-07-05', 80000.00, 3, 5, 4),
    (17, 'Pooja', 'Saxena', 'pooja.saxena@example.com', '2021-03-21', 74000.00, 3, 6, 4),
    (18, 'Rahul', 'Jain', 'rahul.jain@example.com', '2021-11-09', 68000.00, 3, 5, 4),
    (19, 'Ananya', 'Roy', 'ananya.roy@example.com', '2022-08-16', 63000.00, 3, 6, 4),
    (20, 'Siddharth', 'Ali', 'siddharth.ali@example.com', '2023-02-25', 57000.00, 3, 5, 4),
    (21, 'Neel', 'Kapoor', 'neel.kapoor@example.com', '2020-10-10', 82000.00, 4, 7, 5),
    (22, 'Simran', 'Kaur', 'simran.kaur@example.com', '2021-05-06', 70000.00, 4, 7, 5),
    (23, 'Varun', 'Bhat', 'varun.bhat@example.com', '2021-12-13', 66000.00, 4, 7, 5),
    (24, 'Aditi', 'Arora', 'aditi.arora@example.com', '2022-09-01', 60000.00, 4, 7, 5),
    (25, 'Harsh', 'Sethi', 'harsh.sethi@example.com', '2023-04-12', 54000.00, 4, 8, 5),
    (26, 'Leena', 'Menon', 'leena.menon@example.com', '2020-11-25', 88000.00, 5, 8, 1),
    (27, 'Yash', 'Chopra', 'yash.chopra@example.com', '2021-06-30', 71000.00, 5, 8, 26),
    (28, 'Maya', 'Pillai', 'maya.pillai@example.com', '2022-02-14', 64000.00, 5, 8, 26),
    (29, 'Om', 'Prakash', 'om.prakash@example.com', '2022-10-18', 59000.00, 5, 8, 26),
    (30, 'Zoya', 'Mirza', 'zoya.mirza@example.com', '2023-06-07', 51000.00, 5, 8, 26);

-- Selection: return only employees earning at least 80,000.
SELECT emp_id, first_name, last_name, salary
FROM employees
WHERE salary >= 80000;

-- Projection: choose just the requested columns (DISTINCT avoids duplicate departments).
SELECT DISTINCT department_id
FROM employees;

-- Aggregate functions over all employees.
SELECT COUNT(*) AS employee_count,
       MIN(salary) AS lowest_salary,
       MAX(salary) AS highest_salary,
       ROUND(AVG(salary), 2) AS average_salary,
       SUM(salary) AS payroll
FROM employees;

-- GROUP BY: salary totals and averages for each department.
SELECT d.department_name,
       COUNT(e.emp_id) AS employee_count,
       ROUND(AVG(e.salary), 2) AS average_salary,
       SUM(e.salary) AS department_payroll
FROM departments AS d
JOIN employees AS e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- HAVING filters groups after grouping.
SELECT d.department_name, COUNT(e.emp_id) AS employee_count, SUM(e.salary) AS payroll
FROM departments AS d
JOIN employees AS e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING SUM(e.salary) > 350000;

-- CASE labels each salary with a readable band.
SELECT emp_id, first_name, last_name, salary,
       CASE
           WHEN salary >= 100000 THEN 'Executive'
           WHEN salary >= 75000 THEN 'Senior'
           WHEN salary >= 60000 THEN 'Mid-level'
           ELSE 'Associate'
       END AS salary_band
FROM employees;

-- ORDER BY presents the highest-paid employees first, breaking ties by name.
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC, last_name ASC, first_name ASC;
