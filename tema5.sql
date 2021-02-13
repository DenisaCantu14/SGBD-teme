--ex1 

DECLARE
    TYPE inf IS RECORD (
        id      employees.employee_id%TYPE,
        salary  employees.salary%TYPE
    );
    TYPE ang IS
        TABLE OF inf INDEX BY BINARY_INTEGER;
    v_id         ang;
    v_id_update  ang;
BEGIN
    SELECT employee_id, salary
    BULK COLLECT
    INTO v_id
    FROM
        (
            SELECT employee_id, salary
            FROM employees
            WHERE commission_pct IS NULL
            ORDER BY salary
        )
    WHERE
        ROWNUM <= 5;

    FOR i IN v_id.first..v_id.last LOOP
        dbms_output.put('Angajatul cu idul: '
                        || v_id(i).id
                        || ' are salariul egal cu '
                        || v_id(i).salary
                        || ' ');

        dbms_output.new_line;
        UPDATE employees
        SET salary = salary * 1.05
        WHERE employee_id = v_id(i).id;

    END LOOP;

    SELECT employee_id, salary
    BULK COLLECT
    INTO v_id_update
    FROM
        (
            SELECT employee_id, salary
            FROM employees
            WHERE commission_pct IS NULL
            ORDER BY salary
        )
    WHERE
        ROWNUM <= 5;

    FOR i IN v_id_update.first..v_id_update.last LOOP
        dbms_output.put('Angajatul cu idul: '
                        || v_id_update(i).id
                        || ' are noul salariu egal cu '
                        || v_id_update(i).salary
                        || ' ');

        dbms_output.new_line;
    END LOOP;

END;
/


--ex2


CREATE TABLE excursie_dca (
    cod_excursie  NUMBER(4) PRIMARY KEY,
    denumire      VARCHAR(20),
    status        VARCHAR(11)
);

CREATE OR REPLACE TYPE tip_orase_dca  IS TABLE  OF varchar(20);
/

ALTER TABLE excursie_dca
ADD (orase tip_orase_dca)
NESTED TABLE orase STORE AS tabel_orase_dca;

--a

INSERT INTO excursie_dca VALUES (
    1,
    'Excursie1',
    'disponibilã',
     tip_orase_dca('Bucuresti', 'Iasi')
);

INSERT INTO excursie_dca VALUES (
    2,
    'Excusie2',
    'disponibila',
     tip_orase_dca('Cluj', 'Constanta')
);

INSERT INTO excursie_dca VALUES (
    3,
    'Excusie3',
    'disponibilã',
     tip_orase_dca('NewYork', 'LA')
);

INSERT INTO excursie_dca VALUES (
    4,
    'Excusie4',
    'disponibila',
    tip_orase_dca('Roma', 'Milano')
);

INSERT INTO excursie_dca VALUES (
    5,
    'Excusie5',
    'disponibilã',
    tip_orase_dca('Venetia', 'Napoli')
);

--b


SET SERVEROUTPUT ON;

DECLARE
    cod_exc   NUMBER(4) := &cod;
    excursie  tip_orase_dca := tip_orase_dca();
    oras1     VARCHAR(20) := '&nume1';
    oras2     VARCHAR(20) := '&nume2';
    sters     VARCHAR(20) := '&nume3';
    nr_excursii number(4);
