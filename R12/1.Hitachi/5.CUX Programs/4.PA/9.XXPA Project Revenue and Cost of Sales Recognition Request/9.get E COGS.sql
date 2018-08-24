--from process_cos(
/*CURSOR lines_c(p_request_id NUMBER) IS*/
SELECT xpmm.task_id,
       --get_accounting_date(xpmm.org_id, p_pa_period) accounting_date,
       xpmm.org_id,
       hou.name organization_name,
       xpmm.project_id,
       xpmm.cos_amount,
       xpmm.cos_add_up_amount
  FROM xxpa_proj_milestone_manage_all /*_all*/ xpmm,
       hr_all_organization_units      hou
 WHERE xpmm.org_id = hou.organization_id
/*   AND 'Y' = xxpa_proj_revenue_cos_pkg.get_process_flag('COS' --g_cos_type
,
 xpmm.task_id,
 2207196 --p_project_id
,
 970347 --p_task_id
,
 xpmm.org_id,
 'MAR-18' --p_pa_period
 )*/

;

--from get_process_flag(
--get_process_flag
/*CURSOR line_c(p_task_id        NUMBER,
                  p_rep_project_id NUMBER,
                  p_rep_task_id    NUMBER) IS*/
SELECT xpmm.task_id,
       xpmm.org_id,
       xpmm.*
  FROM xxpa_proj_milestone_manage_all xpmm
 WHERE 1 = 1
   AND xpmm.task_id = 5724679 --p_task_id
   AND xpmm.project_id = 2207196 --nvl(p_rep_project_id, xpmm.project_id)
   AND xpmm.task_id = 5724679 --nvl(p_rep_task_id, xpmm.task_id)
;

--from get_er_process_flag(
/*CURSOR line_c(p_type VARCHAR2, p_task_id NUMBER, p_end_date DATE) IS*/
SELECT xpmm.task_id,
       xpmm.er_finish_flag,
       xpmm.cos_finish_flag,
       xpmm.hand_over_date,
       xpmm.fully_delivery_date
  FROM xxpa_proj_milestone_manage_all xpmm
 WHERE --(p_type = g_er_type AND nvl(xpmm.er_finish_flag, 'N') != 'Y' OR
       /*p_type*/'COS' = /*g_cos_type*/'COS' AND nvl(xpmm.cos_finish_flag, 'N') != 'Y'/*)*/
   --AND xpmm.fully_delivery_date <= p_end_date
   AND xpmm.task_id = 5724935--5724679--p_task_id
   ;
   
   
SELECT *
  FROM pa_tasks pt
 WHERE 1 = 1
   AND pt.task_id = 970347 --5724679
;
