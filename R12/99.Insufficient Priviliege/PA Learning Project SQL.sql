-- PROJECT
SELECT * FROM pa_projects_v t WHERE t.segment1 = '10101505';
SELECT * FROM pa_projects_all t WHERE t.segment1 = '10101505';
-- project_id = 1194
-- task
SELECT *
  FROM pa_tasks_wbs_v t
 WHERE t.project_id = 1194
 ORDER BY sort_order;

-- 项目任务分级查询
SELECT LEVEL,
       pt.task_id,
       lpad(' ', LEVEL * 6, ' ') || pt.task_number,
       pt.task_name,
       pt.top_task_id,
       pt.wbs_level,
       pt.parent_task_id,
       pt.pm_task_reference,
       pt.long_task_name,
       pt.*
  FROM pa_tasks pt
 WHERE pt.project_id = 1194
 START WITH pt.parent_task_id IS NULL --pt.task_id = 182622
CONNECT BY PRIOR pt.task_id = pt.parent_task_id;

-- key member
SELECT ppp.project_party_id,
       ppp.person_id,
       ppp.resource_id,
       ppp.resource_type_id,
       ppp.start_date_active,
       ppp.end_date_active,
       ppf.employee_number,
       ppf.full_name,
       pprt.project_role_type,
       pprt.project_role_id,
       pprt.meaning role_meaning
  FROM pa_project_players       ppp,
       pa_project_role_types_vl pprt,
       per_all_people_f         ppf
 WHERE ppp.project_id = 1194
   AND ppp.project_role_type = pprt.project_role_type
   AND ppp.person_id = ppf.person_id
   AND ppp.creation_date BETWEEN ppf.effective_start_date AND
       ppf.effective_end_date
 ORDER BY pprt.meaning,
          ppp.start_date_active;

-- Customer and Contacts
SELECT * FROM pa_project_customers_v ppc WHERE ppc.project_id = 1194;
SELECT hca.account_number,
       hp.party_name,
       ppc.bill_to_address_id,
       ppc.ship_to_address_id,
       hl_ship.address1,
       hl_ship.address2,
       hl_ship.address3,
       hl_ship.address4 || decode(hl_ship.address4, NULL, NULL, ', ') ||
       hl_ship.city || ' , ' || nvl(hl_ship.state, hl_ship.province) || ' ' ||
       hl_ship.postal_code || ' , ' || hl_ship.county,
       hl_bill.address1,
       hl_bill.address2,
       hl_bill.address3,
       hl_bill.address4 || decode(hl_bill.address4, NULL, NULL, ', ') ||
       hl_bill.city || ' , ' || nvl(hl_bill.state, hl_bill.province) || ' ' ||
       hl_bill.postal_code || ' , ' || hl_bill.county
  FROM pa_project_customers   ppc,
       hz_cust_accounts       hca,
       hz_parties             hp,
       hz_cust_acct_sites_all hcas_ship,
       hz_party_sites         hps_ship,
       hz_locations           hl_ship,
       hz_cust_acct_sites_all hcas_bill,
       hz_party_sites         hps_bill,
       hz_locations           hl_bill
 WHERE ppc.project_id = 1194
   AND ppc.customer_id = hca.cust_account_id
   AND hca.party_id = hp.party_id
   AND ppc.ship_to_address_id = hcas_ship.cust_acct_site_id(+)
   AND hcas_ship.party_site_id = hps_ship.party_site_id(+)
   AND hps_ship.location_id = hl_ship.location_id(+)
   AND ppc.bill_to_address_id = hcas_bill.cust_acct_site_id(+)
   AND hcas_bill.party_site_id = hps_bill.party_site_id(+)
   AND hps_bill.location_id = hl_bill.location_id(+);

-- Resource List Assignments
SELECT * FROM pa_resource_list_uses_v pplu WHERE pplu.project_id = 1194;

SELECT prla.resource_list_assignment_id,
       prla.resource_list_id,
       prl.name,
       prl.description,
       prlu.use_code,
       prluc.list_use_name,
       prlu.default_flag
  FROM pa_resource_list_assignments prla,
       pa_resource_lists            prl,
       pa_resource_list_uses        prlu,
       pa_resource_list_use_codes_v prluc
 WHERE prla.project_id = 1194
   AND prla.resource_list_id = prl.resource_list_id
   AND prla.resource_list_assignment_id = prlu.resource_list_assignment_id
   AND prlu.use_code = prluc.list_use_code;

