--Project status inquiry
SELECT --row_id,
/*proj_element_id,
element_version_id,
parent_structure_version_id,*/
 org_id,
 project_id,
 task_id,
 mfg_completion_date,
 /*(SELECT ooh.open_flag--ooh.order_number
    FROM oe_order_headers_all ooh
   WHERE 1 = 1
     AND ooh.order_number = v.project_num
     AND ooh.org_id = v.org_id) ooh_open,
 (SELECT ooh.cancelled_flag--ooh.order_number
    FROM oe_order_headers_all ooh
   WHERE 1 = 1
     AND ooh.order_number = v.project_num
     AND ooh.org_id = v.org_id) ooh_cancel,
 (SELECT ooh.booked_flag--ooh.order_number
    FROM oe_order_headers_all ooh
   WHERE 1 = 1
     AND ooh.order_number = v.project_num
     AND ooh.org_id = v.org_id) ooh_book,
 (SELECT ool.open_flag --ool.ordered_item
    FROM oe_order_lines_all ool
   WHERE 1 = 1
     AND ool.project_id = v.project_id
        --AND ool.task_id = v.task_id
     AND ool.ordered_item = v.mfg_num) ool_open,
 (SELECT ool.cancelled_flag --ool.ordered_item
    FROM oe_order_lines_all ool
   WHERE 1 = 1
     AND ool.project_id = v.project_id
        --AND ool.task_id = v.task_id
     AND ool.ordered_item = v.mfg_num) ool_cancel,
 (SELECT ool.booked_flag --ool.ordered_item
    FROM oe_order_lines_all ool
   WHERE 1 = 1
     AND ool.project_id = v.project_id
        --AND ool.task_id = v.task_id
     AND ool.ordered_item = v.mfg_num) ool_book,*/
 customer_id,
 project_end_date,
 project_start_date,
 org_name,
 project_num,
 project_name,
 project_long_name,
 customer_name,
 project_status_code,
 project_status_name,
 project_type_code,
 customer_number,
 task_status,
 mfg_num,
 related_mfg_num,
 mfg_task_name,
 mfg_spec,
 mfg_status,
 scheduled_start_date,
 scheduled_finish_date,
 estimated_start_date,
 estimated_finish_date,
 pt_estimated_start_date,
 pt_estimated_finish_date,
 actual_start_date,
 actual_finish_date,
 project_type,
 qf_start_date,
 qf_end_date
  FROM xxpjm_mfg_status_v2 v
 WHERE (org_id = 84)
      --AND (project_id = 2700747)
   --AND v.project_num = '21000400'
   AND v.scheduled_finish_date >= to_date('20180301','yyyymmdd')
--AND v.mfg_num = 'TAE0736-TH'--'JAJ0295-KH'
--AND 
;

SELECT ool.ordered_item,
       ool.task_id
  FROM oe_order_lines_all ool
 WHERE 1 = 1
   AND ool.project_id = 793108 --2700747--v.project_id
--AND ool.task_id = 3122306--6685404--v.task_id
;
--query the mfg_completion_date(ppe.attribute1)
SELECT ppa.org_id,
       ppe.proj_element_id,
       ppe.project_id,
       ppa.segment1 proj_num,
       ppa.project_type,
       ppa.completion_date,
       ppe.name,
       ppe.element_number,
       ppe.attribute1
  FROM pa_proj_elements ppe,
       pa_projects_all  ppa
 WHERE 1 = 1
   AND ppe.project_id = ppa.project_id
   AND ppa.org_id = 84 --SHE
   AND ppe.element_number IN ('TAA0027-TH' --'JAJ0295-KH' --'JAC0071-IN'
                              
                              );

SELECT *
  FROM pa_proj_elements ppe
 WHERE 1 = 1
   AND ppe.element_number = 'JAJ0295-KH'
   AND EXISTS (SELECT 'X'
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = ppe.project_id
           AND ppa.org_id = 84);

--update the mfg_completion_date
--format:'yyyy/mm/dd'
UPDATE pa_proj_elements ppe
   SET ppe.attribute1 = '2018/03/20'
 WHERE 1 = 1
   AND ppe.element_number = 'JAJ0295-KH'
   AND EXISTS (SELECT 'X'
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = ppe.project_id
           AND ppa.org_id = 84);
