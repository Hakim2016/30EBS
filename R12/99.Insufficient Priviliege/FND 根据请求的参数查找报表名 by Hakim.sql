SELECT application_id,
       concurrent_program_name,
       user_concurrent_program_name,
       enabled_flag,
       concurrent_program_name,
       description,
       execution_options,
       request_priority,
       increment_proc,
       run_alone_flag,
       restart,
       enable_trace,
       nls_compliant,
       output_file_type,
       save_output_flag,
       print_flag,
       minimum_width,
       minimum_length,
       output_print_style,
       required_style,
       printer_name,
       last_update_date,
       execution_method_code,
       last_update_login,
       creation_date,
       created_by,
       executable_id,
       last_updated_by,
       executable_application_id,
       concurrent_program_id,
       concurrent_class_id,
       class_application_id,
       argument_method_code,
       request_set_flag,
       queue_method_code,
       queue_control_flag,
       srs_flag,
       cd_parameter,
       mls_executable_id,
       mls_executable_app_id,
       resource_consumer_group,
       rollback_segment,
       optimizer_mode,
       security_group_id,
       enable_time_statistics,
       refresh_portlet,
       program_type,
       activity_summarizer,
       allow_multiple_pending_request,
       delete_log_file,
       template_appl_short_name,
       template_code,
       multi_org_category
  FROM fnd_concurrent_programs_vl v
 WHERE queue_control_flag = 'N'
   AND ( /*upper(user_concurrent_program_name) = 'XXPA: PROJECT FG COMPLETION DATA COLLECTION' AND*/
        (user_concurrent_program_name LIKE 'xx%' OR user_concurrent_program_name LIKE 'xX%' OR
        user_concurrent_program_name LIKE 'Xx%' OR user_concurrent_program_name LIKE 'XX%'))
   AND v.enabled_flag = 'Y'
   AND EXISTS (SELECT 'Y'
          FROM fnd_descr_flex_col_usage_vl x
         WHERE 1 = 1
           AND x.application_id = v.application_id
           AND x.descriptive_flexfield_name = '$SRS$.' || v.concurrent_program_name
           AND upper(x.end_user_column_name) LIKE '%PERIOD%')
 ORDER BY application_id,
          user_concurrent_program_name
