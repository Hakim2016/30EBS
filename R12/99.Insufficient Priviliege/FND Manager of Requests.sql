SELECT --ROWID,
--row_id,
 concurrent_queue_name,
 user_concurrent_queue_name,
 target_node,
 v.running_processes        actual,
 max_processes              target,
 NULL                       running,
 v.target_queue,
 v.target_processes,
 application_id             app_id,
 concurrent_queue_id,
 control_code,
 manager_type
  FROM fnd_concurrent_queues_vl v
 WHERE enabled_flag = 'Y'
   AND v.user_concurrent_queue_name = 'Standard Manager' --'XXFND:Interface Manager'--'Standard Manager'
 ORDER BY decode(application_id, 0, decode(concurrent_queue_id, 1, 1, 4, 2)),
          sign(max_processes) DESC,
          concurrent_queue_name,
          application_id;

SELECT request_id,
       phase_code,
       status_code,
       argument_text,
       requested_by,
       description,
       concurrent_program_id,
       program_application_id,
       concurrent_queue_id,
       queue_application_id
  FROM fnd_concurrent_worker_requests
 WHERE (phase_code = 'P' OR phase_code = 'R')
   AND hold_flag != 'Y'
   AND requested_start_date <= SYSDATE
   AND ('' IS NULL OR ('' = 'B' AND phase_code = 'R' AND status_code IN ('I', 'Q')))
   AND '1' IN (0, 1, 4)
   AND (concurrent_queue_id = 0)
   AND (queue_application_id = 0)
 ORDER BY priority,
          priority_request_id,
          request_id;
          
SELECT fcp.concurrent_program_name, cwr.*
FROM fnd_concurrent_worker_requests cwr,
fnd_concurrent_programs fcp
WHERE 1=1
AND cwr.CONCURRENT_PROGRAM_ID = fcp.concurrent_program_id;

SELECT * FROM fnd_concurrent_programs_vl fcr;
