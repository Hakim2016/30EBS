SELECT t.name NAME,
       t.description description,
       t.term_id term_id,
       t.start_date_active,
       t.end_date_active,
       COUNT(*) number_of_due_dates,
       --arpt_sql_func_util.get_first_due_date(t.term_id, :1) term_due_date,
       t.in_use in_use
  FROM ra_terms_lines tl, ra_terms t
 WHERE 1=1
-- AND (NAME LIKE :2)
   /*AND (nvl(:3, trunc(SYSDATE)) BETWEEN t.start_date_active AND
       nvl(t.end_date_active, nvl(:4, trunc(SYSDATE))) AND
       t.term_id = tl.term_id)*/
       AND t.term_id = tl.term_id
 GROUP BY t.term_id, t.name, t.description, t.in_use,
       t.start_date_active,
       t.end_date_active /* guarantees cannot have split term terms */
--HAVING 1 = decode(:5, 'GUAR', COUNT(*), 1) AND (nvl(:6, 'Y') = 'Y' OR t.term_id = :7)
 ORDER BY t.name;
 
 SELECT arpt_sql_func_util.get_first_due_date(/*t.term_id*/1062, /*:1*/to_date('2019-02-19','yyyy-mm-dd')) from dual;
