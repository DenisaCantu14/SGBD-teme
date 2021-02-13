--1
--a) 2
--b) text 2
--c) text 3 adaugat in sub-bloc
--d)101
--e)text 1 adaugat in blocul principal
--f)text 2 adaugat in blocul principal


--2 a
SELECT
    book_date, COUNT(*)
FROM rental
GROUP BY book_date
HAVING book_date >= '01-10-2020' AND book_date < '01-11-2020';


 --2 b
CREATE TABLE octombrie_dca (
    id    NUMBER(2) PRIMARY KEY,
    data  DATE
);

DECLARE
    contor    NUMBER(2) := 1;
    data_inf  DATE := to_date('01-10-2020');
BEGIN
    LOOP
        INSERT INTO octombrie_dca VALUES (
            contor,
            data_inf
        );

        contor := contor + 1;
        data_inf := data_inf + 1;
        EXIT WHEN contor > 31;
    END LOOP;
END;

SELECT
    data,
    SUM(decode(book_date, NULL, 0, 1)) "Imprumuturi"
FROM
    octombrie_dca,
    rental
WHERE
    to_char(data) = to_char(book_date(+))
GROUP BY
    data
ORDER BY
    data;

--3

SET SERVEROUTPUT ON

DECLARE
    nume  VARCHAR(25) := '&m_nume';
    nr    NUMBER;
    cod   NUMBER;
BEGIN
    SELECT
        member_id
    INTO cod
    FROM
        member
    WHERE
        last_name = nume;

    SELECT
        COUNT(title_id)
    INTO nr
    FROM
        member  m,
        rental  r
    WHERE
            m.member_id = r.member_id
        AND m.member_id = cod;

    dbms_output.put_line('A imprumutat : '|| nr || ' filme');
    
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru cu acest nume');
    WHEN too_many_rows THEN
        dbms_output.put_line('Sunt mai multi membri cu acest nume'); 
    WHEN OTHERS THEN
        dbms_output.put_line('Alta eroare');
END;


--4

SET SERVEROUTPUT ON

DECLARE
    nume       VARCHAR(25) := '&m_nume';
    nr         NUMBER;
    cod        NUMBER;
    categorie  NUMBER;
    nr_total   NUMBER;
BEGIN
    SELECT
        member_id
    INTO cod
    FROM
        member
    WHERE
        last_name = nume;

    SELECT
        COUNT(title_id)
    INTO nr
    FROM
        member  m,
        rental  r
    WHERE
            m.member_id = r.member_id
        AND m.member_id = cod;

    dbms_output.put_line('A imprumutat : ' || nr || ' filme');
    
    SELECT
        COUNT(title_id)
    INTO nr_total
    FROM
        title;

    IF nr / nr_total > 0.75 THEN
        categorie := 1;
    ELSIF nr / nr_total BETWEEN 0.5 AND 0.75 THEN
        categorie := 2;
    ELSIF nr / nr_total BETWEEN 0.25 AND 0.5 THEN
        categorie := 3;
    ELSE
        categorie := 4;
    END IF;
    dbms_output.put_line('Membrul cu numele: ' || nume || ' face parte din categoria ' || categorie);
    
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru cu acest nume');
    WHEN too_many_rows THEN
        dbms_output.put_line('Sunt mai multi membri cu acest nume');
    WHEN OTHERS THEN
        dbms_output.put_line('Alta eroare'); 
END;


--5

CREATE TABLE member_dca AS SELECT * FROM member;

ALTER TABLE member_dca ADD discount NUMBER(2);

SET SERVEROUTPUT ON
DECLARE
    nr         NUMBER;
    cod        NUMBER :=  &m_cod;
    categorie  NUMBER;
    nr_total   NUMBER;
    valoare_discount   NUMBER;
BEGIN

    SELECT
        COUNT(title_id)
    INTO nr
    FROM
        member  m,
        rental  r
    WHERE
            m.member_id = r.member_id
        AND m.member_id = cod;

    dbms_output.put_line('A imprumutat : ' || nr || ' filme');
    
    SELECT
        COUNT(title_id)
    INTO nr_total
    FROM
        title;

    valoare_discount :=
        CASE
            WHEN nr / nr_total > 0.75 THEN
                10
            WHEN nr / nr_total BETWEEN 0.5 AND 0.75 THEN
                5
            WHEN nr / nr_total BETWEEN 0.25 AND 0.5 THEN
                3
            ELSE 0
        END;

    UPDATE member_dca
    SET
        discount = valoare_discount
    WHERE
        member_id = cod;

    dbms_output.put_line('Nr de linii actualizate: ' || SQL%rowcount);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista niciun membru cu acest nume');
    WHEN too_many_rows THEN
        dbms_output.put_line('Sunt mai multi membri cu acest nume'); 
    WHEN OTHERS THEN
        dbms_output.put_line('Alta eroare'); 
END;
   