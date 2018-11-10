DECLARE
  c_yes_mark             CONSTANT VARCHAR2(1) := 'Y';
  c_no_mark              CONSTANT VARCHAR2(1) := 'N';
  c_create_user_flag     CONSTANT VARCHAR2(1) := c_yes_mark;
  c_username_from        CONSTANT VARCHAR2(100) := 'HAND_SZC';
  c_username_to          CONSTANT VARCHAR2(100) := 'HAND_zjm';
  c_create_user_password CONSTANT VARCHAR2(100) := 'hand12345';
  l_user_rec_from  fnd_user%ROWTYPE;
  l_user_rec_to    fnd_user%ROWTYPE;
  l_profile_result BOOLEAN;

  -- exception
  e_username_from EXCEPTION;
  e_username_to   EXCEPTION;

  CURSOR cur_data_responsibility(p_cur_user_id_from IN NUMBER,
                                 p_cur_user_id_to   IN NUMBER) IS
    SELECT upper(c_username_to) username,
           fa.application_short_name resp_app,
           fr.responsibility_key resp_key,
           fr.responsibility_name,
           fsg.security_group_key security_group,
           furgd_from.description,
           furgd_from.start_date,
           furgd_from.end_date
      FROM fnd_user_resp_groups_direct furgd_from,
           fnd_application             fa,
           fnd_security_groups         fsg,
           fnd_responsibility_vl       fr
     WHERE 1 = 1
       AND furgd_from.responsibility_application_id = fa.application_id
       AND furgd_from.security_group_id = fsg.security_group_id
       AND furgd_from.responsibility_application_id = fr.application_id
       AND furgd_from.responsibility_id = fr.responsibility_id
       AND (furgd_from.responsibility_id, furgd_from.responsibility_application_id) IN
           (SELECT fresp.responsibility_id,
                   fresp.application_id
              FROM fnd_responsibility fresp
             WHERE (fresp.version = '4' OR fresp.version = 'W' OR fresp.version = 'M' OR fresp.version = 'H'))
       AND furgd_from.user_id = p_cur_user_id_from -- 1393
       AND NOT EXISTS
     (SELECT 1
              FROM fnd_user_resp_groups_direct furgd_to
             WHERE 1 = 1
               AND (furgd_to.responsibility_id, furgd_to.responsibility_application_id) IN
                   (SELECT fresp.responsibility_id,
                           fresp.application_id
                      FROM fnd_responsibility fresp
                     WHERE (fresp.version = '4' OR fresp.version = 'W' OR fresp.version = 'M' OR fresp.version = 'H'))
               AND furgd_from.responsibility_application_id = furgd_to.responsibility_application_id
               AND furgd_from.responsibility_id = furgd_to.responsibility_id
               AND furgd_to.user_id = p_cur_user_id_to --2305
            );

  CURSOR cur_data_profile(p_cur_user_id_from IN NUMBER) IS
  
    SELECT flv.meaning level_meaning,
           profile_value.level_id,
           profile_value.level_value,
           profile_value.level_name,
           profile_value.level_value2,
           profile_value.level_value_desc,
           profile_value.application_id,
           profile_value.profile_option_id,
           -- fpo.application_id,
           fpo.user_profile_option_name,
           fpo.profile_option_name,
           profile_value.profile_option_value
      FROM (
            -- User Level
            SELECT fpov.level_id,
                    fpov.level_value,
                    'USER' level_name,
                    fpov.level_value2,
                    fu.user_name level_value_desc,
                    fpov.application_id,
                    fpov.profile_option_id,
                    fpov.profile_option_value
              FROM fnd_profile_option_values fpov,
                    fnd_user                  fu
             WHERE 1 = 1
               AND fpov.level_id = 10004
               AND fpov.level_value = fu.user_id) profile_value,
           fnd_lookup_values_vl flv,
           fnd_profile_options_vl fpo
     WHERE 1 = 1
       AND flv.lookup_type(+) = 'ITA_PROFILE_LEVEL_ID'
       AND flv.lookup_code(+) = profile_value.level_id
       AND profile_value.profile_option_id = fpo.profile_option_id
       AND profile_value.application_id = fpo.application_id
       AND profile_value.level_id = 10004
       AND profile_value.level_value = p_cur_user_id_from; -- 1393

  l_count NUMBER;

