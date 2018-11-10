
SELECT
--Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
/*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/ --Bug 7644130
 --p_parent_project_id,
 decode(ppe.object_type,
        'PA_TASKS',
        ppe.element_number,
        'PA_STRUCTURES',
        to_char(ppvs.version_number)),
 decode(ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name),
 ppe.description,
 ppe.object_type,
 ppv.element_version_id,
 ppe.proj_element_id,
 ppa.project_id/*,
 ppv.display_sequence + p_sequence_offset*/ --bug 4448499  adjust the display sequnece of sub-project tasks with the offset.
,
 ppvsch.milestone_flag
 /* 4275236 : Perf Enhancement - Replaced with  Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
 */,
 decode(nvl(ppvsch.milestone_flag, 'N'), 'N', 'l_no', 'l_yes'),
 ppvsch.critical_flag
 /* 4275236 : Perf Enhancement - Replaced with  Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
 */,
 decode(nvl(ppvsch.critical_flag, 'N'), 'N', 'l_no', 'l_yes'),
 por.object_id_from1,
 por.object_type_from,
 por.relationship_type,
 por.relationship_subtype
 -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
,
 decode(ppe.object_type,
        'PA_STRUCTURES',
        'Y',
        'PA_TASKS',
        pa_proj_elements_utils.is_summary_task_or_structure(ppv.element_version_id)) summary_element_flag -- Fix for Bug # 4490532.
 -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
,
 nvl(ppru.progress_status_code, ppru.eff_rollup_prog_stat_code),
 pps.project_status_name, 
 NULL--ppc.PROGRESS_COMMENT
,
 null--ppc.DESCRIPTION
,
 ppvsch.scheduled_start_date,
 ppvsch.scheduled_finish_date,
 ppe.manager_person_id,
 papf.full_name,
 ppv.parent_structure_version_id,
 ppv.wbs_level,
 ppv.wbs_number,
 ppe.record_version_number,
 ppv.record_version_number,
 ppvsch.record_version_number,
 ppv2.record_version_number,
 pps.status_icon_active_ind,
 ppru.percent_complete_id,
 pps.status_icon_ind, 
 ppe.status_code status_code1, 
 pps2.project_status_name,
 ppe.priority_code,
 pa_proj_elements_utils.get_pa_lookup_meaning('PA_TASK_PRIORITY_CODE',
                                              ppe.priority_code),
 ppe.carrying_out_organization_id,
 hou.name,
 ppe.inc_proj_progress_flag,
 ppvsch.estimated_start_date,
 ppvsch.estimated_finish_date,
 ppvsch.actual_start_date,
 ppvsch.actual_finish_date,
 nvl(ppru.completed_percentage, ppru.eff_rollup_percent_comp),
 por.object_relationship_id,
 por.record_version_number,
 ppvsch.pev_schedule_id, 
 ppvs.latest_eff_published_flag,
 ppa.segment1,
 ppa.name,
 ppv2.proj_element_id,
 pst.structure_type_class_code,
 ppvs.published_date,
 ppe.link_task_flag,
 por.object_id_from1,
 ppru.as_of_date,
 to_number(NULL),
 ppe.baseline_start_date,
 ppe.baseline_finish_date,
 ppvsch.scheduled_start_date - ppe.baseline_start_date,
 ppvsch.scheduled_finish_date - ppe.baseline_finish_date,
 ppvsch.estimated_start_date - ppvsch.scheduled_start_date,
 ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date,
 ppvsch.actual_start_date - ppvsch.scheduled_start_date,
 ppvsch.actual_finish_date - ppvsch.scheduled_finish_date,
 pa_proj_elements_utils.get_pa_lookup_meaning('PM_PRODUCT_CODE',
                                              ppe.pm_source_code),
 ppe.pm_source_code,
 ppe.pm_source_reference,
 pa_proj_elements_utils.is_active_task(ppv.element_version_id,
                                       ppv.object_type)
 /*4275236 : Replaced the function call with Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
 */,
 decode(pa_proj_elements_utils.is_active_task(ppv.element_version_id,
                                              ppv.object_type),
        'Y',
        'l_yes',
        'l_no')
 -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
 -- Fix for Bug # 4447949.
,
 decode(ppv.object_type,
        'PA_STRUCTURES',
        NULL,
        (trunc(ppvsch.scheduled_start_date) - trunc(SYSDATE)))
 -- Fix for Bug # 4447949.
 -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
 -- Fix for Bug # 4447949.
