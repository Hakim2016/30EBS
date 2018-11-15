-- Listing of temp segments.
SELECT a.tablespace_name tablespace,
       d.mb_total,
       SUM(a.used_blocks * d.block_size) / 1024 / 1024 mb_used,
       d.mb_total - SUM(a.used_blocks * d.block_size) / 1024 / 1024 mb_free,
       round(SUM(a.used_blocks) / SUM(a.total_blocks) * 100, 6) used_percentage
  FROM v$sort_segment a,
       (SELECT b.name,
               c.block_size,
               SUM(c.bytes) / 1024 / 1024 mb_total
          FROM v$tablespace b,
               v$tempfile   c
         WHERE b.ts# = c.ts#
         GROUP BY b.name,
                  c.block_size) d
 WHERE a.tablespace_name = d.name
 GROUP BY a.tablespace_name,
          d.mb_total;

-- Temp segment usage per session.
SELECT s.sid || ',' || s.serial# sid_serial,
       s.username,
       s.osuser,
       p.spid,
       s.module,
       p.program,
       SUM(t.blocks) * tbs.block_size / 1024 / 1024 mb_used,
       t.tablespace,
       COUNT(*) statements
  FROM v$sort_usage    t,
       v$session       s,
       dba_tablespaces tbs,
       v$process       p
 WHERE t.session_addr = s.saddr
   AND s.paddr = p.addr
   AND t.tablespace = tbs.tablespace_name
 GROUP BY s.sid,
          s.serial#,
          s.username,
          s.osuser,
          p.spid,
          s.module,
          p.program,
          tbs.block_size,
          t.tablespace
 ORDER BY sid_serial;



SELECT su.tablespace,
       round(su.blocks * 8192 / (1024 * 1024), 2) used_space_m¡¡,
       (SELECT round(SUM(blocks * 8192) / (1024 * 1024), 2)
          FROM v$sort_usage ss
         WHERE ss.tablespace = su.tablespace) used_space_total_m,
       se.username,
       se.sid,
       se.serial#,
       se.sql_address,
       se.machine,
       se.program,
       se.module,
       se.action,
       se.client_identifier,
       su.segtype,
       su.contents,
       su.extents,
       su.blocks * to_number(rtrim(vp.value)) AS space,
       segtype,
       sql_text
--,se.*
  FROM v$sort_usage su,
       v$parameter  vp,
       v$session    se,
       v$sql        s
 WHERE vp.name = 'db_block_size'
   AND su.session_addr = se.saddr
   AND s.hash_value = su.sqlhash
   AND s.address = su.sqladdr
   --AND se.sid = 2119
 ORDER BY se.username,
          se.sid;


SELECT b.tablespace,
       b.segfile#,
       b.segblk#,
       round(((b.blocks * p.value) / 1024 / 1024), 2) size_mb,
       a.inst_id,
       a.sid,
       a.serial#,
       a.username,
       a.osuser,
       a.program,
       a.status,
       a.MODULE
  FROM gv$session    a,
       gv$sort_usage b,
       gv$process    c,
       gv$parameter  p
 WHERE p.name = 'db_block_size'
   AND a.saddr = b.session_addr
   AND a.paddr = c.addr
-- AND b.TABLESPACE='TEMP2'
 ORDER BY a.inst_id,
          b.tablespace,
          b.segfile#,
          b.segblk#,
          b.blocks;
