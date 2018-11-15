CREATE OR REPLACE PACKAGE form_file_upload_download_pkg IS
  PROCEDURE when_button_pressed(button_name IN VARCHAR2);
END form_file_upload_download_pkg;
/
CREATE OR REPLACE PACKAGE BODY form_file_upload_download_pkg IS
  PROCEDURE when_button_pressed(button_name IN VARCHAR2) IS
    --for uploading file
    access_id     NUMBER;
    l_server_url  VARCHAR2(100);
    l_parameters  VARCHAR2(100);
    button_choice INTEGER;
    l_file_id     VARCHAR2(100);
    l_gfm_id      INTEGER;
    --for gen lob
    l_created_by        NUMBER := fnd_global.user_id;
    l_creation_date     DATE := SYSDATE;
    l_last_updated_by   NUMBER := fnd_global.user_id;
    l_last_update_date  DATE := SYSDATE;
    l_last_update_login NUMBER := fnd_global.login_id;
    l_upload_sequence   NUMBER;
    l_row_id            ROWID;
    l_upload_id         NUMBER;
    --for importing to temp table
    l_status  VARCHAR2(10);
    l_message VARCHAR2(4000);
    --for downloading file
    l_download_url VARCHAR2(2000);
  BEGIN
    IF upper(button_name) = 'UPLOAD' THEN
      access_id := fnd_gfm.authorize(NULL);
      fnd_profile.get('APPS_WEB_AGENT', l_server_url);
      l_parameters := 'access_id=' || access_id;
      -- 调出文件上传的Web界面
      fnd_function.execute(function_name => 'FND_FNDFLUPL',
                           open_flag     => 'Y',
                           session_flag  => 'Y',
                           other_params  => l_parameters);
    
      fnd_message.set_name('FND', 'ATCHMT-FILE-UPLOAD-COMPLETE');
      button_choice := fnd_message.question(button1     => 'YES',
                                            button2     => NULL,
                                            button3     => 'NO',
                                            default_btn => 1,
                                            cancel_btn  => 3,
                                            icon        => 'question');
    
      IF (button_choice = 3) THEN
        NULL;
      ELSIF (button_choice = 1) THEN
        :control.file_id   := NULL;
        :control.file_name := NULL;
        l_upload_sequence  := NULL;
        l_row_id           := NULL;
        l_upload_id        := NULL;
        l_file_id          := NULL;
        l_gfm_id           := fnd_gfm.get_file_id(access_id);
      
        IF l_gfm_id IS NOT NULL THEN
          SELECT decode(instr(file_name, '/'), 0, file_name, substr(file_name, instr(file_name, '/') + 1))
            INTO l_file_id
            FROM fnd_lobs
           WHERE file_id = l_gfm_id;
        
          IF l_file_id IS NOT NULL THEN
            :control.file_id   := l_gfm_id;
            :control.file_name := l_file_id;
          
            l_upload_sequence := xxfnd_file_upload_api.gen_upload_sequence(:parameter.g_function_key);
          
            xxfnd_file_upload_pkg.insert_row(x_row_id            => l_row_id,
                                             x_upload_id         => l_upload_id,
                                             p_function_key      => :parameter.g_function_key,
                                             p_upload_sequence   => l_upload_sequence,
                                             p_file_id           => :control.file_id,
                                             p_file_name         => :control.file_name,
                                             p_upload_by         => l_created_by,
                                             p_upload_date       => l_creation_date,
                                             p_import_status     => 'P',
                                             p_created_by        => l_created_by,
                                             p_creation_date     => l_creation_date,
                                             p_last_updated_by   => l_last_updated_by,
                                             p_last_update_date  => l_last_update_date,
                                             p_last_update_login => l_last_update_login);
            forms_ddl('commit');
            go_block('UPLOAD');
            execute_query;
            first_record;
          
          END IF;
        END IF;
      END IF;
    ELSIF upper(button_name) = 'IMPORT' THEN
      IF :upload.upload_id IS NULL THEN
        RAISE form_trigger_failure;
      END IF;
      IF :upload.import_status NOT IN ('P', 'E') THEN
        RAISE form_trigger_failure;
      END IF;
      IF xxfnd_file_upload_api.is_file_format(:upload.file_id) = 'N' THEN
        fnd_message.set_name('XXFND', 'XXFND_007E_002');
        fnd_message.error;
        RAISE form_trigger_failure;
      END IF;
      fnd_message.set_name('XXFND', 'XXFND_007N_001');
      IF NOT fnd_message.warn THEN
        RAISE form_trigger_failure;
      END IF;
    
      --upload to temp
      l_status  := NULL;
      l_message := NULL;
      xxfnd_file_upload_api.gen_upload_temp(p_fnc_key   => :parameter.g_function_key,
                                            p_upload_id => :upload.upload_id,
                                            p_file_id   => :upload.file_id,
                                            x_status    => l_status,
                                            x_message   => l_message);
      IF l_status = 'E' THEN
        fnd_message.set_string(l_message);
        fnd_message.error;
        RAISE form_trigger_failure;
      END IF;
    
      --import temp data
      l_status  := NULL;
      l_message := NULL;
      xxfnd_file_upload_api.import_temp_data(p_fnc_key   => :parameter.g_function_key,
                                             p_upload_id => :upload.upload_id,
                                             p_file_id   => :upload.file_id,
                                             x_status    => l_status,
                                             x_message   => l_message);
      --IF l_status = 'E' THEN
      --fnd_message.set_string(l_message);
      --fnd_message.error;
      --RAISE form_trigger_failure;
      --END IF;
    
      --update row
      set_block_property('UPLOAD', update_allowed, property_true);
      :upload.import_status  := l_status;
      :upload.import_message := l_message;
      :upload.import_by      := l_last_updated_by;
      :upload.import_user    := xxfnd_file_upload_api.get_user_name(l_last_updated_by);
      :upload.import_date    := SYSDATE;
      commit_form;
      set_block_property('UPLOAD', update_allowed, property_false);
      app_standard.synchronize;
    
    ELSIF upper(button_name) = 'VIEW' THEN
      -- download fnd_lobs files
      IF :upload.file_id IS NOT NULL THEN
        l_download_url := fnd_gfm.construct_download_url(gfm_agent => fnd_web_config.gfm_agent,
                                                         file_id   => :upload.file_id);
        web.show_document(l_download_url, '_blank');
      END IF;
    END IF;
  END when_button_pressed;
END form_file_upload_download_pkg;
/
