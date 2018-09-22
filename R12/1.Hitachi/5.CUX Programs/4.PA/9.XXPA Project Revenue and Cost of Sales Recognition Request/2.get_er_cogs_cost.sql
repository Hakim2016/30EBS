--get_er_cogs_cost
/*CURSOR cost_c(p_project_id NUMBER,
p_task_id    NUMBER,
p_end_date   DATE,
p_func_curr  VARCHAR2) IS*/
SELECT /*-sum(*/
 round(decode(pei.system_linkage_function,
              'ST',
              decode(pa_security.view_labor_costs( /*p_project_id*/ 2207196), 'Y', pei.burden_cost, NULL),
              'OT',
              decode(pa_security.view_labor_costs( /*p_project_id*/ 2207196), 'Y', pei.burden_cost, NULL),
              pei.burden_cost),
       2) /*)*/,
 pei.expenditure_type,
 pei.org_id,
 nvl(pa_expenditure_inquiry.get_mode, 'X'),
 (SELECT xx.task_number
    FROM pa_tasks xx
   WHERE 1 = 1
     AND xx.task_id = pei.task_id)
  FROM pa_expenditure_items_all pei,
  pa_tasks pt
 WHERE 1 = 1
 AND pei.project_id = pt.project_id
 AND pei.task_id = pt.task_id
      AND pei.expenditure_type = 'Cost of Sales for ER' --g_expenditure_type
   AND pei.expenditure_item_date <= to_date('20180331', 'yyyymmdd') + 0.99999 --p_end_date
   AND EXISTS (SELECT 1
          FROM pa_implementations imp
         WHERE (pei.org_id = imp.org_id OR nvl(pa_expenditure_inquiry.get_mode, 'X') <> 'CROSS-PROJECT'))
      AND pt.task_number = 'SBK0509-SG.ER'--'SFA0776-SG.ER'
   --AND pei.task_id = /*Subtaskid : */
      --5724681 --p_task_id
;
SELECT imp.org_id,
       imp.*
  FROM pa_implementations imp
 WHERE 1 = 1
--AND imp.org_id = 82
;
SELECT *
  FROM pa_tasks xx
 WHERE 1 = 1
   AND xx.task_id = 5724681;

--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 83);
  
END;
*/
