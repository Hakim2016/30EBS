SELECT fcp.concurrent_program_name,
       fcp.concurrent_program_id,
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
   AND upper(fcp.user_concurrent_program_name) LIKE upper('launch%%')
--AND fcp.concurrent_program_name IN ('XXGLB001')
--AND upper(fe.execution_file_name) LIKE upper('XXPO_PR_IMPORT_PKG%')
;

-- 查询程序对象使用
SELECT ds.*
  FROM dba_dependencies dd,
       dba_source       ds
 WHERE 1 = 1
   AND dd.owner = ds.owner
   AND dd.name = ds.name
   AND dd.referenced_name = upper('xxpo_requisition_import_tmp')
   AND upper(ds.text) LIKE upper('%xxpo_requisition_import_tmp%')
   AND ds.name LIKE 'XX%';

-- 查职责
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
   AND ((frgu.request_unit_type = 'P' AND frgu.unit_application_id = fcp.application_id AND
       frgu.request_unit_id = fcp.concurrent_program_id) OR
       (frgu.request_unit_type = 'A' AND frgu.unit_application_id = fcp.application_id AND
       frgu.request_unit_id = fcp.application_id))
   AND upper(fcp.user_concurrent_program_name) LIKE upper('%xxfnd%interface manage%')
--AND fcp.concurrent_program_name LIKE '%XXPJMB014%'
--AND frg.request_group_name = 'XXFND_REQUEST_GROUP'
--AND fresp.responsibility_name = 'HEA SCM SUPER USER'
--ORDER BY fresp.responsibility_name
;


SELECT fcr.request_id,
       (nvl(fcr.actual_completion_date, SYSDATE) - fcr.actual_start_date) * 24 * 60 * 60 "Time-Consuming",
       fu.user_name,
       (SELECT he.full_name
          FROM hr_employees he
         WHERE 1 = 1
           AND fu.employee_id = he.employee_id) employee_full_name,
       frv.responsibility_name,
       fcr.description,
       fcp.user_concurrent_program_name,
       fl_phase.meaning,
       fl_status.meaning,
       fcr.argument_text,
       fcr.actual_start_date,
       fcrc.release_class_name,
       fcrc.date1,
       fcrc.date2,
       fcrc.class_type,
       fcrc.class_info
  FROM fnd_concurrent_requests    fcr,
       fnd_user                   fu,
       fnd_lookups                fl_phase,
       fnd_lookups                fl_status,
       fnd_concurrent_programs_vl fcp,
       fnd_responsibility_vl      frv,
       fnd_conc_release_classes   fcrc
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
   AND fcr.requested_by = fu.user_id
   AND fcr.responsibility_application_id = frv.application_id
   AND fcr.responsibility_id = frv.responsibility_id
   AND fl_phase.lookup_type = 'CP_PHASE_CODE'
   AND fl_phase.lookup_code = fcr.phase_code
   AND fl_status.lookup_type = 'CP_STATUS_CODE'
   AND fl_status.lookup_code = fcr.status_code
   AND fcr.release_class_app_id = fcrc.application_id(+)
   AND fcr.release_class_id = fcrc.release_class_id(+)
      AND fcr.concurrent_program_id IN (33694)
  -- AND fcr.actual_start_date > trunc(SYSDATE)
   --AND fcr.actual_start_date < trunc(SYSDATE) + 1 / 24
--AND fcr.request_id = 8127904
 ORDER BY fcr.actual_start_date;
SELECT fcr.request_id,
       fcr.request_date,
       fcpa.argument1,
       fcpa.argument2,
       xl.file_name,
       (nvl(fcr.actual_completion_date, SYSDATE) - fcr.actual_start_date) * 24 * 60 * 60 "Time-Consuming",
       fu.user_name,
       frv.responsibility_name,
       fcp.user_concurrent_program_name,
       fl_phase.meaning,
       fl_status.meaning,
       fcr.argument_text,
       fcr.actual_start_date,
       fcpa.*
  FROM fnd_concurrent_requests    fcr,
       fnd_conc_pp_actions        fcpa,
       xdo_lobs                   xl,
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
      --AND fcr.concurrent_program_id IN (55448)
   AND fcr.request_id = fcpa.concurrent_request_id(+)
   AND fcpa.action_type(+) = 6
      --   AND fcr.request_id IN (6078332)
      --AND fcpa.argument2 IN ('XXWIPTP')
   AND fcpa.argument2 = xl.lob_code(+)
   AND xl.xdo_file_type(+) = 'RTF'
      --AND fcr.request_date < SYSDATE - 4
   AND fcr.requested_by = 2722
 ORDER BY fcr.request_id DESC;

