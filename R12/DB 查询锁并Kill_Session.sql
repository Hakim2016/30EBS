SELECT b.sid,
       b.username,
       b.machine,
       a.object,
       'alter system kill session ' || '''' || b.sid || ',' || b.serial# || ''';' kill_command
  FROM v$access  a,
       v$session b
 WHERE a.sid = b.sid
   AND upper(a.object) LIKE '%MTL_DESCR_ELEMENT_VALUES%'
   AND a.type = 'TABLE';

SELECT b.sid,
       b.username,
       b.machine,
       a.object,
       a.type,
       'alter system kill session ' || '''' || b.sid || ',' || b.serial# || ''';' kill_command
  FROM v$access  a,
       v$session b
 WHERE a.sid = b.sid
   AND upper(a.object) LIKE '%XX%'
   AND a.type = 'TABLE';
   
Select /*+RULE*/
 s.machine,
 s.osuser     "O/S-User",
 s.username   "Ora-User",
 s.sid        "Session-ID",
 s.serial#    "Serial",
 s.process    "Process-ID",
 s.status     "Status",
 l.name       "Obj Locked",
 l.mode_held  "Lock Mode",
 s.logon_time,
 s.client_identifier
   FROM v$session s, dba_dml_locks l, v$process p
 Where l.session_id = s.sid
    AND p.addr = s.paddr
    and l.name LIKE 'XLA%'--'MTL_TXN_REQUEST_LINES'
    --AND s.client_identifier = '70236500'
 order by s.logon_time;

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
   AND ao.object_name LIKE 'XLA%'
   ;



--È¡ÏûËø±í£º

 --alter system kill session 'Session_ID,serial';

SELECT * FROM XLA_ACCOUNTING_ERRORS err
WHERE 1=1
AND err.last_update_date > TRUNC(SYSDATE);

----Add by Hakim @ 05-Oct-2018
select * from v$lock where lmode=0 and type in ('TM','TX');
select * from v$lock where lmode>0 and type in ('TM','TX');
