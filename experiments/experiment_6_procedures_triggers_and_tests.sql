USE dbms_lab;
DROP TRIGGER IF EXISTS trg_employees_validate_salary_insert;
DROP TRIGGER IF EXISTS trg_employees_validate_salary_update;
DROP TRIGGER IF EXISTS trg_employees_audit_transfer;
DROP PROCEDURE IF EXISTS transfer_employee;
DROP PROCEDURE IF EXISTS run_experiment_6_tests;
DROP TABLE IF EXISTS employee_transfer_audit;
CREATE TABLE employee_transfer_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_department_id INT NOT NULL,
    new_department_id INT NOT NULL,
    transferred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transferred_by VARCHAR(255) NOT NULL,
    CONSTRAINT fk_audit_employee
        FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    CONSTRAINT fk_audit_old_department
        FOREIGN KEY (old_department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_audit_new_department
        FOREIGN KEY (new_department_id) REFERENCES departments(department_id)
) ENGINE = InnoDB;
DELIMITER //
CREATE TRIGGER trg_employees_validate_salary_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 25000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be at least 25000.';
    END IF;
END//
CREATE TRIGGER trg_employees_validate_salary_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 25000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be at least 25000.';
    END IF;
END//
CREATE TRIGGER trg_employees_audit_transfer
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NOT (OLD.department_id <=> NEW.department_id) THEN
        INSERT INTO employee_transfer_audit
            (emp_id, old_department_id, new_department_id, transferred_by)
        VALUES
            (NEW.emp_id, OLD.department_id, NEW.department_id, CURRENT_USER());
    END IF;
END//
CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_old_dept_id INT DEFAULT NULL;
    DECLARE v_department_exists INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    SELECT department_id INTO v_old_dept_id
    FROM employees
    WHERE emp_id = p_emp_id
    FOR UPDATE;
    IF v_old_dept_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer failed: employee does not exist.';
    END IF;
    SELECT COUNT(*) INTO v_department_exists
    FROM departments
    WHERE department_id = p_new_dept_id;
    IF v_department_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer failed: destination department does not exist.';
    END IF;
    IF v_old_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer failed: employee is already in that department.';
    END IF;
    UPDATE employees
    SET department_id = p_new_dept_id
    WHERE emp_id = p_emp_id;
    COMMIT;
END//
CREATE PROCEDURE run_experiment_6_tests()
BEGIN
    DECLARE v_original_department INT;
    DECLARE v_trigger_rejected BOOLEAN DEFAULT FALSE;
    DECLARE v_same_department_rejected BOOLEAN DEFAULT FALSE;
    DECLARE v_missing_employee_rejected BOOLEAN DEFAULT FALSE;
    DECLARE v_missing_department_rejected BOOLEAN DEFAULT FALSE;
    SELECT department_id INTO v_original_department
    FROM employees
    WHERE emp_id = 30;
    CALL transfer_employee(30, 1);
    SELECT 'valid transfer' AS test_name,
           IF(department_id = 1, 'PASS', 'FAIL') AS result
    FROM employees
    WHERE emp_id = 30;
    CALL transfer_employee(30, v_original_department);
    SELECT 'transfer restored' AS test_name,
           IF(department_id = v_original_department, 'PASS', 'FAIL') AS result
    FROM employees
    WHERE emp_id = 30;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
            SET v_same_department_rejected = TRUE;
        CALL transfer_employee(30, v_original_department);
    END;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
            SET v_missing_employee_rejected = TRUE;
        CALL transfer_employee(9999, 1);
    END;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
            SET v_missing_department_rejected = TRUE;
        CALL transfer_employee(30, 9999);
    END;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
            SET v_trigger_rejected = TRUE;
        UPDATE employees
        SET salary = 24000
        WHERE emp_id = 30;
    END;
    SELECT 'same-department transfer rejected' AS test_name,
           IF(v_same_department_rejected, 'PASS', 'FAIL') AS result
    UNION ALL SELECT 'missing employee rejected', IF(v_missing_employee_rejected, 'PASS', 'FAIL')
    UNION ALL SELECT 'missing department rejected', IF(v_missing_department_rejected, 'PASS', 'FAIL')
    UNION ALL SELECT 'salary below minimum rejected', IF(v_trigger_rejected, 'PASS', 'FAIL');
    SELECT emp_id, old_department_id, new_department_id, transferred_at, transferred_by
    FROM employee_transfer_audit
    WHERE emp_id = 30
    ORDER BY audit_id;
END//
DELIMITER ;
CALL run_experiment_6_tests();
