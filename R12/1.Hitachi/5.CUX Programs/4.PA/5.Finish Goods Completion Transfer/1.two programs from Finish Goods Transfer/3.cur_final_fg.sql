/*CURSOR cur_final_fg IS*/
SELECT p_cost_type cost_type,
       'NON-OVERSER-FG' sub_type,
       ho1.organization_id org_id,
       ho1.name operation_unit,
       t1.task_id mfg_id,
       t1.task_number mfg#,
       ppa.gl_period_name gl_period,
       p.project_type project_type,
       ood.organization_id expenditure_org_id,
       ood.organization_name expenditure_org,
       p.project_id,
       p.segment1 project_num,
       t.task_id,
       t.task_number task_num,
       ppa.end_date expenditure_item_date,
       ppa.end_date + decode(to_char(ppa.end_date, 'D'), 1, 0, 8 - (to_char(ppa.end_date, 'D'))) expenditure_ending_date,
       pt.attribute9 expenditure_type,
       round((-1) * ei.burden_cost, 2) expenditure_amount,
       s.source,
       ei.expenditure_type orig_expenditure_type,
       ei.burden_cost orig_expenditure_amount,
       to_char(ppa.end_date, 'YYYYMMDD') expenditure_reference,
       'PA_EXPENDITURE_ITEMS_ALL' source_table,
       ei.expenditure_item_id source_line_id,
       NULL line_type
  FROM pa_projects p,
       pa_tasks t,
       pa_expenditure_items_all ei,
       pa_expenditures_all x,
       pa_project_types_all pt,
       hr_all_organization_units ho,
       hr_organization_units ho1,
       pa_tasks t1,
       pa_periods_all ppa,
       (SELECT DISTINCT ool.project_id,
                        ool.task_id,
                        xsa.source,
                        pt1.top_task_id
          FROM oe_order_lines_all       ool,
               xxpjm_so_addtn_lines_all xsa,
               pa_tasks                 pt1
         WHERE ool.line_id = xsa.so_line_id
           AND ool.task_id = pt1.task_id) s,
       org_organization_definitions ood,
       pa_expenditure_types pet
 WHERE 1 = 1
   AND ho1.organization_id = fnd_global.org_id
   AND pt.org_id = ho1.organization_id
   AND t.project_id = p.project_id
   AND p.project_id = t1.project_id
   AND t.top_task_id = t1.task_id
   AND ei.project_id = p.project_id
   AND ei.task_id = t.task_id
   AND p.project_type = pt.project_type
   AND nvl(pt.attribute7, '-1') <> 'OVERSEA'
   AND p.org_id = ho1.organization_id
   AND ei.expenditure_id = x.expenditure_id
   AND ei.burden_cost <> 0
   AND ei.expenditure_item_date <= ppa.end_date
   AND ppa.org_id = ho1.organization_id
   AND pt.attribute9 <> 'FAC FG Completion'
   AND ood.organization_name =
       decode(pt.attribute9,
              'FAC FG Completion',
              'SHE_FAC_ORG',
              (decode(fnd_global.org_name, 'SHE_OU', 'SHE_HQ_ORG', 'HET_HQ_ORG')))
   AND ppa.end_date = xxpa_get_last_invoice_period(ho1.organization_id, p.project_id, t1.task_id, NULL)
   AND nvl(ei.override_to_organization_id, x.incurred_by_organization_id) = ho.organization_id
   AND t1.task_id = s.top_task_id(+)
   AND t1.project_id = s.project_id(+)
   AND ho.name = decode(pt.attribute9,
                        'FAC FG Completion',
                        'SHE_FAC_ORG',
                        (decode(fnd_global.org_name, 'SHE_OU', 'SHE_HQ_ORG', 'HET_HQ_ORG')))
   AND ei.expenditure_type = pet.expenditure_type
   AND ((pet.expenditure_category = 'FG Completion' AND ei.attribute8 IS NULL) OR
       pet.expenditure_category <> 'FG Completion')
   AND ppa.gl_period_name = g_period_name
   AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type = p_cost_type
                       AND xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                       AND xcfd.source_line_id = ei.expenditure_item_id))
UNION ALL
SELECT p_cost_type cost_type,
       'NON-OVERSER-ACCUAL' sub_type,
       ho.organization_id org_id,
       ho.name operation_unit,
       t1.task_id mfg_id,
       t1.task_number mfg#,
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
       ppt.attribute9 expenditure_type,
       round((-1) * ct.tot_cmt_burdened_cost, 2) expenditure_amount,
       s.source,
       ct.expenditure_type orig_expenditure_type,
       ct.tot_cmt_burdened_cost orig_expenditure_amount,
       'ACCRUAL:' || ct.cmt_number || '.' || ct.cmt_line_number || '.' || ct.cmt_distribution_id expenditure_reference,
       'PA_COMMITMENT_TXNS' source_table,
       ct.cmt_distribution_id source_line_id,
       ct.line_type
  FROM pa_resource_accum_details rad,
       pa_txn_accum_details tad,
       pa_commitment_txns ct,
       pa_tasks t,
       pa_tasks t1,
       hr_organization_units ho,
       hr_organization_units ho1,
       pa_projects p,
       pa_periods_all ppa,
       pa_project_types_all ppt,
       (SELECT DISTINCT ool.project_id,
                        ool.task_id,
                        xsa.source,
                        pt1.top_task_id
          FROM oe_order_lines_all       ool,
               xxpjm_so_addtn_lines_all xsa,
               pa_tasks                 pt1
         WHERE ool.line_id = xsa.so_line_id
           AND ool.task_id = pt1.task_id) s
 WHERE 1 = 1
   AND ho.organization_id = fnd_global.org_id
   AND rad.txn_accum_id = tad.txn_accum_id
   AND tad.line_type = 'M'
   AND tad.cmt_line_id = ct.cmt_line_id
   AND ct.tot_cmt_burdened_cost <> 0
   AND ct.task_id = t.task_id
   AND ct.organization_id = ho1.organization_id
   AND ppt.attribute9 <> 'FAC FG Completion'
   AND ho1.name = decode(ppt.attribute9,
                         'FAC FG Completion',
                         'SHE_FAC_ORG',
                         (decode(fnd_global.org_name, 'SHE_OU', 'SHE_HQ_ORG', 'HET_HQ_ORG')))
   AND t.project_id = t1.project_id
   AND t.top_task_id = t1.task_id
   AND p.project_id = t.project_id
   AND p.org_id = ho.organization_id
   AND ppa.org_id = p.org_id
   AND p.org_id = ppt.org_id
   AND p.project_type = ppt.project_type
   AND nvl(ppt.attribute7, '-1') <> 'OVERSEA'
   AND ppt.attribute9 IS NOT NULL
   AND t1.task_id = s.top_task_id(+)
   AND t1.project_id = s.project_id(+)
   AND ppa.end_date = xxpa_get_last_invoice_period(ho.organization_id, p.project_id, t1.task_id, NULL)
   AND ppa.gl_period_name = g_period_name
   AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type = p_cost_type
                       AND xcfd.source_table = 'PA_COMMITMENT_TXNS'
                       AND xcfd.source_line_id = ct.cmt_distribution_id
                       AND xcfd.attribute1 = ct.line_type));
