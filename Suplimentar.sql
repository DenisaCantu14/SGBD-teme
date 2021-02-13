CREATE SEQUENCE sec_dca
start with 207
increment by 1
minvalue 207
maxvalue 99999999999
cycle;
select * from jobs;
 drop sequence sec_dca;

CREATE OR REPLACE PACKAGE pachet1_dca
AS 
    --a
    PROCEDURE adauga_emp
    (v_first_name emp_dca.first_name%TYPE,
     v_last_name emp_dca.last_name%TYPE,
     v_nr_telef emp_dca.phone_number%TYPE,
     v_email emp_dca.email%TYPE
     );
     
    FUNCTION cod_m( 
      v_first  emp_dca.first_name%TYPE, 
      v_last emp_dca.last_name%TYPE)
    RETURN NUMBER;
    
    FUNCTION cod_d( 
      v_name  dept_dca.department_name%TYPE) 
    RETURN NUMBER;
    
    FUNCTION cod_j( 
      v_name1  jobs.job_title%TYPE) 
    RETURN VARCHAR;
    
    FUNCTION sal( 
    v_dep emp_dca.department_id%TYPE,
    v_job emp_dca.job_id%TYPE) 
    RETURN NUMBER;
    
    
    --b
    PROCEDURE schimba_dep(
        v_first_name emp_dca.first_name%TYPE,
        v_last_name emp_dca.last_name%TYPE,
        v_dep_name dept_dca.department_name%TYPE,
        v_job_name jobs.job_title%TYPE,
        v_m_first_name emp_dca.first_name%TYPE,
        v_m_last_name emp_dca.last_name%TYPE
        );
    FUNCTION comm
        (v_dep emp_dca.department_id%TYPE,
        v_job emp_dca.job_id%TYPE) 
    RETURN NUMBER;
    --c
    FUNCTION subalterni(
    v_first_name emp_dca.first_name%TYPE,
        v_last_name emp_dca.last_name%TYPE)
    RETURN NUMBER;    
    --d
    PROCEDURE promovare
    (v_first  emp_dca.first_name%TYPE, 
      v_last emp_dca.last_name%TYPE);

   --e
   PROCEDURE act_salariu
   (  v_last emp_dca.last_name%TYPE,
      v_valoare emp_dca.salary%TYPE);

   --f
   
   CURSOR lista_angajati (v_job emp_dca.job_id%TYPE) 
        RETURN emp_dca%ROWTYPE IS
        SELECT *
        FROM emp_dca
        WHERE job_id = v_job;
        
  --g
  
  CURSOR lista_joburi 
        RETURN jobs%ROWTYPE IS
        SELECT *
        FROM jobs;
 --h
 
 PROCEDURE detalii_job;
