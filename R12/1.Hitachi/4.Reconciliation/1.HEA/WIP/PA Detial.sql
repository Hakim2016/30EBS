--PA Detail

SELECT hou.name,
       ei.expenditure_item_id,
       ppa.segment1 project,
       pt.task_number task,
       ptt.task_type,
       (SELECT expenditure_category
          FROM apps.pa_expenditure_types
         WHERE expenditure_type = ei.expenditure_type) expenditure_category,
       (SELECT segment1
          FROM apps.mtl_system_items_b msi
         WHERE ei.inventory_item_id = msi.inventory_item_id
           AND msi.organization_id = 83) inventory_item,
       ei.expenditure_type,
       ei.expenditure_item_date,
       pad.gl_date,
       ei.quantity,
       ei.project_burdened_cost project_func_burden_cost,
       ei.burden_cost project_burdened_cost,
       xei.transaction_source,
       xei.orginal_trans_ref,
       xei.original_user_expnd_transf_ref,
       decode(ei.transaction_source,
              'PO RECEIPT',
              (SELECT ph.segment1
                 FROM apps.rcv_transactions rt,
                      apps.po_headers_all   ph
                WHERE ei.org_id = ph.org_id
                  AND rt.po_header_id = ph.po_header_id
                  AND ei.document_distribution_id = rt.transaction_id),
              xei.po_number) po_number,
       dr.concatenated_segments dr_segments,
       cr.concatenated_segments cr_segments,
       --pad.gl_period_name,
       pad.gl_period_name            dist_gl_period,
       xpm.ba_fully_packing_date,
       xpm.fully_packing_date,
       xpm.fully_delivery_date,
       xpm.hand_over_date,
       xfd.fully_delivery_date       non_sales_completion_date,
       ei.attribute3,
       ei.creation_date,
       ei.created_by,
       ei.attribute9,
       ei.system_linkage_function,
       ei.orig_transaction_reference,
       ppt.project_type,
       ppt.description               project_type_description,
       pe.expenditure_group
  FROM apps.pa_expenditure_items_all       ei,
       apps.pa_cost_distribution_lines_all pad,
       apps.gl_code_combinations_kfv       dr,
       apps.gl_code_combinations_kfv       cr,
       apps.pa_expenditures_all            pe,
       apps.pa_projects_all                ppa,
       apps.pa_tasks                       pt,
       apps.hr_operating_units             hou,
       apps.pa_project_types_all           ppt,
       apps.pa_proj_elements               ppe,
       apps.pa_task_types                  ptt,
       apps.xxpa_proj_milestone_manage_all xpm,
       apps.xxinv_proj_fully_delivery_all  xfd,
       apps.xxpa_exp_items_expend_v        xei
 WHERE ei.expenditure_id = pe.expenditure_id(+)
   AND ei.expenditure_item_id = pad.expenditure_item_id(+)
   AND pad.dr_code_combination_id = dr.code_combination_id(+)
   AND pad.cr_code_combination_id = cr.code_combination_id(+)
   AND ei.org_id = hou.organization_id
   AND ei.project_id = ppa.project_id(+)
   AND ei.task_id = pt.task_id(+)
   AND ppt.project_type(+) = ppa.project_type
   AND ppt.org_id(+) = ppa.org_id
   AND ppe.proj_element_id(+) = pt.task_id
   AND ptt.task_type_id(+) = ppe.type_id
   AND ptt.object_type = 'PA_TASKS'
   AND xpm.task_id(+) = pt.top_task_id
   AND xfd.top_task_id(+) = pt.top_task_id
   AND ei.expenditure_item_id = xei.expenditure_item_id(+)
   AND dr.segment3 IN ('1145500000', '1161500990') ---必要时失效账户限制（存在事务处理填错账户的情况，限制了账户，就可能无法查询到这种情况）
   AND ei.org_id = 82 --HEA 82 SHE 84
   AND ppa.segment1 IN ('11001262')--('112100048', '12001478')
      --Project NO.
   AND pad.gl_period_name = 'APR-17'--'MAR-15'
 ORDER BY ei.expenditure_item_id,
          ppa.segment1,
          pt.task_number,
          xei.transaction_source
;
