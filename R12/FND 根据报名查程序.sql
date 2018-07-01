
SELECT fcp.concurrent_program_name,
       fcp.concurrent_program_id,
       fcp.user_concurrent_program_name,
       fe.executable_name,
       --fe.execution_method_code,
       flv.meaning execution_method_name,
       fe.execution_file_name,
       ds.name,
       ds.type,
       ds.text
  FROM fnd_concurrent_programs_vl fcp,
       fnd_executables_vl         fe,
       fnd_lookup_values_vl       flv,
       dba_source                 ds,
       dba_dependencies           dd
 WHERE fcp.executable_application_id = fe.application_id
   AND fcp.executable_id = fe.executable_id
   AND flv.lookup_type = 'CP_EXECUTION_METHOD_CODE'
   AND flv.lookup_code = fe.execution_method_code
      -- AND upper(fcp.user_concurrent_program_name) LIKE upper('%XXPA_Project_Cost_Detail_Repor%')
      -- AND fcp.concurrent_program_name IN ('XXOMB006')
      -- AND upper(fe.execution_file_name) LIKE upper('XXGL_ACCOUNT_EXP_ERV_PKG%')
   AND upper(fe.execution_file_name) LIKE upper('%' || dd.name || '%')
   AND ds.owner = dd.owner
   AND ds.name = dd.name
   AND dd.referenced_name = 'XXPA_REPORTS_UTILS'
   AND upper(ds.text) LIKE upper('%xxpa_reports_utils.get_exp_type%');
;