END pachet1_dca; 
  
  
  
  
CREATE OR REPLACE PACKAGE BODY pachet1_dca
AS  
--a
   FUNCTION cod_m( 
      v_first  emp_dca.first_name%TYPE, 
      v_last emp_dca.last_name%TYPE)
   RETURN NUMBER
   IS
        rez emp_dca.employee_id%TYPE;
   BEGIN
        SELECT employee_id
        INTO rez
        FROM emp_dca
        WHERE first_name = v_first and last_name = v_last;
        RETURN rez;
   EXCEPTION
             WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat');
             WHEN TOO_MANY_ROWS THEN
             RAISE_APPLICATION_ERROR(-20001,'Exista mai multi angajati cu numele dat');
             WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
                 
   END;
   
    FUNCTION cod_d( 
      v_name  dept_dca.department_name%TYPE) 
    RETURN NUMBER
    IS
        rez emp_dca.department_id%TYPE;
    BEGIN
        SELECT department_id
        INTO rez
        FROM departments
        WHERE department_name = v_name;
        RETURN rez;
        
    EXCEPTION
             WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20000, 'Nu exista departament cu numele dat');
             WHEN TOO_MANY_ROWS THEN
             RAISE_APPLICATION_ERROR(-20001,'Exista mai multe departamente cu numele dat');
             WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
                  
   END;
  
   FUNCTION cod_j( 
      v_name1  jobs.job_title%TYPE) 
   RETURN VARCHAR
   IS
        rez emp_dca.job_id%TYPE;
   BEGIN
        SELECT job_id
        INTO rez
        FROM jobs
        WHERE job_title = v_name1;
        RETURN rez;
    EXCEPTION
             WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20000, 'Nu exista job cu numele dat');
             WHEN TOO_MANY_ROWS THEN
             RAISE_APPLICATION_ERROR(-20001,'Exista mai multe joburi cu numele dat');
             WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
                 
   END;

   FUNCTION sal( 
    v_dep emp_dca.department_id%TYPE,
    v_job emp_dca.job_id%TYPE) 
   RETURN NUMBER
   IS
        rez emp_dca.salary%TYPE;
   BEGIN
        SELECT min(salary)
        INTO rez
        FROM emp_dca
        WHERE department_id = v_dep and job_id = v_job;
        RETURN rez;
    EXCEPTION
             WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati care lucreaza in aceste departamnet si la acest job');
             WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
                  
   END;
    
   PROCEDURE adauga_emp
    (v_first_name emp_dca.first_name%TYPE,
     v_last_name emp_dca.last_name%TYPE,
     v_nr_telef emp_dca.phone_number%TYPE,
     v_email emp_dca.email%TYPE
     )
    IS
    v_salariu emp_dca.salary%TYPE;
    v_cod_manager emp_dca.employee_id%TYPE;
    v_cod_dep emp_dca.department_id%TYPE;
    v_cod_job emp_dca.job_id%TYPE;
    
    BEGIN 
            v_cod_manager := cod_m('Douglas', 'Grant');
            v_cod_dep := cod_d ('Administration');
            v_cod_job := cod_j('Accountant');
            v_salariu := sal( v_cod_dep,v_cod_job);
            
            INSERT into emp_dca VALUES
            (SEC_DCA.nextval,
             v_first_name,
             v_last_name,
             v_email,
             v_nr_telef,
             SYSDATE,
             v_cod_job, 
             v_salariu,
             NULL, 
             v_cod_manager, 
             v_cod_dep
             );    
      END adauga_emp;    
         
--b
FUNCTION comm
        (v_dep emp_dca.department_id%TYPE,
        v_job emp_dca.job_id%TYPE) 
    RETURN NUMBER
 IS
        rez emp_dca.commission_pct%TYPE;
   BEGIN
        SELECT min(commission_pct)
        INTO rez
        FROM emp_dca
        WHERE department_id = v_dep and job_id = v_job;
        RETURN rez;
    EXCEPTION
             WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati care lucreaza in aceste departamnet si la acest job');
             WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
                  
END;
    
 PROCEDURE schimba_dep(
        v_first_name emp_dca.first_name%TYPE,
        v_last_name emp_dca.last_name%TYPE,
        v_dep_name dept_dca.department_name%TYPE,
        v_job_name jobs.job_title%TYPE,
        v_m_first_name emp_dca.first_name%TYPE,
        v_m_last_name emp_dca.last_name%TYPE
        )
IS
    v_salariu emp_dca.salary%TYPE;
    v_cod_manager emp_dca.employee_id%TYPE;
    v_cod_dep emp_dca.department_id%TYPE;
    v_cod_job emp_dca.job_id%TYPE;
    v_cod_emp emp_dca.employee_id%TYPE;
    v_comm emp_dca.commission_pct %TYPE;

 BEGIN 
            v_cod_manager := cod_m(v_m_first_name, v_m_last_name);
            v_cod_dep := cod_d (v_dep_name);
            v_cod_job := cod_j( v_job_name);
            v_cod_emp := cod_m(v_first_name, v_last_name);
            v_comm := comm(v_cod_dep,v_cod_job);
            SELECT salary
            INTO v_salariu
            FROM emp_dca
            WHERE employee_id = v_cod_emp;
            IF (v_salariu < sal( v_cod_dep,v_cod_job)) THEN
                v_salariu := sal( v_cod_dep,v_cod_job);  
            END IF; 
            UPDATE emp_dca
            SET department_id = v_cod_dep,
            job_id = v_cod_job,
            manager_id = v_cod_manager,
            salary = v_salariu, 
            commission_pct = v_comm,
            hire_date = SYSDATE
            WHERE employee_id = v_cod_emp;
            
          
           
            INSERT INTO job_hist_dca VALUES
            (v_cod_emp,
            SYSDATE,
            '19-OCT-22', 
            v_cod_job,
            v_cod_dep );

