SELECT item.expenditure_item_id,
       item.request_id,
       item.expenditure_id,
       exp.expenditure_group,
       item.cost_dist_rejection_code,
       15480082,
       275,
       32735,
       item.*
  FROM pa_expenditures_all      exp,
       pa_expenditure_items_all item
 WHERE exp.expenditure_status_code || '' = 'APPROVED'
   AND exp.expenditure_id = item.expenditure_id
   AND item.cost_distributed_flag = 'N'
      --AND (nvl(item.request_id, 15480082 + 1) != 15480082 OR item.cost_dist_rejection_code IS NULL)
      --AND exp.expenditure_group = 'HKM2018060902WEBADIPJ2893504'
   AND item.project_id = 2084
   AND item.system_linkage_function NOT IN ('OT', 'ER', 'ST', 'VI', 'BTC')
 ORDER BY item.system_linkage_function,
          item.expenditure_item_date,
          nvl(item.adjusted_expenditure_item_id, item.expenditure_item_id),
          item.expenditure_item_id;

SELECT *
  FROM pa_expenditures_all exp
 WHERE 1 = 1
   AND exp.expenditure_group = 'HKM2018060902WEBADIPJ2893504';

SELECT *
  FROM pa_expenditure_groups_all peg
 WHERE 1 = 1
   AND peg.expenditure_group = 'HKM2018060902WEBADIPJ2893504';

/*
Example:
If your custom AA SQL is setup like:
*/
SELECT nvl((SELECT ppc.class_code
             FROM pa_projects_all          ppa,
                  pa_expenditure_items_all peia,
                  pa.pa_project_classes    ppc
            WHERE ppc.project_id = ppa.project_id
              AND peia.project_id = ppa.project_id
              AND peia.org_id <> ppa.org_id
              AND ppc.class_category = 'Junk Entry'
              AND peia.expenditure_item_id = :2
              AND ppc.project_id = :1),
           '000')
  FROM dual;

--It will have to be modified to put the :1 and :2 parameters in proper order:

SELECT nvl((SELECT ppc.class_code
             FROM pa_projects_all          ppa,
                  pa_expenditure_items_all peia,
                  pa.pa_project_classes    ppc
            WHERE ppc.project_id = ppa.project_id
              AND peia.project_id = ppa.project_id
              AND peia.org_id <> ppa.org_id
              AND ppc.class_category = 'Sales Channel'
              AND ppc.project_id = :1
              AND peia.expenditure_item_id = :2),
           '000')
  FROM sys.dual;

--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/