-- Xdo
SELECT xtv.application_short_name,
       xtv.template_code,
       xtv.ds_app_short_name,
       xtv.data_source_code,
       xtv.template_name,
       --xl.lob_type,
       --xl.application_short_name,
       xl.xdo_file_type,
       xl.lob_code,
       --xl.language,
       --xl.territory,
       xl.file_name,
       xl.file_content_type
  FROM xdo_templates_vl xtv,
       xdo_lobs         xl
 WHERE 1 = 1
      -- AND xtv.application_short_name = 'XXOM'
      -- AND xtv.data_source_code = 'XXOMTIPRT'
   AND xtv.application_short_name = xl.application_short_name
   AND xtv.template_code = xl.lob_code
   AND upper(xl.file_name) IN ('XXOMDEPRT.RTF',
                               'XXOMEQPRT.RTF',
                               'XXOMFACDMCM.RTF',
                               'XXOMHODMCM.RTF',
                               'XXOMJBPRT.RTF',
                               'XXOMMAPRT.RTF',
                               'XXOMOSPRT.RTF');

-- function-menu-responsibility

SELECT frv.responsibility_name,
       fm.menu_name,
       fm_sub.menu_name sub_menu_name,
       tmp.*
  FROM (SELECT rownum row_num,
               LEVEL,
               fme.menu_id,
               fme.sub_menu_id,
               fme.entry_sequence,
               fme.prompt,
               fme.function_id,
               fff.function_name,
               ff.form_name
          FROM fnd_menu_entries_vl   fme,
               fnd_form_functions_vl fff,
               fnd_form_vl           ff
         WHERE 1 = 1 --(menu_id = 86117)
              -- AND function_id = 47244
           AND fme.function_id = fff.function_id(+)
           AND fff.form_id = ff.form_id(+)
         START WITH fff.function_name = 'XXMRPF001' -- fme.function_id = 47244 --fff.function_id -- 1172        
        CONNECT BY PRIOR fme.menu_id = fme.sub_menu_id) tmp,
       fnd_menus_vl fm,
       fnd_menus_vl fm_sub,
       fnd_responsibility_vl frv
 WHERE 1 = 1
      --AND tmp.prompt IS NOT NULL
   AND tmp.menu_id = fm.menu_id
   AND fm.menu_id = frv.menu_id(+)
   AND tmp.sub_menu_id = fm_sub.menu_id(+)
 ORDER BY tmp.row_num;


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
       fnd_form_functions_vl fff,
       fnd_form_vl           ffv
 WHERE 1 = 1 -- fff.function_id = 1172
   AND frv.menu_id = fm.menu_id
      --AND fff.function_name = 'XXPJMF007'
   AND fff.form_id = ffv.form_id
   AND ffv.form_name = 'XXMRPF001'
   AND EXISTS (SELECT LEVEL,
               fme.menu_id,
               fme.function_id,
               fme.sub_menu_id
          FROM fnd_menu_entries_vl fme
         WHERE fm.menu_id = fme.menu_id
         START WITH fme.function_id = fff.function_id -- 1172
        CONNECT BY PRIOR fme.menu_id = fme.sub_menu_id)
 ORDER BY frv.responsibility_name;

-- Brower Menu Name
SELECT LEVEL,
       fme.menu_id,
       fme.function_id,
       fme.sub_menu_id,
       fme.prompt
  FROM fnd_menu_entries_vl fme
-- WHERE fm.menu_id = fme.menu_id
 START WITH fme.function_id = 47622 --fff.function_id -- 1172
CONNECT BY PRIOR fme.menu_id = fme.sub_menu_id

;

ALTER session SET nls_language = 'SIMPLIFIED CHINESE';