END;
--C
    FUNCTION subalterni(
    v_first_name emp_dca.first_name%TYPE,
        v_last_name emp_dca.last_name%TYPE)
    RETURN NUMBER
    IS
        v_cod emp_dca.employee_id%TYPE;
        rez NUMBER;
    BEGIN
        v_cod := cod_m(v_first_name, v_last_name);
        SELECT count(employee_id)-1
        INTO rez
        FROM emp_dca
        START WITH employee_id = v_cod
        CONNECT BY PRIOR  employee_id = manager_id;
        RETURN rez;
   END;     
--d
    PROCEDURE promovare
          (v_first  emp_dca.first_name%TYPE, 
          v_last emp_dca.last_name%TYPE)
    IS
        v_cod_emp emp_dca.employee_id%TYPE;
        v_cod_man emp_dca.employee_id%TYPE;
    BEGIN
        v_cod_emp := cod_m(v_first, v_last);
        SELECT manager_id
        INTO v_cod_man
        FROM emp_dca
        WHERE employee_id = v_cod_emp;
        
        UPDATE emp_dca
        SET manager_id  = (SELECT manager_id 
                           FROM emp_dca
                           WHERE employee_id = v_cod_man)
        WHERE employee_id = v_cod_emp;
     END;   
 --e
 
  PROCEDURE act_salariu
   (  v_last emp_dca.last_name%TYPE,
      v_valoare emp_dca.salary%TYPE)
 IS
    TYPE angajat IS RECORD
        (v_nume emp_dca.last_name%TYPE,
         v_prenume emp_dca.first_name%TYPE,
         v_cod emp_dca.employee_id%TYPE);
    TYPE tabel_angajati IS TABLE OF angajat;
    
    v_angajati tabel_angajati := tabel_angajati();
    v_cod_job emp_dca.job_id%TYPE;
    v_cod_emp emp_dca.employee_id%TYPE;
    v_min_salary emp_dca.salary%TYPE;
    v_max_salary emp_dca.salary%TYPE;
    limits EXCEPTION;
    
    BEGIN
        SELECT employee_id, job_id
        INTO v_cod_emp, v_cod_job
        FROM emp_dca
        WHERE last_name = v_last;
        
        SELECT min_salary, max_salary
        INTO v_min_salary, v_max_salary
        FROM jobs
        WHERE job_id = v_cod_job;
        
        IF v_valoare >= v_min_salary and v_valoare <= v_max_salary THEN
            UPDATE emp_dca
            SET salary = v_valoare
            WHERE employee_id = v_cod_emp;
        ELSE
           RAISE limits;
        END IF;
        
    EXCEPTION
        WHEN limits
                THEN DBMS_OUTPUT.PUT_LINE('Salariul nu respecta limitele impuse pentru acest job');
        WHEN NO_DATA_FOUND
                THEN DBMS_OUTPUT.PUT_LINE('Nu exista niciun angajat cu numele ' || v_last);
        WHEN TOO_MANY_ROWS
                THEN DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati cu numele ' || v_last);
                     SELECT last_name, first_name, employee_id
                     BULK COLLECT INTO v_angajati
                     FROM emp_dca
                     WHERE last_name = v_last;
                     FOR i IN v_angajati.FIRST..v_angajati.LAST LOOP
                        DBMS_OUTPUT.PUT_LINE(v_angajati(i).v_nume || ' ' || v_angajati(i).v_prenume || ' ' || v_angajati(i).v_cod);
                     END LOOP;
        END;

  PROCEDURE detalii_job
  AS
    job_nou NUMBER;
    BEGIN
        FOR i IN lista_joburi LOOP
            DBMS_OUTPUT.PUT_LINE(i.job_title);
            DBMS_OUTPUT.NEW_LINE;
            FOR j IN lista_angajati(i.job_id) LOOP
                DBMS_OUTPUT.PUT_LINE(j.first_name || ' ' || j.last_name);
                SELECT count(*)
                INTO job_nou
                FROM job_history
                WHERE employee_id = j.employee_id and job_id = i.job_id;
                IF job_nou != 0 THEN 
                    DBMS_OUTPUT.PUT_LINE('Angajatul a mai avut acest job in trecut.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Angajatul nu a mai avut acest job in trecut.');
                END IF;  
            END LOOP;
            DBMS_OUTPUT.NEW_LINE;
        END LOOP;
    END;
 END pachet1_dca;       
        
/
select * from job_history;
     
--pachet1_dca.schimba_dep('Alexander', 'Hunold', 'Administration', 'President', 'David', 'Austin');
set serveroutput on;
BEGIN
    DBMS_OUTPUT.PUT_LINE(pachet1_dca.subalterni('Steven','King'));
END;

