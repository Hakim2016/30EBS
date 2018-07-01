select sa.SQL_TEXT
  from v$session se, v$sqlarea sa
 where se.PREV_HASH_VALUE = sa.HASH_VALUE
   and se.AUDSID = 41681718 --DB_SESSION_ID
