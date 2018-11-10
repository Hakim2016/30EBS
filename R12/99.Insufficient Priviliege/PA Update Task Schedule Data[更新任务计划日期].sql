-- Update Task Schedule Date
DECLARE
  c_datetime_format CONSTANT VARCHAR2(21) := 'DD-MON-YY HH24:MI:SS';
  x_return_status VARCHAR2(1);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(4000);

  l_task_id               pa_tasks.task_id%TYPE;
  l_task_number           pa_tasks.task_number%TYPE;
  l_element_version_id    pa_proj_element_versions.element_version_id%TYPE;
  l_pev_schedule_id       pa_proj_elem_ver_schedule.pev_schedule_id%TYPE;
  l_record_version_number pa_proj_elem_ver_schedule.record_version_number%TYPE;
  l_scheduled_start_date  pa_proj_elem_ver_schedule.scheduled_start_date%TYPE;
  l_scheduled_finish_date pa_proj_elem_ver_schedule.scheduled_finish_date%TYPE;

  PROCEDURE update_schedule_version(p_pev_schedule_id       IN NUMBER,
                                    p_record_version_number IN NUMBER,
                                    p_scheduled_start_date  IN DATE := pa_interface_utils_pub.g_pa_miss_date,
                                    p_scheduled_end_date    IN DATE := pa_interface_utils_pub.g_pa_miss_date,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'Update_Schedule_Version';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    x_project_id NUMBER;
    x_task_id    NUMBER;
    l_index      NUMBER;
    l_data       VARCHAR2(1000);
  BEGIN
    pa_task_pub1.update_schedule_version(p_pev_schedule_id       => p_pev_schedule_id,
                                         p_scheduled_start_date  => p_scheduled_start_date,
                                         p_scheduled_end_date    => p_scheduled_end_date,
                                         p_record_version_number => p_record_version_number,
                                         x_return_status         => x_return_status,
                                         x_msg_count             => x_msg_count,
                                         x_msg_data              => x_msg_data);
    FOR i IN 1 .. nvl(x_msg_count, 0)
    LOOP
      pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                          p_msg_index     => i,
                                          p_msg_count     => x_msg_count,
                                          p_msg_data      => x_msg_data,
                                          p_data          => l_data,
                                          p_msg_index_out => l_index);
      x_msg_data := substrb(x_msg_data || l_data, 1, 255);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'Calling update_schedule_version Occurred Error ' || SQLERRM;
  END update_schedule_version;

BEGIN
  --fnd_global.apps_initialize(user_id => 2657, resp_id => 50676, resp_appl_id => 660);
  --mo_global.init(p_appl_short_name => 'PA');
  --mo_global.set_policy_context('S',82);
 
  l_task_number := 'ST00910-TH.A';
  -- Step 1
  SELECT pt.task_id,
         pev.element_version_id
    INTO l_task_id,
         l_element_version_id
    FROM pa_proj_element_versions pev,
         pa_tasks                 pt
   WHERE pev.proj_element_id = pt.task_id
     AND pev.parent_structure_version_id = pa_project_structure_utils.get_current_working_ver_id(pev.project_id) --newest current woking 
     AND pt.task_number = l_task_number;

  dbms_output.put_line(' Step 1 - l_task_number        : ' || l_task_number);
  dbms_output.put_line(' Step 1 - l_task_id            : ' || l_task_id);
  dbms_output.put_line(' Step 1 - l_element_version_id : ' || l_element_version_id);

  -- Step 2
  SELECT sch.pev_schedule_id,
         sch.record_version_number,
         sch.scheduled_start_date,
         sch.scheduled_finish_date
    INTO l_pev_schedule_id,
         l_record_version_number,
         l_scheduled_start_date,
         l_scheduled_finish_date
    FROM pa.pa_proj_elem_ver_schedule sch
   WHERE sch.element_version_id = l_element_version_id
   -- FOR UPDATE NOWAIT
  ;
  dbms_output.put_line(' Step 2 - l_pev_schedule_id       : ' || l_pev_schedule_id);
  dbms_output.put_line(' Step 2 - l_record_version_number : ' || l_record_version_number);
  dbms_output.put_line(' Step 2 - l_scheduled_start_date  : ' || to_char(l_scheduled_start_date, c_datetime_format));
  dbms_output.put_line(' Step 2 - l_scheduled_finish_date : ' || to_char(l_scheduled_finish_date, c_datetime_format));

  -- Step 3 
  l_scheduled_finish_date := l_scheduled_finish_date + 1;
  update_schedule_version(p_pev_schedule_id       => l_pev_schedule_id,
                          p_record_version_number => l_record_version_number,
                          p_scheduled_start_date  => l_scheduled_start_date,
                          p_scheduled_end_date    => l_scheduled_finish_date,
                          x_return_status         => x_return_status,
                          x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data);

  dbms_output.put_line(' Step 3 - l_scheduled_start_date  : ' || to_char(l_scheduled_start_date, c_datetime_format));
  dbms_output.put_line(' Step 3 - l_scheduled_finish_date : ' || to_char(l_scheduled_finish_date, c_datetime_format));
  dbms_output.put_line(' Step 3 - x_return_status : ' || x_return_status);
  dbms_output.put_line(' Step 3 - x_msg_count     : ' || x_msg_count);
  dbms_output.put_line(' Step 3 - x_msg_data      : ' || x_msg_data);
END;
/

/*  -- 12000961
SELECT ppa.project_id,
         ppa.segment1,
         pt.task_id,
         pt.task_number
    FROM pa_projects_all ppa,
         pa_tasks        pt
   WHERE 1 = 1
     AND ppa.org_id = 82
     AND ppa.project_id = pt.project_id
     AND pt.task_id = pt.top_task_id
   ORDER BY ppa.creation_date DESC;*/
