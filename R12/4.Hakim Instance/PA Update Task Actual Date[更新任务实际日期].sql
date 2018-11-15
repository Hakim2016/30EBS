DECLARE
  l_project_number     pa_projects_all.segment1%TYPE;
  l_task_number        pa_tasks.task_number%TYPE;
  l_task_id            NUMBER;
  l_return_status      VARCHAR2(1);
  l_msg_data           VARCHAR2(32767);
  l_percent_completes  NUMBER;
  l_actual_start_date  DATE;
  l_actual_finish_date DATE;

  FUNCTION func_get_task_code(p_task_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_status_code VARCHAR2(100);
  BEGIN
    SELECT pps.project_status_code
      INTO l_status_code
      FROM pa_project_statuses pps
     WHERE 1 = 1
       AND pps.status_type = 'TASK'
       AND trunc(SYSDATE) BETWEEN nvl(pps.start_date_active, trunc(SYSDATE)) AND
           nvl(pps.end_date_active, trunc(SYSDATE))
       AND pps.project_status_name = p_task_name;
    RETURN l_status_code;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END func_get_task_code;

  PROCEDURE update_task_actual(x_return_status      OUT VARCHAR2,
                               x_msg_data           OUT VARCHAR2,
                               p_task_id            IN NUMBER,
                               p_percent_completes  IN NUMBER := pa_interface_utils_pub.g_pa_miss_num,
                               p_actual_start_date  IN DATE := pa_interface_utils_pub.g_pa_miss_date,
                               p_actual_finish_date IN DATE := pa_interface_utils_pub.g_pa_miss_date) IS
    l_project_id         NUMBER;
    l_element_version_id NUMBER;
    l_latest_wp_version  NUMBER;
    l_task_status        pa_proj_elements.status_code%TYPE;
    l_percent_completes  NUMBER;
    l_as_of_date         DATE;
  
    -- 
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_data      VARCHAR2(2000);
    l_idx       NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  
    SELECT ppv.project_id,
           ppv.element_version_id,
           ppv.parent_structure_version_id
      INTO l_project_id,
           l_element_version_id,
           l_latest_wp_version
      FROM apps.pa_proj_element_versions ppv
     WHERE 1 = 1
       AND ppv.proj_element_id = p_task_id
       AND ppv.parent_structure_version_id = pa_project_structure_utils.get_latest_wp_version(ppv.project_id);
    l_percent_completes := p_percent_completes;
    IF p_percent_completes >= 100 THEN
      l_task_status       := func_get_task_code(p_task_name => 'Completed'); -- xxpjm_status_pub.g_tsk_sts_completed;
      l_percent_completes := 100;
    ELSIF p_percent_completes < 100 AND p_percent_completes > 0 THEN
      l_task_status := func_get_task_code(p_task_name => 'In Progress'); -- xxpjm_status_pub.g_tsk_sts_in_progress;
    
    ELSE
      l_task_status := func_get_task_code(p_task_name => 'Not Started'); -- xxpjm_status_pub.g_tsk_sts_not_started;
    END IF;
  
    SELECT pa_progress_utils.as_of_date(ppe.project_id, ppe.proj_element_id, ppp.progress_cycle_id, ppe.object_type)
      INTO l_as_of_date
      FROM pa_proj_elements         ppe,
           pa_proj_progress_attr    ppp,
           pa_proj_element_versions ppv
     WHERE ppe.project_id = ppp.project_id(+)
       AND 'WORKPLAN' = ppp.structure_type(+)
       AND ppe.proj_element_id = ppv.proj_element_id
       AND ppv.element_version_id = l_element_version_id;
  
    -- dbms_output.put_line(l_as_of_date);
  
    -- Call Standard API
    pa_status_pub.update_progress(p_api_version_number => 1.0,
                                  p_init_msg_list      => fnd_api.g_true,
                                  p_commit             => fnd_api.g_false,
                                  p_return_status      => x_return_status,
                                  p_msg_count          => l_msg_count,
                                  p_msg_data           => x_msg_data,
                                  p_project_id         => l_project_id,
                                  p_task_id            => l_task_id,
                                  p_as_of_date         => l_as_of_date,
                                  p_actual_start_date  => p_actual_start_date,
                                  p_actual_finish_date => p_actual_finish_date,
                                  p_percent_complete   => l_percent_completes,
                                  p_object_id          => l_task_id,
                                  p_object_version_id  => l_element_version_id,
                                  p_object_type        => 'PA_TASKS',
                                  p_task_status        => l_task_status,
                                  p_structure_type     => 'WORKPLAN');
  
    FOR i IN 1 .. nvl(l_msg_count, 0)
    LOOP
      pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                          p_msg_index     => i,
                                          p_msg_count     => l_msg_count,
                                          p_msg_data      => l_msg_data,
                                          p_data          => l_data,
                                          p_msg_index_out => l_idx);
      x_msg_data := x_msg_data || substrb(l_data, 1, 200);
    END LOOP;
  
    dbms_output.put_line(' x_return_status : ' || x_return_status);
    dbms_output.put_line(' l_msg_count     : ' || l_msg_count);
    dbms_output.put_line(' x_msg_data      : ' || x_msg_data);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := x_msg_data || 'Calling update_schedule_version Occurred Error SQLERRM : ' || SQLERRM;
  END update_task_actual;

