DECLARE
  -- form
  c_form_appl_short_name CONSTANT VARCHAR2(100) := 'XXMRP';
  c_form_name            CONSTANT VARCHAR2(200) := 'XXMRPF003';
  c_user_form_name       CONSTANT VARCHAR2(200) := 'XXMRP:Sales Budgeted Month Maintenance';
  -- function
  c_function_name      CONSTANT VARCHAR2(200) := 'XXMRPF003';
  c_user_function_name CONSTANT VARCHAR2(200) := 'XXMRP:Sales Budgeted Month Maintenance';
  -- menu
  c_relate_menu_name        CONSTANT VARCHAR2(200) := 'XXMRP_MENU';
  c_entry_sequence          CONSTANT NUMBER := 19;
  c_relate_menu_prompt      CONSTANT VARCHAR2(200) := 'Sales Budgeted Month Maintenance';
  c_relate_menu_description CONSTANT VARCHAR2(200) := 'XXMRP:Sales Budgeted Month Maintenance';

  l_form_application_id NUMBER;
  l_application_id      NUMBER;
  l_form_id             NUMBER;
  l_function_id         NUMBER;
  l_menu_id             NUMBER;
  l_sub_menu_id         NUMBER;
  l_sub_function_id     NUMBER;

  x_rowid    VARCHAR2(400);
  l_count    NUMBER;
  l_cur_date DATE := SYSDATE;
  l_user_id  NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.login_id;
  l_commit   BOOLEAN := FALSE;
