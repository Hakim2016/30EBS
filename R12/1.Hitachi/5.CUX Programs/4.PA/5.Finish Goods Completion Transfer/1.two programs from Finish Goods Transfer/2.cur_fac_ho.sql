/*
For efficiency
add condition t.top_task_id = 3413614
e.g.(TAC0523-TH)
*/

/*CURSOR cur_fac_ho IS*/
SELECT /*p_cost_type*/
 ei.expenditure_item_id,
 p.project_id,
 t.task_id,
 'FAC_TO_HO_FG' cost_type,
 'FAC_TO_HO' sub_type,
 ho1.organization_id org_id,
 ho1.name operation_ou,
 t1.task_id mfg_id,
 t1.task_number mfg#,
 ppa.gl_period_name gl_period,
 pt.project_type,
 ood.organization_id expenditure_org_id,
 ood.organization_name expenditure_org,
 p.project_id,
 p.segment1 project_number,
 t.task_id,
 t.task_number,
 ppa.end_date expenditure_item_date,
 ppa.end_date + decode(to_char(ppa.end_date, 'D'), 1, 0, 8 - (to_char(ppa.end_date, 'D'))) expenditure_ending_date,
 pt.attribute8 expenditure_type,
 round((-1) * ei.burden_cost, 2) expenditure_amount,
 ei.expenditure_type orig_expenditure_type,
 ei.burden_cost orig_expenditure_amount,
 xdnh.delivery_note_num expenditure_reference,
 'PA_EXPENDITURE_ITEMS_ALL' source_table,
 ei.expenditure_item_id source_line_id
  FROM pa_projects_all              p,
       pa_tasks                     t,
       pa_expenditure_items_all     ei,
       pa_expenditures_all          x,
       pa_project_types_all         pt,
       hr_all_organization_units    ho,
       hr_organization_units        ho1,
       xxinv_dely_note_headers_all  xdnh,
       pa_periods_all               ppa,
       pa_tasks                     t1,
       org_organization_definitions ood
 WHERE 1 = 1
   AND xdnh.org_id = ho1.organization_id
   AND xdnh.project_id = p.project_id
   AND xdnh.task_id = t.task_id
   AND p.project_type = pt.project_type
   AND pt.attribute8 IS NOT NULL
   AND pt.org_id = ho1.organization_id
   AND p.project_id = t1.project_id
   AND t.top_task_id = t1.task_id
   AND ei.project_id = p.project_id
   AND ho1.organization_id = pt.org_id
   AND ei.task_id = t.task_id
   AND ei.expenditure_id = x.expenditure_id
   AND ei.burden_cost <> 0
   AND nvl(ei.override_to_organization_id, x.incurred_by_organization_id) = ho.organization_id
   AND ei.expenditure_type IN ('FAC FG Completion', pt.attribute8)
   AND ei.expenditure_item_date <= last_day(xdnh.creation_date)
   AND ppa.end_date = trunc(last_day(xdnh.creation_date))
   AND ppa.org_id = ho1.organization_id
   --AND ppa.period_name = '18-Aug' --g_period_name
   AND ppa.start_date = to_date('20180801', 'yyyymmdd')
   AND ood.organization_name = 'SHE_HQ_ORG'
   AND ((ei.expenditure_type = pt.attribute8 AND ei.attribute8 IS NULL) OR ei.expenditure_type <> pt.attribute8)
/*AND (NOT EXISTS (SELECT 1
 FROM xxpa_cost_flow_dtls_all xcfd
WHERE xcfd.cost_type = 'FAC_TO_HO_FG' --p_cost_type
  AND xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
  AND xcfd.source_line_id = ei.expenditure_item_id))*/
  AND t.top_task_id = 3413614
;

SELECT *
  FROM pa_periods_all xx
 WHERE 1 = 1
   AND xx.period_name = ''
   AND xx.org_id = 84
   AND xx.start_date = to_date('20180801', 'yyyymmdd');
   
   
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
