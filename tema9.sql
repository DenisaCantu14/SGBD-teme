--ex1
CREATE OR REPLACE TRIGGER trig1_dca BEFORE
    DELETE ON dept_dca
BEGIN
    IF user <> 'SCOTT' THEN
        raise_application_error(-20000, 'Nu pot fi sterse informatii din acest tabel');
    END IF;
END;
/

DELETE FROM dept_dca
WHERE department_id = 50;

DROP TRIGGER trig1_dca;

--ex2

CREATE OR REPLACE TRIGGER trig2_dca BEFORE
    UPDATE OF commission_pct ON emp_dca
    FOR EACH ROW
BEGIN
    IF :new.commission_pct > 0.5 THEN
        raise_application_error(-20001, 'Comisionul depaseste 50% din valoarea salariului');
    END IF;
END;
/

UPDATE emp_dca
SET commission_pct = 0.55
WHERE employee_id = 100;

DROP TRIGGER trig2_dca;

--ex3

--a

ALTER TABLE info_dept_dca ADD numar NUMBER;

UPDATE info_dept_dca
SET
    numar = (
        SELECT COUNT(employee_id)
        FROM employees
        WHERE department_id = id
    );
             
--b

CREATE OR REPLACE TRIGGER trig3_dca AFTER
    INSERT OR UPDATE OR DELETE ON info_emp_dca
    FOR EACH ROW
BEGIN
    IF inserting THEN
        UPDATE info_dept_dca
        SET numar = numar + 1
        WHERE id = :new.id_dept;

    ELSIF updating THEN
        UPDATE info_dept_dca
        SET numar = numar + 1
        WHERE id = :new.id_dept;

        UPDATE info_dept_dca
        SET numar = numar - 1
        WHERE id = :old.id_dept;

    ELSIF deleting THEN
        UPDATE info_dept_dca
        SET numar = numar - 1
        WHERE id = :old.id_dept;

    END IF;
END;
/

DROP TRIGGER trig3_dca;

--ex4

CREATE OR REPLACE TRIGGER trig4_dca BEFORE
    INSERT OR UPDATE ON emp_dca
    FOR EACH ROW
DECLARE
    v_numar NUMBER;
BEGIN
    SELECT COUNT(employee_id)
    INTO v_numar
    FROM emp_dca
    WHERE department_id = :new.department_id;

    IF v_numar = 45 THEN
        raise_application_error(-20004, 'Intr-un departament nu pot lucra mai mult de 45 de persoane');
    END IF;
END;

DROP TRIGGER trig4_dca;

--ex5

--a

CREATE TABLE emp_test_dca (
    employee_id     NUMBER(6) PRIMARY KEY,
    last_name       VARCHAR2(25),
    first_name      VARCHAR2(20),
    department_id   NUMBER(4)
);

INSERT INTO emp_test_dca
    SELECT
        employee_id,
        last_name,
        first_name,
        department_id
    FROM emp_dca;


DROP TABLE emp_test_dca;

CREATE TABLE dept_test_dca (
    department_id     NUMBER(4) PRIMARY KEY,
    department_name   VARCHAR2(30)
);

INSERT INTO dept_test_dca
    SELECT
        department_id,
        department_name
    FROM
        departments;



DROP TABLE dept_test_dca;

--b
--nu este definit? constrângere de cheie extern? între cele dou? tabele;

CREATE OR REPLACE TRIGGER trig5_dca AFTER
    DELETE OR UPDATE ON dept_test_dca
    FOR EACH ROW
BEGIN
    IF deleting THEN
        DELETE FROM emp_test_dca
        WHERE
            department_id = :old.department_id;

    ELSIF updating THEN
        UPDATE emp_test_dca
        SET
            department_id = :new.department_id
        WHERE
            department_id = :old.department_id;

    END IF;
END;

--este definit? constrângerea de cheie extern? între cele dou? tabele;

ALTER TABLE emp_test_dca
    ADD CONSTRAINT fk_department_id FOREIGN KEY ( department_id )
        REFERENCES dept_test_dca ( department_id );

--este definit? constrângerea de cheie extern? între cele dou? tabele cu op?iunea ON DELETE CASCADE;

ALTER TABLE emp_test_dca DROP CONSTRAINT fk_department_id;

ALTER TABLE emp_test_dca
    ADD CONSTRAINT fk_department_id FOREIGN KEY ( department_id )
        REFERENCES dept_test_dca ( department_id )
            ON DELETE CASCADE;
--nu mai este nevoie de trigger la delete

DROP TRIGGER trig5_dca;

CREATE OR REPLACE TRIGGER trig5_dca AFTER
    UPDATE ON dept_test_dca
    FOR EACH ROW
BEGIN
    UPDATE emp_test_dca
    SET department_id = :new.department_id
    WHERE
        department_id = :old.department_id;

END;