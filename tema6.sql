--ex1

--a
set serveroutput on;
DECLARE
    v_cod1 employees.job_id%Type;
    v_cod2 v_cod1%Type;
    v_titlu jobs.job_title%Type;
    v_nume employees.last_name%Type;
    v_salariu employees.salary%Type;
    CURSOR v_job IS (SELECT job_id, job_title FROM jobs);
    CURSOR v_emp IS (SELECT job_id, last_name, salary FROM employees);
BEGIN
    OPEN v_job;
    LOOP 
        FETCH v_job INTO v_cod1, v_titlu;
        EXIT WHEN v_job % NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || v_titlu || ' are angajatii: ');
        OPEN v_emp;
        LOOP 
            FETCH v_emp INTO v_cod2, v_nume, v_salariu;
            EXIT WHEN v_emp % NOTFOUND;
            IF v_cod1 = v_cod2 THEN
                DBMS_OUTPUT.PUT_LINE('Angajatul cu numele ' || v_nume || ' are salariul de ' || v_salariu);
            END IF;
        END LOOP;
        dbms_output.new_line;
        CLOSE v_emp;
    END LOOP;
    CLOSE v_job;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');    
END;

--b

set serveroutput on;
DECLARE
    CURSOR v_job IS (SELECT job_id, job_title FROM jobs);
    CURSOR v_emp IS (SELECT job_id, last_name, salary FROM employees);
BEGIN
    for i in v_job loop
         DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || i.job_title || ' are angajatii: ');
         for j in v_emp loop
             IF i.job_id = j.job_id THEN
                DBMS_OUTPUT.PUT_LINE('Angajatul cu numele ' || j.last_name || ' are salariul de ' || j.salary);
            END IF;
         END LOOP;
         dbms_output.new_line;
    end loop;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');      
END;    
            

--c

set serveroutput on;
BEGIN
    for i in (SELECT job_id, job_title FROM jobs) loop
         DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || i.job_title || ' are angajatii: ');
         for j in  (SELECT job_id, last_name, salary FROM employees) loop
             IF i.job_id = j.job_id THEN
                DBMS_OUTPUT.PUT_LINE('Angajatul cu numele ' || j.last_name || ' are salariul de ' || j.salary);
            END IF;
         END LOOP;
         dbms_output.new_line;
    end loop;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');  
END;    
          
   
--d

set serveroutput on;
DECLARE
    v_titlu jobs.job_title%Type;
    v_nume employees.last_name%Type;
    v_salariu employees.salary%Type;
    TYPE refcursor IS REF CURSOR;
    CURSOR v_job IS (SELECT  job_title , 
                            CURSOR (SELECT  last_name, salary 
                                    FROM employees e
                                    WHERE e.job_id = j.job_id)
                    FROM jobs j);
    v_cursor refcursor;                
  
BEGIN
    OPEN v_job;
    LOOP 
        FETCH v_job INTO  v_titlu, v_cursor;
        EXIT WHEN v_job % NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || v_titlu || ' are angajatii: ');
        LOOP 
            FETCH v_cursor INTO v_nume, v_salariu;
            EXIT WHEN v_cursor % NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Angajatul cu numele ' || v_nume || ' are salariul de ' || v_salariu);
        END LOOP;
        dbms_output.new_line;
    END LOOP;
    CLOSE v_job;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');  
END;

--ex 2

set serveroutput on;
DECLARE
    CURSOR v_job IS (SELECT job_id, job_title FROM jobs);
    CURSOR v_emp IS (SELECT job_id, last_name, salary FROM employees);
    v_ordine NUMBER(4) := 0;
    v_nr_ang NUMBER(4) := 0;
    v_sal_job employees.salary%type ;
    v_sal_total employees.salary%type := 0;
    BEGIN
    for i in v_job loop
         DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || i.job_title || ' are angajatii: ');
         v_ordine :=0;
         v_sal_job := 0;
         for j in v_emp loop
             IF i.job_id = j.job_id THEN
                v_ordine := v_ordine + 1;
                DBMS_OUTPUT.PUT_LINE(v_ordine || '. Angajatul cu numele ' || j.last_name || ' are salariul de ' || j.salary);
                v_sal_job := v_sal_job + j.salary;
            END IF;
         END LOOP;
         DBMS_OUTPUT.PUT_LINE('Jobul are ' || v_ordine || ' angajati, salariul totalpe aceste job este de ' || v_sal_job || ' si media este de ' || v_sal_job / v_ordine );
         v_nr_ang := v_nr_ang + v_ordine;
         v_sal_total := v_sal_total + v_sal_job;
         dbms_output.new_line;
    end loop;
    DBMS_OUTPUT.PUT_LINE('Compania are ' || v_nr_ang || ' angajati, are salariu total de ' || v_sal_total || ' si media totala ' || round((v_sal_total / v_nr_ang), 2);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');      
END;    
   
   
--ex3
   
   
   
   set serveroutput on;
DECLARE
    CURSOR v_job IS (SELECT job_id, job_title FROM jobs);
    CURSOR v_emp IS (SELECT job_id, last_name, salary FROM employees);
    v_ordine NUMBER(4) := 0;
    v_nr_ang NUMBER(4) := 0;
    v_sal_job employees.salary%type ;
    v_sal_total employees.salary%type := 0;
    v_com_job employees.commission_pct%type;
    v_com_total int;
    BEGIN
    SELECT SUM(case when commission_pct is null then salary else  salary + salary * commission_pct end)
    INTO v_com_total
    FROM employees;
    for i in v_job loop
         DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || i.job_title || ' are angajatii: ');
         v_ordine :=0;
         v_sal_job := 0;
         for j in v_emp loop
             IF i.job_id = j.job_id THEN
                v_ordine := v_ordine + 1;
                DBMS_OUTPUT.PUT_LINE(v_ordine || '. Angajatul cu numele ' || j.last_name || ' are salariul de ' || j.salary || ' insemnand '|| 
                round((j.salary * 100 / v_com_total),2 )|| '% din suma totala ');
                v_sal_job := v_sal_job + j.salary;
            END IF;
         END LOOP;
         DBMS_OUTPUT.PUT_LINE('Jobul are ' || v_ordine || ' angajati, salariul total pe aceste job este de ' || v_sal_job || ' si media este de ' || round((v_sal_job / v_ordine ),2));
         v_nr_ang := v_nr_ang + v_ordine;
         v_sal_total := v_sal_total + v_sal_job;
         dbms_output.new_line;
    end loop;
    DBMS_OUTPUT.PUT_LINE('Compania are ' || v_nr_ang || ' angajati, are salariu total de ' || v_sal_total || ' si media totala ' || round((v_sal_total / v_nr_ang),2));
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');      
END;    
   
  
--ex4

