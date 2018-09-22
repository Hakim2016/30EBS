/*CURSOR csr_percent IS*/

SELECT ppa.segment1,
       pt_mfg.task_number,
       xtdv.task_type,
       xtdv.completed_percentage/*,
       (SELECT *
          FROM pa_progress_rollup ppr
         WHERE 1 = 1 AND ppr.progress_rollup_id = )*/
--,     xtdv.period_date
  FROM pa_proj_element_versions ppev,
       pa_projects_all          ppa,
       pa_project_types_all     ppt,
       pa_proj_elements         ppe,
       pa_tasks                 pt,
       pa_tasks                 pt_mfg,
       xxpa_task_dtls_v         xtdv,
       pa_tasks                 pt2
 WHERE 1 = 1
   AND ppev.project_id = ppa.project_id
   AND ppev.proj_element_id = ppe.proj_element_id
   AND ppev.object_type = 'PA_TASKS'
   AND ppev.wbs_level = 1
   AND ppev.project_id = pt.project_id
   AND pt.project_id = pt_mfg.project_id
   AND pt.top_task_id = pt_mfg.task_id
   AND pt_mfg.task_number = 'SBG0231-SG' --'SFA0776-SG' --p_mfg_no
   AND ppe.element_number = pt.task_number
   AND ppev.parent_structure_version_id = xxpa_utils.get_structure_version_id2(ppev.project_id)
   AND xtdv.project_id(+) = ppev.project_id
   AND xtdv.parent_structure_version_id(+) = ppev.parent_structure_version_id
   AND ppa.project_type = ppt.project_type
   AND ppa.org_id = ppt.org_id
   AND xtdv.task_id = pt2.task_id
   AND pt2.top_task_id = pt_mfg.task_id
   AND ppt.project_type_class_code = 'CONTRACT'
      --AND ppa.project_id = 2207196 --p_project_id
   AND ppa.segment1 = '11001297'
      --AND xtdv.cliam_task              = 'Y'
   AND xtdv.task_type = 'Installation' --p_task_type
;
SELECT completed_percentage
  FROM (SELECT xtdv.completed_percentage
        --,     xtdv.period_date
          FROM pa_proj_element_versions ppev,
               pa_projects_all          ppa,
               pa_project_types_all     ppt,
               pa_proj_elements         ppe,
               pa_tasks                 pt,
               pa_tasks                 pt_mfg,
               xxpa_task_dtls_v         xtdv,
               pa_tasks                 pt2
         WHERE ppev.project_id = ppa.project_id
           AND ppev.proj_element_id = ppe.proj_element_id
           AND ppev.object_type = 'PA_TASKS'
           AND ppev.wbs_level = 1
           AND ppev.project_id = pt.project_id
           AND pt.project_id = pt_mfg.project_id
           AND pt.top_task_id = pt_mfg.task_id
           AND pt_mfg.task_number = 'SBG0231-SG' --'SFA0776-SG' --p_mfg_no
           AND ppe.element_number = pt.task_number /*
                                                                                                                                                                                                         AND ppev.parent_structure_version_id = nvl(pa_project_structure_utils.get_latest_wp_version(ppev.project_id),
                                                                                                                                                                                                                                                    pa_project_structure_utils.get_current_working_ver_id(ppev.project_id)) */
           AND ppev.parent_structure_version_id = xxpa_utils.get_structure_version_id2(ppev.project_id)
           AND xtdv.project_id(+) = ppev.project_id
              --AND xtdv.wbs_number(+) LIKE to_char(ppev.wbs_number) ||'%'
           AND xtdv.parent_structure_version_id(+) = ppev.parent_structure_version_id
           AND ppa.project_type = ppt.project_type
           AND ppa.org_id = ppt.org_id
           AND xtdv.task_id = pt2.task_id
           AND pt2.top_task_id = pt_mfg.task_id
           AND ppt.project_type_class_code = 'CONTRACT'
              --AND ppa.project_id = 2207196 --p_project_id
           AND ppa.segment1 = '11001297'
              --AND xtdv.cliam_task              = 'Y'
           AND xtdv.task_type = 'Installation' --p_task_type
        /*UNION ALL
        SELECT t.installation_progress completed_percentage
          FROM xxpa_mfg_ed_handover_info_t t,
               pa_tasks                    pt
         WHERE 1 = 1
           AND t.project_id = 2207196 --p_project_id
           AND pt.project_id = t.project_id
           AND t.task_id = pt.task_id
           AND pt.task_number = 'SFA0776-SG' --p_mfg_no
           */
        )
 ORDER BY completed_percentage;

SELECT *
  FROM xxpa_task_dtls_v xx
 WHERE 1 = 1
   AND xx.project_id = 2207196
--AND xx.task_type LIKE 'H%'
;

SELECT *
  FROM xxpa_mfg_ed_handover_info_t xx
 WHERE 1 = 1
   AND xx.project_id = 2207196
--AND xx.task_id = 5724679
;

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
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/
