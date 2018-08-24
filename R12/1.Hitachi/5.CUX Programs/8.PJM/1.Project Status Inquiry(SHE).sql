SELECT --row_id,
       org_id,
       mfg_completion_date,
       project_num,
       mfg_num,
       proj_element_id,
       element_version_id,
       parent_structure_version_id,
       project_id,
       task_id,
       customer_id,
       project_end_date,
       project_start_date,
       org_name,
       project_name,
       project_long_name,
       customer_name,
       project_status_code,
       project_status_name,
       project_type_code,
       customer_number,
       task_status,
       related_mfg_num,
       mfg_task_name,
       mfg_spec,
       mfg_status,
       scheduled_start_date,
       scheduled_finish_date,
       estimated_start_date,
       estimated_finish_date,
       pt_estimated_start_date,
       pt_estimated_finish_date,
       actual_start_date,
       actual_finish_date,
       project_type,
       qf_start_date,
       qf_end_date
  FROM xxpjm_mfg_status_v2 v
 WHERE 1=1
 AND org_id = 84
   --AND project_id = 1431916
   --AND v.project_num = '21000056'--'21000769'
   AND v.project_type_code = 'SHE HO_SHE Project'
   --AND v.mfg_completion_date IS NULL
   AND v.scheduled_finish_date >= to_date('20180301','yyyymmdd')
;
