SELECT pt_mfg.task_number,xtdv.completed_percentage,
xtdv.*,
ppev.*
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
   AND pt_mfg.task_number IN ('SFA0775-SG','SBK0510-SG') --p_mfg_no
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
   AND ppa.project_id = 2207196 --p_project_id
      --AND xtdv.cliam_task              = 'Y'
   AND xtdv.task_type = 'Installation' --p_task_type
;


/*CURSOR csr_percent IS*/
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
             AND pt_mfg.task_number = 'SBK0508-SG' --p_mfg_no
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
             AND ppa.project_id = 2207196 --p_project_id
                --AND xtdv.cliam_task              = 'Y'
             AND xtdv.task_type = 'Installation' --p_task_type
          UNION ALL
          SELECT t.installation_progress completed_percentage
            FROM xxpa_mfg_ed_handover_info_t t,
                 pa_tasks                    pt
           WHERE 1 = 1
             AND t.project_id = 2207196 --p_project_id
             AND pt.project_id = t.project_id
             AND t.task_id = pt.task_id
             AND pt.task_number = 'SBK0508-SG' --p_mfg_no
          )
         ORDER BY completed_percentage;


SELECT *
  FROM xxpa_mfg_ed_handover_info_t xx
 WHERE 1 = 1; --AND
