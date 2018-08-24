/*CURSOR date_c(p_task_id NUMBER) IS*/
SELECT MAX(trunc(fnd_conc_date.string_to_date(ool.attribute4)))
  FROM oe_order_lines_all ool,
       pa_tasks           pt
 WHERE ool.task_id = pt.task_id
   AND ool.project_id = pt.project_id
   AND pt.top_task_id = 7482238 --p_task_id
   AND NOT EXISTS (SELECT NULL
          FROM oe_order_lines_all ool2,
               pa_tasks           pt2
         WHERE ool2.task_id = pt2.task_id
           AND ool2.project_id = pt2.project_id
           AND pt2.top_task_id = 7482238 --p_task_id
           --AND ool2.attribute4 IS NULL
           AND ool2.flow_status_code <> 'CANCELLED');

--CURSOR date_c(p_task_id NUMBER) IS
SELECT trunc(xmps.fully_packing_date)
  FROM xxinv_mfg_full_packing_sts xmps,
       pa_tasks                   pa,
       pa_projects_all            ppa --update by steven.wang 2017/02/07 add org_id for get_ba_fully_packing_date
 WHERE xmps.mfg_number = pa.task_number
      --update by steven.wang 2017/02/07 add org_id for get_ba_fully_packing_date begin
   AND pa.project_id = ppa.project_id
   AND ppa.org_id = xmps.org_id
      --update by steven.wang 2017/02/07 add org_id for get_ba_fully_packing_date end
   AND pa.task_id = 7482238--p_task_id
   ;