BEGIN
  l_count := 0;
  dbms_output.put_line(lpad(' ', 50, '='));
  dbms_output.put_line(lpad('c_username_from : ', 30, ' ') || c_username_from);
  dbms_output.put_line(lpad('c_username_to : ', 30, ' ') || c_username_to);
  dbms_output.put_line(lpad('c_create_user_password : ', 30, ' ') || c_create_user_password);
  dbms_output.put_line(lpad(' ', 50, '='));
  BEGIN
    SELECT fu.*
      INTO l_user_rec_from
      FROM fnd_user fu
     WHERE fu.user_name = upper(c_username_from);
    dbms_output.put_line(' user_id_from : ' || l_user_rec_from.user_id);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE e_username_from;
  END;

  BEGIN
    SELECT fu.*
      INTO l_user_rec_to
      FROM fnd_user fu
     WHERE fu.user_name = upper(c_username_to);
    dbms_output.put_line(' user_id_to : ' || l_user_rec_to.user_id);
  EXCEPTION
    WHEN OTHERS THEN
      IF c_create_user_flag = c_yes_mark THEN
        dbms_output.put_line('Note ========== create new user');
        l_user_rec_to.user_id := fnd_user_pkg.createuserid(x_user_name            => upper(c_username_to), --:x_user_name,
                                                           x_owner                => 'CUST', --:x_owner,
                                                           x_unencrypted_password => lower(c_create_user_password) --:x_unencrypted_password,
                                                           --x_session_number             => :x_session_number,
                                                           --x_start_date                 => :x_start_date,
                                                           --x_end_date                   => :x_end_date,
                                                           --x_last_logon_date            => :x_last_logon_date,
                                                           --x_description                => :x_description,
                                                           --x_password_date              => :x_password_date,
                                                           --x_password_accesses_left     => :x_password_accesses_left,
                                                           --x_password_lifespan_accesses => :x_password_lifespan_accesses,
                                                           --x_password_lifespan_days     => :x_password_lifespan_days,
                                                           --x_employee_id                => :x_employee_id,
                                                           --x_email_address              => :x_email_address,
                                                           --x_fax                        => :x_fax,
                                                           --x_customer_id                => :x_customer_id,
                                                           --x_supplier_id                => :x_supplier_id
                                                           );
      
        SELECT fu.*
          INTO l_user_rec_to
          FROM fnd_user fu
         WHERE fu.user_name = upper(c_username_to);
        dbms_output.put_line('Success ========== create User Id : ' || l_user_rec_to.user_id);
      ELSE
        dbms_output.put_line('Note ========== don''t create new user');
        RAISE e_username_to;
      END IF;
  END;

  -- assign responsibility
  FOR rec_data IN cur_data_responsibility(p_cur_user_id_from => l_user_rec_from.user_id, --
                                          p_cur_user_id_to   => l_user_rec_to.user_id)
  LOOP
    l_count := l_count + 1;
    fnd_user_pkg.addresp(username       => rec_data.username,
                         resp_app       => rec_data.resp_app,
                         resp_key       => rec_data.resp_key,
                         security_group => rec_data.security_group,
                         description    => rec_data.description,
                         start_date     => rec_data.start_date,
                         end_date       => rec_data.end_date);
    dbms_output.put_line('Success Adding ' || lpad(l_count, 3, ' ') || '  =====    APPL : ' ||
                         rpad(rec_data.resp_app, 10, ' ') || ' RESPONSIBILITY_NAME : ' || rec_data.responsibility_name);
  END LOOP;
  dbms_output.put_line('Success ========== assign responsibility');
  -- assign persion
  fnd_user_pkg.updateuser(x_user_name => l_user_rec_to.user_name, -- :x_user_name,
                          x_owner     => l_user_rec_to.user_name, --:x_owner,
                          --x_unencrypted_password       => :x_unencrypted_password,
                          --x_session_number             => :x_session_number,
                          --x_start_date                 => :x_start_date,
                          --x_end_date                   => :x_end_date,
                          --x_last_logon_date            => :x_last_logon_date,
                          --x_description                => :x_description,
                          --x_password_date              => :x_password_date,
                          --x_password_accesses_left     => :x_password_accesses_left,
                          --x_password_lifespan_accesses => :x_password_lifespan_accesses,
                          --x_password_lifespan_days     => :x_password_lifespan_days,
                          x_employee_id => l_user_rec_from.employee_id --:x_employee_id,
                          --x_email_address              => :x_email_address,
                          --x_fax                        => :x_fax,
                          --x_customer_id                => :x_customer_id,
                          --x_supplier_id                => :x_supplier_id,
                          --x_old_password               => :x_old_password
                          );
  dbms_output.put_line('Success ========== assign employee_id : ' || l_user_rec_from.employee_id);
  dbms_output.put_line('                   assign employee    : ' ||
                       hr_person_name.get_person_name(p_person_id      => l_user_rec_from.employee_id,
                                                      p_effective_date => SYSDATE,
                                                      p_format         => hr_person_name.g_full_name));

  -- set profile user level
  FOR rec IN cur_data_profile(p_cur_user_id_from => l_user_rec_from.user_id)
  LOOP
    l_profile_result := fnd_profile.save(x_name        => rec.profile_option_name, -- :x_name,
                                         x_value       => rec.profile_option_value, -- :x_value,
                                         x_level_name  => rec.level_name, -- :x_level_name,
                                         x_level_value => l_user_rec_to.user_id -- :x_level_value,
                                         --x_level_value_app_id => :x_level_value_app_id,
                                         --x_level_value2       => :x_level_value2
                                         );
    IF sys.diutil.bool_to_int(l_profile_result) = 1 THEN
      dbms_output.put_line('Success ========== set profile user level');
    ELSE
      dbms_output.put_line('Failure ========== set profile user level');
    END IF;
    dbms_output.put_line('                   user_profile_option_name : ' || rec.user_profile_option_name);
    dbms_output.put_line('                   profile_option_value     : ' || rec.profile_option_value);
    dbms_output.put_line('                   level_name               : ' || rec.level_name);
    dbms_output.put_line('                   level_value              : ' || l_user_rec_to.user_id);
  
  END LOOP;

EXCEPTION
  WHEN e_username_from THEN
    dbms_output.put_line('From user name (' || c_username_from || ')is error!');
  WHEN e_username_to THEN
    dbms_output.put_line('To user name (' || c_username_to || ')is error!');
  WHEN OTHERS THEN
    dbms_output.put_line('SQLERRM : ' || SQLERRM);
END;