,
 decode(ppv.object_type,
        'PA_STRUCTURES',
        NULL,
        (trunc(ppvsch.scheduled_finish_date) - trunc(SYSDATE)))
 -- Fix for Bug # 4447949.
,
 papf.work_telephone,
 pa_proj_elements_utils.get_pa_lookup_meaning('SERVICE TYPE',
                                              pt.service_type_code),
 pt.service_type_code,
 pwt.name,
 pt.work_type_id
 /*4275236 : Replaced the function call with Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
 */,
 decode(pt.chargeable_flag, 'Y', 'l_yes', 'l_no'),
 pt.chargeable_flag
 /*4275236 : Replaced the function call with Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
 */,
 decode(pt.billable_flag, 'Y', 'l_yes', 'l_no'),
 pt.billable_flag
 /*4275236 : Replaced the function call with Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
 */,
 decode(pt.receive_project_invoice_flag, 'Y', 'l_yes', 'l_no'),
 pt.receive_project_invoice_flag,
 decode(ppe.task_status, NULL, pt.start_date, ppvsch.scheduled_start_date) start_date,
 decode(ppe.task_status,
        NULL,
        pt.completion_date,
        ppvsch.scheduled_finish_date) completion_date,
 pa_progress_utils.get_prior_percent_complete(ppa.project_id,
                                              ppe.proj_element_id,
                                              ppru.as_of_date),
 ppvsch.last_update_date,
 to_date(NULL),
 ppa.baseline_as_of_date,
 ppru.last_update_date,
 ppru.last_update_date
 -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
,
 decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
,
 trunc(ppvsch.estimated_start_date) - trunc(SYSDATE),
 trunc(ppvsch.estimated_finish_date) - trunc(SYSDATE),
 trunc(SYSDATE) - trunc(ppvsch.actual_start_date),
 trunc(SYSDATE) - trunc(ppvsch.actual_finish_date),
 decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
 /*4275236 : Replaced the function call with Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
 */,
 decode(ppvsch.actual_finish_date, NULL, 'l_no', 'l_yes'),
 ppe.creation_date
 /*4275236 : Replaced the function call with Local variable
 ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
 */,
 decode(pa_proj_elements_utils.is_lowest_task(ppv.element_version_id),
        'Y',
        'l_yes',
        'l_no'),
 ppe.type_id,
 tt.task_type,
 ppe.status_code status_code2,
 pps3.project_status_name,
 ppe5.phase_code,
 pps5.project_status_name,
 pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
 -- Fix for Bug # 4319171.
,
 por.weighting_percentage,
 ppvsch.duration,
 pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration),
 pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration),
 pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration),
 pt.address_id,
 addr.address1,
 addr.address2,
 addr.address3,
 addr.address4 || decode(addr.address4, NULL, NULL, ', ') || addr.city || ', ' ||
 nvl(addr.state, addr.province) || ', ' || addr.county,
 ppe.wq_item_code,
 pa_proj_elements_utils.get_pa_lookup_meaning('PA_WQ_WORK_ITEMS',
                                              ppe.wq_item_code),
 ppe.wq_uom_code,
 pa_proj_elements_utils.get_pa_lookup_meaning('UNIT', ppe.wq_uom_code),
 ppvsch.wq_planned_quantity,
 ppe.wq_actual_entry_code,
 pa_proj_elements_utils.get_pa_lookup_meaning('PA_ACTUAL_WQ_ENTRY_CODE',
                                              ppe.wq_actual_entry_code),
 tt.prog_entry_enable_flag,
 decode(pppa.percent_comp_enable_flag,
        'Y',
        tt.percent_comp_enable_flag,
        'N'),
 decode(pppa.remain_effort_enable_flag,
        'Y',
        tt.remain_effort_enable_flag,
        'N'),
 ppe.task_progress_entry_page_id,
 ppl.page_name,
 nvl(ppe.base_percent_comp_deriv_code, tt.base_percent_comp_deriv_code),
 pa_proj_elements_utils.get_pa_lookup_meaning('PA_PERCENT_COMP_DERIV_CODE',
                                              nvl(ppe.base_percent_comp_deriv_code,
                                                  tt.base_percent_comp_deriv_code)),
 tt.wq_enable_flag,
 tt.prog_entry_req_flag,
 pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours,
                                                        pfxat.equipment_hours,
                                                        NULL),
                            ppru.estimated_remaining_effort,
                            ppru.eqpmt_etc_effort,
                            NULL,
                            ppru.subprj_ppl_etc_effort,
                            ppru.subprj_eqpmt_etc_effort,
                            NULL,
                            NULL,
                            pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date,
                                                       ppru.eqpmt_act_effort_to_date,
                                                       NULL,
                                                       ppru.subprj_ppl_act_effort,
                                                       ppru.subprj_eqpmt_act_effort,
                                                       NULL)) estimated_remaining_effort
 -- Fix for Bug # 4319171.
 -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
 -- Fix for Bug # 4447949.
