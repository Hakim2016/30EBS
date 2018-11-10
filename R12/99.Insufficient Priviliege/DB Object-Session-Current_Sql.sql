SELECT vs.sid,
       vs.machine,
       vs.terminal,
       vs.program,
       vs.module,
       vs.action,
       vs.client_identifier,
       swn.piece,
       swn.sql_text,
       'alter system kill session ' || '''' || vs.sid || ',' || vs.serial# || ''';' kill_command
  FROM v$session               vs,
       v$sqltext_with_newlines swn
 WHERE 1 = 1
   AND vs.client_identifier = 'HAND_PJL'
   AND vs.sid IN (SELECT va.sid
                    FROM v$access va
                   WHERE va.object = upper('po_line_locations_all'))
   AND vs.prev_sql_addr = swn.address
 ORDER BY vs.sid,
          vs.client_identifier,
          swn.piece;
