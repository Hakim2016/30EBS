
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

SELECT t.requested_start_date, t.*
  FROM fnd_conc_requests_form_v t
 WHERE 1 = 1
   and t.program_short_name='XXPAPCCR'
 ORDER BY t.request_id DESC;

SELECT *
  FROM fnd_concurrent_requests fcr
 WHERE 1 = 1
   AND fcr.phase_code = 'P';

SELECT FRV.RESPONSIBILITY_NAME, FRV.RESPONSIBILITY_ID
  FROM fnd_responsibility_vl frv, fnd_concurrent_requests fcr
 WHERE fcr.responsibility_id = frv.RESPONSIBILITY_ID
   AND fcr.responsibility_application_id = frv.APPLICATION_ID
   AND fcr.request_id = 11627299;

SELECT FRV.RESPONSIBILITY_NAME
  FROM fnd_concurrent_programs_vl fcp,
       fnd_responsibility_vl      frv,
       fnd_request_group_units    frg
 WHERE ((fcp.CONCURRENT_PROGRAM_ID = frg.request_unit_id AND
       fcp.APPLICATION_ID = frg.unit_application_id AND
       frg.request_unit_type = 'P') OR
       (fcp.APPLICATION_ID = frg.request_unit_id AND
       fcp.APPLICATION_ID = frg.unit_application_id AND
       frg.request_unit_type = 'A'))
   AND frg.request_group_id = frv.REQUEST_GROUP_ID
   AND FCP.USER_CONCURRENT_PROGRAM_NAME = 'XXINV:Inventory Balance Report';
