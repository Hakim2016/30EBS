-- PA Delete published WBS Structure
DECLARE
  CURSOR cur_data(p_cur_project_id IN NUMBER) IS
    SELECT ppevs.element_version_id,
           ppevs.version_number,
           ppevs.name
      FROM pa_proj_elem_ver_structure ppevs
     WHERE ppevs.status_code = 'STRUCTURE_PUBLISHED'
       AND ppevs.project_id = p_cur_project_id
          -- don't delete max and min version
       AND ppevs.version_number NOT IN (SELECT MIN(ppevs2.version_number)
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
BEGIN
  l_idx := 0;
  FOR one_ver IN versions_c(p_project_id)
  LOOP
    output(one_ver.name || '.' || one_ver.version_number);
    l_idx := l_idx + 1;
    l_structure_version_id.extend;
    l_record_version_number.extend;
    l_structure_version_id(l_idx) := one_ver.element_version_id;
    l_record_version_number(l_idx) := one_ver.version_number;
  END LOOP;

  IF l_idx > 0 THEN
  
    pa_project_structure_pub1.delete_published_structure_ver(p_project_id                => p_project_id,
                                                             p_structure_version_id_tbl  => l_structure_version_id,
                                                             p_record_version_number_tbl => l_record_version_number,
                                                             x_return_status             => l_return_status,
                                                             x_msg_count                 => l_msg_count,
                                                             x_msg_data                  => l_msg_data);
  
    output('l_return_status: ' || l_return_status);
    output('l_msg_count:     ' || l_msg_count);
    output('l_msg_data:      ' || l_msg_data);
  
    FOR i IN 1 .. nvl(l_msg_count, 0)
    LOOP
      fnd_msg_pub.get(p_msg_index => i, p_encoded => fnd_api.g_false, p_data => l_data, p_msg_index_out => l_idx2);
      output(l_data);
    END LOOP;
  END IF;
END;