,
 decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
,
 ppru.cumulative_work_quantity
 -- Bug Fix 5609629
 -- Replaced the following function call with local variable.
 -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
,
 'l_versioning_enabled_flag'
 -- End of Bug Fix 5609629
,
 ppe.phase_version_id,
 ppe5.name,
 ppe5.element_number,
 pt.attribute_category,
 pt.attribute1,
 pt.attribute2,
 pt.attribute3,
 pt.attribute4,
 pt.attribute5,
 pt.attribute6,
 pt.attribute7,
 pt.attribute8,
 pt.attribute9,
 pt.attribute10,
 ppwa.lifecycle_version_id,
 ppv.task_unpub_ver_status_code,
 pa_control_items_utils.get_open_control_items(ppe.project_id,
                                               ppe.object_type,
                                               ppe.proj_element_id,
                                               'ISSUE'),
 to_number(NULL),
 pa_proj_elements_utils.check_child_element_exist(ppv.element_version_id),
 trunc(ppvsch.scheduled_finish_date) - trunc(SYSDATE),
 ppeph.name,
 pa_control_items_utils.get_open_control_items(ppe.project_id,
                                               ppe.object_type,
                                               ppe.proj_element_id,
                                               'CHANGE_REQUEST'),
 pa_control_items_utils.get_open_control_items(ppe.project_id,
                                               ppe.object_type,
                                               ppe.proj_element_id,
                                               'CHANGE_ORDER'),
 pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
,
 pfxat.prj_raw_cost raw_cost,
 pfxat.prj_brdn_cost burdened_cost,
 pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
,
 pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date,
                            ppru.eqpmt_act_effort_to_date,
                            NULL,
                            NULL,
                            NULL,
                            NULL) actual_effort -- Fix for Bug # 4319171.
,
 ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
,
 pa_relationship_utils.display_predecessors(ppv.element_version_id) predecessors,
 pa_progress_utils.percent_spent_value((nvl(ppru.ppl_act_effort_to_date, 0) +
                                       nvl(ppru.eqpmt_act_effort_to_date,
                                            0)),
                                       (nvl(pfxat.labor_hours, 0) +
                                       nvl(pfxat.equipment_hours, 0))) percent_spent_effort,
 pa_progress_utils.percent_spent_value((nvl(ppru.oth_act_cost_to_date_pc, 0) +
                                       nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                                       nvl(ppru.eqpmt_act_cost_to_date_pc,
                                            0)),
                                       nvl(pfxat.prj_brdn_cost, 0)) percent_spent_cost,
 pa_progress_utils.percent_complete_value((nvl(ppru.ppl_act_effort_to_date,
                                               0) + nvl(ppru.eqpmt_act_effort_to_date,
                                                         0)),
                                          (nvl(ppru.estimated_remaining_effort,
                                               0) +
                                          nvl(ppru.eqpmt_etc_effort, 0))) percent_complete_effort,
 pa_progress_utils.percent_complete_value((nvl(ppru.oth_act_cost_to_date_pc,
                                               0) + nvl(ppru.ppl_act_cost_to_date_pc,
                                                         0) +
                                          nvl(ppru.eqpmt_act_cost_to_date_pc,
                                               0)),
                                          (nvl(ppru.oth_etc_cost_pc, 0) +
                                          nvl(ppru.ppl_etc_cost_pc, 0) +
                                          nvl(ppru.eqpmt_etc_cost_pc, 0))) percent_complete_cost,
 trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) actual_duration,
 trunc(ppvsch.scheduled_finish_date) - trunc(SYSDATE) remaining_duration,
 pa_proj_elements_utils.get_pa_lookup_meaning('PA_SCHEDULE_CONSTRAINT_TYPE',
                                              ppvsch.constraint_type_code) constraint_type,
 ppvsch.constraint_type_code,
 ppvsch.constraint_date,
 ppvsch.early_start_date,
 ppvsch.early_finish_date,
 ppvsch.late_start_date,
 ppvsch.late_finish_date,
 ppvsch.free_slack,
 ppvsch.total_slack
 -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
