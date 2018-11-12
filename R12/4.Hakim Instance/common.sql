SELECT fcp.concurrent_program_name,
       --fcp.concurrent_program_id,
       fcp.user_concurrent_program_name,
       fe.executable_name,
       --fe.execution_method_code,
       flv.meaning execution_method_name,
       fe.execution_file_name
  FROM fnd_concurrent_programs_vl fcp,
       fnd_executables_vl         fe,
       fnd_lookup_values_vl       flv
 WHERE fcp.executable_application_id = fe.application_id
   AND fcp.executable_id = fe.executable_id
   AND flv.lookup_type = 'CP_EXECUTION_METHOD_CODE'
   AND flv.lookup_code = fe.execution_method_code
   AND fcp.user_concurrent_program_name LIKE '%HEA%'
--AND fcp.concurrent_program_name IN ('XXPJMR002', 'XXPJMF004', 'XXPJMF005')

;

-- ²éÖ°Ôð
SELECT fresp.responsibility_name,
       --fresp.responsibility_key,
       --fresp.group_application_id,
       --fresp.request_group_id,
       frg.request_group_name,
       --frg.description,
       frgu.request_unit_type,
       fl.meaning,
       --frgu.unit_application_id,
       --frgu.request_unit_id,
       fcp.user_concurrent_program_name,
       fcp.concurrent_program_name
  FROM fnd_responsibility_vl      fresp,
       fnd_request_groups         frg,
       fnd_request_group_units    frgu,
       fnd_lookups                fl,
       fnd_concurrent_programs_vl fcp
 WHERE fresp.group_application_id = frg.application_id
   AND fresp.request_group_id = frg.request_group_id
   AND frg.application_id = frgu.application_id
   AND frg.request_group_id = frgu.request_group_id
   AND fl.lookup_type = 'SRS_REQUEST_UNIT_TYPES'
   AND fl.lookup_code = frgu.request_unit_type
   AND ((frgu.request_unit_type = 'P' AND
       frgu.unit_application_id = fcp.application_id AND
       frgu.request_unit_id = fcp.concurrent_program_id) OR
       (frgu.request_unit_type = 'A' AND
       frgu.unit_application_id = fcp.application_id AND
       frgu.request_unit_id = fcp.application_id))
      --AND fcp.user_concurrent_program_name LIKE '%C%'
   AND fcp.concurrent_program_name LIKE '%XXPJMB001%'
--AND frg.request_group_name = 'XXFND_REQUEST_GROUP'
--AND fresp.responsibility_name = 'HEA SCM SUPER USER'
--ORDER BY fresp.responsibility_name
;

SELECT fcr.request_id,
       to_char(nvl(fcr.actual_completion_date, SYSDATE), 'SSSSS') -
       to_char(fcr.actual_start_date, 'SSSSS') haoshi,
       fu.user_name,
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
   AND fcr.concurrent_program_id IN (45788, 45889)
 ORDER BY fcr.request_id DESC;

-- function-menu-responsibility
SELECT frv.responsibility_name,
       frv.menu_id,
       fm.menu_id,
       fm.user_menu_name,
       fm.menu_name,
       fff.function_id,
       fff.function_name,
       fff.user_function_name
  FROM fnd_responsibility_vl frv,
       fnd_menus_vl          fm,
       fnd_form_functions_vl fff
 WHERE 1 = 1 -- fff.function_id = 1172
   AND frv.menu_id = fm.menu_id
   AND fff.function_name = 'XXPJMF001'
   AND EXISTS
 (SELECT LEVEL, fme.menu_id, fme.function_id, fme.sub_menu_id
          FROM fnd_menu_entries_vl fme
         WHERE fm.menu_id = fme.menu_id
         START WITH fme.function_id = fff.function_id -- 1172
        CONNECT BY PRIOR fme.menu_id = fme.sub_menu_id);

SELECT LEVEL, fme.menu_id, fme.function_id, fme.sub_menu_id, fme.prompt
  FROM fnd_menu_entries_vl fme
-- WHERE fm.menu_id = fme.menu_id
 START WITH fme.function_id = 47282 --fff.function_id -- 1172
CONNECT BY PRIOR fme.menu_id = fme.sub_menu_id

 ALTER session SET nls_language = 'SIMPLIFIED CHINESE';
