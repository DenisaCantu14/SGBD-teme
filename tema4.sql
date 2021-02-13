--1
--a
SET SERVEROUTPUT ON;

DECLARE
    TYPE job_record IS RECORD (
        job_id      jobs.job_id%TYPE,
        job_title   jobs.job_title%TYPE,
        avg_salary  NUMBER(6)
    );
    v_job job_record;
BEGIN
    v_job.job_id := 'AD_PRES';
    v_job.job_title := 'President';
    v_job.avg_salary := '12000';
    dbms_output.put_line('Jobul cu codul '
                         || v_job.job_id
                         || ' si titlul '
                         || v_job.job_title
                         || ' are media salariului '
                         || v_job.avg_salary);

END;
 
 --b

SET SERVEROUTPUT ON;

DECLARE
    TYPE job_record IS RECORD (
        job_id      jobs.job_id%TYPE,
        job_title   jobs.job_title%TYPE,
        avg_salary  NUMBER(6)
    );
    v_job job_record;
BEGIN
    SELECT
        job_id,
        job_title,
        ( min_salary + max_salary ) / 2
    INTO v_job
    FROM jobs
    WHERE job_id = 'IT_PROG';

    dbms_output.put_line('Jobul cu codul '
                         || v_job.job_id
                         || ' si titlul '
                         || v_job.job_title
                         || ' are media salariului '
                         || v_job.avg_salary);

END;


--c

CREATE TABLE jobs_dca AS SELECT * FROM jobs;

SET SERVEROUTPUT ON;

DECLARE
    TYPE job_record IS RECORD (
        job_id      jobs.job_id%TYPE,
        job_title   jobs.job_title%TYPE,
        avg_salary  NUMBER(6)
    );
    v_job job_record;
BEGIN
    DELETE FROM jobs_dca
    WHERE job_id = 'ST_MAN'
    RETURNING job_id, job_title, ( min_salary + max_salary ) / 2 INTO v_job;

    dbms_output.put_line('Jobul cu codul '
                         || v_job.job_id
                         || ' si titlul '
                         || v_job.job_title
                         || ' are media salariului '
                         || v_job.avg_salary);

END;
ROLLBACK;


--2
CREATE TABLE emp_dca AS SELECT * FROM employees;

SET SERVEROUTPUT ON;

DECLARE
    v_emp1  employees%rowtype;
    v_emp2  employees%rowtype;
BEGIN
    SELECT *
    INTO v_emp1
    FROM employees
    WHERE salary = ( SELECT MAX(salary) FROM employees) AND ROWNUM <= 1;

    SELECT *
    INTO v_emp2
    FROM employees
    WHERE salary = ( SELECT MIN(salary) FROM employees) AND ROWNUM <= 1;

    IF v_emp2.salary < v_emp1.salary * 0.1 
    THEN
        v_emp2.salary := v_emp2.salary + v_emp2.salary * 0.1;
    END IF;

    UPDATE emp_dca
    SET
        row = v_emp2
    WHERE
        employee_id = v_emp2.employee_id;

END;

ROLLBACK;

--3 a

CREATE TABLE dept_dca AS SELECT * FROM departments;

SET SERVEROUTPUT ON;

DECLARE
    v_dept1  departments%rowtype;
    v_dept2  departments%rowtype;
BEGIN
    v_dept1.department_id := 300;
    v_dept1.department_name := 'Research';
    v_dept1.manager_id := 103;
    v_dept1.location_id := 1700;
    INSERT INTO dept_dca VALUES v_dept1;

END;
 
 
 --3 b

SET SERVEROUTPUT ON;

DECLARE
    v_dept1  departments%rowtype;
    v_dept2  departments%rowtype;
BEGIN
    DELETE FROM dept_dca
    WHERE
        department_id = 50
    RETURNING department_id,
              department_name,
              manager_id,
              location_id INTO v_dept2;

    dbms_output.put_line('Departamentul cu codul '
                         || v_dept2.department_id
                         || ' si numele '
                         || v_dept2.department_name
                         || ' are managerul cu codul '
                         || v_dept2.manager_id
                         || ' si locatia '
                         || v_dept2.location_id);

END;

ROLLBACK;