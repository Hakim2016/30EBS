SELECT nvl(ses.username, 'ORACLE PROC') || ' (' || ses.sid || ')' username,
       sid,
       machine,
       sql.piece,
       REPLACE(sql.sql_text, chr(10), '') stmt,
       ltrim(to_char(floor(ses.last_call_et / 3600), '09')) || ':' ||
       ltrim(to_char(floor(MOD(ses.last_call_et, 3600) / 60), '09')) || ':' ||
       ltrim(to_char(MOD(ses.last_call_et, 60), '09')) runt,
       ses.module
  FROM v$session               ses,
       v$sqltext_with_newlines SQL
 WHERE ses.status = 'ACTIVE'
   AND ses.username IS NOT NULL
   AND ses.sql_address = sql.address
   AND ses.sql_hash_value = sql.hash_value
   AND ses.audsid <> userenv('SESSIONID')
 ORDER BY runt DESC,
          1,
          sql.piece;

SELECT ses.sid,
       ses.serial#,
       ses.username,
       ses.sql_id,
       ses.sql_child_number,
       optimizer_mode,
       hash_value,
       address,
       sql_text
  FROM v$sqlarea sqlarea,
       v$session ses
 WHERE ses.sql_hash_value = sqlarea.hash_value
   AND ses.sql_address = sqlarea.address
--AND ses.username IS NOT NULL;
 ORDER BY ses.sid
