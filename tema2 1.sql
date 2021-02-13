-- 7 a
select count(*)
from title t join title_copy tc on (t.title_id = tc.title_id)
where (
      ((t.title_id, copy_id) not in (  select title_id, copy_id from rental where act_ret_date is null) and status = 'AVAILABLE'  )
or 
      ((t.title_id, copy_id)  in (  select title_id, copy_id from rental where act_ret_date is null) and status = 'RENT' )
      ); 
--7 b
UPDATE title_copy_DCA tc1
SET STATUS = 
    case 
        when  ((
                (title_id, copy_id)  not in 
                ( select title_id, copy_id 
                from rental r
                where act_ret_date is null) 
                and 
                status = 'AVAILABLE'
               
                ))
        THEN 'RENT'
        when (( (title_id, copy_id)  in 
                ( select title_id, copy_id 
                from rental r
                where act_ret_date is null) 
                and 
                status = 'RENT'
               ))
        THEN 'AVAILABLE'
        ELSE STATUS
        END;
        
--8--

select case 
     when res_date =  act_ret_date
     then 'Da'
     else 
     'Nu'
     end
from rental r, reservation re
where r.title_id = re.title_id;

--9



WITH val AS (SELECT r.member_id, NVL(SUM(DECODE(r.title_id, 92, 1)),0) "Willie and Christmas Too" , 
                                     NVL(SUM(DECODE(r.title_id, 93, 1)),0) "Alien Again",
                                     NVL(SUM(DECODE(r.title_id, 94, 1)),0) "The Glob",
                                     NVL(SUM(DECODE(r.title_id, 95, 1)),0) "My Day Off",
                                     NVL(SUM(DECODE(r.title_id, 96, 1)),0) "Miracles on Ice",
                                     NVL(SUM(DECODE(r.title_id, 97, 1)),0) "Soda Gang",
                                     NVL(SUM(DECODE(r.title_id, 98, 1)),0) "Interstellar Wars"
FROM rental r
GROUP BY r.member_id)
select last_name,first_name, v.*
from member m, val v
where m.member_id=v.member_id;

--10
WITH val AS (SELECT r.member_id,r.title_id,  NVL(SUM(DECODE(copy_id, 1, 1)),0) "1" , 
                                     NVL(SUM(DECODE(copy_id, 2, 1)),0) "2",
                                     NVL(SUM(DECODE(r.copy_id, 3, 1)),0) "3"
                                    
FROM rental r
GROUP BY r.member_id, r.title_id
order by r.member_id, r.title_id)
select last_name,first_name,t.title, v.*
from member m, val v, title t
where m.member_id=v.member_id and t.title_id = v.title_id;
 

