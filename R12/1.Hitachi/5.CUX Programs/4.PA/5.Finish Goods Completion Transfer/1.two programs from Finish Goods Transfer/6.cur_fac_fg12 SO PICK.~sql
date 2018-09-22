/*CURSOR cur_fac_fg12 IS*/
--*     6.00  2018/05/07 steven.wang update for performance  end 
--Sales order pick release
SELECT /*p_cost_type*/'FAC_FG' cost_type,
       'SO-PICK' sub_type,
       hou.organization_id org_id,
       hou.name operation_ou,
       mfg.task_id mfg_id,
       mfg.task_number mfg#,
       pp.gl_period_name,
       ppt.project_type,
       ood.organization_id expenditure_org_id,
       ood.organization_name exp_org,
       ppa.project_id,
       ppa.segment1 project_number,
       pt.task_id,
       pt.task_number,
       pp.end_date expenditure_item_date,
       pp.end_date + decode(to_char(pp.end_date, 'D'), 1, 0, 8 - (to_char(pp.end_date, 'D'))) expenditure_ending_date,
       pet.expenditure_type,
       round((mmt.primary_quantity * mmt.actual_cost), 2) actual_cost,
       to_char(ooh.order_number),
       (mmt.primary_quantity * mmt.actual_cost) orig_cost,
       to_char(pp.end_date, 'YYYYMMDD') expenditure_ref,
       'MTL_MATERIAL_TRANSACTIONS' source_table,
       mmt.transaction_id source_line_id,
       NULL line_type
  FROM apps.mtl_material_transactions mmt,
       apps.mtl_transaction_types     mtt,
       org_organization_definitions   ood,
       hr_operating_units             hou,
       oe_order_lines_all             ool,
       oe_order_headers_all           ooh,
       apps.pa_projects_all               ppa,
       pa_project_types_all           ppt,
       apps.pa_tasks                  pt,
       pa_tasks                       mfg,
       pa_expenditure_types           pet,
       pa_periods_all                 pp,
       mtl_item_locations             mil
 WHERE 1 = 1
   AND mmt.transaction_type_id = mtt.transaction_type_id
   AND mmt.organization_id = ood.organization_id
   AND ood.operating_unit = hou.organization_id
   AND ood.organization_name = 'SHE_FAC_ORG'
   AND mtt.transaction_type_name IN ('Sales Order Pick')
   AND mmt.primary_quantity * mmt.actual_cost <> 0
   AND mmt.trx_source_line_id = ool.line_id
   AND ool.header_id = ooh.header_id
   AND ool.project_id = ppa.project_id
   AND ppa.project_type = ppt.project_type
   --AND ppt.attribute7 = 'OVERSEA'
   AND ool.task_id = pt.task_id
   AND pt.top_task_id = mfg.task_id
   AND ool.attribute5 = pet.attribute15
   AND pet.end_date_active IS NULL -- add by gusenlin 20130723  for 11 parts
   AND ppa.org_id = pp.org_id
   AND mmt.locator_id = mil.inventory_location_id(+)
   AND mil.segment19 IS NULL --no project info
   AND decode(mmt.pm_cost_collected, NULL, 
                         decode(mmt.pm_cost_collector_group_id, NULL, 
                                 4, 
                                 1), 
                          'Y', 1, 
                          'N', 2, 
                          'E', 3) = '1' --Transfered to PA
   AND mmt.primary_quantity < 0
   AND mmt.transaction_date <= pp.end_date + 0.99999
   /*   
   AND EXISTS (SELECT 1
          FROM oe_order_lines_all        ool2,
               ra_customer_trx_lines_all rctl,
               ra_customer_trx_all       rct,
               pa_tasks                  pt_ol
         WHERE rctl.line_type = 'LINE'
           AND rctl.org_id = ool2.org_id
           AND rctl.customer_trx_id = rct.customer_trx_id
           AND rctl.interface_line_attribute6 = to_char(ool2.line_id)
           AND ool2.project_id = ppa.project_id
           AND ool2.task_id = pt_ol.task_id
           AND ool2.org_id = hou.organization_id
           AND pt_ol.top_task_id = mfg.task_id
           AND pt_ol.project_id = ppa.project_id
           AND nvl(ool2.attribute5, '@#$') = nvl(ool.attribute5, '@#$')
           AND rct.trx_date <= pp.end_date + 0.99999)*/
      --end modified
   --AND pp.gl_period_name = g_period_name
   --AND pp.start_date = to_date('20170801','yyyymmdd')
   --AND ppa.segment1 = '217060080'
   AND mfg.task_number = 'SV00125-SG'
   /*AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type = \*p_cost_type*\'FAC_FG'
                       AND xcfd.source_table = 'MTL_MATERIAL_TRANSACTIONS'
                       AND xcfd.source_line_id = mmt.transaction_id))*/
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
  
END;*/