-- Resources / Planning Resources
SELECT tl.name,
       tl.description,
       bg.resource_list_id,
       bg.control_flag,
       decode(assign.use_for_wp_flag,
              'Y',
              'WorkplanEnabled',
              'WorkplanDisabled') AS workplan,
       decode(bg.control_flag, 'Y', 'ControlEnabled', 'ControlDisabled') AS control,
       decode(assign.use_for_fp_flag,
              'Y',
              'FinplanEnabled',
              'FinplanDisabled') AS finplan,
       decode('Y', 'Y', 'ViewEnabled', 'ViewDisabled') AS viewplanres
  FROM pa_resource_lists_all_bg       bg,
       pa_resource_lists_tl           tl,
       pa_resource_list_assignments_v assign
 WHERE assign.resource_list_id = tl.resource_list_id
   AND assign.resource_list_id = bg.resource_list_id
   AND tl.language = userenv('LANG')
   AND assign.project_id = 1194;
-- resource_list_id : 1004

-- View Planning Resources 
SELECT *
  FROM (SELECT rlm.alias,
               rcvl.name,
               rlm.enabled_flag,
               decode(rlm.enabled_flag, 'N', 'CheckboxEnabled') enabled_switcher,
               decode(rlm.enabled_flag,
                      'Y',
                      'UpdateEnabled',
                      NULL,
                      decode(rlm.resource_class_flag, 'Y', 'UpdateEnabled')) update_switcher,
               'N' mulsel2,
               decode(rlm.enabled_flag, 'N', 'Y', 'N') resatt,
               to_char(rlm.resource_list_id) resource_list_id,
               to_char(rlm.resource_class_id) resource_class_id,
               rfvl.name format_name,
               to_char(rfvl.res_format_id) res_format_id,
               rlm.resource_list_member_id,
               NULL AS plan_res_combination,
               decode(rlm.resource_class_flag,
                      'Y',
                      'Y',
                      decode(rlm.enabled_flag, 'N', 'Y', 'N')) resource_class_flag,
               decode(rlm.resource_class_flag, 'Y', 1, 0) res_class_flag_att,
               rlm.record_version_number,
               rcvl.resource_class_seq,
               rlm.object_type,
               rlm.object_id project_id,
               1 read_only,
               rlm.spread_curve_id,
               rlm.etc_method_code,
               rlm.mfc_cost_type_id
          FROM pa_resource_list_members rlm,
               pa_plan_res_defaults     rcdf,
               pa_resource_classes_vl   rcvl,
               pa_res_formats_vl        rfvl
         WHERE rlm.resource_class_id = rcdf.resource_class_id
           AND rlm.resource_class_id = rcvl.resource_class_id
           AND rlm.res_format_id = rfvl.res_format_id
           AND rcdf.enabled_flag = 'Y'
           AND rlm.resource_list_id = 1004 -- :1
        --AND rlm.object_type = :2
        --AND rlm.object_id = :3
        ) qrslt
 ORDER BY resource_class_seq,
          alias ASC;
-- Unpublished Versions
SELECT *
  FROM pa_structure_unpub_vers_v t
 WHERE t.project_id = 1194
--AND t.structure_type = 'WORKPLAN'
;
-- reference View PA_STRUCTURE_UNPUB_VERS_V
SELECT ppevs.element_version_id,
       ppevs.version_number,
       ppevs.name,
       ppevs.proj_element_id,
       ppevs.status_code,
       pps.project_status_name,
       ppevs.lock_status_code,
       ppevs.current_working_flag,
       ppevsch.scheduled_start_date,
       ppevsch.scheduled_finish_date,
       ppst.proj_structure_type_id,
       ppst.structure_type_id,
       pst.structure_type,
       pst.structure_type_class_code
  FROM pa.pa_proj_elem_ver_structure ppevs, -- version record
       pa_project_statuses           pps,
       pa_proj_element_versions      ppev,
       pa_proj_elem_ver_schedule     ppevsch,
       pa_proj_structure_types       ppst,
       pa_structure_types            pst
 WHERE ppevs.project_id = 1194
   AND ppevs.status_code = pps.project_status_code
   AND ppevs.element_version_id = ppev.element_version_id
   AND ppevs.project_id = ppev.project_id
   AND ppev.element_version_id = ppevsch.element_version_id(+)
   AND ppevs.proj_element_id = ppst.proj_element_id
   AND ppst.structure_type_id = pst.structure_type_id
   AND pst.structure_type IN ('WORKPLAN');

