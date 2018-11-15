SELECT pa_project_structure_utils.get_latest_wp_version(pt.project_id) lastest_ver,
       pa_project_structure_utils.get_current_working_ver_id(pt.project_id) current_ver,
       xtd.parent_structure_version_id,
       pt.task_id,
       ppa.segment1,
       --pt.wbs_level,
       xtd.wbs_number,
       lpad(' ', xtd.wbs_level * 6, '  ') || pt.task_number task_number,
       xxpjm_install_sch_update_pkg.fun_has_child_task_flag(pt.task_id) has_child_flag,
       xxpjm_install_sch_update_pkg.isautocaculate(pt.task_id) autocaculate,
       xxpjm_install_sch_update_pkg.get_progress_info(xtd.project_id, xtd.task_id, 'PERCENT') autopercent,
       xxpjm_install_sch_update_pkg.get_progress_info(xtd.project_id, xtd.task_id, 'ACTUAL_START_DATE') auto_actual_start,
       xxpjm_install_sch_update_pkg.get_progress_info(xtd.project_id, xtd.task_id, 'ACTUAL_FINISH_DATE') auto_actual_start,
       xtd.percent2,
       xtd.actual_start_date,
       xtd.actual_finish_date,
       pt.attribute3,
       xtd.task_type,
       pt.task_name
  FROM (SELECT t.project_id,
               t.task_id,
               t.wbs_level,
               t.task_number,
               t.task_name,
               t.attribute3
          FROM pa_tasks t
         START WITH t.project_id = 306253
                --AND t.task_id = 1685565                   
                AND t.task_number = 'SAA0067-HR.EQ'--'SHA0042-SG.N'--'SAA0067-HR.EQ'
        CONNECT BY PRIOR t.task_id = t.parent_task_id) pt,
       --pa_proj_element_versions ppev,
       xxpjm_task_dtls_v xtd,
       pa_projects_all   ppa
 WHERE 1 = 1
   AND pt.task_id = xtd.task_id
   AND pt.project_id = xtd.project_id
      -- AND xtd.parent_structure_version_id = pa_project_structure_utils.get_latest_wp_version(pt.project_id)
   AND xtd.object_type = 'PA_TASKS'
   AND xtd.project_id = 306253
      --AND pt.task_id = 1685565
   AND pt.project_id = ppa.project_id
 ORDER BY xtd.parent_structure_version_id;

SELECT *
  FROM pa_projects_all ppa
 WHERE ppa.segment1 = '13123001'
