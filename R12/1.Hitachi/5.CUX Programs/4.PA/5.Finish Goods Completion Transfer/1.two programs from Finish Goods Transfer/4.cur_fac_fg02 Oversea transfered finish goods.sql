/*CURSOR cur_fac_fg02 IS*/
--Oversea transfered finish goods
SELECT /*p_cost_type*/'FAC_FG' cost_type,
       'OVERSEA-TXNED' sub_type,
       ho1.organization_id org_id,
       ho1.name operation_ou,
       ppe.proj_element_id mfg_id,
       ppe.element_number mfg#,
       ppa.gl_period_name gl_period,
       pt.project_type,
       ho.organization_id expenditure_org_id,
       ho.name expenditure_org,
       p.project_id,
       p.segment1 proj_num,
       t.task_id,
       t.task_number,
       ppa.end_date expenditure_item_date,
       ppa.end_date + decode(to_char(ppa.end_date, 'D'), 1, 0, 8 - (to_char(ppa.end_date, 'D'))) expenditure_ending_date,
       parts_pet.expenditure_type expenditure_type,
       round((-1) * (ei.burden_cost), 2) expenditure_amt, -- IF THERE IS WARNING SUBMIT COST COLLECTING AND CREAT ACCOUNTING
       ei.expenditure_type orig_expenditure_type,
       ei.burden_cost orig_expenditure_amt,
       to_char(ppa.end_date, 'YYYYMMDD') expenditure_reference,
       'PA_EXPENDITURE_ITEMS_ALL' source_table,
       ei.expenditure_item_id source_line_id,
       NULL line_type
  FROM pa_projects_all              p,
       pa_tasks                 t,
       pa_expenditure_items_all ei,
       pa_expenditure_types     pet,
       
       pa_expenditure_types      parts_pet, -- add by gusenlin 20130724  for 11 parts
       pa_expenditures_all       x,
       pa_project_types_all      pt,
       hr_all_organization_units ho,
       hr_organization_units     ho1,
       pa_proj_elements          ppe,
       pa_periods_all            ppa
 WHERE 1 = 1
   AND p.project_id = t.project_id
   AND p.project_id = ei.project_id
   AND t.task_id = ei.task_id
   AND ei.burden_cost <> 0
   AND ei.expenditure_id = x.expenditure_id
   AND ei.expenditure_type = pet.expenditure_type
   AND pet.expenditure_category = 'FG Completion'
      
   AND pet.attribute15 = parts_pet.attribute15
   AND parts_pet.expenditure_category = 'FG Completion'
   AND parts_pet.attribute15 IS NOT NULL
      
   AND parts_pet.end_date_active IS NULL -- add by gusenlin 20130723  for 11 parts
   AND p.project_type = pt.project_type
   AND nvl(pt.attribute7, '-1') = 'OVERSEA'
   AND nvl(ei.override_to_organization_id, x.incurred_by_organization_id) = ho.organization_id
   AND ho.name = 'SHE_FAC_ORG'
   AND pt.org_id = ho1.organization_id
   AND t.top_task_id = ppe.proj_element_id
   AND ppe.object_type = 'PA_TASKS'
   AND p.org_id = ppa.org_id
   AND ei.attribute8 IS NULL
   AND ei.expenditure_item_date <= ppa.end_date
   AND t.task_number = 'SBH0216-PH.EQ'
   AND (EXISTS (SELECT 1
                  FROM xxpa.xxpa_cost_carry_over_tmp a
                 WHERE nvl(ei.override_to_organization_id, x.incurred_by_organization_id) = a.organization_id
                   AND pet.attribute15 = a.category_concat_segs
                   AND p.project_id = a.project_id
                   AND t.task_id = a.task_id) OR
        (ppa.end_date =
        xxpa_get_last_invoice_period(ho1.organization_id, p.project_id, ppe.proj_element_id, ei.attribute9) AND
        EXISTS (SELECT 1 --Only so pick judge invoice
                         FROM xxpa_cost_flow_dtls_all xcfd
                        WHERE xcfd.cost_type = /*p_cost_type*/'FAC_FG'
                          AND xcfd.sub_type = 'SO-PICK'
                          AND xcfd.source_table = 'MTL_MATERIAL_TRANSACTIONS'
                          AND xcfd.project_id = p.project_id
                          AND xcfd.task_id = t.task_id
                          AND xcfd.expenditure_type = pet.expenditure_type)) OR
        (ppa.end_date =
        xxpa_get_last_invoice_period(ho1.organization_id, p.project_id, ppe.proj_element_id, pet.attribute9) AND
        pet.attribute15 = 'OTS' AND x.expenditure_group NOT IN ('SO 1PJ58487') AND EXISTS
         (SELECT 1
                   FROM oe_order_lines_all        ool2,
                        ra_customer_trx_lines_all rctl,
                        ra_customer_trx_all       rct,
                        pa_tasks                  pt_ol
                  WHERE rctl.line_type = 'LINE'
                    AND rctl.org_id = ool2.org_id
                    AND rctl.customer_trx_id = rct.customer_trx_id
                    AND rctl.interface_line_attribute6 = to_char(ool2.line_id)
                    AND ool2.project_id = p.project_id
                    AND ool2.task_id = pt_ol.task_id
                    AND ool2.org_id = ho1.organization_id
                    AND pt_ol.top_task_id = ppe.proj_element_id
                    AND pt_ol.project_id = p.project_id
                    AND nvl(pet.attribute15, '@#$') = nvl(ool2.attribute5, '@#$')
                    AND rct.trx_date <= ppa.end_date + 0.99999)))
   --AND ppa.gl_period_name = g_period_name
   AND ppa.start_date = to_date('20180401','yyyymmdd')
   AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type = /*p_cost_type*/'FAC_FG'
                       AND xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                       AND xcfd.source_line_id = ei.expenditure_item_id))
   AND x.expenditure_group NOT IN ('SO FGPJ58490', 'SO 2PJ58488', 'Reverse SO2');
