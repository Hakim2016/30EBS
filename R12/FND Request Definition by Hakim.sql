--Request Definition
SELECT fcp.user_concurrent_program_name program,
       fcp.concurrent_program_name      short_name,
       --fcp.executable_id,
       --fef.executable_id,
       fef.executable_name,
       fef.execution_file_name,
       fef.execution_method_code,
       fef.application_name,
       fef.description
  FROM fnd_concurrent_programs_vl fcp,
       fnd_executables_form_v     fef
 WHERE 1 = 1
   AND fcp.executable_id = fef.executable_id
      AND fcp.concurrent_program_name = 'INCTCM'--'XXPAB003'
   --AND fcp.user_concurrent_program_name = 'XXOM:SO Balance Report'
   ;

--Request with parameters
SELECT 
fcu.COLUMN_SEQ_NUM,
fcu.END_USER_COLUMN_NAME,
fcu.FORM_LEFT_PROMPT,
fcu.default_type,
fcu.DEFAULT_VALUE,
fcp.user_concurrent_program_name program,
       fcp.concurrent_program_name      short_name,
       --fcp.executable_id,
       --fef.executable_id,
       fef.executable_name,
       fef.execution_file_name,
       fef.execution_method_code,
       fef.application_name,
       fef.description
  FROM fnd_concurrent_programs_vl fcp,
       fnd_executables_form_v     fef,
       fnd_descr_flex_col_usage_vl fcu
 WHERE 1 = 1
   AND fcp.executable_id = fef.executable_id
   AND '$SRS$.' || fcp.CONCURRENT_PROGRAM_NAME = fcu.DESCRIPTIVE_FLEXFIELD_NAME
      --AND fcp.concurrent_program_name = 'XXPAB003'
   AND fcp.user_concurrent_program_name = 'XXOM:SO Balance Report';

SELECT column_seq_num,
       end_user_column_name,
       description,
       enabled_flag,
       default_value,
       required_flag,
       security_enabled_flag,
       range_code,
       display_flag,
       display_size,
       maximum_description_len,
       concatenation_description_len,
       form_left_prompt,
       srw_param,
       row_id,
       created_by,
       default_type,
       form_above_prompt,
       descriptive_flex_context_code,
       last_update_login,
       creation_date,
       last_updated_by,
       last_update_date,
       application_column_name,
       application_id,
       flex_value_set_id,
       descriptive_flexfield_name
  FROM fnd_descr_flex_col_usage_vl
 WHERE (application_id = 20010)
   AND (descriptive_flexfield_name = '$SRS$.XXOMSOBR')
 ORDER BY column_seq_num;
