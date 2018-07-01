DECLARE

  l_structure_version_id pa_proj_elem_ver_structure.element_version_id%TYPE;
  l_parent_task_number   pa_tasks.task_number%TYPE;
  l_parent_task_name     pa_tasks.task_name%TYPE;
  l_parent_task_id       pa_tasks.parent_task_id%TYPE;
  l_project_id           pa_tasks.project_id%TYPE;
  l_task_number          pa_tasks.task_number%TYPE;
  l_task_name            pa_tasks.task_name%TYPE;
  l_task_id              pa_tasks.task_id%TYPE;
  l_project_number       pa_projects_all.segment1%TYPE;
  l_task_type_id         pa_task_types.task_type_id%TYPE;
  x_task_id              pa_tasks.task_id%TYPE;
  x_return_status        VARCHAR2(1);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);

  PROCEDURE add_proj_task(p_project_id            NUMBER,
                          p_structure_version_id  NUMBER,
                          p_task_name             VARCHAR2,
                          p_task_number           VARCHAR2,
                          p_task_description      VARCHAR2 := pa_interface_utils_pub.g_pa_miss_char,
                          p_scheduled_start_date  DATE := pa_interface_utils_pub.g_pa_miss_date,
                          p_scheduled_finish_date DATE := pa_interface_utils_pub.g_pa_miss_date,
                          p_parent_task_id        NUMBER,
                          p_task_type             NUMBER,
                          x_task_id               OUT NUMBER,
                          x_return_status         OUT VARCHAR2,
                          x_msg_count             OUT NUMBER,
                          x_msg_data              OUT VARCHAR2) IS
    x_project_id     NUMBER;
    x_project_number pa_projects_all.segment1%TYPE;
    l_index          NUMBER;
    l_data           VARCHAR2(1000);
    l_msg_data       VARCHAR2(2000);
  BEGIN
  
    pa_project_pub.add_task(p_api_version_number    => 1.0,
                            p_msg_count             => x_msg_count,
                            p_msg_data              => x_msg_data,
                            p_return_status         => x_return_status,
                            p_pm_product_code       => NULL,
                            p_pa_project_id         => p_project_id,
                            p_pm_task_reference     => p_task_name || p_parent_task_id,
                            p_pa_task_number        => p_task_number,
                            p_task_name             => p_task_name,
                            p_task_description      => p_task_description,
                            p_scheduled_start_date  => p_scheduled_start_date,
                            p_scheduled_finish_date => p_scheduled_finish_date,
                            p_pa_parent_task_id     => p_parent_task_id,
                            p_structure_version_id  => p_structure_version_id,
                            --p_financial_task_flag  => 'Y',
                            p_structure_type        => 'WORKPLAN',
                            p_pa_project_id_out     => x_project_id,
                            p_pa_project_number_out => x_project_number,
                            p_task_type             => p_task_type,
                            p_task_id               => x_task_id);
    --dbms_output.put_line(' x_msg_count : ' || x_msg_count);
    FOR i IN 0 .. nvl(x_msg_count, 0)
    LOOP
      --dbms_output.put_line('- enter to get message');
      pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                          p_msg_index     => i,
                                          p_msg_count     => x_msg_count,
                                          p_msg_data      => l_msg_data,
                                          p_data          => l_data,
                                          p_msg_index_out => l_index);
      l_msg_data := l_msg_data || l_data;
    END LOOP;
    x_msg_data := l_msg_data;
  END add_proj_task;

BEGIN

  mo_global.init(p_appl_short_name => 'PA');
  fnd_global.apps_initialize(user_id => 2657, resp_id => 50676, resp_appl_id => 660);
  --mo_global.set_policy_context('S', 82);
  fnd_msg_pub.initialize;
  l_parent_task_number := 'ST00910-TH.H';
  SELECT pt.project_id,
         pt.task_id,
         pt.task_name,
         ppa.segment1
    INTO l_project_id,
         l_parent_task_id,
         l_parent_task_name,
         l_project_number
    FROM pa_tasks        pt,
         pa_projects_all ppa
   WHERE pt.task_number = l_parent_task_number
     AND pt.project_id = ppa.project_id;
  l_task_number          := xxpjm_project_public.get_new_task_number(p_parent_task_id => l_parent_task_id);
  l_structure_version_id := pa_project_structure_utils.get_current_working_ver_id(p_project_id => l_project_id);

  -- task type same with parent task
  SELECT ppe.type_id
    INTO l_task_type_id
    FROM pa_proj_elements ppe,
         pa_task_types    ptt
   WHERE 1 = 1
     AND ppe.type_id = ptt.task_type_id
     AND ppe.element_number = l_parent_task_number
     AND ppe.project_id = l_project_id;

  l_task_name := substrb(l_parent_task_name || ' - Sub', -10);
  
  dbms_output.put_line(' l_parent_task_name  - Sub            : ' || l_parent_task_name || ' - Sub');
  dbms_output.put_line(' l_project_id            : ' || l_project_id);
  dbms_output.put_line(' l_project_number        : ' || l_project_number);
  dbms_output.put_line(' l_structure_version_id  : ' || l_structure_version_id);
  dbms_output.put_line(' l_parent_task_id        : ' || l_parent_task_id);
  dbms_output.put_line(' l_parent_task_number    : ' || l_parent_task_number);
  dbms_output.put_line(' l_parent_task_name      : ' || l_parent_task_name);
  dbms_output.put_line(' l_task_number           : ' || l_task_number);
  dbms_output.put_line(' l_task_name             : ' || l_task_name);
  dbms_output.put_line(' l_task_type_id          : ' || l_task_type_id);

  add_proj_task(p_project_id           => l_project_id,
                p_structure_version_id => pa_project_structure_utils.get_current_working_ver_id(l_project_id), -- x_dest_structure_version_id,
                p_task_name            => l_task_name,
                p_task_number          => l_task_number,
                p_parent_task_id       => l_parent_task_id,
                p_task_type            => l_task_type_id,
                x_task_id              => x_task_id,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data);

  dbms_output.put_line(' ------------------------- After invoking API -------------------------');
  dbms_output.put_line('      x_task_id         : ' || x_task_id);
  dbms_output.put_line('      x_return_status   : ' || x_return_status);
  dbms_output.put_line('      x_msg_count       : ' || x_msg_count);
  dbms_output.put_line('      x_msg_data        : ' || x_msg_data);

  /*  FOR l_index IN 1 .. 30
  LOOP
    x_msg_data := fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
    dbms_output.put_line(' x_msg_data ' || l_index || ' : ' || x_msg_data);
  END LOOP;*/
END;
/

DECLARE x_msg_data VARCHAR2(2000);
BEGIN
  FOR l_index IN 1 .. 5
  LOOP
    x_msg_data := fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
    dbms_output.put_line(' x_msg_data ' || l_index || ' : ' || x_msg_data);
  END LOOP;
END;
/

SELECT *
  FROM dba_objects do
 WHERE 1 = 1
   AND do.object_name LIKE 'PA%STRUCT%'
   AND do.object_type IN ('TABLE', 'VIEW');

SELECT *
  FROM pa_proj_elem_ver_structure t
 WHERE t.project_id = 533666;