BEGIN
    SELECT orase
    INTO excursie
    FROM excursie_dca
    WHERE cod_excursie = cod_exc;
    
  --prima cerinta  

    excursie.extend;
    excursie(excursie.last) := 'Nou';
    UPDATE excursie_dca
    SET orase = excursie
    WHERE cod_excursie = cod_exc;
    
    --a doua cerinta

    excursie.extend;
    FOR i IN REVERSE 2..excursie.last LOOP
        excursie(i) := excursie(i - 1);
    END LOOP;

    excursie(2) := 'Nou 2';
    
    UPDATE excursie_dca
    SET orase = excursie
    WHERE cod_excursie = cod_exc;
    
    --  a treia cerinta
     FOR i IN excursie.first..excursie.last LOOP
        IF excursie(i) = oras1 THEN
            excursie(i) := oras2;
        ELSIF excursie(i) = oras2 THEN
            excursie(i) := oras1;
        END IF;
       
    end loop;

     -- a patra cerinta

    FOR i IN excursie.first..excursie.last LOOP
        IF excursie(i) = sters THEN
            excursie.DELETE(i);
        END IF;
    END LOOP;
  
    UPDATE excursie_dca
    SET orase = excursie
    WHERE cod_excursie = cod_exc;
end;
    
    
    --c
    set serveroutput on;
    
    DECLARE
    cod_exc   NUMBER(4) := &cod;
    excursie  tip_orase_dca := tip_orase_dca();
    
    BEGIN
    SELECT orase
    INTO excursie
    FROM excursie_dca
    WHERE cod_excursie = cod_exc;
    
    dbms_output.put_line('Nr de orase ' || excursie.count);
    dbms_output.new_line;
    
    for i in excursie.first..excursie.last loop
        dbms_output.put_line(excursie(i));
    end loop;
    end;
    
    --d
   
    set serveroutput on;
    DECLARE
    excursie  tip_orase_dca := tip_orase_dca();
    nr_excursii number(4);
    BEGIN
        select count(*)
        into nr_excursii
        from excursie_dca;

        FOR i IN 1..nr_excursii loop
            SELECT orase
            into excursie
            FROM excursie_dca
            WHERE cod_excursie = i;

            dbms_output.put_line('Excursia ' || i);
            
            FOR j IN excursie.first..excursie.last loop
                dbms_output.put_line(excursie(j));
                
            end loop;
            dbms_output.new_line; 
        end loop;  
        
            end;
         
    
    --e
    
    DECLARE
    excursie  tip_orase_dca := tip_orase_dca();
    nr_excursii number(4);
    mini number(4) := 999;
    BEGIN
        select count(*)
        into nr_excursii
        from excursie_dca;
        
        dbms_output.put_line( nr_excursii);
        
        FOR i IN 1..nr_excursii loop
            SELECT orase
            into excursie
            FROM excursie_dca
            WHERE cod_excursie = i;
             
            if mini > excursie.count then mini := excursie.count; end if; 
            
        end loop;
        
        FOR i IN 1..nr_excursii loop
            SELECT orase
            into excursie
            FROM excursie_dca
            WHERE cod_excursie = i;
            
            if excursie.count = mini then
            update excursie_dca
            set status  = 'anulata'
            where cod_excursie = i;
            end if;
            
        end loop;
end;   
      

--ex3


 create or replace TYPE tip_orase_dca as varray (40) of varchar(20);
 
 CREATE TABLE excursie_dca (
    cod_excursie  NUMBER(4) PRIMARY KEY,
    denumire      VARCHAR(20),
    status        VARCHAR(11),
    orase        tip_orase_dca
);


--diferenta fata de ex 2: la ultima cerinta de la b nu pot folosi delete
SET SERVEROUTPUT ON;

DECLARE
    cod_exc   NUMBER(4) := &cod;
    excursie  tip_orase_dca := tip_orase_dca();
    excursie1  tip_orase_dca := tip_orase_dca();
    sters     VARCHAR(20) := '&nume1';
    contor number(2) := 1;
BEGIN
    SELECT orase
    INTO excursie
    FROM excursie_dca
    WHERE cod_excursie = cod_exc;
    
    FOR i IN excursie.first..excursie.last LOOP
        IF excursie(i) != sters THEN
            excursie1.extend;
            excursie1(contor):= excursie(i);
            contor := contor +1;
        END IF;
    END LOOP;
  
    UPDATE excursie_dca
    SET orase = excursie1
    WHERE cod_excursie = cod_exc;
end;

