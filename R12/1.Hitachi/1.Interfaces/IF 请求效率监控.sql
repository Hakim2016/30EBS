SELECT fcp.USER_CONCURRENT_PROGRAM_NAME,
       fcr.request_id,
       fcr.request_date,
       fcr.requested_by,
       fcr.argument_text,

       round((fcr.actual_start_date - fcr.request_date) * 24 * 60, 2) wait_time,
       round((fcr.actual_completion_date - fcr.actual_start_date) * 24 * 60,
             2) run_time,
       (SELECT COUNT(1)
          FROM xxgl_accounting_hfg_int a
         WHERE a.request_id = fcr.request_id) count_num
  FROM fnd_concurrent_requests fcr, fnd_concurrent_programs_vl fcp
 WHERE fcr.concurrent_program_id = fcp.CONCURRENT_PROGRAM_ID
   AND fcp.CONCURRENT_PROGRAM_NAME = 'XXGLAD1'
   AND fcr.request_date > SYSDATE - 4;
   
   
SELECT fcp.USER_CONCURRENT_PROGRAM_NAME,
       fcr.request_id,
       fcr.request_date,
       fu.user_name requested_by,
       fcr.argument_text,
       round((fcr.actual_start_date - fcr.request_date) * 24 * 60, 2) wait_time,
       round((fcr.actual_completion_date - fcr.actual_start_date) * 24 * 60,
             2) run_time,
       (SELECT COUNT(1)
          FROM mtl_material_transactions mmt
         WHERE mmt.request_id = fcr.request_id
         and mmt.transaction_date >=trunc(SYSDATE)
         ) costed_count
  FROM fnd_concurrent_requests    fcr,
       fnd_concurrent_programs_vl fcp,
       fnd_user                   fu
 WHERE fcr.concurrent_program_id = fcp.CONCURRENT_PROGRAM_ID
   AND fcp.CONCURRENT_PROGRAM_NAME = 'CMCACW'
   AND fcr.requested_by = fu.user_id
   AND fcr.request_date > trunc(SYSDATE);