BEGIN
  l_project_number := '10203019';
  l_task_number    := 'XN0854-EL1.F.12';
  fnd_global.apps_initialize(user_id      => 2657, -- 1393, --
                             resp_id      => 50676, --
                             resp_appl_id => 660);
  mo_global.init(fnd_global.application_short_name);

  SELECT pt.task_id
    INTO l_task_id
    FROM pa_projects_all ppa,
         pa_tasks        pt
   WHERE ppa.project_id = pt.project_id
     AND ppa.segment1 = l_project_number
     AND pt.task_number = l_task_number;
  --l_task_id           := -1;
  l_percent_completes  := 63.34;
  l_actual_start_date  := to_date('29-Dec-2013', 'DD-Mon-YYYY');
  l_actual_finish_date := NULL; --to_date('2014-11-13', 'YYYY-MM-DD');

  update_task_actual(x_return_status      => l_return_status, --
                     x_msg_data           => l_msg_data, --
                     p_task_id            => l_task_id, --
                     p_percent_completes  => l_percent_completes, --
                     p_actual_start_date  => l_actual_start_date, --
                     p_actual_finish_date => l_actual_finish_date);

  dbms_output.put_line(' l_return_status : ' || l_return_status);
  dbms_output.put_line(' l_msg_data      : ' || l_msg_data);

END;
/