,
 decode(pa_proj_elements_utils.is_summary_task_or_structure(ppv.element_version_id),
        'Y',
        'N',
        'N',
        'Y') lowest_task -- Fix for Bug # 4490532.
 -- , 'N')  Lowest_Task -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
 /* Bug Fix 5466645
 --   ,to_number ( null ) Estimated_Baseline_Start
 --   ,to_number ( null ) Estimated_Baseline_Finish
 */,
 (ppvsch.estimated_start_date - ppe.baseline_start_date) estimated_baseline_start,
 (ppvsch.estimated_finish_date - ppe.baseline_finish_date) estimated_baseline_finish,
 to_number(NULL) planned_baseline_start,
 to_number(NULL) planned_baseline_finish,
 pa_progress_utils.calc_plan(pfxat.base_equip_hours,
                             pfxat.base_labor_hours,
                             NULL) baseline_effort
 -- Fix for Bug # 4319171.
,
 pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours,
                                                        pfxat.equipment_hours,
                                                        NULL),
                            ppru.estimated_remaining_effort,
                            ppru.eqpmt_etc_effort,
                            NULL,
                            ppru.subprj_ppl_etc_effort,
                            ppru.subprj_eqpmt_etc_effort,
                            NULL,
                            NULL,
                            pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date,
                                                       ppru.eqpmt_act_effort_to_date,
                                                       NULL,
                                                       ppru.subprj_ppl_act_effort,
                                                       ppru.subprj_eqpmt_act_effort,
                                                       NULL)) etc_effort -- Fix for Bug # 4319171.
,
 nvl(ppru.ppl_act_effort_to_date, 0) +
 nvl(ppru.eqpmt_act_effort_to_date, 0) +
 pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours, 0) +
                                  nvl(pfxat.equipment_hours, 0)),
                                  ppru.estimated_remaining_effort,
                                  ppru.eqpmt_etc_effort,
                                  NULL,
                                  ppru.subprj_ppl_etc_effort,
                                  ppru.subprj_eqpmt_etc_effort,
                                  NULL,
                                  NULL,
                                  (nvl(ppru.ppl_act_effort_to_date, 0) +
                                  nvl(ppru.eqpmt_act_effort_to_date, 0) +
                                  nvl(ppru.subprj_ppl_act_effort, 0) +
                                  nvl(ppru.subprj_eqpmt_act_effort, 0)),
                                  decode(ppwa.wp_enable_version_flag,
                                         'Y',
                                         'PUBLISH',
                                         'WORKING')) estimate_at_completion_effort,
 nvl(pfxat.base_labor_hours, 0) + nvl(pfxat.base_equip_hours, 0) -
 (nvl(ppru.ppl_act_effort_to_date, 0) +
  nvl(ppru.eqpmt_act_effort_to_date, 0) +
  pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours, 0) +
                                   nvl(pfxat.equipment_hours, 0)),
                                   ppru.estimated_remaining_effort,
                                   ppru.eqpmt_etc_effort,
                                   NULL,
                                   ppru.subprj_ppl_etc_effort,
                                   ppru.subprj_eqpmt_etc_effort,
                                   NULL,
                                   NULL,
                                   (nvl(ppru.ppl_act_effort_to_date, 0) +
                                   nvl(ppru.eqpmt_act_effort_to_date, 0) +
                                   nvl(ppru.subprj_ppl_act_effort, 0) +
                                   nvl(ppru.subprj_eqpmt_act_effort, 0)),
                                   decode(ppwa.wp_enable_version_flag,
                                          'Y',
                                          'PUBLISH',
                                          'WORKING'))) variance_at_completion_effort,
 ppru.earned_value - (nvl(ppru.ppl_act_effort_to_date, 0) +
 nvl(ppru.eqpmt_act_effort_to_date, 0)),
 round((((ppru.earned_value) - (nvl(ppru.ppl_act_effort_to_date, 0) +
       nvl(ppru.eqpmt_act_effort_to_date, 0))) /
       (decode(ppru.earned_value, 0, 1, ppru.earned_value))),
       2),
 pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc,
                            ppru.eqpmt_act_cost_to_date_pc,
                            ppru.oth_act_cost_to_date_pc,
                            NULL,
                            NULL,
                            NULL) actual_cost -- Fix for Bug # 4319171.
