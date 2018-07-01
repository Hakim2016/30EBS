DECLARE
  l_project_id    NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data      VARCHAR2(32767);

  PROCEDURE proc_delete_wbs_version(p_project_id    IN NUMBER,
                                    x_return_status OUT VARCHAR2,
                                    x_msg_data      OUT VARCHAR2) IS
    CURSOR cur_versions(p_cur_project_id NUMBER) IS
      SELECT ppevs.element_version_id,
             ppevs.version_number,
             ppevs.name
        FROM pa_proj_elem_ver_structure ppevs
       WHERE ppevs.status_code = 'STRUCTURE_PUBLISHED'
         AND ppevs.project_id = p_cur_project_id
         AND ppevs.version_number NOT IN
             (SELECT MIN(ppevs2.version_number)
                FROM pa_proj_elem_ver_structure ppevs2
               WHERE ppevs2.project_id = ppevs.project_id
                 AND ppevs2.status_code = 'STRUCTURE_PUBLISHED'
              UNION ALL
              SELECT MAX(ppevs3.version_number)
                FROM pa_proj_elem_ver_structure ppevs3
               WHERE ppevs3.project_id = ppevs.project_id
                 AND ppevs3.status_code = 'STRUCTURE_PUBLISHED');
  
    l_structure_version_id  system.pa_num_tbl_type := system.pa_num_tbl_type();
    l_record_version_number system.pa_num_tbl_type := system.pa_num_tbl_type();
    l_idx                   NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_data                  VARCHAR2(2000);
    l_idx2                  NUMBER;
  
    l_index NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_idx           := 0;
    FOR rec_ver IN cur_versions(p_project_id)
    LOOP
      l_idx := l_idx + 1;
      l_structure_version_id.extend;
      l_record_version_number.extend;
      l_structure_version_id(l_idx) := rec_ver.element_version_id;
      l_record_version_number(l_idx) := rec_ver.version_number;
    END LOOP;
  
    IF l_idx > 0 THEN
      pa_project_structure_pub1.delete_published_structure_ver(p_project_id                => p_project_id,
                                                               p_structure_version_id_tbl  => l_structure_version_id,
                                                               p_record_version_number_tbl => l_record_version_number,
                                                               x_return_status             => x_return_status,
                                                               x_msg_count                 => l_msg_count,
                                                               x_msg_data                  => x_msg_data);
      /*FOR i IN 1 .. nvl(l_msg_count, 0)
      LOOP
      
        fnd_msg_pub.get(p_msg_index     => i, --
                        p_encoded       => fnd_api.g_false,
                        p_data          => l_data,
                        p_msg_index_out => l_idx2);
      
      END LOOP;*/
    
      FOR i IN 1 .. nvl(l_msg_count, 0)
      LOOP
        pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                            p_msg_index     => i,
                                            p_msg_count     => l_msg_count,
                                            p_msg_data      => l_msg_data,
                                            p_data          => l_data,
                                            p_msg_index_out => l_index);
        x_msg_data := substrb(x_msg_data || '[' || l_data || ']', 1, 4000);
      END LOOP;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'Calling proc_delete_wbs_version Occurred Error ' || SQLERRM;
  END proc_delete_wbs_version;

BEGIN
  l_project_id := -1;
  proc_delete_wbs_version(p_project_id    => l_project_id, --
                          x_return_status => l_return_status,
                          x_msg_data      => l_msg_data);

  dbms_output.put_line(' l_return_status : ' || l_return_status);
  dbms_output.put_line(' l_msg_data      : ' || l_msg_data);

END;
