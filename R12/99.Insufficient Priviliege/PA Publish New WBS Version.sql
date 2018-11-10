-- PA Publish New WBS Version
DECLARE
  l_structure_version_id NUMBER;
  l_status_code          VARCHAR2(100) := 'STRUCTURE_PUBLISHED';
  l_index                NUMBER;
  l_data                 VARCHAR2(1000);
  -- 
  l_project_id              NUMBER;
  x_published_struct_ver_id NUMBER;
  x_return_status           VARCHAR2(1);
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(32767);
BEGIN
  fnd_global.apps_initialize(user_id      => 1393, --
                             resp_id      => 50676, --
                             resp_appl_id => 660);
  mo_global.init(fnd_global.application_short_name);

  pa_debug.enable_debug;
  l_project_id := 213785;
  SELECT pa_project_structure_utils.get_current_working_ver_id(l_project_id)
    INTO l_structure_version_id
    FROM dual;
  pa_project_pub.change_structure_status(p_return_status           => x_return_status,
                                         p_msg_count               => x_msg_count,
                                         p_msg_data                => x_msg_data,
                                         p_structure_version_id    => l_structure_version_id,
                                         p_pa_project_id           => l_project_id,
                                         p_status_code             => l_status_code,
                                         p_process_mode            => 'ONLINE',
                                         p_published_struct_ver_id => x_published_struct_ver_id);
  FOR i IN 1 .. nvl(x_msg_count, 0)
  LOOP
    pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                        p_msg_index     => i,
                                        p_msg_count     => x_msg_count,
                                        p_msg_data      => x_msg_data,
                                        p_data          => l_data,
                                        p_msg_index_out => l_index);
  
    -- x_msg_data := substrb(x_msg_data || l_data, 1, 255);
    x_msg_data := x_msg_data || ' [' || x_msg_data || '] ';
  END LOOP;

  IF nvl(x_msg_count, 0) <> 0 THEN
    dbms_output.put_line(' x_msg_count : ' || x_return_status);
    dbms_output.put_line(' x_msg_count : ' || x_msg_count);
    dbms_output.put_line(' x_msg_data : ' || x_msg_data);
  ELSE
    dbms_output.put_line(' New WBS Version Published Success. published_struct_ver_id : ' || x_published_struct_ver_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_count     := 1;
    x_msg_data      := 'SQLCODE : ' || SQLCODE || ' SQLERRM : ' || SQLERRM;
END;
