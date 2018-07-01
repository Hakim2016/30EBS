-- Concurrent 
-- Snapshot Monitor
-- Memory-based Snapshot Worker

-- Concurrent Program (Snapshot Monitor) will lock table MTL_MATERIAL_TRANSACTIONS_TEMP .
-- Usually, this situation will lead material transaction£¨inv_txn_manager_pub.process_transactions£© keeping running 
-- until table MTL_MATERIAL_TRANSACTIONS_TEMP released.

-- Solution
-- Cancelled concurrent "Snapshot Monitor" or "Memory-based Snapshot Worker"

-- Query Script
SELECT fcr.request_id,
       fcr.parent_request_id,
       (nvl(fcr.actual_completion_date, SYSDATE) - fcr.actual_start_date) * 24 * 60 * 60 "Time-Consuming",
       fu.user_name,
       (SELECT he.full_name
          FROM hr_employees he
         WHERE 1 = 1
           AND fu.employee_id = he.employee_id) employee_full_name,
       frv.responsibility_name,
       fcp.user_concurrent_program_name,
       fl_phase.meaning,
       fl_status.meaning,
       fcr.argument_text,
       fcr.actual_start_date
  FROM fnd_concurrent_requests    fcr,
       fnd_user                   fu,
       fnd_lookups                fl_phase,
       fnd_lookups                fl_status,
       fnd_concurrent_programs_vl fcp,
       fnd_responsibility_vl      frv
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.requested_by = fu.user_id
   AND fcr.responsibility_application_id = frv.application_id
   AND fcr.responsibility_id = frv.responsibility_id
   AND fl_phase.lookup_type = 'CP_PHASE_CODE'
   AND fl_phase.lookup_code = fcr.phase_code
   AND fl_status.lookup_type = 'CP_STATUS_CODE'
   AND fl_status.lookup_code = fcr.status_code
      -- AND fcr.concurrent_program_id IN (106523)
      --AND fl_phase.meaning NOT IN ('Completed', 'Pending')
   AND upper(fcp.user_concurrent_program_name) LIKE upper('%Snapshot%')
--AND fcr.request_id = 5876057
 ORDER BY fcr.request_id DESC;
