--1.1SQL1
--project type not fulfill the condition
SELECT 'FAC_FG' /*p_cost_type*/ cost_type,
       'HO-PROJECT' sub_type,
       pt.attribute7,
       ppa.gl_period_name,
       ho1.organization_id org_id,
       ho1.name operation_ou,
       ppe.proj_element_id mfg_id,
       ppe.element_number mfg_number,
       ppa.gl_period_name gl_period,
       p.project_type,
       pt.project_type,
       ho.organization_id expenditure_org_id,
       ho.name expenditure_org,
       p.project_id,
       p.segment1 project_number,
       t.task_id,
       t.task_number,
       last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')) expenditure_item_date,
       last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')) +
       decode(to_char(last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')), 'D'),
              1,
              0,
              8 - (to_char(last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')), 'D'))) expenditure_ending_date,
       'FAC FG Completion'/*p_cost_type_expd*/  expenditure_type,
       round((-1) * (ei.burden_cost), 2) expenditure_amount, -- IF THERE IS WARNING SUBMIT COST COLLECTING AND CREAT ACCOUNTING
       ei.expenditure_type orig_expenditure_type,
       ei.burden_cost orig_expenditure_amount,
       to_char(ppa.end_date, 'YYYYMMDD') expenditure_reference,
       'PA_EXPENDITURE_ITEMS_ALL' source_table,
       ei.expenditure_item_id source_line_id,
       NULL line_type
  FROM pa_projects_all              p,
       pa_tasks                 t,
       pa_expenditure_items_all ei,
       pa_expenditures_all      x,
       pa_project_types_all     pt,
       hr_all_organization_units ho,
       hr_organization_units     ho1,
       pa_proj_elements          ppe,
       pa_periods_all            ppa
 WHERE 1 = 1
   AND p.project_id = t.project_id
   AND p.project_id = ei.project_id
   AND t.task_id = ei.task_id
   AND ei.expenditure_id = x.expenditure_id
   AND ei.burden_cost <> 0
   AND p.project_type = pt.project_type--important
   AND nvl(pt.attribute9, 0) != 'HO - HEA Project FG'
   AND nvl(pt.attribute7, '-1') <> 'OVERSEA'
   AND pt.attribute7 IS NOT NULL
   AND nvl(ei.override_to_organization_id, x.incurred_by_organization_id) = ho.organization_id
   AND ho.name = 'SHE_FAC_ORG'
   AND pt.org_id = ho1.organization_id
   AND t.top_task_id = ppe.proj_element_id
   AND ppe.object_type = 'PA_TASKS'
   AND p.org_id = ppa.org_id
   AND ppa.end_date = last_day(to_date(ppe.attribute1, 'YYYY-MM-DD'))
   AND ei.expenditure_item_date <= last_day(to_date(ppe.attribute1, 'YYYY-MM-DD'))
   AND ei.attribute8 IS NULL
   AND ppa.gl_period_name = '18-Mar' /*g_period_name*/ --1 modify by jingjinghe 20180119

   /*AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type ='FAC_FG'\*p_cost_type*\ 
                       AND xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                       AND xcfd.source_line_id = ei.expenditure_item_id))
                       */
AND p.org_id = 84
AND ppe.proj_element_id = 1045474;

--sum of wip
SELECT SUM (t.expenditure_amount), SUM(t.orig_expenditure_amount)
FROM 
(SELECT 'FAC_FG' /*p_cost_type*/ cost_type,
       'HO-PROJECT' sub_type,
       pt.attribute7,
       ppa.gl_period_name,
       ho1.organization_id org_id,
       ho1.name operation_ou,
       ppe.proj_element_id mfg_id,
       ppe.element_number mfg_number,
       ppa.gl_period_name gl_period,
       p.project_type,
       pt.project_type,
       ho.organization_id expenditure_org_id,
       ho.name expenditure_org,
       p.project_id,
       p.segment1 project_number,
       t.task_id,
       t.task_number,
       last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')) expenditure_item_date,
       last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')) +
       decode(to_char(last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')), 'D'),
              1,
              0,
              8 - (to_char(last_day(to_date(ppe.attribute1, 'YYYY-MM-DD')), 'D'))) expenditure_ending_date,
       'FAC FG Completion'/*p_cost_type_expd*/  expenditure_type,
       round((-1) * (ei.burden_cost), 2) expenditure_amount, -- IF THERE IS WARNING SUBMIT COST COLLECTING AND CREAT ACCOUNTING
       ei.expenditure_type orig_expenditure_type,
       ei.burden_cost orig_expenditure_amount,
       to_char(ppa.end_date, 'YYYYMMDD') expenditure_reference,
       'PA_EXPENDITURE_ITEMS_ALL' source_table,
       ei.expenditure_item_id source_line_id,
       NULL line_type
  FROM pa_projects_all              p,
       pa_tasks                 t,
       pa_expenditure_items_all ei,
       pa_expenditures_all      x,
       pa_project_types_all     pt,
       hr_all_organization_units ho,
       hr_organization_units     ho1,
       pa_proj_elements          ppe,
       pa_periods_all            ppa
 WHERE 1 = 1
   AND p.project_id = t.project_id
   AND p.project_id = ei.project_id
   AND t.task_id = ei.task_id
   AND ei.expenditure_id = x.expenditure_id
   AND ei.burden_cost <> 0
   AND p.project_type = pt.project_type--important
   AND nvl(pt.attribute9, 0) != 'HO - HEA Project FG'
   AND nvl(pt.attribute7, '-1') <> 'OVERSEA'
   AND pt.attribute7 IS NOT NULL
   AND nvl(ei.override_to_organization_id, x.incurred_by_organization_id) = ho.organization_id
   AND ho.name = 'SHE_FAC_ORG'
   AND pt.org_id = ho1.organization_id
   AND t.top_task_id = ppe.proj_element_id
   AND ppe.object_type = 'PA_TASKS'
   AND p.org_id = ppa.org_id
   AND ppa.end_date = last_day(to_date(ppe.attribute1, 'YYYY-MM-DD'))
   AND ei.expenditure_item_date <= last_day(to_date(ppe.attribute1, 'YYYY-MM-DD'))
   AND ei.attribute8 IS NULL
   AND ppa.gl_period_name = '18-Mar' /*g_period_name*/ --1 modify by jingjinghe 20180119

   /*AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type ='FAC_FG'\*p_cost_type*\ 
                       AND xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                       AND xcfd.source_line_id = ei.expenditure_item_id))
                       */
AND p.org_id = 84
AND ppe.proj_element_id = 1045474) t;
