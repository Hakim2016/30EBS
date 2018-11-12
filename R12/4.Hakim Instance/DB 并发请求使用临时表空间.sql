-- 并发请求使用临时表空间
SELECT fcr.request_id,
       --fcp.concurrent_program_name,
       fcp.user_concurrent_program_name,
       to_char(nvl(fcr.actual_completion_date, SYSDATE), 'SSSSS') - to_char(fcr.actual_start_date, 'SSSSS') "Time-consuming",
       fcr.phase_code,
       --fcr.status_code,
       su.tablespace,
       round(su.blocks * 8192 / (1024 * 1024), 2) used_space_m　,
       /*(SELECT round(SUM(blocks * 8192) / (1024 * 1024), 2)
        FROM v$sort_usage ss
       WHERE ss.tablespace = su.tablespace) used_space_total_m,*/
       (dtfs.tablespace_size - dtfs.free_space) / 1024 / 1024 used_space_total_m,
       --fcr.controlling_manager,
       --fcr.oracle_process_id,       
       vs.username,
       vs.machine,
       vs.program,
       vp.addr,
       vs.sid,
       vs.serial#,
       vs.saddr,
       su.segtype,
       s.sql_text,
       su.sqladdr,
       su.sqlhash
  FROM fnd_concurrent_requests    fcr,
       fnd_concurrent_programs_vl fcp,
       v$process                  vp,
       v$session                  vs,
       v$sort_usage               su,
       v$sql                      s,
       dba_temp_free_space        dtfs
 WHERE 1 = 1
      --AND fcr.request_id = 4725017
      -- AND fcr.concurrent_program_id = 100517
   AND fcp.concurrent_program_name = 'XXPAPCAS'
   --AND fcr.phase_code = 'R'
   AND fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
   AND fcr.oracle_process_id = vp.spid(+)
   AND vp.addr = vs.paddr(+)
   AND vs.saddr = su.session_addr(+)
      /*AND su.sqlhash = s.hash_value(+)
      AND su.sqladdr = s.address(+)*/
   AND su.sql_id = s.sql_id(+)
   AND su.tablespace = dtfs.tablespace_name(+)
 ORDER BY fcr.request_id DESC;


-- 临时表空间利用率
SELECT t.tablespace_name,
       t.tablespace_size,
       t.tablespace_size / 1024 / 1024 total_space_m,
       t.free_space,
       t.free_space / 1024 / 1024 free_space_m,
       (t.tablespace_size - t.free_space) / 1024 / 1024 used_space_m,
       round((1 - t.free_space / t.tablespace_size) * 100, 2) used_percentage
  FROM dba_temp_free_space t;
