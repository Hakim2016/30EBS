  SELECT sess.sid,
       sess.serial#,
       lo.oracle_username,
       lo.os_user_name,
       sess.client_identifier,
       ao.object_name,
       ao.OBJECT_TYPE,
       sa.sql_text,
       sa.action,
       sn.STATUS,
       lo.locked_mode,  
       sess.terminal,
       sess.audsid,
       sess.logon_time  
  FROM v$locked_object lo,
       dba_objects     ao,
       v$session       sess,
       v$sqlarea       sa,
       SYS.GV_$SESSION sn
 WHERE ao.object_id = lo.object_id
   AND lo.session_id = sess.sid
   AND sa.address = sess.prev_sql_addr
   AND lo.PROCESS = sn.PROCESS
   AND ao.object_name LIKE 'XXPA_WIP_COST_SOUCHI_DTL_TMP'--'XLA%'
   ;

SELECT *
  FROM xla_accounting_errors
 WHERE 1 = 1 --AND 
;
