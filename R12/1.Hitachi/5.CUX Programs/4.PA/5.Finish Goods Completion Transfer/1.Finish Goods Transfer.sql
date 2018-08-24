

--1.Details
SELECT project_number,
       task_number,
       expenditure_item_date,
       expenditure_ending_date,
       expenditure_type,
       expenditure_amount,
       orig_expenditure_type,
       expenditure_reference,
       project_type,
       cost_type,
       sub_type,
       source_table,
       source_line_id,
       cost_detail_id,
       cost_header_id,
       row_id,
       transfered_pa_flag,
       batch_name,
       org_id,
       period_name,
       expenditure_org_id,
       project_id,
       project_name,
       project_long_name,
       mfg_id,
       mfg_number,
       task_id,
       expenditure_id,
       orig_expenditure_amount,
       creation_date,
       created_by,
       last_updated_by,
       last_update_date,
       last_update_login,
       request_id,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
       --SUM(expenditure_amount)
  FROM xxpa_cost_flow_dtls_v
 WHERE - 1 = -1
 AND expenditure_amount <> 0
   AND (cost_header_id = 89806)
 ORDER BY project_number,
          task_number,
          expenditure_type;
--2.Summary  
SELECT organization_name,
       project_number,
       mfg_number,
       task_number,
       expenditure_item_date,
       expenditure_ending_date,
       expenditure_type,
       expenditure_amount,
       row_id,
       cost_header_id,
       org_id,
       transfered_pa_flag,
       period_name,
       new_expenditure_item_id,
       new_interface_id,
       batch_name,
       cost_type,
       project_type,
       source_code,
       expenditure_org_id,
       project_id,
       project_name,
       mfg_id,
       task_id,
       task_name,
       expenditure_id,
       creation_date,
       created_by,
       last_updated_by,
       last_update_date,
       last_update_login,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
  FROM xxpa_cost_flow_sum_v
 WHERE (expenditure_amount <> 0)
   AND (org_id = 84)
   AND (transfered_pa_flag = 'N')
   AND (period_name = '18-Jul')
   AND (cost_type LIKE 'FAC_FG')
   AND (project_id = 793108)
   AND (mfg_id = 3122306)
 ORDER BY project_number,
          task_number,
          expenditure_type
;
          
--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;
*/
