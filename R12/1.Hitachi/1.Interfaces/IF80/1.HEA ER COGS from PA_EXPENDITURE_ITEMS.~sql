SELECT pei.org_id,
       'ER' AS data_type,
       decode(substr(pa.long_name, 1, length(pa.segment1)),
              pa.segment1,
              nvl(substr(pa.long_name, length(pa.segment1) + 2), pa.long_name),
              pa.long_name) site,
       er.task_id AS task_id,
       top.top_task_id AS top_task_id,
       pa.project_id AS project_id,
       er.task_number AS er_task_number,
       top.task_number as　task_number,
       pa.segment1 AS project_number,
       pa.long_name AS project_name,
       pa.project_type AS project_type,
       NULL AS sales_amount,
       - (SUM(decode(pei.system_linkage_function,
                    'ST',
                    decode(pa_security.view_labor_costs(pei.project_id), 'Y', pei.burden_cost, NULL),
                    'OT',
                    decode(pa_security.view_labor_costs(pei.project_id), 'Y', pei.burden_cost, NULL),
                    pei.burden_cost))) AS cogs_amount
  FROM pa_expenditure_items_all pei, --项目支出子表
       pa_tasks                 er,
       pa_tasks                 top,
       pa_projects_all          pa
 WHERE 1=1
 AND pei.expenditure_type = 'Cost of Sales for ER'--Help to restrict the org_id
   AND pei.task_id = er.task_id
   AND er.top_task_id = top.task_id
   AND pei.project_id = pa.project_id
      --AND PEI.ORG_ID = G_HEA_OU --removed by jingjing.he
      --AND top.task_number = 'SBC0266-SG'
   AND pei.expenditure_item_date BETWEEN to_date('2016-06-01', 'yyyy-mm-dd') /*p_start_date*/
       AND to_date('2016-06-30', 'yyyy-mm-dd') + 0.99999 /*p_end_date*/
 GROUP BY pei.org_id,
          er.task_id,
          top.top_task_id,
          top.task_number,
          pa.project_id,
          er.task_number,
          top.task_number,
          pa.segment1,
          pa.long_name,
          pa.project_type;
