--ex 16
select table_name
from user_tables
where table_name like upper('%emp\_%') escape '\';

--ex22
--atunci cand tabela nu exista


--ex 23
spool d:/insert_tables.sql;

select 'insert into ' || table_name || 'VALUES' || (1, Administration, 200, 1700)
from user_tables
where table_name like upper('departments');

spool off;


