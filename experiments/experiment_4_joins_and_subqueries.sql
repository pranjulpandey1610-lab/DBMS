USE dbms_lab;
SELECT e.emp_id, e.first_name, e.last_name, d.department_name
FROM employees AS e
INNER JOIN departments AS d ON d.department_id = e.department_id
ORDER BY e.emp_id;
SELECT d.department_name, COUNT(e.emp_id) AS employee_count
FROM departments AS d
LEFT JOIN employees AS e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_name;
SELECT e.emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS employee,
       CONCAT(m.first_name, ' ', m.last_name) AS manager
FROM employees AS e
LEFT JOIN employees AS m ON m.emp_id = e.manager_id
ORDER BY e.emp_id;
SELECT e.emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS employee,
       d.department_name,
       p.project_name
FROM employees AS e
JOIN departments AS d ON d.department_id = e.department_id
JOIN projects AS p ON p.project_id = e.project_id
ORDER BY d.department_name, e.emp_id;
SELECT e.emp_id, e.first_name, e.last_name, e.salary, e.department_id
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(peer.salary)
    FROM employees AS peer
    WHERE peer.department_id = e.department_id
)
ORDER BY e.department_id, e.salary DESC;
SELECT d.department_id, d.department_name
FROM departments AS d
WHERE EXISTS (
    SELECT 1
    FROM employees AS e
    JOIN projects AS p ON p.project_id = e.project_id
    WHERE e.department_id = d.department_id
      AND p.budget >= 300000
)
ORDER BY d.department_id;
SELECT e.emp_id, e.first_name, e.last_name
FROM employees AS e
WHERE e.department_id = 1
  AND e.emp_id IN (
      SELECT assigned.emp_id
      FROM employees AS assigned
      JOIN projects AS p ON p.project_id = assigned.project_id
      WHERE p.department_id = 1
  )
ORDER BY e.emp_id;
SELECT e.emp_id, e.first_name, e.last_name
FROM employees AS e
WHERE e.department_id = 4
  AND NOT EXISTS (
      SELECT 1
      FROM projects AS p
      WHERE p.project_id = e.project_id
        AND p.department_id = 4
  )
ORDER BY e.emp_id;
EXPLAIN SELECT emp_id, first_name, last_name, salary
FROM employees
WHERE department_id = 1;
EXPLAIN SELECT emp_id, first_name, last_name, salary
FROM employees
WHERE department_id + 0 = 1;
EXPLAIN SELECT e.emp_id, d.department_name, p.project_name
FROM employees AS e
JOIN departments AS d ON d.department_id = e.department_id
JOIN projects AS p ON p.project_id = e.project_id
WHERE e.department_id = 1;
EXPLAIN SELECT e.emp_id, e.salary
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(peer.salary)
    FROM employees AS peer
    WHERE peer.department_id = e.department_id
);