-- Check Result
  SELECT t.task_id,
         t.element_version_id,
         t.parent_structure_version_id,
         t.actual_start_date,
         t.actual_finish_date,
         t.percent2,
         t.element_number,
         t.project_status_name
    FROM (SELECT ppv.element_version_id,
                 ppv.project_id,
                 pa.task_id,
                 pa.parent_task_id,
                 ppv.parent_structure_version_id,
                 ppv.wbs_number,
                 ppv.object_type,
                 ppv.wbs_level,
                 ppe.element_number,
                 ppe.name,
                 pps.project_status_name,
                 nvl(ppr.completed_percentage, ppr.eff_rollup_percent_comp) percent2,
                 sch.scheduled_start_date,
                 sch.scheduled_finish_date,
                 sch.estimated_start_date,
                 sch.estimated_finish_date,
                 sch.actual_start_date,
                 sch.actual_finish_date,
                 pa.attribute1 part_task,
                 pa.attribute3 task_type,
                 pa.attribute5 er_claim_item
          
            FROM pa_proj_element_versions   ppv,
                 pa_proj_elem_ver_structure ppvs,
                 pa_progress_rollup         ppr,
                 pa_proj_elem_ver_schedule  sch,
                 pa_proj_elements           ppe,
                 pa_project_statuses        pps,
                 pa_tasks                   pa
          
           WHERE ppv.parent_structure_version_id = ppvs.element_version_id
             AND ppv.project_id = ppvs.project_id
             AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
             AND ppv.project_id = sch.project_id
             AND ppv.element_version_id = sch.element_version_id
             AND ppv.proj_element_id = ppe.proj_element_id
             AND ppe.status_code = pps.project_status_code
             AND ppv.object_type = 'PA_TASKS'
             AND ppv.project_id = pa.project_id
             AND ppe.element_number = pa.task_number
             AND ppr.current_flag(+) != 'W'
             AND ppr.project_id(+) = ppv.project_id
             AND ppr.object_id(+) = ppv.proj_element_id
             AND ppr.structure_type(+) = 'WORKPLAN'
             AND ppr.structure_version_id(+) IS NULL
             AND ppr.object_version_id(+) <= ppv.element_version_id
             AND nvl(ppr.as_of_date, trunc(SYSDATE)) =
                 (SELECT nvl(MAX(ppr2.as_of_date), trunc(SYSDATE))
                    FROM pa_progress_rollup         ppr2,
                         pa_proj_element_versions   ppev,
                         pa_proj_elem_ver_structure ppevs
                   WHERE ppr2.object_id = ppv.proj_element_id
                     AND ppr2.proj_element_id = ppv.proj_element_id
                     AND ppr2.project_id = ppv.project_id
                     AND ppr2.object_type = ppv.object_type
                     AND ppr2.structure_type = 'WORKPLAN'
                     AND ppr2.structure_version_id IS NULL
                     AND ppr2.current_flag <> 'W'
                     AND ppr2.object_version_id = ppev.element_version_id
                     AND ppevs.project_id = ppev.project_id
                     AND ppevs.element_version_id = ppev.parent_structure_version_id
                     AND ppevs.status_code = 'STRUCTURE_PUBLISHED'
                     AND ppevs.published_date <= ppvs.published_date)
          
          UNION ALL
          
          SELECT ppv.element_version_id,
                 ppv.project_id,
                 pa.task_id,
                 pa.parent_task_id,
                 ppv.parent_structure_version_id,
                 ppv.wbs_number,
                 ppv.object_type,
                 ppv.wbs_level,
                 ppe.element_number,
                 ppe.name,
                 pps.project_status_name,
                 nvl(ppr.completed_percentage, ppr.eff_rollup_percent_comp) percent2,
                 sch.scheduled_start_date,
                 sch.scheduled_finish_date,
                 sch.estimated_start_date,
                 sch.estimated_finish_date,
                 sch.actual_start_date,
                 sch.actual_finish_date,
                 pa.attribute1 part_task,
                 pa.attribute3 task_type,
                 pa.attribute5 er_claim_item
          
            FROM pa_proj_element_versions   ppv,
                 pa_proj_elem_ver_structure ppvs,
                 pa_progress_rollup         ppr,
                 pa_proj_elem_ver_schedule  sch,
                 pa_proj_elements           ppe,
                 pa_project_statuses        pps,
                 pa_tasks                   pa
          
           WHERE ppv.parent_structure_version_id = ppvs.element_version_id
             AND ppv.project_id = ppvs.project_id
             AND ppvs.status_code != 'STRUCTURE_PUBLISHED'
             AND ppv.project_id = sch.project_id
             AND ppv.element_version_id = sch.element_version_id
             AND ppv.proj_element_id = ppe.proj_element_id
             AND ppe.status_code = pps.project_status_code
             AND ppv.object_type = 'PA_TASKS'
             AND ppv.project_id = pa.project_id
             AND ppe.element_number = pa.task_number
             AND ppr.project_id(+) = ppv.project_id
             AND ppr.object_id(+) = ppv.proj_element_id
             AND ppr.structure_type(+) = 'WORKPLAN'
             AND ppr.current_flag(+) = 'Y'
             AND ppr.structure_version_id(+) = ppv.parent_structure_version_id
             AND ppr.object_version_id(+) = ppv.element_version_id) t,
         pa_projects_all ppa,
         pa_tasks pt
   WHERE t.task_id = pt.task_id
     AND t.project_id = pt.project_id
     AND pt.project_id = ppa.project_id
     AND ppa.segment1 = '10203019'
     AND pt.task_number = 'XN0854-EL1.F.12'
   ORDER BY t.task_id,
            t.element_version_id;
