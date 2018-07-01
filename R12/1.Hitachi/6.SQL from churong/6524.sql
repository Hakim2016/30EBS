SELECT DISTINCT (ppa.segment1) project_number,
                pt.task_number,
                ppa.org_id,
                ppa.completion_date expire_date1,
                ptop.completion_date expire_date2,
                pt.completion_date expire_date3
                --,ppa.*
                --,pt.*      
  FROM pa_tasks         PT,
       pa_task_types    ptt,
       pa_proj_elements ppe,
       pa_projects_all  ppa,
       pa_tasks         ptop
 WHERE 1 = 1
   and ppa.attribute1 is Null
   --and ppa.org_id not in ('84','82','101')
   AND ppa.org_id = 84
   AND ppa.project_status_code NOT IN ('CANCELLED', 'CLOSED')
   AND ppe.proj_element_id = pt.task_id
   AND ppe.type_id = ptt.task_type_id
   AND pt.top_task_id = ptop.task_id
   AND ptt.task_type IN ('EQ COST', 'ER COST', 'FM COST')
   AND ppa.project_id = pt.project_id
   AND pt.task_number = ppe.element_number
   AND (ppa.completion_date IS NOT NULL OR pt.completion_date IS NOT NULL OR
       ptop.completion_date IS NOT NULL);
   
   /*(ppa.completion_date >= to_date('2016-11-01', 'yyyy-mm-dd') and
       ppa.completion_date <= to_date('2016-11-30', 'yyyy-mm-dd') or
       pt.completion_date >= to_date('2016-11-01', 'yyyy-mm-dd') and
       pt.completion_date <= to_date('2016-11-30', 'yyyy-mm-dd'));*/


SELECT distinct xha.so_number,
                ppa.attribute1,
                ppa.segment1,
                ppa.creation_date,
                ppa.start_date,
                ppa.completion_date,
                xha.approved_date,
                xha.last_invoice_flag,
                xha.status_code,
                xha.*
  FROM XXOM_DO_INVOICE_HEADERS_ALL xha,
       oe_order_lines_all          ool,
       pa_projects_all             ppa
 WHERE 1 = 1
   --AND xha.approved_date >= to_date('2017-01-01', 'yyyy-mm-dd')
   --AND xha.approved_date <= to_date('2017-01-31', 'yyyy-mm-dd')
   AND xha.last_invoice_flag = 'Y'
   AND xha.status_code in ('APPROVED','INVOICE')
   and xha.org_id = 141
   and ool.header_id = xha.oe_header_id
   and ool.project_id = ppa.project_id(+)
   

SELECT his.last_update_date, ppa.segment1, his.*
  FROM xxpa.xxpa_project_fin_date_his his, pa_projects_all ppa
 WHERE 1 = 1
   AND his.request_id = 11754828
   and his.project_id = ppa.project_id
--AND his.request_id in (11754548,11754539,11754523,11754512,11754458)
 ORDER BY his.last_update_date DESC;

SELECT his.last_update_date, his.*
  FROM xxpa.xxpa_project_fin_date_his his
  WHERE 1=1
  AND his.request_id=11756308
 ORDER BY his.last_update_date DESC;
