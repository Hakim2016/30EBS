
-- Step 1 : 获取界面上的SID ，通过个性化消息获得
SELECT t.sid
  FROM v$mystat t
 WHERE rownum = 1;
SELECT *
  FROM v$session t
 WHERE upper(t.module) LIKE upper('%XXARPTAX%');

--directly v2.0 by Hakim
-- Step 2 : 点击LOV不选，查询以下语句获得LOV里的SQL
SELECT s.prev_sql_addr,
       s.sql_address,
       s.module,
       s.client_identifier,
       swn.piece,
       swn.sql_text
  FROM v$session               s,
       v$sqltext_with_newlines swn
 WHERE s.sid = (SELECT t.SID
  FROM v$session t
 WHERE upper(t.module) LIKE UPPER('%INVSDOIO%'))--('%XXARPTAX%'))--409
   AND s.prev_sql_addr = swn.address
 ORDER BY swn.piece;

SELECT s.prev_sql_addr,
       s.sql_address,
       s.module,
       s.client_identifier,
       swn.piece,
       swn.sql_text
  FROM v$session               s,
       v$sqltext_with_newlines swn
 WHERE 1 = 1
      -- AND s.sid = 409 
   AND s.prev_sql_addr = swn.address
   AND upper(s.module) LIKE upper('%XXINVDNF%') -- Form Name
 ORDER BY s.module,
          s.client_identifier,
          swn.piece;
