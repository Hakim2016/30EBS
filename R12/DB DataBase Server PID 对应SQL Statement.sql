SELECT p.spid,
       ss.value cpu_time,
       se.sid,
       se.prev_sql_addr,
       se.sql_address,
       se.module,
       se.client_identifier,
       swn.piece,
       swn.sql_text,
       p.*
  FROM v$process               p,
       v$session               se,
       v$sesstat               ss,
       v$sqltext_with_newlines swn
 WHERE 1 = 1
   AND p.spid IN (5069, 7731)
      --AND se.sid IN (2312, 1902, 2329, 2028)
   AND se.paddr = p.addr
   AND se.prev_sql_addr = swn.address
   AND ss.statistic# IN (SELECT statistic#
                           FROM v$statname
                          WHERE NAME = 'CPU used by this session')
   AND se.sid = ss.sid
--AND ss.sid > 6
 ORDER BY ss.value DESC,
          to_number(p.spid),
          se.sid,
          se.module,
          swn.piece;
