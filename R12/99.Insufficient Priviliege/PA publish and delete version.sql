

--wbs delete version
DECLARE
  l_retcode VARCHAR2(1);
  l_errbuf  VARCHAR2(2000);

  CURSOR cur_project IS
    SELECT tmp.project_id
      FROM pa_projects_all tmp
     WHERE 1 = 1
          --AND tmp.project_id = 1232
       AND (SELECT COUNT(DISTINCT ppev.parent_structure_version_id)
              FROM pa_proj_element_versions ppev
             WHERE ppev.project_id = tmp.project_id) > 2;
BEGIN
  FOR rec IN cur_project LOOP
    xxpjm_delete_publish_ver_pkg.main(l_errbuf, l_retcode, rec.project_id);
    dbms_output.put_line('rec.project_id      : ' || rec.project_id);
    dbms_output.put_line('l_errbuf            : ' || l_errbuf);
    dbms_output.put_line('l_retcode           : ' || l_retcode);
  END LOOP;
END;



--wbs publish version
DECLARE
  CURSOR lines_c
  IS
    SELECT 1234 project_id
      FROM dual;
       
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_ver_id            NUMBER;
  l_count             NUMBER:=0;
BEGIN

  fnd_global.apps_initialize(user_id => 1234,resp_id => 50676,resp_appl_id => 660);
  mo_global.init(fnd_global.application_short_name);

  pa_debug.enable_debug;
  FOR one_line in lines_c LOOP
  
    BEGIN
      xxpa_proj_public_pvt.structure_published(one_line.project_id,
                                               l_ver_id,
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
        l_return_status := 'E';
        l_msg_count     := 1;
        l_msg_data      := SQLCODE || SQLERRM;
    END;
             
    l_count := l_count+1;                        
    IF l_return_status != 'S' THEN
      dbms_output.put_line('one_line.project_id: ' || one_line.project_id);
      dbms_output.put_line('l_ver_id:            ' || l_ver_id);
      dbms_output.put_line('l_return_status:     ' || l_return_status);
      dbms_output.put_line('l_msg_count:         ' || l_msg_count);
      dbms_output.put_line('l_msg_data:          ' || l_msg_data);    
    END IF;
  
  END LOOP;
  dbms_output.put_line('l_count:          ' || l_count);  
END;