BEGIN
  -- ///////////////////////////////////////////////////////////////
  -- FORM
  dbms_output.put_line(' ------------------------------- Begin define FORM : ' || c_form_name);
  BEGIN
    SELECT a.application_id
      INTO l_application_id
      FROM fnd_application a
     WHERE a.application_short_name = c_form_appl_short_name;
    --validate FORM existed
    SELECT f.form_id
      INTO l_form_id
      FROM fnd_form f
     WHERE f.application_id = l_application_id
       AND f.form_name = c_form_name;
    dbms_output.put_line('SUCCESS==FORM : ' || c_form_name || ' has existed!');
  EXCEPTION
    WHEN no_data_found THEN
      -- validate form user name existed
      SELECT COUNT(1)
        INTO l_count
        FROM fnd_form_tl t
       WHERE t.user_form_name = c_user_form_name
         AND t.application_id = l_application_id;
      IF l_count > 0 THEN
        dbms_output.put_line('FORM user name £º' || c_user_form_name || ' existed');
        raise_application_error(-20001, 'USER_FORM_NAME_EXISTS');
      END IF;
      -- Register From
      SELECT fnd_form_s.nextval
        INTO l_form_id
        FROM dual;
      fnd_form_pkg.insert_row(x_rowid              => x_rowid,
                              x_application_id     => l_application_id,
                              x_form_id            => l_form_id,
                              x_form_name          => c_form_name,
                              x_audit_enabled_flag => 'N',
                              x_user_form_name     => c_user_form_name,
                              x_description        => '',
                              x_creation_date      => l_cur_date,
                              x_created_by         => l_user_id,
                              x_last_update_date   => l_cur_date,
                              x_last_updated_by    => l_user_id,
                              x_last_update_login  => l_login_id);
      l_commit := TRUE;
      IF x_rowid IS NULL THEN
        raise_application_error(-20001, 'define FORM fail£º' || SQLERRM);
      END IF;
      dbms_output.put_line('SUCCESS== FORM : ' || c_form_name || ' define Success!');
  END;
  dbms_output.put_line(' ------------------------------- End define FORM : ' || c_form_name);
  dbms_output.put_line(' ');
  -- ///////////////////////////////////////////////////////////////
  -- FUNCTION
  dbms_output.put_line(' ------------------------------- Begin define FUNCTION : ' || c_function_name);
  BEGIN
    --validate FUNCTION existed
    SELECT f.function_id
      INTO l_function_id
      FROM fnd_form_functions f
     WHERE f.function_name = c_function_name;
    dbms_output.put_line('SUCCESS==FUNCTION : ' || c_function_name || ' has existed£¡');
  EXCEPTION
    WHEN no_data_found THEN
      -- validate FUNCTION user name existed
      SELECT COUNT(1)
        INTO l_count
        FROM fnd_form_functions_tl t
       WHERE t.user_function_name = c_user_function_name;
      IF l_count > 0 THEN
        dbms_output.put_line('Function User Name £º' || c_user_function_name || ' has existed£¡');
        raise_application_error(-20001, 'USER_FUNCTION_NAME_EXISTS');
      END IF;
      -- Register FUNCTION
      SELECT fnd_form_functions_s.nextval
        INTO l_function_id
        FROM dual;
      fnd_form_functions_pkg.insert_row(x_rowid                  => x_rowid,
                                        x_function_id            => l_function_id,
                                        x_web_host_name          => '',
                                        x_web_agent_name         => '',
                                        x_web_html_call          => '',
                                        x_web_encrypt_parameters => 'N',
                                        x_web_secured            => 'N',
                                        x_web_icon               => '',
                                        x_object_id              => NULL,
                                        x_region_application_id  => NULL,
                                        x_region_code            => '',
                                        x_function_name          => c_function_name,
                                        x_application_id         => l_application_id,
                                        x_form_id                => l_form_id,
                                        x_parameters             => '',
                                        x_type                   => 'FORM',
                                        x_user_function_name     => c_user_function_name,
                                        x_description            => c_user_function_name,
                                        x_creation_date          => l_cur_date,
                                        x_created_by             => l_user_id,
                                        x_last_update_date       => l_cur_date,
                                        x_last_updated_by        => l_user_id,
                                        x_last_update_login      => l_login_id);
      l_commit := TRUE;
      IF x_rowid IS NULL THEN
        raise_application_error(-20001, 'define FUNCTION fail£º' || SQLERRM);
      END IF;
      dbms_output.put_line('SUCCESS==FUNCTION : ' || c_function_name || ' define Success£¡');
  END;

  dbms_output.put_line(' ------------------------------- End define FUNCTION : ' || c_function_name);
  dbms_output.put_line(' ');
  -- ///////////////////////////////////////////////////////////////
  -- MENU
  dbms_output.put_line(' ------------------------------- Begin relate Menu Name : ' || c_relate_menu_name);
  BEGIN
    -- validate MENU existed
    BEGIN
      SELECT m.menu_id
        INTO l_menu_id
        FROM fnd_menus m
       WHERE m.menu_name = c_relate_menu_name;
    EXCEPTION
      WHEN no_data_found THEN
        dbms_output.put_line('MENU name : ' || c_relate_menu_name || ' not existed£¡');
        raise_application_error(-20001, 'PAR_MENU_NOT_EXISTS');
    END;
    BEGIN
      SELECT m.function_id
        INTO l_sub_function_id
        FROM fnd_form_functions m
       WHERE m.function_name = c_function_name;
    EXCEPTION
      WHEN no_data_found THEN
        dbms_output.put_line(' Function Name : ' || c_function_name || ' not existed£¡');
        raise_application_error(-20001, 'SUB_FUNCTION_NOT_EXISTS');
    END;
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_menu_entries e,
           fnd_menus        m
     WHERE e.menu_id = m.menu_id
       AND m.menu_name = c_relate_menu_name
       AND e.entry_sequence = c_entry_sequence;
    IF l_count > 0 THEN
      dbms_output.put_line('In menu name : ' || c_relate_menu_name || ' entry sequence : ' || c_entry_sequence ||
                           ' existed£¡');
      raise_application_error(-20001, 'SUB_SEQUENCE_EXISTS');
    END IF;
    fnd_menu_entries_pkg.insert_row(x_rowid             => x_rowid,
                                    x_menu_id           => l_menu_id,
                                    x_entry_sequence    => c_entry_sequence,
                                    x_sub_menu_id       => l_sub_menu_id,
                                    x_function_id       => l_sub_function_id,
                                    x_grant_flag        => 'Y',
                                    x_prompt            => c_relate_menu_prompt,
                                    x_description       => c_relate_menu_description,
                                    x_creation_date     => l_cur_date,
                                    x_created_by        => l_user_id,
                                    x_last_update_date  => l_cur_date,
                                    x_last_updated_by   => l_user_id,
                                    x_last_update_login => l_login_id);
    l_commit := TRUE;
  
    dbms_output.put_line('SUCCESS==Form relate to Menu Name : ' || c_relate_menu_name || ' entry sequence : ' ||
                         c_entry_sequence || ' define Success£¡');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.put_line(to_char(SQLCODE) || '-' || SQLERRM);
      raise_application_error(-20001,
                              'Form relate to Menu Name : ' || c_relate_menu_name || ' entry sequence : ' ||
                              c_entry_sequence || '  Fail');
    
  END;

  dbms_output.put_line(' ------------------------------- End relate Menu Name : ' || c_relate_menu_name);
  dbms_output.put_line(' ');
  -- ///////////////////////////////////////////////////////////////
END;