,
 pfxat.prj_base_brdn_cost baseline_cost,
 nvl(ppru.oth_act_cost_to_date_pc, 0) +
 nvl(ppru.ppl_act_cost_to_date_pc, 0) +
 nvl(ppru.eqpmt_act_cost_to_date_pc, 0) +
 pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost,
                                  ppru.ppl_etc_cost_pc,
                                  ppru.eqpmt_etc_cost_pc,
                                  ppru.oth_etc_cost_pc,
                                  ppru.subprj_ppl_etc_cost_pc,
                                  ppru.subprj_eqpmt_etc_cost_pc,
                                  ppru.subprj_oth_etc_cost_pc,
                                  NULL,
                                  (nvl(ppru.oth_act_cost_to_date_pc, 0) +
                                  nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                                  nvl(ppru.eqpmt_act_cost_to_date_pc, 0) +
                                  nvl(ppru.subprj_oth_act_cost_to_date_pc,
                                       0) +
                                  nvl(ppru.subprj_ppl_act_cost_pc, 0) +
                                  nvl(ppru.subprj_eqpmt_act_cost_pc, 0)),
                                  decode(ppwa.wp_enable_version_flag,
                                         'Y',
                                         'PUBLISH',
                                         'WORKING')) estimate_at_completion_cost,
 nvl(ppru.earned_value, 0) -
 (nvl(ppru.oth_act_cost_to_date_pc, 0) +
  nvl(ppru.ppl_act_cost_to_date_pc, 0) +
  nvl(ppru.eqpmt_act_cost_to_date_pc, 0)),
 round((((nvl(ppru.earned_value, 0)) -
       (nvl(ppru.oth_act_cost_to_date_pc, 0) +
       nvl(ppru.ppl_act_cost_to_date_pc, 0) +
       nvl(ppru.eqpmt_act_cost_to_date_pc, 0))) /
       (decode(ppru.earned_value, 0, 1, ppru.earned_value))),
       2),
 round((nvl(ppvsch.wq_planned_quantity, 0) -
       nvl(cumulative_work_quantity, 0)),
       2) etc_work_quantity,
 pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost, 0) /
                                       decode(nvl(cumulative_work_quantity,
                                                   0),
                                               0,
                                               1,
                                               nvl(cumulative_work_quantity,
                                                   0))),
                                       ppa.project_currency_code) planned_cost_per_unit -- 4195352
,
 pa_currency.round_trans_currency_amt1((nvl((nvl(ppru.oth_act_cost_to_date_pc,
                                                 0) + nvl(ppru.ppl_act_cost_to_date_pc,
                                                           0) +
                                            nvl(ppru.eqpmt_act_cost_to_date_pc,
                                                 0)),
                                            0) /
                                       decode(nvl(ppru.cumulative_work_quantity,
                                                   0),
                                               0,
                                               1,
                                               ppru.cumulative_work_quantity)),
                                       ppa.project_currency_code) actual_cost_per_unit -- 4195352