-- Workplan / Task
SELECT lpad(' ', ppev.wbs_level * 6, ' ') || ppev.wbs_number "Outline Number",
       decode(ppe.object_type,
              'PA_TASKS',
              ppe.element_number,
              'PA_STRUCTURES',
              to_char(ppevs.version_number)) "Task Number",
       decode(ppe.object_type,
              'PA_TASKS',
              ppe.name,
              'PA_STRUCTURES',
              ppevs.name) "Task Name",
       pps.project_status_name,
       ppevsch.scheduled_start_date,
       ppevsch.scheduled_finish_date,
       ppevsch.estimated_start_date,
       ppevsch.estimated_finish_date,
       ppevsch.actual_start_date,
       ppevsch.actual_finish_date,
       ppc.progress_comment "Comments",
       ppe.proj_element_id,
       ppe.object_type,
       ppe.element_number,
       ppe.name,
       ppe.status_code,
       ppe.carrying_out_organization_id,
       ppev.element_version_id,
       ppev.object_type,
       ppev.parent_structure_version_id,
       ppev.display_sequence,
       ppev.wbs_level,
       ppev.wbs_number,
       ppev.task_unpub_ver_status_code,
       ppev.financial_task_flag,
       ppevs.version_number,
       ppevs.name,
       ppevs.proj_element_id,
       ' ---------- ',
       ppru.percent_complete_id,
       nvl(ppru.completed_percentage, ppru.eff_rollup_percent_comp),
       ppru.base_percent_complete,
       ppru.as_of_date,
       nvl(ppru.progress_status_code, ppru.eff_rollup_prog_stat_code),
       ppc.progress_status_code,
       pps_progress.project_status_name "Progress Status"
  FROM pa_proj_elements           ppe,
       pa_project_statuses        pps,
       pa_proj_element_versions   ppev,
       pa_proj_elem_ver_structure ppevs,
       pa_proj_elem_ver_schedule  ppevsch,
       pa_progress_rollup         ppru,
       pa_percent_completes       ppc,
       pa_project_statuses        pps_progress
 WHERE 1 = 1
   AND ppe.status_code = pps.project_status_code(+)
   AND ppe.proj_element_id = ppev.proj_element_id
   AND ppev.parent_structure_version_id = ppevs.element_version_id
   AND ppev.project_id = ppevs.project_id
   AND ppev.element_version_id = ppevsch.element_version_id(+)
   AND ppev.project_id = ppevsch.project_id(+)
      --
   AND ppev.project_id = ppru.project_id(+)
   AND ppev.object_type = ppru.object_type(+)
   AND ppev.proj_element_id = ppru.object_id(+)
   AND ppev.element_version_id = ppru.object_version_id(+)
   AND ppru.structure_type(+) = 'WORKPLAN'
   AND ppru.current_flag(+) <> 'W'
   AND ppru.structure_version_id(+) IS NULL
   AND nvl(ppru.as_of_date, trunc(SYSDATE)) =
       (SELECT nvl(MAX(ppr2.as_of_date), trunc(SYSDATE))
          FROM pa_progress_rollup ppr2
         WHERE ppr2.object_id = ppev.proj_element_id
           AND ppr2.proj_element_id = ppev.proj_element_id
           AND ppr2.object_version_id = ppev.element_version_id
           AND ppr2.project_id = ppev.project_id
           AND ppr2.object_type = ppev.object_type --'PA_TASKS'
           AND ppr2.structure_type = 'WORKPLAN'
           AND ppr2.structure_version_id IS NULL
           AND ppr2.current_flag <> 'W')
   AND ppru.percent_complete_id = ppc.percent_complete_id(+)
   AND ppc.progress_status_code = pps_progress.project_status_code(+)
   AND ppevs.name = '20131121173731' -- version_number
   AND ppe.project_id = 1194
-- AND ppev.wbs_number = '22.10'
-- AND nvl(ppev.wbs_level, -1) < 1
 ORDER BY -- ppev.parent_structure_version_id,
          nvl(ppev.display_sequence, -1) NULLS FIRST,
          ppev.wbs_number;

BEGIN
  mo_global.set_policy_context('S', 82);
END;
