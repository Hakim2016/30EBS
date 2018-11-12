
-- Current Running Request Performance
SELECT /*fcr.request_id,
       vp.spid,
       se.SID,se.PROCESS,se.AUDSID,
       fcr.oracle_process_id, -- Database process identifier
       fcr.oracle_session_id, -- Database session identifier
       fcr.os_process_id, -- Operating system process identifier
       (nvl(fcr.actual_completion_date, SYSDATE) - fcr.actual_start_date) * 24 * 60 * 60 "Time-Consuming",
       fu.user_name,
       fcp.user_concurrent_program_name,
       fl_phase.meaning,
       fl_status.meaning,
       fcr.argument_text,
       fcr.actual_start_date,
       vp.addr,
       vp.pid,
       se.status,
       se.sql_exec_start,
       se.module,
       vs.sql_text,
       --vs.sql_fulltext,
       se.sql_id,
       vs_prev.sql_text prev_sql_text,
       --vs_prev.sql_fulltext prev_sql_fulltext,
       se.prev_sql_id,
       vp.**/
 fcr.request_id,
 vs_prev.*
  FROM fnd_concurrent_requests    fcr,
       fnd_user                   fu,
       fnd_lookups                fl_phase,
       fnd_lookups                fl_status,
       fnd_concurrent_programs_vl fcp,
       v$process                  vp,
       v$session                  se,
       v$sql                      vs,
       v$sql                      vs_prev
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
   AND fcr.requested_by = fu.user_id
   AND fl_phase.lookup_type = 'CP_PHASE_CODE'
   AND fl_phase.lookup_code = fcr.phase_code
   AND fl_status.lookup_type = 'CP_STATUS_CODE'
   AND fl_status.lookup_code = fcr.status_code
      --AND vp.spid IN (2550)
   AND vp.spid = fcr.oracle_process_id
   AND se.paddr = vp.addr
   AND se.sql_id = vs.sql_id
   AND se.prev_sql_id = vs_prev.sql_id
   AND vs.child_number = 0
   AND vs_prev.child_number = 0
      
   AND fl_phase.meaning <> 'Completed'
--AND fcr.concurrent_program_id IN (55467)
--AND fcr.request_id = 5876057
 ORDER BY to_number(vp.spid),
          fcr.request_id DESC;

SELECT *
  FROM v$sql t
 WHERE t.sql_id = '78ghnd3gghjwm';

SELECT *
  FROM v$sqltext t
 WHERE t.sql_id = '78ghnd3gghjwm';