,
 round((nvl(nvl(ppru.cumulative_work_quantity, 0) -
            nvl(ppvsch.wq_planned_quantity, 0),
            0)),
       2) work_quantity_variance,
 round((((ppru.cumulative_work_quantity - ppvsch.wq_planned_quantity) /
       decode(nvl(ppvsch.wq_planned_quantity, 0),
                0,
                1,
                ppvsch.wq_planned_quantity)) * 100),
       2) work_quantity_variance_percent,
 ppru.earned_value earned_value,
 nvl(ppru.earned_value, 0) - nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                            ppru.object_id,
                                                            ppv.proj_element_id,
                                                            ppru.as_of_date,
                                                            ppv.parent_structure_version_id,
                                                            pppa.task_weight_basis_code,
                                                            ppe.baseline_start_date,
                                                            ppe.baseline_finish_date,
                                                            ppa.project_currency_code),
                                 0) schedule_variance,
 (nvl(ppru.earned_value, 0) - nvl((nvl(ppru.oth_act_cost_to_date_pc, 0) +
                                  nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                                  nvl(ppru.eqpmt_act_cost_to_date_pc, 0)),
                                  0)) earned_value_cost_variance,
 (nvl(ppru.earned_value, 0) - nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                             ppru.object_id,
                                                             ppe.proj_element_id,
                                                             ppru.as_of_date,
                                                             ppv.parent_structure_version_id,
                                                             pppa.task_weight_basis_code,
                                                             ppe.baseline_start_date,
                                                             ppe.baseline_finish_date,
                                                             ppa.project_currency_code),
                                  0)) earned_value_schedule_variance,
 ((nvl(pfxat.prj_base_brdn_cost, 0)) -
 (nvl(ppru.oth_act_cost_to_date_pc, 0) +
 nvl(ppru.ppl_act_cost_to_date_pc, 0) +
 nvl(ppru.eqpmt_act_cost_to_date_pc, 0) +
 pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost,
                                    ppru.ppl_etc_cost_pc,
                                    ppru.eqpmt_etc_cost_pc,
                                    ppru.oth_etc_cost_pc,
                                    ppru.subprj_ppl_etc_cost_pc,
                                    ppru.subprj_eqpmt_etc_cost_pc,
                                    ppru.subprj_oth_etc_cost_pc,
                                    NULL,
                                    (nvl(ppru.oth_act_cost_to_date_pc, 0) +
                                    nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                                    nvl(ppru.eqpmt_act_cost_to_date_pc, 0) +
                                    nvl(ppru.subprj_oth_act_cost_to_date_pc,
                                         0) +
                                    nvl(ppru.subprj_ppl_act_cost_pc, 0) +
                                    nvl(ppru.subprj_eqpmt_act_cost_pc, 0)),
                                    decode(ppwa.wp_enable_version_flag,
                                           'Y',
                                           'PUBLISH',
                                           'WORKING')))) variance_at_completion_cost,
 round(decode(ppru.task_wt_basis_code,
              'EFFORT',
              (((nvl(pfxat.base_labor_hours, 0) +
              nvl(pfxat.base_equip_hours, 0)) - ppru.earned_value) /
              decode(((nvl(pfxat.base_labor_hours, 0) +
                      nvl(pfxat.base_equip_hours, 0)) -
                      (nvl(ppru.ppl_act_effort_to_date, 0) +
                      nvl(ppru.eqpmt_act_effort_to_date, 0))),
                      0,
                      1,
                      (nvl(pfxat.base_labor_hours, 0) +
                      nvl(pfxat.base_equip_hours, 0)) -
                      (nvl(ppru.ppl_act_effort_to_date, 0) +
                      nvl(ppru.eqpmt_act_effort_to_date, 0)))) --End of Effort Value
              
              /*Cost Starts here*/,
              (nvl(pfxat.prj_base_brdn_cost, 0) - ppru.earned_value) /
              decode(nvl(pfxat.prj_base_brdn_cost, 0) -
                     (nvl(ppru.oth_act_cost_to_date_pc, 0) +
                      nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                      nvl(ppru.eqpmt_act_cost_to_date_pc, 0)),
                     0,
                     1,
                     nvl(pfxat.prj_base_brdn_cost, 0) -
                     (nvl(ppru.oth_act_cost_to_date_pc, 0) +
                      nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                      nvl(ppru.eqpmt_act_cost_to_date_pc, 0)))
              /*Computation of Cost Value ends here*/) -- End of Decode Before Round
      ,
       2) to_complete_performance_index
 /* Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
 ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
  +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
  +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
  +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)
  +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index */,
 (nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                 ppru.object_id,
                                 ppe.proj_element_id,
                                 ppru.as_of_date,
                                 ppv.parent_structure_version_id,
                                 pppa.task_weight_basis_code,
                                 ppe.baseline_start_date,
                                 ppe.baseline_finish_date,
                                 ppa.project_currency_code),
      0)) budgeted_cost_of_work_sch,
 round((nvl(ppru.earned_value, 0) /
       decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                              ppru.object_id,
                                              ppe.proj_element_id,
                                              ppru.as_of_date,
                                              ppv.parent_structure_version_id,
                                              pppa.task_weight_basis_code,
                                              ppe.baseline_start_date,
                                              ppe.baseline_finish_date,
                                              ppa.project_currency_code),
                   0),
               0,
               1,
               nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                              ppru.object_id,
                                              ppe.proj_element_id,
                                              ppru.as_of_date,
                                              ppv.parent_structure_version_id,
                                              pppa.task_weight_basis_code,
                                              ppe.baseline_start_date,
                                              ppe.baseline_finish_date,
                                              ppa.project_currency_code),
                   0))),
       2) schedule_performance_index
 /*Bug 4343962 : Included Fix similar to 4327703 */,
 round(decode(ppru.task_wt_basis_code,
              'EFFORT',
              (nvl(ppru.earned_value, 0) /
              decode((nvl(ppru.ppl_act_effort_to_date, 0) +
                      nvl(ppru.eqpmt_act_effort_to_date, 0)),
                      0,
                      1,
                      (nvl(ppru.ppl_act_effort_to_date, 0) +
                      nvl(ppru.eqpmt_act_effort_to_date, 0)))),
              (nvl(ppru.earned_value, 0) /
              decode((nvl(ppru.oth_act_cost_to_date_pc, 0) +
                      nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                      nvl(ppru.eqpmt_act_cost_to_date_pc, 0)),
                      0,
                      1,
                      (nvl(ppru.oth_act_cost_to_date_pc, 0) +
                      nvl(ppru.ppl_act_cost_to_date_pc, 0) +
                      nvl(ppru.eqpmt_act_cost_to_date_pc, 0))))),
       2) cost_performance_index
 -- Bug Fix 5150944. NAMBURI
 --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
