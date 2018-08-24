/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50848,
                             resp_appl_id => 275);
  mo_global.init('M');
  
END;*/

SELECT 'FAC_FG' /*p_cost_type*/ cost_type,
       'NON-OVERSER-ACCUAL' sub_type,
       ho.organization_id org_id,
       ho.name operation_unit,
       t1.task_id mfg_id,
       t1.task_number mfg_number,
       ppa.gl_period_name gl_period,
       p.project_type proj_type,
       ho1.organization_id expenditure_org_id,
       ho1.name expenditure_org,
       p.project_id,
       p.segment1 proj_num,
       t.task_id,
       t.task_number task_num,
       ppa.end_date expenditure_item_date,
       ppa.end_date + decode(to_char(ppa.end_date, 'D'), 1, 0, 8 - (to_char(ppa.end_date, 'D'))) expenditure_ending_date,
       'FAC FG Completion'/*p_cost_type_expd*/  expenditure_type,
       round((-1) * ct.tot_cmt_burdened_cost, 2) expenditure_amount,
       ct.expenditure_type orig_expenditure_type,
       ct.tot_cmt_burdened_cost orig_expenditure_amount,
       'ACCRUAL:' || ct.cmt_number || '.' || ct.cmt_line_number || '.' || ct.cmt_distribution_id expenditure_reference,
       'PA_COMMITMENT_TXNS' source_table,
       ct.cmt_distribution_id source_line_id,
       ct.line_type
  FROM pa_resource_accum_details rad,
       pa_txn_accum_details      tad,
       pa_commitment_txns        ct,
       pa_tasks                  t,
       pa_tasks                  t1,
       pa_proj_elements          ppe,
       hr_organization_units     ho,
       hr_organization_units     ho1,
       pa_projects_all           p,
       pa_periods_all            ppa,
       pa_project_types_all      ppt
 WHERE 1 = 1
   AND ho.name = 'SHE_OU'
   AND rad.txn_accum_id = tad.txn_accum_id
   AND tad.line_type = 'M'
   AND tad.cmt_line_id = ct.cmt_line_id
   AND ct.tot_cmt_burdened_cost <> 0
   AND ct.task_id = t.task_id
   AND ct.organization_id = ho1.organization_id
   AND ct.project_id = p.project_id
   AND ho1.name = 'SHE_FAC_ORG'
   AND t.project_id = t1.project_id
   AND t.top_task_id = t1.task_id
   AND p.project_id = t.project_id
   AND t.project_id = ppe.project_id
   AND t.top_task_id = ppe.proj_element_id
   AND ppe.object_type = 'PA_TASKS'
   AND ppa.end_date = last_day(to_date(ppe.attribute1, 'YYYY-MM-DD'))
   AND p.org_id = ho.organization_id
   AND ppa.org_id = p.org_id
   AND p.org_id = ppt.org_id
   AND p.project_type = ppt.project_type
   AND nvl(ppt.attribute9, 0) != 'HO - HEA Project FG'
   AND nvl(ppt.attribute7, '-1') <> 'OVERSEA'
   AND ppt.attribute7 IS NOT NULL
   AND ppt.attribute9 IS NOT NULL
   AND trunc(ct.expenditure_item_date) <= ppa.end_date
      /*AND ppa.end_date = xxpa_get_last_invoice_period(ho.organization_id,
      p.project_id,
      t1.task_id,
      NULL)*/
   AND ppa.gl_period_name = '18-Apr' /*g_period_name*/ --1 modify by jingjinghe 20180119
      --AND p.project_id IN (1504003, 1507013)
   AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type ='FAC_FG'/*p_cost_type*/ 
                       AND xcfd.source_table = 'PA_COMMITMENT_TXNS'
                       AND xcfd.source_line_id = ct.cmt_distribution_id
                       AND xcfd.attribute1 = ct.line_type))
AND ppe.proj_element_id = 1045474;
/*
SELECT * FROM pa_proj_elements          ppe,

 WHERE 1=1 AND */
 
 SELECT * FROM pa_tasks pt WHERE 1=1 AND pt.task_id = 1045474;
