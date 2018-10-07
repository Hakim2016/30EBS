CREATE TABLE xxom.xxom_order_line_close_all AS
(SELECT ool.line_id/*to_number(NULL)*/ prj_line_id,
       ppa.project_id,
       ppa.project_status_code,
       ool.flow_status_code,
       ool.line_id oe_line_id,
       -1 created_by,
       SYSDATE creation_date,
       -1 last_updated_by,
       SYSDATE last_update_date,
       -1 last_update_login
  FROM pa_projects_all      ppa,
       oe_order_lines_all   ool,
       xxom_wf_projects_all t
 WHERE ool.project_id = t.project_id
   AND ool.task_id = t.task_id
   AND ool.project_id = ppa.project_id
   AND ppa.project_status_code = 'CLOSED'
   AND nvl(ppa.template_flag, 'N') != 'Y'
      -- AND ool.line_id = 9210
   AND ool.org_id = 84
      --AND ppa.project_id = 127112
   AND EXISTS (SELECT '1'
          FROM wf_item_activity_statuses wias,
               wf_process_activities     wpa
         WHERE wias.item_type = 'OEOL'
           AND wias.item_key = to_char(ool.line_id)
           AND wias.process_activity = wpa.instance_id
           AND wpa.instance_label = 'XXOM_BLOCK')
      --  AND ppa.project_id = nvl(p_project_id, ppa.project_id)
   AND ool.flow_status_code NOT IN ('ENTERED', 'CANCELLED', 'CLOSED')
   AND 1 = 2)
   ;
   
INSERT INTO xxom.xxom_order_line_close_all 
(SELECT ool.line_id prj_line_id,
       ppa.project_id,
       ppa.project_status_code,
       ool.flow_status_code,
       ool.line_id oe_line_id,
       -1 created_by,
       SYSDATE creation_date,
       -1 last_updated_by,
       SYSDATE last_update_date,
       -1 last_update_login
  FROM pa_projects_all      ppa,
       oe_order_lines_all   ool,
       xxom_wf_projects_all t
 WHERE ool.project_id = t.project_id
   AND ool.task_id = t.task_id
   AND ool.project_id = ppa.project_id
   AND ppa.project_status_code = 'CLOSED'
   AND nvl(ppa.template_flag, 'N') != 'Y'
      -- AND ool.line_id = 9210
   AND ool.org_id = 84
      --AND ppa.project_id = 127112
   AND EXISTS (SELECT '1'
          FROM wf_item_activity_statuses wias,
               wf_process_activities     wpa
         WHERE wias.item_type = 'OEOL'
           AND wias.item_key = to_char(ool.line_id)
           AND wias.process_activity = wpa.instance_id
           AND wpa.instance_label = 'XXOM_BLOCK')
      --  AND ppa.project_id = nvl(p_project_id, ppa.project_id)
   AND ool.flow_status_code NOT IN ('ENTERED', 'CANCELLED', 'CLOSED'))
   ;
   

UPDATE xxom.xxom_order_line_close_all l SET l.prj_line_id = NULL;

--check close stauts
SELECT /*ool.line_id,
       ool.project_id,
       ool.flow_status_code*/COUNT(*)
  FROM xxom.xxom_order_line_close_all n,
       oe_order_lines_all             ool
 WHERE n.oe_line_id = ool.line_id;

