/*CURSOR cur_fac_fg04 IS*/
SELECT /*p_cost_type*/'FAC_FG' cost_type,
       'OVERSEA-WIP-R' sub_type,
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
       round((-1 * pei.burden_cost), 2) actual_cost,
       we.wip_entity_name,
       (pei.burden_cost) orig_cost,
       to_char(pp.end_date, 'YYYYMMDD') expenditure_ref,
       'PA_EXPENDITURE_ITEMS_ALL' source_table,
       pei.expenditure_item_id source_line_id,
       NULL line_type
  FROM wip_transactions             wt,
       pa_expenditure_items_all     pei,
       org_organization_definitions ood,
       hr_operating_units           hou,
       pa_projects_all                  ppa,
       pa_project_types_all         ppt,
       pa_tasks                     pt,
       pa_tasks                     mfg,
       pa_periods_all               pp,
       apps.mtl_item_categories_v   msc,
       pa_expenditure_types         pet,
       wip_discrete_jobs            wdj,
       wip_entities                 we
 WHERE wt.transaction_id = pei.orig_transaction_reference
   AND pei.transaction_source = 'Work In Process'
   AND wt.project_id = pei.project_id
   AND wt.task_id = pei.task_id
   AND pei.burden_cost <> 0
   AND wt.organization_id = ood.organization_id
   AND ood.operating_unit = hou.organization_id
   AND ood.organization_name = 'SHE_FAC_ORG'
   AND wt.project_id = ppa.project_id
   AND ppa.project_type = ppt.project_type
   AND ppt.attribute7 = 'OVERSEA'
   AND wt.task_id = pt.task_id
   AND pt.top_task_id = mfg.task_id
   AND hou.organization_id = pp.org_id
   AND wt.wip_entity_id = wdj.wip_entity_id
   AND wt.organization_id = wdj.organization_id
   AND msc.inventory_item_id = wdj.primary_item_id
   AND msc.organization_id = wdj.organization_id
   AND msc.category_set_name = 'GSCM Item Category Set'
   AND msc.category_concat_segs = pet.attribute15
   AND pet.end_date_active IS NULL -- add by gusenlin 20130723  for 11 parts
   AND wt.wip_entity_id = we.wip_entity_id
   AND wt.transaction_date <= pp.end_date + 0.99999
   AND EXISTS (SELECT 1
          FROM mtl_material_transactions mmt
         WHERE mmt.transaction_source_id = we.wip_entity_id
           AND mmt.transaction_type_id = 44 --WIP Completion
           AND mmt.final_completion_flag = 'Y')
   /*AND EXISTS (SELECT 1
          FROM xxpa.xxpa_cost_carry_over_tmp a
         WHERE ood.organization_id = a.organization_id
           AND pet.attribute15 = a.category_concat_segs
           AND ppa.project_id = a.project_id
           AND pt.task_id = a.task_id)*/
   --AND pp.gl_period_name = g_period_name
   AND pp.start_date = to_date('20180401','yyyymmdd')
   AND pt.task_number = 'SBH0216-PH.EQ'
   AND (NOT EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_type = /*p_cost_type*/'FAC_FG'
                       AND xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                       AND xcfd.source_line_id = pei.expenditure_item_id));

      
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
