# Output / Result Sheet — Experiments 3–6

This is the **output-only** companion to the SQL files. Values below are the expected results from the supplied sample data; rows containing a time or database user are produced at run time.

## Experiment 3 — Schema and query results

### Data created

| Item | Output |
| --- | ---: |
| Departments inserted | 5 |
| Projects inserted | 8 |
| Employees inserted | 30 |
| Employee salary range | 51,000.00 to 150,000.00 |

### Selection: employees with salary at least 80,000

| Emp. ID | Employee | Salary |
| ---: | --- | ---: |
| 1 | Asha Mehta | 150,000.00 |
| 2 | Rohan Shah | 110,000.00 |
| 3 | Meera Iyer | 95,000.00 |
| 4 | Kabir Khan | 105,000.00 |
| 5 | Nisha Gupta | 100,000.00 |
| 6 | Arjun Rao | 85,000.00 |
| 16 | Aditya Kulkarni | 80,000.00 |
| 21 | Neel Kapoor | 82,000.00 |
| 26 | Leena Menon | 88,000.00 |

### Projection output

| Department ID |
| ---: |
| 1 |
| 2 |
| 3 |
| 4 |
| 5 |

### Aggregate output

| Employee count | Lowest salary | Highest salary | Average salary | Total payroll |
| ---: | ---: | ---: | ---: | ---: |
| 30 | 51,000.00 | 150,000.00 | 74,700.00 | 2,241,000.00 |

### Department salary summary (`GROUP BY`)

| Department | Employees | Average salary | Department payroll |
| --- | ---: | ---: | ---: |
| Engineering | 7 | 89,428.57 | 626,000.00 |
| Human Resources | 6 | 67,166.67 | 403,000.00 |
| Finance | 6 | 74,500.00 | 447,000.00 |
| Sales | 6 | 72,000.00 | 432,000.00 |
| Operations | 5 | 66,600.00 | 333,000.00 |

### `HAVING` output: departments with payroll above 350,000

| Department | Employees | Payroll |
| --- | ---: | ---: |
| Engineering | 7 | 626,000.00 |
| Human Resources | 6 | 403,000.00 |
| Finance | 6 | 447,000.00 |
| Sales | 6 | 432,000.00 |

### `CASE` salary-band output

| Salary band | Employees |
| --- | ---: |
| Executive | 4 |
| Senior | 6 |
| Mid-level | 14 |
| Associate | 6 |

### `ORDER BY` output: five highest-paid employees

| Rank | Employee | Salary |
| ---: | --- | ---: |
| 1 | Asha Mehta | 150,000.00 |
| 2 | Rohan Shah | 110,000.00 |
| 3 | Kabir Khan | 105,000.00 |
| 4 | Nisha Gupta | 100,000.00 |
| 5 | Meera Iyer | 95,000.00 |

## Experiment 4 — Join, subquery, and `EXPLAIN` results

| Operation | Outcome |
| --- | --- |
| `INNER JOIN` | 30 employee–department rows are returned. |
| `LEFT JOIN` | All 5 departments are returned, including a department that would have zero employees. In this data set, every department has employees. |
| Self-join | 30 employee–manager rows are returned; Asha Mehta has no manager. |
| Three-way join | 30 employee–department–project rows are returned. |

### Employees earning above their own department average

| Department | Employee | Salary |
| --- | --- | ---: |
| Engineering | Asha Mehta | 150,000.00 |
| Engineering | Rohan Shah | 110,000.00 |
| Human Resources | Meera Iyer | 95,000.00 |
| Human Resources | Ishita Sen | 72,000.00 |
| Finance | Kabir Khan | 105,000.00 |
| Finance | Aditya Kulkarni | 80,000.00 |
| Sales | Nisha Gupta | 100,000.00 |
| Sales | Neel Kapoor | 82,000.00 |
| Operations | Leena Menon | 88,000.00 |
| Operations | Yash Chopra | 71,000.00 |

### `EXISTS` output

Departments with at least one employee assigned to a project budgeted at 300,000 or more:

| Department ID | Department |
| ---: | --- |
| 1 | Engineering |
| 4 | Sales |

### Simulated set-operation output

| Simulation | Result |
| --- | --- |
| `INTERSECT` | Engineering employees assigned to Engineering-owned projects: Asha Mehta, Rohan Shah, Arjun Rao, Priya Nair, Vikram Singh, Sneha Patel, and Dev Malhotra. |
| `EXCEPT` | Sales employees not assigned to a Sales-owned project: Harsh Sethi. |

### `EXPLAIN` comparison

| Query shape | Expected plan outcome |
| --- | --- |
| `department_id = 1` | Can use `idx_employees_department` to look up matching employees. |
| `department_id + 0 = 1` | The expression prevents a direct indexed lookup, so the plan is less efficient. |
| Three-way join | Uses the employee department filter followed by primary-key lookups into Department and Project. |
| Correlated subquery | Evaluates the peer salary average per employee/department; it is more expensive than the direct indexed lookup. |

Exact `EXPLAIN` cost estimates depend on the MySQL version, statistics, and server configuration.

## Experiment 5 — View and hierarchy results

### Department salary summary view

The view returns the same five-row department summary shown in Experiment 3.

### Employee hierarchy view

| Hierarchy level | Number of employees |
| ---: | ---: |
| 0 — top level | 1 |
| 1 — direct reports to Asha Mehta | 5 |
| 2 — remaining staff | 24 |

### View updatability test

| Test | Output |
| --- | --- |
| Attempt to update `v_department_salary_summary` | Rejected because an aggregate / `GROUP BY` view is not updatable. |
| Update `v_employee_directory` | Succeeds: employee 30's email temporarily becomes `zoya.mirza+view-test@example.com`. |
| Restore | Employee 30's email is restored to `zoya.mirza@example.com`. |

### Reporting chain for employee 30

| Distance from employee | Employee |
| ---: | --- |
| 2 | Asha Mehta |
| 1 | Leena Menon |
| 0 | Zoya Mirza |

## Experiment 6 — Procedure, trigger, and audit-test results

| Test | Expected result |
| --- | --- |
| Transfer employee 30 from Operations to Engineering | `PASS` |
| Restore employee 30 to Operations | `PASS` |
| Transfer to current department | Rejected; `PASS` |
| Transfer nonexistent employee 9999 | Rejected; `PASS` |
| Transfer to nonexistent department 9999 | Rejected; `PASS` |
| Set salary below 25,000 | Rejected by salary trigger; `PASS` |

### Transfer audit output

| Emp. ID | Old department | New department | Timestamp | Database user |
| ---: | ---: | ---: | --- | --- |
| 30 | 5 — Operations | 1 — Engineering | Generated at execution | Current MySQL user |
| 30 | 1 — Engineering | 5 — Operations | Generated at execution | Current MySQL user |

The test finishes with employee 30 restored to Operations and the original salary unchanged.