,
 decode(ppa.structure_sharing_code,
        'SPLIT_MAPPING',
        pa_proj_struc_mapping_utils.get_mapped_fin_task_id(ppv.element_version_id,
                                                           ppa.structure_sharing_code)) mapped_financial_task,
 pa_deliverable_utils.get_associated_deliverables(ppe.proj_element_id),
 pt.gen_etc_source_code,
 pa_proj_elements_utils.get_pa_lookup_meaning('PA_TASK_LVL_ETC_SRC',
                                              pt.gen_etc_source_code),
 ppe.wf_item_type,
 ppe.wf_process,
 ppe.wf_start_lead_days,
 ppe.enable_wf_flag,
 pa_proj_struc_mapping_utils.get_mapped_fin_task_name(ppv.element_version_id,
                                                      ppa.structure_sharing_code),
 pa_progress_utils.calc_etc(pfxat.prj_brdn_cost,
                            ppru.ppl_etc_cost_pc,
                            ppru.eqpmt_etc_cost_pc,
                            ppru.oth_etc_cost_pc,
                            ppru.subprj_ppl_etc_cost_pc,
                            ppru.subprj_eqpmt_etc_cost_pc,
                            ppru.subprj_oth_etc_cost_pc,
                            NULL,
                            pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc,
                                                       ppru.eqpmt_act_cost_to_date_pc,
                                                       ppru.oth_act_cost_to_date_pc,
                                                       ppru.subprj_ppl_act_cost_pc,
                                                       ppru.subprj_eqpmt_act_cost_pc,
                                                       ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
 -- Fix for Bug # 4319171.
,
 ppru.progress_rollup_id,
 ppru.base_percent_complete --Bug 4416432 Issue 2
,
 nvl(pfxat.labor_hours, 0) + nvl(pfxat.equipment_hours, 0) -
 (nvl(pfxat.base_labor_hours, 0) + nvl(pfxat.base_equip_hours, 0)) planned_baseline_effort_var -- Added  for bug 5090355
,
 nvl(pfxat.prj_brdn_cost, 0) - nvl(pfxat.prj_base_brdn_cost, 0) planned_baseline_cost_var -- Added  for bug 5090355
  FROM pa_proj_elem_ver_structure ppvs
       --,ra_addresses_all addr
      ,
       hz_cust_acct_sites_all       s,
       hz_party_sites               ps,
       hz_locations                 addr,
       pa_proj_elem_ver_schedule    ppvsch,
       per_all_people_f             papf,
       pa_project_statuses          pps2,
       hr_all_organization_units_tl hou,
       pa_projects_all              ppa,
       pa_proj_structure_types      ppst,
       pa_structure_types           pst,
       pa_work_types_tl             pwt,
       pa_task_types                tt,
       pa_project_statuses          pps3,
       pa_page_layouts              ppl,
       pa_progress_rollup           ppru
       -----,pa_percent_completes ppc
      ,
       pa_project_statuses      pps,
       pa_project_statuses      pps5,
       pa_proj_elements         ppe5,
       pa_proj_element_versions ppv5,
       pa_proj_workplan_attr    ppwa,
       pa_proj_element_versions ppev6,
       pa_proj_progress_attr    pppa,
       pa_proj_element_versions ppv2,
       pa_tasks                 pt,
       pa_proj_elements         ppe,
       pa_proj_element_versions ppv,
       pa_object_relationships  por,
       pa_proj_elements         ppeph,
       pa_proj_element_versions ppevph,
       pji_fm_xbs_accum_tmp1    pfxat
 WHERE ppe.proj_element_id = ppv.proj_element_id
   AND ppv.parent_structure_version_id = ppvs.element_version_id
   AND ppv.project_id = ppvs.project_id
   AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
   AND ppv.element_version_id = ppvsch.element_version_id(+)
   AND ppv.project_id = ppvsch.project_id(+)
   AND ppv.element_version_id = por.object_id_to1
   AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
   AND ppe.manager_person_id = papf.person_id(+)
   AND ppe.object_type = 'PA_TASKS'
   AND SYSDATE BETWEEN papf.effective_start_date(+) AND
       papf.effective_end_date(+)
   AND ppe.status_code = pps2.project_status_code(+)
   AND ppe.carrying_out_organization_id = hou.organization_id(+)
   AND userenv('LANG') = hou.language(+)
   AND ppe.project_id = ppa.project_id
   AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
   AND por.object_id_from1 = ppv2.element_version_id(+)
   AND ppe.proj_element_id = ppst.proj_element_id(+)
   AND pst.structure_type_id(+) = ppst.structure_type_id
   AND por.relationship_type = 'S'
   AND (ppe.link_task_flag <> 'Y' OR ppe.task_status IS NOT NULL)
   AND ppv.proj_element_id = pt.task_id(+)
   AND pt.work_type_id = pwt.work_type_id(+)
   AND pwt.language(+) = userenv('lang')
   AND tt.task_type_id = ppe.type_id
   AND tt.object_type = 'PA_TASKS'
   AND ppe.status_code = pps3.project_status_code(+)
   AND pps3.status_type(+) = 'TASK'
      --AND pt.address_id = addr.address_id (+)
   AND pt.address_id = s.cust_acct_site_id(+)
   AND ps.party_site_id(+) = s.party_site_id
   AND addr.location_id(+) = ps.location_id
   AND ppe.task_progress_entry_page_id = ppl.page_id(+)
   AND ppv.project_id = ppru.project_id(+)
   AND ppv.proj_element_id = ppru.object_id(+)
   AND ppv.object_type = ppru.object_type(+)
   AND ppru.structure_type(+) = 'WORKPLAN'
      -- Begin fix for Bug # 4499065.
   AND ppru.current_flag(+) <> 'W' -----= 'Y' (changed to <> 'W' condition)
   AND ppru.object_version_id(+) = ppv.element_version_id
   AND nvl(ppru.as_of_date, trunc(SYSDATE)) =
       (SELECT /*+  INDEX (ppr2 pa_progress_rollup_u2)*/
         nvl(MAX(ppr2.as_of_date), trunc(SYSDATE)) --Bug 7644130
          FROM pa_progress_rollup ppr2
         WHERE ppr2.object_id = ppv.proj_element_id
           AND ppr2.proj_element_id = ppv.proj_element_id
           AND ppr2.object_version_id = ppv.element_version_id
           AND ppr2.project_id = ppv.project_id
           AND ppr2.object_type = 'PA_TASKS'
           AND ppr2.structure_type = 'WORKPLAN'
           AND ppr2.structure_version_id IS NULL
           AND ppr2.current_flag <> 'W')
      -- End fix for Bug # 4499065.
   AND ppru.structure_version_id(+) IS NULL
   AND nvl(ppru.progress_status_code, ppru.eff_rollup_prog_stat_code) =
       pps.project_status_code(+)
      ---AND ppc.project_id (+) = ppru.project_id
   AND 'PA_TASKS' = ppru.object_type(+)
      ---AND ppc.object_id (+) = ppru.object_id
      ---AND ppc.date_computed (+) = ppru.as_of_date
   AND ppe.phase_version_id = ppv5.element_version_id(+)
   AND ppv5.proj_element_id = ppe5.proj_element_id(+)
   AND ppe5.phase_code = pps5.project_status_code(+)
   AND ppe.project_id <> 0
   AND ppv.parent_structure_version_id = ppev6.element_version_id(+)
   AND ppev6.proj_element_id = ppwa.proj_element_id(+)
   AND ppev6.project_id = pppa.project_id(+)
   AND 'PA_STRUCTURES' = pppa.object_type(+)
   AND ppev6.proj_element_id = pppa.object_id(+)
   AND ppwa.current_phase_version_id = ppevph.element_version_id(+)
   AND ppevph.proj_element_id = ppeph.proj_element_id(+)
   AND pfxat.project_id(+) = ppv.project_id
   AND pfxat.project_element_id(+) = ppv.proj_element_id
   AND pfxat.struct_version_id(+) = ppv.parent_structure_version_id
   AND pfxat.calendar_type(+) = 'A'
   AND pfxat.plan_version_id(+) > 0
   AND pfxat.txn_currency_code(+) IS NULL 
   AND pppa.structure_type(+) = 'WORKPLAN'
      ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4190747.
      ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4190747.
      ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4216980.
      AND ppa.project_id =  1194
      AND PT.TASK_ID IN (761130)
      --( 182178,182272)
       
      ;
   AND ppa.project_id = p_project_id
   AND ppv.parent_structure_version_id = p_structure_version_id
   AND por.object_id_from1 = p_task_version_id;
