--ex3
set serveroutput on;
CREATE OR REPLACE FUNCTION func_dca (oras locations.city%TYPE)  
RETURN NUMBER IS 
    v_nr1 NUMBER;
    v_nr2 NUMBER;
    v_nr3 NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_nr1
    FROM locations
    WHERE city = oras;
    IF v_nr1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Orasul nu exista');
        RETURN 0;
    ELSE
        SELECT COUNT(*) INTO v_nr2
        FROM employees e, departments d, locations l
        WHERE city = oras and e.department_id = d.department_id and d.location_id = l.location_id;
        IF v_nr2 = 0 THEN
             DBMS_OUTPUT.PUT_LINE('Orasul nu are angajati'); 
            RETURN 0;
        ELSE
            SELECT COUNT(COUNT(*)) INTO v_nr3
            FROM employees e , job_history j 
            WHERE e.job_id = j.job_id
            GROUP BY j.employee_id
            HAVING COUNT(j.job_id) > 2;
            RETURN v_nr3;
        END IF;
    END IF;
END func_dca;
/
BEGIN
 DBMS_OUTPUT.PUT_LINE('Nr de angajati este '|| func_dca('Seattle'));
END;

--ex 4
set serveroutput on;
CREATE OR REPLACE PROCEDURE proc_dca (v_id employees.employee_id%TYPE := 101) 
IS 
    v_nr NUMBER;
    v_nr2 NUMBER;
    v_nr3 NUMBER;
    v_cod employees.employee_id%TYPE;
    v_nr4 NUMBER;
    CURSOR ang IS
        SELECT employee_id
        FROM emp_dca
        WHERE LEVEL > 1
        START WITH employee_id = v_id
        CONNECT BY PRIOR employee_id = manager_id;
BEGIN
    SELECT COUNT(*) INTO v_nr
    FROM emp_dca
    WHERE employee_id = v_id;
    
    IF v_nr = 0 THEN
         DBMS_OUTPUT.PUT_LINE('Nu exista angajat cu acest id');
    ELSE
        SELECT COUNT(*) INTO v_nr2
        FROM employees
        WHERE manager_id = v_id
        GROUP BY manager_id;
        IF v_nr2 = 0 THEN
              DBMS_OUTPUT.PUT_LINE('Managerul nu are angajati');
        ELSE
            OPEN ang;
            LOOP 
                FETCH ang INTO v_cod;
                EXIT WHEN ang % NOTFOUND;
                UPDATE emp_dca 
                    SET salary = salary * 1.1
                    WHERE employee_id = v_cod;
            END LOOP;
            v_nr4 := ang % ROWCOUNT; 
            CLOSE ang;
        END IF;
    END IF;
END;
/


BEGIN
proc_dca(100);
END;
/


--ex5

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE proc1_dca IS
    TYPE tab_index IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    max_ang NUMBER;
    ang NUMBER;
    v_zi tab_index;
BEGIN
    FOR v_dep IN (SELECT department_name, department_id
                  FROM departments ) LOOP
        SELECT COUNT(*)
        INTO ang
        FROM employees e, departments d
        WHERE e.department_id = d.department_id and d.department_id = v_dep.department_id;
        
        IF ang != 0 THEN
            SELECT MAX(COUNT(employee_id))
            INTO max_ang
            FROM employees
            WHERE department_id = v_dep.department_id
            GROUP BY TO_CHAR(hire_date, 'd');
            
            SELECT DISTINCT TO_CHAR(hire_date, 'd')
            BULK COLLECT INTO v_zi
            FROM employees
            WHERE department_id = v_dep.department_id
            GROUP BY TO_CHAR(hire_date, 'd')
            HAVING COUNT(employee_id) = max_ang;
            
            DBMS_OUTPUT.PUT_LINE(v_dep.department_name || ': ');
            DBMS_OUTPUT.PUT_LINE('Ziua cu cei mai multi angajati: ' || v_zi(1));
            FOR v_emp IN ( 
                SELECT last_name, SYSDATE - hire_date vechime, salary venit
                FROM employees
                WHERE department_id = v_dep.department_id AND 
                      TO_CHAR(hire_date, 'd') = v_zi(1)
            ) LOOP
                DBMS_OUTPUT.PUT_LINE(v_emp.last_name || ' ' || v_emp.vechime || ' ' || v_emp.venit);
            END LOOP;
            DBMS_OUTPUT.NEW_LINE;
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_dep.department_name || ': Nu exista angajati');
        END IF;
        
    END LOOP;
END;
/

BEGIN
proc1_dca;
END;
/
drop procedure proc1_dca;
--ex6

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE proc2_dca IS
    TYPE tab_index IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    max_ang NUMBER;
    ang NUMBER;
    v_zi tab_index;
    crt NUMBER;
    vechime NUMBER;
BEGIN
    
    FOR v_dep IN (SELECT department_name, department_id
                  FROM departments ) LOOP
        SELECT COUNT(*)
        INTO ang
        FROM employees e, departments d
        WHERE e.department_id = d.department_id and d.department_id = v_dep.department_id;
        
      
        IF ang != 0 THEN
            SELECT MAX(COUNT(employee_id))
            INTO max_ang
            FROM employees
            WHERE department_id = v_dep.department_id
            GROUP BY TO_CHAR(hire_date, 'd');
            
            SELECT DISTINCT TO_CHAR(hire_date, 'd')
            BULK COLLECT INTO v_zi
            FROM employees
            WHERE department_id = v_dep.department_id
            GROUP BY TO_CHAR(hire_date, 'd')
            HAVING COUNT(employee_id) = max_ang;
            
            DBMS_OUTPUT.PUT_LINE(v_dep.department_name || ': ');
            DBMS_OUTPUT.PUT_LINE('Ziua cu cei mai multi angajati: ' || v_zi(1));
            crt := 1;
            vechime := -1;
            FOR v_emp IN ( 
                SELECT last_name, SYSDATE - hire_date vechime, salary  venit
                FROM employees
                WHERE department_id = v_dep.department_id AND 
                      TO_CHAR(hire_date, 'd') = v_zi(1)
                ORDER BY vechime DESC
            ) LOOP
                DBMS_OUTPUT.PUT_LINE(crt || ' ' || v_emp.last_name || ' ' || v_emp.vechime || ' ' || v_emp.venit);
                IF vechime != v_emp.vechime THEN
                    crt := crt + 1;
                    vechime := v_emp.vechime;
                END IF;
            END LOOP;
            DBMS_OUTPUT.NEW_LINE;
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_dep.department_name || ': Nu exista angajati');
        END IF;
        
    END LOOP;
END;
/
BEGIN
proc2_dca;
END;
/