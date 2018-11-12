SELECT ppa.org_id,
       ppa.segment1 project_num,
       ppp.organization_id,
       ppp.costing_group_id,
       --ppp.wip_acct_class_code, -- default wip class code
       NULL,
       ccg.cost_group,
       ccg.cost_group_type,
       NULL,
       ccw.class_code,
       NULL,
       wac.class_type,
       wac.disable_date
  FROM pa_projects_all         ppa,
       pjm_project_parameters  ppp,
       cst_cost_groups         ccg,
       cst_cost_group_accounts ccga,
       cst_cg_wip_acct_classes ccw,
       wip_accounting_classes  wac
 WHERE 1 = 1
   AND ppa.segment1 = '10101505'
   AND ppa.project_id = ppp.project_id
   AND ppp.costing_group_id = ccg.cost_group_id
   AND ccg.cost_group_id = ccga.cost_group_id
   AND ppp.organization_id = ccga.organization_id
   AND ccga.cost_group_id = ccw.cost_group_id
   AND ccga.organization_id = ccw.organization_id
   AND ccw.class_code = wac.class_code
   AND ccw.organization_id = wac.organization_id
   AND nvl(wac.disable_date, SYSDATE) >= SYSDATE
