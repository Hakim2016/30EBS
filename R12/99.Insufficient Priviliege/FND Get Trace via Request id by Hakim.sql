SELECT 'Request id: ' || request_id,
       'Trace id: ' || oracle_process_id,
       'Trace Flag: ' || req.enable_trace,
       'Trace Name: ' || dest.VALUE || '/' || UPPER(dbnm.VALUE) || '_ora_' || oracle_process_id ||
       '.trc',
       'Prog. Name: ' || prog.user_concurrent_program_name,
       'File Name: ' || execname.execution_file_name || execname.subroutine_name,
       'Status : ' || decode(phase_code, 'R', 'Running') || '-' ||
       decode(status_code, 'R', 'Normal'),
       'SID Serial: ' || ses.sid || ',' || ses.serial#,
       'Module : ' || ses.module
  FROM fnd_concurrent_requests    req,
       v$session                  ses,
       v$process                  proc,
       v$parameter                dest,
       v$parameter                dbnm,
       fnd_concurrent_programs_vl prog,
       fnd_executables            execname
 WHERE req.request_id = 14471375--&request
   AND req.oracle_process_id = proc.spid(+)
   AND proc.addr = ses.paddr(+)
   AND dest.NAME = 'user_dump_dest'
   AND dbnm.NAME = 'db_name'
   AND req.concurrent_program_id = prog.concurrent_program_id
   AND req.program_application_id = prog.application_id
   AND prog.application_id = execname.application_id
   AND prog.executable_id = execname.executable_id;