set serveroutput on;
DECLARE
    v_cod1 employees.job_id%Type;
    v_cod2 v_cod1%Type;
    v_nume employees.last_name%Type;
    v_titlu jobs.job_title%Type;
    v_salariu employees.salary%Type;
    CURSOR v_job IS (SELECT job_id, job_title FROM jobs);
    CURSOR v_emp (cod Employees.Job_Id%Type) IS ( SELECT * FROM (SELECT Last_Name,salary 
                                                FROM Employees
                                                WHERE job_id=cod
                                                ORDER BY salary desc) WHERE ROWNUM <=5);
                                                
    v_ordine NUMBER(4) := 0;
    BEGIN
    OPEN v_job;
    LOOP 
         FETCH v_job INTO v_cod1, v_titlu;
         EXIT WHEN v_job % NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || v_titlu || ' are angajatii: ');
         v_ordine :=0;
         OPEN v_emp(v_cod1);
         LOOP 
            FETCH v_emp INTO v_nume,v_salariu;
            EXIT WHEN v_emp%NOTFOUND;
            v_ordine := v_ordine + 1;
            DBMS_OUTPUT.PUT_LINE(v_ordine || '. Angajatul cu numele ' || v_nume || ' are salariul de ' || v_salariu); 
         END LOOP;
         IF v_ordine < 5 THEN
            DBMS_OUTPUT.PUT_LINE('CONTINE MAI PUTIN DE 5 ANGAJATI!');
        END IF;
         dbms_output.new_line;
          CLOSE v_emp;
    end loop;
     CLOSE v_job;
   EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');      
END;    
   
   
--ex 5
  set serveroutput on;
DECLARE
    v_cod1 employees.job_id%Type;
    v_cod2 v_cod1%Type;
    v_titlu jobs.job_title%Type;
    v_nume employees.last_name%Type;
    v_salariu employees.salary%Type;
    v_sal_ant employees.salary%Type := 0;
    v_ordine NUMBER(4) := 0;
    CURSOR v_job IS (SELECT job_id, job_title FROM jobs);
    CURSOR v_emp IS (SELECT job_id, last_name, salary FROM employees);
BEGIN
    OPEN v_job;
    LOOP 
        FETCH v_job INTO v_cod1, v_titlu;
        EXIT WHEN v_job % NOTFOUND;
        v_ordine := 0;
        DBMS_OUTPUT.PUT_LINE('Jobul cu titlul ' || v_titlu || ' are angajatii: ');
        OPEN v_emp;
        LOOP 
            FETCH v_emp INTO v_cod2, v_nume, v_salariu;
            EXIT WHEN v_emp % NOTFOUND;
            
            IF v_cod1 = v_cod2 and v_ordine < 5 THEN
                v_ordine := v_ordine + 1;
                v_sal_ant := v_salariu;
                DBMS_OUTPUT.PUT_LINE(v_ordine || '. Angajatul cu numele ' || v_nume || ' are salariul de ' || v_salariu);
            ELSIF  v_cod1 = v_cod2 and v_salariu = v_sal_ant then
                v_ordine := v_ordine + 1;
                DBMS_OUTPUT.PUT_LINE(v_ordine || '. Angajatul cu numele ' || v_nume || ' are salariul de ' || v_salariu);     
            END IF;
        END LOOP;
           IF v_ordine < 5 THEN
            DBMS_OUTPUT.PUT_LINE('CONTINE MAI PUTIN DE 5 ANGAJATI!');
        END IF;
        dbms_output.new_line;
        CLOSE v_emp;
    END LOOP;
    CLOSE v_job;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru care sa lucreze la acest departament');    
END;