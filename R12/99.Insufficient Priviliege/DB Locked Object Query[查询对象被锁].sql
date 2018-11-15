
SELECT do.owner,
       do.object_name,
       do.object_type,
       vl.session_id,
       vl.os_user_name,
       vl.locked_mode,
       vs.logon_time,
       vs.osuser,
       vs.machine,
       vs.terminal,
       vs.program,
       vs.module,
       vs.client_identifier,
       vs.prev_sql_addr
  FROM v$locked_object         vl,
       dba_objects             do,
       v$session               vs
 WHERE 1 = 1
   AND do.object_id = vl.object_id
   AND vl.session_id = vs.sid
   AND do.object_name LIKE upper('%pa_transaction_interface_all%')
   AND 1 = 1
 ORDER BY do.owner,
          do.object_name,
          vl.session_id,
          vs.module,
          vs.client_identifier,
          vs.prev_sql_addr;



SELECT do.owner,
       do.object_name,
       do.object_type,
       vl.session_id,
       vl.os_user_name,
       vl.locked_mode,
       vs.logon_time,
       vs.osuser,
       vs.machine,
       vs.terminal,
       vs.program,
       vs.module,
       vs.client_identifier,
       vs.prev_sql_addr,
       swn.piece,
       swn.sql_text,
       'alter system kill session ' || '''' || vs.sid || ',' || vs.serial# || ''';' kill_command
  FROM v$locked_object         vl,
       dba_objects             do,
       v$session               vs,
       v$sqltext_with_newlines swn
 WHERE 1 = 1
   AND do.object_id = vl.object_id
   AND vl.session_id = vs.sid
   AND vs.prev_sql_addr = swn.address
  --AND upper(vs.module) LIKE upper('%XXINVF003%')
   AND do.object_name LIKE upper('%pa_transaction_interface_all%')
   AND 1 = 1
 ORDER BY do.owner,
          do.object_name,
          vl.session_id,
          vs.module,
          vs.client_identifier,
          vs.prev_sql_addr,
          swn.piece;

SELECT va.sid,
       va.owner,
       va.object,
       va.type,
       vs.logon_time,
       vs.osuser,
       vs.machine,
       vs.terminal,
       vs.program,
       vs.module,
       vs.client_identifier,
       vs.prev_sql_addr,
       swn.piece,
       swn.sql_text,
       'alter system kill session ' || '''' || vs.sid || ',' || vs.serial# || ''';' kill_command
  FROM v$access                va,
       v$session               vs,
       v$sqltext_with_newlines swn
 WHERE 1 = 1
   AND va.sid = vs.sid
   AND vs.prev_sql_addr = swn.address
   AND upper(vs.module) LIKE upper('%XXINVF003%')
   AND va.object LIKE '%XXINV_PACKING_LISTS%'
   AND 1 = 1
 ORDER BY va.owner,
          va.object,
          va.sid,
          vs.module,
          vs.client_identifier,
          vs.prev_sql_addr,
          swn.piece;


-- 查询阻塞会话和其他信息
SELECT swait.sid waiters_session,
       --swait.lockwait,
       --swait.client_identifier,
       --swait.sql_id,
       --swait.prev_sql_id,
       swait.state,
       --lwait.id1,
       sqlwait.sql_text waiters_sql,
       slock.sid        blocker_session,
       --slock.client_identifier,
       --slock.sql_id,
       --slock.prev_sql_id,
       slock.state,
       sqllock.sql_text blocker_sql
  FROM v$session swait,
       v$lock    lwait,
       v$sql     sqlwait,
       v$lock    llock,
       v$session slock,
       v$sql     sqllock
 WHERE 1 = 1
   AND swait.lockwait IS NOT NULL
   AND swait.sid = lwait.sid
   AND swait.lockwait = lwait.kaddr
   AND swait.sql_id = sqlwait.sql_id
   AND lwait.id1 = llock.id1
   AND lwait.sid <> llock.sid
   AND llock.sid = slock.sid
   AND slock.prev_sql_id = sqllock.sql_id
   AND slock.prev_child_number = sqllock.child_number
