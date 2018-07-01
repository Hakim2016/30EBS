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
       'alter system kill session ' || '''' || b.sid || ',' || b.serial# || ''';' kill_command
  FROM v$access  a,
       v$session b
 WHERE a.sid = b.sid
   AND upper(a.object) LIKE '%CUX%'
   AND a.type = 'PACKAGE'
