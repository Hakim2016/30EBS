--get_er_cogs_cost
/*CURSOR cost_c(p_project_id NUMBER,
p_task_id    NUMBER,
p_end_date   DATE,
p_func_curr  VARCHAR2) IS*/
SELECT /*-sum(*/round(decode(pei.system_linkage_function,
                         'ST',
                         decode(pa_security.view_labor_costs( /*p_project_id*/ 2207196), 'Y', pei.burden_cost, NULL),
                         'OT',
                         decode(pa_security.view_labor_costs( /*p_project_id*/ 2207196), 'Y', pei.burden_cost, NULL),
                         pei.burden_cost),
                  2)/*)*/
                  ,pei.expenditure_type
  FROM pa_expenditure_items_all pei
 WHERE 1=1
   --AND pei.expenditure_type = 'Cost of Sales for ER' --g_expenditure_type
   AND pei.expenditure_item_date <= to_date('20180331','yyyymmdd') + 0.99999 --p_end_date
   /*AND EXISTS (SELECT 1
          FROM pa_implementations imp
         WHERE (pei.org_id = imp.org_id OR nvl(pa_expenditure_inquiry.get_mode, 'X') <> 'CROSS-PROJECT'))
   */
   AND pei.task_id = /*Subtaskid : */
       5724681 --p_task_id
;

SELECT *
  FROM pa_tasks xx
 WHERE 1 = 1
   AND xx.task_id = 5724681;
