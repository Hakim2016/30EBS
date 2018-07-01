CREATE OR REPLACE PACKAGE xxfnd_file_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxfnd_file_pkg
  Description:
      This program provide main procedure to perform:
        file process
  History:
      1.00  2012-03-06 Huaijun.Yan  Creation
  ==================================================*/

  g_if_base_path      VARCHAR2(400) := fnd_profile.value('XXFND_IF_BASE_PATH');
  g_if_path_separator VARCHAR2(10) := fnd_profile.value('XXFND_IF_PATH_SEPARATOR');
  g_group_id          NUMBER;
  g_interface_id      NUMBER;
  g_group_list        VARCHAR2(4000);

  FUNCTION group_id RETURN NUMBER;
  FUNCTION group_list RETURN VARCHAR2;

  FUNCTION get_module(p_api_name     IN VARCHAR2,
                      p_program_name IN VARCHAR2,
                      p_phase        IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE log_message(p_module  IN VARCHAR2,
                        p_status  IN VARCHAR2,
                        p_message IN VARCHAR2);

  FUNCTION getlistfiles(path    IN VARCHAR2,
                        suffix  IN VARCHAR2,
                        isdepth IN VARCHAR2,
                        splitby IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.getListFiles( java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

  FUNCTION readfilenames(filename IN VARCHAR2,
                         chaset   IN VARCHAR2,
                         splitby  IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.readFileNames( java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

  FUNCTION uploadfile(fileid   IN VARCHAR2,
                      filename IN VARCHAR2,
                      charset  IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.uploadFile( java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

  FUNCTION getfileencode(filename IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.getFileEncode( java.lang.String) return java.lang.String';

  FUNCTION convertblob(inblob   IN BLOB,
                       sourcecs IN VARCHAR2,
                       destcs   IN VARCHAR2) RETURN BLOB AS
    LANGUAGE JAVA NAME 'FileViewer.convertBlob( oracle.sql.BLOB,java.lang.String,java.lang.String) return oracle.sql.BLOB';

  FUNCTION createfile(filedir  IN VARCHAR2 ,
                      filename IN VARCHAR2,
                      charset  IN VARCHAR2,
                      inblob   IN BLOB) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.createFile(java.lang.String,java.lang.String,java.lang.String, oracle.sql.BLOB) return java.lang.String';

  FUNCTION deletefile(filename IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.deleteFile(java.lang.String) return java.lang.String';
  
  FUNCTION isFileExists(filename IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer.isFileExists(java.lang.String) return java.lang.String';

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_file_encode
  *
  *   DESCRIPTION: 
  *       get the file charset
  *   ARGUMENT: p_file_name      file name
  *   RETURN  : charset, now only include:'GBK','UTF16','UTF8','Unicode','TIS620','JIS'
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  FUNCTION get_file_encode(p_file_name IN VARCHAR2) RETURN VARCHAR2;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  insert_lob
  *
  *   DESCRIPTION: 
  *       insert blob data
  *   ARGUMENT: p_file_id        the key value of the fnd_lobs
  *             p_file_name      file name
  *             p_lobs           blob data
  *             p_charset        char set
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE insert_lob(p_file_id   IN VARCHAR2,
                       p_file_name IN VARCHAR2,
                       p_lobs      IN BLOB,
                       p_charset   IN VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  upload_file
  *
  *   DESCRIPTION: 
  *       upload db server file to database
  *   ARGUMENT: p_file_name      the whole path of the file
  *             p_charset        Character set --add 2012.07.05
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_file_id        file id 
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE upload_file(p_file_name     IN VARCHAR2,
                        p_charset       IN VARCHAR2,
                        p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                        p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                        x_file_id       OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  extract_blob
  *
  *   DESCRIPTION: 
  *       split blob data
  *   ARGUMENT: p_file_id        the key value of the fnd_lobs
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE extract_blob(p_file_id       IN NUMBER,
                         p_interface_id  IN NUMBER,
                         p_int_rec       IN xxfnd_interface_config%ROWTYPE,
                         p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                         p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  process_file
  *
  *   DESCRIPTION: 
  *      process file
  *   ARGUMENT: p_file_name      file name. if multiple, combination with ;
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE process_file(p_file_name     IN VARCHAR2,
                         p_interface_id  IN NUMBER,
                         p_int_rec       IN xxfnd_interface_config%ROWTYPE,
                         p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                         p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                         x_file_id       OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  process_file
  *
  *   DESCRIPTION: 
  *      process file
  *   ARGUMENT: p_file_id        file id ;
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE create_file(p_file_id       IN NUMBER,
                        p_orig_path     IN VARCHAR2,
                        p_new_path      IN VARCHAR2,
                        p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                        p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  inbound
  *
  *   DESCRIPTION: 
  *      inbound file
  *   ARGUMENT: p_interface_id   interface ID ;
  *             p_txn_id         transaction ID
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE inbound(p_interface_id  IN NUMBER,
                    p_txn_id        IN NUMBER,
                    p_ledger        IN VARCHAR2,
                    p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                    p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                    x_grp_list      OUT NOCOPY VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  isFileExists
  *
  *   DESCRIPTION: 
  *      Judge the file exists
  *   ARGUMENT: p_interface_id   Interface id 
  *   HISTORY:
  *     1.00 2012-11-12 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE isFileExists(p_interface_id IN NUMBER,
                         p_ledger       IN VARCHAR2,
                         x_status       OUT VARCHAR2,
                         x_message      OUT VARCHAR2);
                         
  PROCEDURE outbound(p_interface_id IN NUMBER,
                     p_group_id     IN NUMBER,
                     p_ledger       IN VARCHAR2,
                     x_status       OUT VARCHAR2,
                     x_message      OUT VARCHAR2);
END xxfnd_file_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxfnd_file_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxfnd_file_pkg
  Description:
      This program provide main procedure to perform:
        file process
  History:
      1.00  2012-03-06 Huaijun.Yan  Creation
  ==================================================*/
  g_pkg_name CONSTANT VARCHAR2(30) := 'xxfnd_file_pkg';
  cv_dest_cs    VARCHAR2(30) := 'UTF8';
  g_debug       VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_log_enabled VARCHAR2(1) := nvl(fnd_profile.value('XXFND_INTERFACE_LOG_ENABLE'), 'N');
  g_request_id  NUMBER := fnd_global.conc_request_id;
  g_split_by    VARCHAR2(1) := ':';
  g_success     VARCHAR(1) := 'S';
  g_warning     VARCHAR2(1) := 'W';
  g_error       VARCHAR2(1) := 'E';
  g_sysdate     DATE := SYSDATE;
  g_session_id  NUMBER := userenv('sessionid');
  g_user_id     NUMBER := fnd_global.user_id;
  g_program_id  NUMBER := fnd_global.conc_program_id;
  g_login_id    NUMBER := fnd_global.login_id;
  g_date_format VARCHAR2(30) := 'YYMMDDHH24MISS';

  TYPE g_grp_list_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE file_tbl IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
  g_file_tbl file_tbl;

  PROCEDURE log(p_msg IN VARCHAR2) IS
  
  BEGIN
    IF nvl(g_request_id, -1) = -1 THEN
      dbms_output.put_line(p_msg);
    ELSE
      xxfnd_conc_utl.log_msg(p_msg);
    END IF;
    IF g_debug = 'Y' THEN
      xxfnd_debug.log(p_msg);
    END IF;
  END log;

  FUNCTION group_id RETURN NUMBER IS
  BEGIN
    RETURN g_group_id;
  END group_id;

  FUNCTION group_list RETURN VARCHAR2 IS
  BEGIN
    RETURN g_group_list;
  END group_list;

  FUNCTION get_module(p_api_name     IN VARCHAR2,
                      p_program_name IN VARCHAR2,
                      p_phase        IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN p_api_name || '.' || p_program_name || '.' || p_phase;
  END get_module;

  PROCEDURE log_message(p_module  IN VARCHAR2,
                        p_status  IN VARCHAR2,
                        p_message IN VARCHAR2) IS
    l_log_rec       xxfnd_interface_trx_logs%ROWTYPE;
    l_log_message   VARCHAR2(2000);
    l_debug_message VARCHAR2(2000);
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_log_enabled <> 'Y' THEN
      RETURN;
    END IF;
    l_log_message := '[' || p_status || '].' || p_message;
  
    l_log_rec              := NULL;
    l_log_rec.interface_id := g_interface_id;
    l_log_rec.group_id     := xxfnd_file_pkg.group_id;
    l_log_rec.module       := p_module;
    l_log_rec.timestamp    := SYSDATE;
    l_log_rec.log_sequence := xxfnd_interface_trx_logs_s.nextval;
    l_log_rec.log_message  := l_log_message;
    l_log_rec.session_id   := g_session_id;
    l_log_rec.user_id      := g_user_id;
    l_log_rec.request_id   := g_request_id;
    l_log_rec.program_id   := g_program_id;
    INSERT INTO xxfnd_interface_trx_logs
    VALUES l_log_rec;
  
    COMMIT;
  
    l_debug_message := '[' || to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss') || '][' || p_module || '][' || p_status || '].' ||
                       p_message;
    fnd_file.put_line(fnd_file.log, l_debug_message);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END log_message;

  PROCEDURE log_step(p_transaction_id IN NUMBER,
                     p_step_number    IN NUMBER,
                     p_description    IN VARCHAR2,
                     p_message        IN VARCHAR2) IS
    l_step_rec xxfnd_file_process_steps%ROWTYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  
    l_step_rec := NULL;
    SELECT xxfnd_file_process_steps_s.nextval
      INTO l_step_rec.process_step_id
      FROM dual;
    l_step_rec.transaction_id    := p_transaction_id;
    l_step_rec.step_no           := p_step_number;
    l_step_rec.description       := p_description;
    l_step_rec.ref_request_id    := g_request_id;
    l_step_rec.process_message   := p_message;
    l_step_rec.creation_date     := g_sysdate;
    l_step_rec.created_by        := g_user_id;
    l_step_rec.last_updated_by   := g_user_id;
    l_step_rec.last_update_date  := g_sysdate;
    l_step_rec.last_update_login := g_login_id;
    INSERT INTO xxfnd_file_process_steps
    VALUES l_step_rec;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END log_step;

  PROCEDURE update_step(p_request_id  IN NUMBER,
                        p_step_number IN NUMBER,
                        p_message     IN VARCHAR2) IS
    l_step_rec xxfnd_file_process_steps%ROWTYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  
    UPDATE xxfnd_file_process_steps
       SET process_message = p_message
     WHERE ref_request_id = p_request_id
       AND step_no = p_step_number;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END update_step;

  --add by jiaming.zhou 2014-06-18 start
  FUNCTION get_separator_length(p_separator IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_separator IS
      SELECT length('|| chr(' || xl.lookup_code || ') || ''')
        FROM xxfnd_lookups xl
       WHERE xl.lookup_type = 'XXFND_COLUMN_SEPARATOR'
         AND xl.enabled_flag = 'Y'
         AND SYSDATE BETWEEN nvl(xl.start_date_active, SYSDATE) AND nvl(xl.end_date_active, SYSDATE)
         AND xl.lookup_code = p_separator;
    l_separator NUMBER;
  BEGIN
    OPEN cur_separator;
    FETCH cur_separator
      INTO l_separator;
    IF cur_separator%NOTFOUND THEN
      l_separator := length('|| chr() || ''');
    END IF;
    CLOSE cur_separator;
    RETURN l_separator;
  END;
  --add by jiaming.zhou 2014-06-18 end

  FUNCTION get_param(p_interface_id IN NUMBER,
                     x_status       OUT VARCHAR2,
                     x_message      OUT VARCHAR2) RETURN xxfnd_interface_config%ROWTYPE IS
    l_api_name VARCHAR2(30) := 'get_interface';
    l_phase    VARCHAR2(30);
    l_module   VARCHAR2(400);
    CURSOR cur_param IS
      SELECT *
        FROM xxfnd_interface_config xic
       WHERE xic.enabled_flag = 'Y'
         AND xic.frozen_flag = 'Y'
         AND xic.interface_id = p_interface_id;
    l_param_rec cur_param%ROWTYPE;
  BEGIN
    x_status  := g_success;
    x_message := NULL;
  
    l_phase  := '10.Get interface config info.';
    l_module := get_module(g_pkg_name, l_api_name, l_phase);
    OPEN cur_param;
    FETCH cur_param
      INTO l_param_rec;
    IF cur_param%NOTFOUND THEN
      x_status  := g_error;
      x_message := 'Error:no interface config found.';
    END IF;
    CLOSE cur_param;
  
    log_message(l_module, x_status, x_message);
    RETURN l_param_rec;
  END get_param;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  split_names
  *
  *   DESCRIPTION: 
  *       Split the names into type table
  *   ARGUMENT: p_string       file name string
  *             p_charset      charset
  *   RETURN  : Y/N
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE split_names(p_string  IN VARCHAR2,
                        p_splitby IN VARCHAR2 DEFAULT ':') IS
    l_idx    NUMBER;
    l_string VARCHAR2(32000) := ltrim(p_string, ':');
    l_count  NUMBER := 0;
  BEGIN
    fnd_file.put_line(fnd_file.log, 'l_string=' || l_string);
    g_file_tbl.delete;
    IF l_string IS NOT NULL THEN
      LOOP
        l_idx := instr(l_string, p_splitby);
        IF l_idx > 0 THEN
          l_count := l_count + 1;
          g_file_tbl(l_count) := substr(l_string, 1, l_idx - 1);
          l_string := substr(l_string, l_idx + length(p_splitby));
        ELSE
          l_count := l_count + 1;
          g_file_tbl(l_count) := l_string;
          EXIT;
        END IF;
      END LOOP;
    END IF;
  
  END split_names;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  is_charset_valid
  *
  *   DESCRIPTION: 
  *       Judge the charset is valid or not
  *   ARGUMENT: p_charset      charset
  *   RETURN  : Y/N
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  FUNCTION is_charset_valid(p_charset IN VARCHAR2) RETURN VARCHAR2 IS
    l_flag VARCHAR2(1);
  BEGIN
  
    IF p_charset IN ('GBK', 'UTF16', 'UTF8', 'UTF-16', 'UTF-8', 'Unicode', 'TIS620', 'JIS') THEN
      l_flag := 'Y';
    ELSE
      l_flag := 'N';
    END IF;
    RETURN l_flag;
  EXCEPTION
    WHEN OTHERS THEN
      log('is_charset_valid Error:' || SQLERRM);
      RETURN 'N';
  END is_charset_valid;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_file_encode
  *
  *   DESCRIPTION: 
  *       get the file charset
  *   ARGUMENT: p_file_name      file name
  *   RETURN  : charset, now only include:'GBK','UTF16','UTF8','Unicode','TIS620','JIS'
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  FUNCTION get_file_encode(p_file_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_charset VARCHAR2(2000);
  BEGIN
    log('p_file_name = ' || p_file_name);
    l_charset := getfileencode(filename => p_file_name);
    IF is_charset_valid(l_charset) = 'N' THEN
      dbms_output.put_line('Get charset error.l_charset:' || l_charset);
      RAISE fnd_api.g_exc_error;
    END IF;
    RETURN l_charset;
    dbms_output.put_line('l_file_names:' || p_file_name);
    dbms_output.put_line('l_charset:' || l_charset);
  EXCEPTION
    WHEN OTHERS THEN
      log('get_file_encode Error:' || SQLERRM);
      RETURN l_charset;
  END get_file_encode;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  insert_lob
  *
  *   DESCRIPTION: 
  *       insert blob data
  *   ARGUMENT: p_file_id        the key value of the fnd_lobs
  *             p_file_name      file name
  *             p_lobs           blob data
  *             p_charset        char set
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE insert_lob(p_file_id   IN VARCHAR2,
                       p_file_name IN VARCHAR2,
                       p_lobs      IN BLOB,
                       p_charset   IN VARCHAR2) IS
  
  BEGIN
    dbms_output.put_line('p_file_Id:' || p_file_id);
    INSERT INTO fnd_lobs
      (file_id,
       file_name,
       file_content_type,
       file_data,
       upload_date,
       program_name,
       program_tag,
       LANGUAGE,
       oracle_charset,
       file_format)
    VALUES
      (p_file_id,
       p_file_name,
       'text/html; charset=' || p_charset,
       p_lobs, --CLOB
       SYSDATE,
       'XXFND_FILE',
       'XXFND',
       'US',
       p_charset,
       'text');
  EXCEPTION
    WHEN OTHERS THEN
      log('insert_lob Error:' || SQLERRM);
      RAISE;
  END insert_lob;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  upload_file
  *
  *   DESCRIPTION: 
  *       upload db server file to database
  *   ARGUMENT: p_file_name      the whole path of the file
  *             p_charset        Character set --add 2012.07.05
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_file_id        file id 
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE upload_file(p_file_name     IN VARCHAR2,
                        p_charset       IN VARCHAR2,
                        p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                        p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                        x_file_id       OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_message        LONG;
    l_charset        VARCHAR2(2000);
    l_api_name       VARCHAR2(30) := 'upload_file';
    l_savepoint_name VARCHAR2(30) := 'upload_file_sp';
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    l_phase  := '10.upload file.';
    l_module := get_module(g_pkg_name, l_api_name, l_phase);
  
    --modified by Huaijun.yan@2012.07.05
    --l_charset := get_file_encode(p_file_name => p_file_name);
    l_charset := p_charset;
    --End
    log_message(l_module, x_return_status, 'l_charset:' || l_charset);
    --Char set is invalid or not
    --Modified by Huaijun.Yan 2012.07.05
    --IF is_charset_valid(l_charset) = 'Y' THEN
    --Get file ID
    SELECT fnd_lobs_s.nextval
      INTO x_file_id
      FROM dual;
  
    l_message := uploadfile(fileid => to_char(x_file_id), filename => p_file_name, charset => l_charset);
    /* ELSE
      log('l_charset:' || l_charset);
      RAISE fnd_api.g_exc_error;
    END IF;*/
    --End 
    log('l_file_names:' || p_file_name);
    log('l_message:' || l_message);
  
    IF l_message <> 'S' THEN
      fnd_message.set_name('FND', 'ERROR_MESSAGE');
      fnd_message.set_token('MESSAGE', l_message);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => p_commit,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END upload_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  extract_blob
  *
  *   DESCRIPTION: 
  *       split blob data
  *   ARGUMENT: p_file_id        the key value of the fnd_lobs
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE extract_blob(p_file_id       IN NUMBER,
                         p_interface_id  IN NUMBER,
                         p_int_rec       IN xxfnd_interface_config%ROWTYPE,
                         p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                         p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2) IS
  
    l_api_name       VARCHAR2(30) := 'extract_blob';
    l_savepoint_name VARCHAR2(30) := 'extract_blob_sp';
    l_message        LONG;
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
    l_oracle_charset VARCHAR2(40); --added 2012.07.05
  
    l_data BLOB := NULL;
  
    c_data        CLOB := NULL;
    n_pos         INTEGER;
    n_offset      INTEGER;
    n_clob_size   INTEGER;
    n_line_no     INTEGER;
    n_src_offset  INTEGER := 1;
    n_dest_offset INTEGER := 1;
    v_buf         VARCHAR2(30000);
    v_warn        VARCHAR2(30000);
  
    n_lang_ctx   INTEGER := dbms_lob.default_lang_ctx;
    l_file_id    NUMBER;
    l_file_name  VARCHAR2(256);
    l_src_cs     VARCHAR2(255);
    l_intf_date  DATE;
    l_sql_string VARCHAR2(32767);
    l_temp_rec   xxfnd_interface_middle_temp%ROWTYPE;
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    l_phase   := '10.extract blob.';
    l_module  := get_module(g_pkg_name, l_api_name, l_phase);
    l_message := 'Exract blob.file ID=' || p_file_id;
    log_message(l_module, x_return_status, l_message);
  
    l_file_id := p_file_id;
  
    dbms_lob.createtemporary(c_data, FALSE, dbms_lob.session);
  
    -- Get blob(L_DATA)
    IF p_file_id IS NOT NULL THEN
      SELECT fl.file_data,
             fl.file_name,
             fl.oracle_charset,
             fl.upload_date
        INTO l_data,
             l_file_name,
             l_src_cs,
             l_intf_date
        FROM fnd_lobs fl
       WHERE fl.file_id = p_file_id
         FOR UPDATE OF file_id;
    
      dbms_output.put_line(dbms_lob.getlength(l_data));
      IF dbms_lob.getlength(l_data) = 0 THEN
        log('The upload file is null.');
        RETURN;
      END IF;
    
      -- Judge the character set is UTF8 or not
      /*IF l_src_cs <> cv_dest_cs THEN
        l_data := convertblob(l_data,
                              l_src_cs,
                              cv_dest_cs);
        SELECT fnd_lobs_s.nextval INTO l_file_id FROM dual;
        dbms_output.put_line('l_new_file_id:'||l_file_id);
        
        insert_lob(p_file_Id   => l_file_id,
                   p_file_name => l_file_name,
                   p_lobs      => l_data,
                   p_charset   => cv_dest_cs);
      END IF;*/
    
      -- Convert the BLOB format to CLOB format
      --added by huaijun.yan 2012.07.05
      l_oracle_charset := nvl(p_int_rec.oracle_characterset, cv_dest_cs);
      --end;
      dbms_lob.converttoclob(dest_lob     => c_data,
                             src_blob     => l_data,
                             amount       => dbms_lob.lobmaxsize,
                             dest_offset  => n_dest_offset,
                             src_offset   => n_src_offset,
                             blob_csid    => nls_charset_id(l_oracle_charset),
                             lang_context => n_lang_ctx,
                             warning      => v_warn);
    
      --c_data := TRIM(REPLACE(c_data,'"'));  
      DELETE xxfnd_interface_middle_temp;
      n_clob_size := dbms_lob.getlength(c_data);
      v_buf       := dbms_lob.substr(lob_loc => c_data,
                                     amount  => 1, -- N_NEXT_POS - N_POS,
                                     offset  => n_clob_size - 1);
    
      --dbms_output.put_line(n_clob_size || ':' || ascii(v_buf));
      IF v_buf <> chr(10) AND v_buf <> chr(13) AND n_clob_size > 0 THEN
        --Last row has no chr(10)
        c_data      := c_data || chr(10);
        n_clob_size := dbms_lob.getlength(c_data);
      END IF;
      --log('n_clob_size = ' || n_clob_size);
      n_offset  := 1;
      n_line_no := 1;
      LOOP
        n_pos := dbms_lob.instr(lob_loc => c_data, pattern => chr(10), offset => n_offset, nth => 1);
        --dbms_output.put_line(to_char(n_pos));
        --log('n_pos = ' || n_pos);
        IF nvl(n_pos, 0) = 0 THEN
          n_pos := n_clob_size + 1;
        END IF;
      
        EXIT WHEN n_pos > n_clob_size;
      
        v_buf := dbms_lob.substr(lob_loc => c_data,
                                 amount  => n_pos - n_offset, -- N_NEXT_POS - N_POS,
                                 offset  => n_offset); --N_POS+1);
        --dbms_output.put_line(v_buf);
      
        n_offset := n_pos + 1;
      
        -- break down the fields into different columns by the Tab Delimiter
        l_temp_rec                := NULL;
        l_temp_rec.interface_id   := p_interface_id;
        l_temp_rec.interface_date := l_intf_date;
        l_temp_rec.file_id        := l_file_id;
        l_temp_rec.line_num       := n_line_no;
        l_temp_rec.raw_data       := REPLACE(v_buf, chr(13));
        IF l_temp_rec.raw_data IS NOT NULL THEN
          INSERT INTO xxfnd_interface_middle_temp
          VALUES l_temp_rec;
        END IF;
        --log(l_temp_rec.raw_data);
        n_line_no := n_line_no + 1;
      END LOOP;
    
      IF dbms_lob.istemporary(l_data) > 0 THEN
        dbms_lob.freetemporary(l_data);
      END IF;
    
      IF dbms_lob.istemporary(c_data) > 0 THEN
        dbms_lob.freetemporary(c_data);
      END IF;
    
      l_phase   := '20.end insert data into middle template.';
      l_module  := get_module(g_pkg_name, l_api_name, l_phase);
      l_message := 'Read temp file.l_temp_file=' || l_file_name || ',row_count=' || n_line_no;
      log_message(l_module, x_return_status, l_message);
    
      --move record to interface tbl
      xxfnd_file_pkg.g_group_id := NULL;
      l_sql_string              := NULL;
      l_sql_string              := 'select ' || p_int_rec.group_seq_name || '.nextval from dual';
      EXECUTE IMMEDIATE l_sql_string
        INTO xxfnd_file_pkg.g_group_id;
    
      l_phase   := '30.Insert data into interface table.';
      l_module  := get_module(g_pkg_name, l_api_name, l_phase);
      l_message := 'Insert record to interface table.l_list_rec.interface_id=' || p_interface_id ||
                   ',l_list_rec.file_id=' || p_file_id || ',p_int_rec.title_rows=' || p_int_rec.title_rows ||
                   ',g_group_id=' || xxfnd_file_pkg.group_id;
      log_message(l_module, x_return_status, l_message);
    
      l_sql_string := NULL;
      l_sql_string := p_int_rec.data_fetch_sql;
      --log(l_sql_string);    
      BEGIN
        EXECUTE IMMEDIATE l_sql_string
          USING IN p_interface_id, p_file_id, p_int_rec.title_rows;
      EXCEPTION
        WHEN OTHERS THEN
          l_message := 'End insert data into interface table.Error:' || SQLERRM;
          log_message(l_module, 'E', l_message);
          log(l_message);
          RAISE fnd_api.g_exc_error;
      END;
    
      l_message := 'Successfully insert data into interface table.';
      log_message(l_module, x_return_status, l_message);
    
    END IF;
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => p_commit,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END extract_blob;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  process_file
  *
  *   DESCRIPTION: 
  *      process file
  *   ARGUMENT: p_file_name      file name. if multiple, combination with ;
  *             p_interface_id   Interface name ID
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE process_file(p_file_name     IN VARCHAR2,
                         p_interface_id  IN NUMBER,
                         p_int_rec       IN xxfnd_interface_config%ROWTYPE,
                         p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                         p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                         x_file_id       OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       VARCHAR2(30) := 'process_file';
    l_savepoint_name VARCHAR2(30) := 'process_file_sp';
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
    l_file_names     VARCHAR2(4000);
    l_file_id        NUMBER;
  BEGIN
  
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    l_phase  := '10.upload file.';
    l_module := get_module(g_pkg_name, l_api_name, l_phase);
  
    upload_file(p_file_name     => p_file_name,
                p_charset       => nvl(p_int_rec.java_characterset, cv_dest_cs), --2012.07.05
                p_init_msg_list => p_init_msg_list,
                p_commit        => p_commit,
                x_file_id       => l_file_id,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
    log_message(l_module, x_return_status, 'l_file_id:' || l_file_id || ' ' || x_msg_data);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    l_phase  := '20.extract blob.';
    l_module := get_module(g_pkg_name, l_api_name, l_phase);
    extract_blob(p_file_id       => l_file_id,
                 p_interface_id  => p_interface_id,
                 p_int_rec       => p_int_rec,
                 p_init_msg_list => p_init_msg_list,
                 p_commit        => p_commit,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data);
    log_message(l_module, x_return_status, 'End extract blob ' || x_msg_data);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    x_file_id := l_file_id;
  
    dbms_output.put_line('l_file_names:' || l_file_names);
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => p_commit,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END process_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  delete_file
  *
  *   DESCRIPTION: 
  *      delete file
  *   ARGUMENT: p_file_name      file name ;
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE delete_file(p_file_name     IN VARCHAR2,
                        p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                        p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       VARCHAR2(30) := 'delete_file';
    l_savepoint_name VARCHAR2(30) := 'delete_file_sp';
    l_message        VARCHAR2(2000);
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
  BEGIN
  
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    --Initialize the table parameter  
    l_phase  := '10.Start delete file.';
    l_module := get_module(g_pkg_name, l_api_name, l_phase);
    log_message(l_module, x_return_status, 'p_file_name:' || p_file_name);
    l_message := deletefile(filename => p_file_name);
    IF l_message <> 'S' THEN
      fnd_message.set_name('FND', 'ERROR_MESSAGE');
      fnd_message.set_token('MESSAGE', l_message);
      fnd_msg_pub.add;
      log_message(l_module, 'E', 'End call deleteFile:' || l_message);
      log(g_pkg_name || '.' || l_api_name || ':' || l_message);
      RAISE fnd_api.g_exc_error;
    END IF;
    log_message(l_module, x_return_status, 'End call deleteFile:' || p_file_name);
  
    dbms_output.put_line('p_file_name:' || p_file_name);
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => p_commit,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END delete_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  create_file
  *
  *   DESCRIPTION: 
  *      process file
  *   ARGUMENT: p_file_id        file id ;
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE create_file(p_file_id       IN NUMBER,
                        p_orig_path     IN VARCHAR2,
                        p_new_path      IN VARCHAR2,
                        p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                        p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       VARCHAR2(30) := 'create_file';
    l_savepoint_name VARCHAR2(30) := 'create_file_sp';
    l_message        VARCHAR2(2000);
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
    l_file_name      VARCHAR2(255);
    l_file_dir       VARCHAR2(255);
    l_charset        VARCHAR2(40);
    l_blob           BLOB;
  BEGIN
  
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    l_phase   := '10.Get file blob.';
    l_message := NULL;
    l_module  := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
  
    BEGIN
      SELECT fl.file_name,
             fl.file_data,
             fl.oracle_charset
        INTO l_file_name,
             l_blob,
             l_charset
        FROM fnd_lobs fl
       WHERE fl.file_id = p_file_id;
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('FND', 'ERROR_MESSAGE');
        fnd_message.set_token('MESSAGE', ' Get file no data found. file id:' || p_file_id || SQLERRM);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      WHEN OTHERS THEN
        fnd_message.set_name('FND', 'ERROR_MESSAGE');
        fnd_message.set_token('MESSAGE', ' file id:' || p_file_id || ' ' || SQLERRM);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
    END;
  
    l_file_name := p_new_path || REPLACE(l_file_name, p_orig_path);
    l_file_dir  := substr(l_file_name, 1, instr(l_file_name, '/', -1, 1));
    log_message(l_module, x_return_status, 'New file_name:' || l_file_name || ';l_file_dir:' || l_file_dir);
  
    --20 
    l_phase   := '20.Create File.';
    l_message := NULL;
    l_module  := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
  
    l_message := createfile(filedir => l_file_dir, filename => l_file_name, charset => l_charset, inblob => l_blob);
    log_message(l_module, x_return_status, l_message);
    IF l_message <> 'S' THEN
      fnd_message.set_name('FND', 'ERROR_MESSAGE');
      fnd_message.set_token('MESSAGE', l_message);
      fnd_msg_pub.add;
      log_message(l_module, 'E', l_message);
      log(g_pkg_name || '.' || l_api_name || ':' || l_message);
      RAISE fnd_api.g_exc_error;
    END IF;
  
    IF g_debug <> 'Y' THEN
      DELETE fnd_lobs
       WHERE file_id = p_file_id;
    END IF;
  
    dbms_output.put_line('l_file_names:' || p_file_id);
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => p_commit,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END create_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  list_file
  *
  *   DESCRIPTION: 
  *      list file
  *   ARGUMENT: p_file_id        file id ;
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE list_file(p_int_rec IN xxfnd_interface_config%ROWTYPE,
                      p_ledger  IN VARCHAR2,
                      x_status  OUT VARCHAR2,
                      x_message OUT VARCHAR2) IS
    l_api_name       VARCHAR2(30) := 'list_file';
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
    l_data_file_path VARCHAR2(400);
    l_ctl_file       VARCHAR2(400);
    l_file_list_rec  xxfnd_file_list_temp%ROWTYPE;
    l_status         VARCHAR2(1);
    l_file_names     VARCHAR2(4000);
    l_message        VARCHAR2(4000);
    l_ledger_path    VARCHAR2(30);
  BEGIN
    --init
    l_phase  := '10.initialize.';
    l_module := get_module(g_pkg_name, l_api_name, l_phase);
  
    l_status  := g_success;
    l_message := NULL;
    IF p_ledger IS NOT NULL THEN
      l_ledger_path := REPLACE(upper(p_ledger), ' ', '_') || g_if_path_separator;
    END IF;
    l_data_file_path := g_if_base_path || g_if_path_separator || p_int_rec.interface_folder || g_if_path_separator ||
                        l_ledger_path || p_int_rec.unprocess_subfdr;
    DELETE FROM xxfnd_file_list_temp;
    l_message := 'control_flag=' || p_int_rec.control_flag;
    log_message(l_module, l_status, l_message);
  
    l_phase   := '20.Generate file list.';
    l_module  := get_module(g_pkg_name, l_api_name, l_phase);
    l_status  := g_success;
    l_message := NULL;
  
    --whether enable control file
    IF p_int_rec.control_flag = 'Y' THEN
      --read control file
      l_ctl_file := l_data_file_path || g_if_path_separator || p_int_rec.control_file;
      l_message  := 'l_ctl_file=' || l_ctl_file;
      log_message(l_module, l_status, l_message);
    
      l_file_names := readfilenames(l_ctl_file, cv_dest_cs, g_split_by);
    
      --split file names into table
      split_names(l_file_names);
    
      FOR i IN 1 .. g_file_tbl.count
      LOOP
        BEGIN
          l_file_list_rec                := NULL;
          l_file_list_rec.interface_id   := p_int_rec.interface_id;
          l_file_list_rec.interface_date := g_sysdate;
          l_file_list_rec.file_path      := l_data_file_path;
          l_file_list_rec.file_name      := g_file_tbl(i);
          l_file_list_rec.full_name      := l_data_file_path || g_if_path_separator || g_file_tbl(i);
          l_file_list_rec.file_id        := xxfnd_interface_fileid_s.nextval;
        
          INSERT INTO xxfnd_file_list_temp
          VALUES l_file_list_rec;
        EXCEPTION
          WHEN OTHERS THEN
            l_message := 'Insert into xxfnd_file_list_temp error:' || SQLERRM;
            log_message(l_module, l_status, l_message);
            EXIT;
        END;
      END LOOP;
    
      l_message := 'row_count=' || g_file_tbl.count;
      log_message(l_module, l_status, l_message);
    
    ELSE
      --list file in directory
      l_file_names := getlistfiles(path    => l_data_file_path || g_if_path_separator,
                                   suffix  => NULL,
                                   isdepth => 'TRUE',
                                   splitby => g_split_by);
    
      --split file names into table
      split_names(l_file_names);
    
      l_message := 'List file in dir.l_data_file_path=' || l_data_file_path || ',l_file_list_tbl.count=' ||
                   g_file_tbl.count;
      log_message(l_module, l_status, l_message);
    
      FOR i IN 1 .. g_file_tbl.count
      LOOP
        l_file_list_rec                := NULL;
        l_file_list_rec.interface_id   := p_int_rec.interface_id;
        l_file_list_rec.interface_date := g_sysdate;
        l_file_list_rec.file_path      := l_data_file_path;
        l_file_list_rec.file_name      := REPLACE(g_file_tbl(i), l_data_file_path || g_if_path_separator);
        l_file_list_rec.full_name      := g_file_tbl(i);
        l_file_list_rec.file_id        := xxfnd_interface_fileid_s.nextval;
        INSERT INTO xxfnd_file_list_temp
        VALUES l_file_list_rec;
      END LOOP;
    
      l_message := 'List file.';
      log_message(l_module, l_status, l_message);
    END IF;
  
    x_status  := l_status;
    x_message := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_status  := g_error;
      x_message := 'Error:' || SQLERRM;
  END list_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  inbound
  *
  *   DESCRIPTION: 
  *      inbound file
  *   ARGUMENT: p_interface_id   interface ID ;
  *             p_txn_id         transaction ID
  *             p_init_msg_list  initial message list
  *             p_commit         commit flag
  *             x_return_status  status code
  *             x_msg_count      message count
  *   HISTORY:
  *     1.00 2012-03-06 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE inbound(p_interface_id  IN NUMBER,
                    p_txn_id        IN NUMBER,
                    p_ledger        IN VARCHAR2,
                    p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                    p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                    x_grp_list      OUT NOCOPY VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2) IS
    -- Disabled by eric.liu on 04-JUN-2012 begin
    --PRAGMA AUTONOMOUS_TRANSACTION;
    -- Disabled by eric.liu on 04-JUN-2012 end
    l_api_name       VARCHAR2(30) := 'inbound';
    l_savepoint_name VARCHAR2(30) := 'inbound_sp';
    l_message        VARCHAR2(2000);
    l_phase          VARCHAR2(100);
    l_module         VARCHAR2(400);
    l_file_count     NUMBER := 0;
    l_file_id        NUMBER;
    l_orig_path      VARCHAR2(200);
    l_new_path       VARCHAR2(200);
    l_sql_string     VARCHAR2(200);
  
    l_ledger_path VARCHAR2(30);
  
    l_para_rec xxfnd_interface_config%ROWTYPE;
    l_grp_list g_grp_list_type;
  
    CURSOR c_file_cur IS
      SELECT interface_id,
             interface_date,
             file_path,
             file_name,
             full_name,
             file_id
        FROM xxfnd_file_list_temp t
       ORDER BY file_name;
  
  BEGIN
  
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    --10 Get the interface configuation
    --Get param
    l_phase := '10.Get interface config.';
    log_step(p_transaction_id => p_txn_id,
             p_step_number    => 10,
             p_description    => 'Get interface config',
             p_message        => NULL);
    g_interface_id := p_interface_id;
    l_message      := NULL;
    l_module       := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
    l_para_rec     := get_param(p_interface_id, x_return_status, l_message);
    log_message(l_module, x_return_status, l_message);
  
    --20 Get the control file and file list  
    l_phase := '20.List file.';
    log_step(p_transaction_id => p_txn_id, p_step_number => 20, p_description => 'List file', p_message => NULL);
    l_message := NULL;
    l_module  := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
    list_file(p_int_rec => l_para_rec, p_ledger => p_ledger, x_status => x_return_status, x_message => l_message);
    log_message(l_module, x_return_status, 'End call list_file.' || l_message);
    --add by Colin.Chen at 2012-12-11
    IF x_return_status <> g_success THEN
      x_return_status := g_error;
      RETURN;
    END IF;
    --end add
    FOR c1 IN c_file_cur
    LOOP
      l_file_count := l_file_count + 1;
      --30 Upload the files into blob and extact blob data into middle template
      l_phase := '30.Upload the files into blob, then into tempalte.';
      log_step(p_transaction_id => p_txn_id,
               p_step_number    => 30,
               p_description    => 'Upload the files into blob, then into tempalte',
               p_message        => NULL);
      l_message := NULL;
      l_module  := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
      log_message(l_module, x_return_status, l_message);
      process_file(p_file_name     => c1.full_name,
                   p_interface_id  => p_interface_id,
                   p_int_rec       => l_para_rec,
                   p_init_msg_list => p_init_msg_list,
                   p_commit        => p_commit,
                   x_file_id       => l_file_id,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data);
      log_message(l_module, x_return_status, 'End call process_file.' || x_msg_data);
      update_step(g_request_id, 30, x_msg_data);
      IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    
      --40 delete files from unprocess folder  
      l_phase := '40.Delete files from unprocess folder.';
      log_step(p_transaction_id => p_txn_id,
               p_step_number    => 40,
               p_description    => 'Delete files from unprocess folder',
               p_message        => NULL);
      l_message := NULL;
      l_module  := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
      log_message(l_module, x_return_status, l_message);
      delete_file(p_file_name     => c1.full_name,
                  p_init_msg_list => p_init_msg_list,
                  p_commit        => p_commit,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data);
      log_message(l_module, x_return_status, 'End call delete_file.' || x_msg_data);
      update_step(g_request_id, 40, x_msg_data);
      IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    
      --50 Create file in processed folder
      l_phase := '50.Create file in processed folder.';
      log_step(p_transaction_id => p_txn_id,
               p_step_number    => 50,
               p_description    => 'Create file in processed folder',
               p_message        => NULL);
      l_message := NULL;
      l_module  := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
      IF p_ledger IS NOT NULL THEN
        l_ledger_path := REPLACE(upper(p_ledger), ' ', '_') || g_if_path_separator;
      END IF;
      l_orig_path := g_if_base_path || g_if_path_separator || l_para_rec.interface_folder || g_if_path_separator ||
                     l_ledger_path || l_para_rec.unprocess_subfdr || g_if_path_separator;
      l_new_path  := g_if_base_path || g_if_path_separator || l_para_rec.interface_folder || g_if_path_separator ||
                     l_ledger_path || l_para_rec.processed_subfdr || g_if_path_separator;
      log_message(l_module, x_return_status, l_message);
      create_file(p_file_id       => l_file_id,
                  p_orig_path     => l_orig_path,
                  p_new_path      => l_new_path,
                  p_init_msg_list => p_init_msg_list,
                  p_commit        => p_commit,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data);
      log_message(l_module, x_return_status, 'End call create_file.' || x_msg_data);
      update_step(g_request_id, 50, x_msg_data);
      IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    
      l_grp_list(l_file_count) := xxfnd_file_pkg.group_id;
    
    END LOOP;
  
    FOR i IN 1 .. l_grp_list.count
    LOOP
      x_grp_list := x_grp_list || CASE
                      WHEN x_grp_list IS NULL THEN
                       ''
                      ELSE
                       ','
                    END || l_grp_list(i);
    
    END LOOP;
  
    xxfnd_file_pkg.g_group_list := x_grp_list;
  
    --60 end inbound
    l_phase := '60.End inbound.';
    log_step(p_transaction_id => p_txn_id, p_step_number => 60, p_description => 'End inbound', p_message => NULL);
    IF l_file_count = 0 THEN
      x_return_status := g_warning;
      l_message       := 'No file processed';
    ELSE
      x_return_status := g_success;
      l_message       := NULL;
    END IF;
    l_module := xxfnd_file_pkg.get_module(g_pkg_name, l_api_name, l_phase);
    log_message(l_module, x_return_status, l_message);
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => fnd_api.g_true,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END inbound;

  FUNCTION get_fix_data_file_name(p_int_rec IN xxfnd_interface_config%ROWTYPE,
                                  p_ledger  IN VARCHAR2) RETURN VARCHAR2 IS
    l_data_file_name VARCHAR2(60);
  BEGIN
    IF p_int_rec.interface_code = 'IF26' THEN
      /*OPEN cur;
      FETCH cur
        INTO l_current_serial;
      CLOSE cur;
      IF l_current_serial IS NULL THEN
        l_current_serial := 1;
      ELSE
        l_current_serial := l_current_serial + 1;
      END IF;
      INSERT INTO xxfnd_int_file_serial
      VALUES
        (p_int_rec.interface_id
        ,p_ledger
        ,l_current_serial
        ,SYSDATE
        ,SYSDATE
        ,g_user_id
        ,g_user_id
        ,SYSDATE
        ,g_login_id
        ,g_request_id);
      l_data_file_name := 'CUSTGS00N' ||
                          lpad(MOD(l_current_serial, 1000), 3, '0')||'.txt';*/
      IF upper(p_ledger) = 'SHE LEDGER' THEN
        l_data_file_name := 'CUSTGS00N001' || p_int_rec.datafile_suffix;
      ELSE
        l_data_file_name := 'CUSTFB00N001' || p_int_rec.datafile_suffix;
      END IF;
    ELSIF p_int_rec.interface_code = 'IF27' THEN
      /*OPEN cur;
      FETCH cur
        INTO l_current_serial;
      CLOSE cur;
      IF l_current_serial IS NULL THEN
        l_current_serial := 1;
      ELSE
        l_current_serial := l_current_serial + 1;
      END IF;
      INSERT INTO xxfnd_int_file_serial
      VALUES
        (p_int_rec.interface_id
        ,p_ledger
        ,l_current_serial
        ,SYSDATE
        ,SYSDATE
        ,g_user_id
        ,g_user_id
        ,SYSDATE
        ,g_login_id
        ,g_request_id);
      l_data_file_name := 'VENDGS00N' ||
                          lpad(MOD(l_current_serial, 1000), 3, '0')||'.txt';*/
      IF upper(p_ledger) = 'SHE LEDGER' THEN
        l_data_file_name := 'VENDGS00N001' || p_int_rec.datafile_suffix;
      ELSE
        l_data_file_name := 'VENDFB00N001' || p_int_rec.datafile_suffix;
      END IF;
    ELSIF p_int_rec.interface_code = 'IF45' THEN
      IF upper(p_ledger) = 'SHE LEDGER' THEN
        l_data_file_name := 'INTOGS00N001' || p_int_rec.datafile_suffix;
      END IF;
    END IF;
    RETURN l_data_file_name;
  END get_fix_data_file_name;

  FUNCTION get_data_file_name(p_int_rec IN xxfnd_interface_config%ROWTYPE,
                              p_ledger  IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_date(p_date IN DATE) IS
      SELECT xifs.serial_number
        FROM xxfnd_int_file_serial xifs
       WHERE xifs.ledger_name = p_ledger
         AND xifs.interface_id = p_int_rec.interface_id
         AND trunc(xifs.last_date) = trunc(p_date)
       ORDER BY xifs.serial_number DESC;
    CURSOR cur IS
      SELECT xifs.serial_number
        FROM xxfnd_int_file_serial xifs
       WHERE xifs.ledger_name = p_ledger
         AND xifs.interface_id = p_int_rec.interface_id
       ORDER BY xifs.serial_number DESC;
    l_current_serial NUMBER;
    l_post_flag      VARCHAR2(1);
    l_data_file_name VARCHAR2(60);
  BEGIN
    l_data_file_name := get_fix_data_file_name(p_int_rec => p_int_rec, p_ledger => p_ledger);
    IF l_data_file_name IS NULL THEN
      IF p_int_rec.interface_code = 'IF10' THEN
        OPEN cur_date(SYSDATE);
        FETCH cur_date
          INTO l_current_serial;
        CLOSE cur_date;
        IF l_current_serial IS NULL THEN
          l_current_serial := 1;
        ELSE
          l_current_serial := l_current_serial + 1;
        END IF;
        INSERT INTO xxfnd_int_file_serial
        VALUES
          (p_int_rec.interface_id,
           p_ledger,
           l_current_serial,
           SYSDATE,
           SYSDATE,
           g_user_id,
           g_user_id,
           SYSDATE,
           g_login_id,
           g_request_id);
      
        IF upper(p_ledger) = 'SHE LEDGER' THEN
          l_post_flag := 'B';
        ELSE
          l_post_flag := 'A';
        END IF;
        l_data_file_name := to_char(SYSDATE, 'YYYYMMDD') || 'AT' || l_post_flag || lpad(l_current_serial, 4, '0') ||
                            '.txt';
      ELSIF p_int_rec.interface_code = 'IF49' THEN
        OPEN cur_date(SYSDATE);
        FETCH cur_date
          INTO l_current_serial;
        CLOSE cur_date;
        IF l_current_serial IS NULL THEN
          l_current_serial := 1;
        ELSE
          l_current_serial := l_current_serial + 1;
        END IF;
        INSERT INTO xxfnd_int_file_serial
        VALUES
          (p_int_rec.interface_id,
           p_ledger,
           l_current_serial,
           SYSDATE,
           SYSDATE,
           g_user_id,
           g_user_id,
           SYSDATE,
           g_login_id,
           g_request_id);
      
        l_data_file_name := to_char(SYSDATE, 'YYYYMMDD') || 'ATD' || lpad(l_current_serial, 4, '0') || '.txt';
      ELSE
        l_data_file_name := p_int_rec.datafile_prefix || to_char(SYSDATE, g_date_format) || p_int_rec.datafile_suffix;
      END IF;
    END IF;
  
    RETURN l_data_file_name;
  END get_data_file_name;

  PROCEDURE construc_file(p_int_rec  IN xxfnd_interface_config%ROWTYPE,
                          p_group_id IN NUMBER,
                          p_ledger   IN VARCHAR2,
                          x_status   OUT VARCHAR2,
                          x_message  OUT VARCHAR2) IS
    l_program          VARCHAR2(30) := 'construc_file';
    l_phase            VARCHAR2(30);
    l_module           VARCHAR2(400);
    l_status           VARCHAR2(1);
    l_message          VARCHAR2(4000);
    l_remote_data_file VARCHAR2(400);
    l_remote_file_dir  VARCHAR2(400);
    l_file             utl_file.file_type;
    TYPE l_data_type IS TABLE OF VARCHAR2(20000) INDEX BY PLS_INTEGER;
    l_data_rec       l_data_type;
    l_title_sql      VARCHAR2(20000);
    l_title          VARCHAR2(20000);
    cur_data         SYS_REFCURSOR;
    l_process_status VARCHAR2(1);
    l_file_data      CLOB;
    l_bfile_data     BLOB;
    l_length         PLS_INTEGER;
  
    l_ledger_path VARCHAR2(30);
    --added by Huaijun.Yan 2012.07.05 
    --l_charset        VARCHAR2(40) := 'UTF8';
    l_java_charset   VARCHAR2(40) := nvl(p_int_rec.java_characterset, cv_dest_cs);
    l_oracle_charset VARCHAR2(40) := nvl(p_int_rec.oracle_characterset, cv_dest_cs);
    l_trigger_dir    VARCHAR2(400);
    l_trigger_file   VARCHAR2(30) := 'Triger.txt';
    l_tfile_data     BLOB;
    --end
    --add by jiaming.zhou 2014-06-18 start
    l_separator_length NUMBER;
    --add by jiaming.zhou 2014-06-18 end
  
    n_src_offset  INTEGER := 1;
    n_dest_offset INTEGER := 1;
    v_buf         VARCHAR2(30000);
    v_warn        VARCHAR2(30000);
    n_lang_ctx    INTEGER := dbms_lob.default_lang_ctx;
  
    CURSOR cur_column IS
      SELECT xicc.column_name
        FROM xxfnd_interface_col_config xicc
       WHERE xicc.interface_id = p_int_rec.interface_id
         AND xicc.enabled_flag = 'Y'
       ORDER BY xicc.display_seq ASC;
  BEGIN
    l_status  := g_success;
    l_message := NULL;
  
    --init
    l_phase            := '10.Initialize Variable.';
    l_module           := get_module(g_pkg_name, l_program, l_phase);
    l_remote_data_file := NULL;
    l_remote_file_dir  := NULL;
    l_data_rec.delete;
    log_message(l_module, l_status, l_message);
  
    OPEN cur_data FOR p_int_rec.data_fetch_sql
      USING IN p_group_id, IN l_process_status;
    FETCH cur_data BULK COLLECT
      INTO l_data_rec;
  
    IF l_data_rec.count > 0 THEN
      --construct data file
      l_phase  := '20.Construct data file.';
      l_module := get_module(g_pkg_name, l_program, l_phase);
      IF p_ledger IS NOT NULL THEN
        l_ledger_path := REPLACE(upper(p_ledger), ' ', '_') || g_if_path_separator;
      END IF;
      l_remote_file_dir  := g_if_base_path || g_if_path_separator || p_int_rec.interface_folder || g_if_path_separator ||
                            l_ledger_path || p_int_rec.unprocess_subfdr || g_if_path_separator;
      l_remote_data_file := get_data_file_name(p_int_rec, p_ledger);
    
      l_trigger_dir := g_if_base_path || g_if_path_separator || p_int_rec.interface_folder || g_if_path_separator ||
                       l_ledger_path || 'endstatus' || g_if_path_separator;
    
      l_message := l_remote_file_dir || l_remote_data_file;
      log_message(l_module, l_status, l_message);
    
      dbms_lob.createtemporary(lob_loc => l_file_data, cache => TRUE, dur => dbms_lob.call);
      dbms_lob.createtemporary(lob_loc => l_bfile_data, cache => FALSE, dur => dbms_lob.call);
      dbms_lob.createtemporary(lob_loc => l_tfile_data, cache => FALSE, dur => dbms_lob.call);
      dbms_lob.writeappend(l_tfile_data, 1, utl_raw.cast_to_raw('S'));
      --add title
      IF p_int_rec.title_rows > 0 THEN
        l_phase     := '21.Construct title sql.';
        l_module    := get_module(g_pkg_name, l_program, l_phase);
        l_title_sql := 'select ''';
      
        FOR rec IN cur_column
        LOOP
          l_title_sql := l_title_sql || rec.column_name || ''' || chr(' || p_int_rec.column_separator || ') || ''';
        END LOOP;
      
        IF l_title_sql <> 'select ''' THEN
          --update by jiaming.zhou 2014-06-18 start
          --l_title_sql := substr(l_title_sql, 1, (length(l_title_sql) - 15));
          fnd_file.put_line(fnd_file.log,p_int_rec.column_separator);
          l_separator_length := get_separator_length(p_int_rec.column_separator);
          fnd_file.put_line(fnd_file.log,l_separator_length);
          l_title_sql        := substr(l_title_sql, 1, (length(l_title_sql) - l_separator_length));
          --update by jiaming.zhou 2014-06-18 end  
          l_title_sql := l_title_sql || ' || chr(13) || chr(10) from dual';
        
          EXECUTE IMMEDIATE l_title_sql
            INTO l_title;
          dbms_lob.writeappend(l_file_data,
                               lengthb(l_title),
                               /*utl_raw.cast_to_raw(*/
                               l_title /*)*/);
        END IF;
      END IF;
      FOR i IN 1 .. l_data_rec.count
      LOOP
        l_length := lengthb(l_data_rec(i) || chr(13) || chr(10));
        dbms_lob.writeappend(l_file_data,
                             l_length,
                             /*utl_raw.cast_to_raw(*/
                             l_data_rec(i) || chr(13) || chr(10)) /*)*/
        ;
      END LOOP;
      CLOSE cur_data;
    
      dbms_lob.converttoblob(dest_lob     => l_bfile_data,
                             src_clob     => l_file_data,
                             amount       => dbms_lob.lobmaxsize,
                             dest_offset  => n_dest_offset,
                             src_offset   => n_src_offset,
                             blob_csid    => nls_charset_id(l_oracle_charset),
                             lang_context => n_lang_ctx,
                             warning      => v_warn);
    
      l_message := createfile(filedir  => l_remote_file_dir,
                              filename => l_remote_file_dir || l_remote_data_file,
                              charset  => l_java_charset, --Modified 2012.07.05
                              inblob   => l_bfile_data);
      IF l_message <> 'S' THEN
        l_status := fnd_api.g_ret_sts_error;
      END IF;
    
      --Create trigger file
      /*l_message := createfile(filedir  => l_trigger_dir,
                              filename => l_trigger_dir ||
                                          l_trigger_file,
                              charset  => l_java_charset, --Modified 2012.07.05
                              inblob   => l_tfile_data);
      IF l_message <> 'S' THEN
        l_status := fnd_api.g_ret_sts_error;
      END IF;*/
      --add by jiaming.zhou 2014-06-02 start
      --ELSE
    ELSIF nvl(p_int_rec.interface_code, '@#$') <> 'IF54' THEN
      --add by jiaming.zhou 2014-06-02 end
      --modified by colin.chen begin
      --l_message := null;
    
      l_message := 'NO_DATA';
      l_status  := 'W';
    
      --end mod
    END IF;
  
    x_status  := l_status;
    x_message := l_message;
  EXCEPTION
    WHEN OTHERS THEN
      x_status  := g_error;
      x_message := 'Error:' || SQLERRM;
  END construc_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  isFileExists
  *
  *   DESCRIPTION: 
  *      Judge the file exists
  *   ARGUMENT: p_interface_id   Interface id 
  *   HISTORY:
  *     1.00 2012-11-12 Huaijun.Yan Creation
  * =============================================*/
  PROCEDURE isfileexists(p_interface_id IN NUMBER,
                         p_ledger       IN VARCHAR2,
                         x_status       OUT VARCHAR2,
                         x_message      OUT VARCHAR2) IS
    l_program          VARCHAR2(30) := 'isFileExists';
    l_phase            VARCHAR2(30);
    l_module           VARCHAR2(400);
    l_para_rec         xxfnd_interface_config%ROWTYPE;
    l_status           VARCHAR2(1);
    l_message          VARCHAR2(4000);
    l_remote_data_file VARCHAR2(400);
    l_remote_file_dir  VARCHAR2(400);
    l_flag             VARCHAR2(1);
    l_ledger_path      VARCHAR2(30);
  BEGIN
    x_status  := g_success;
    x_message := NULL;
    --IF 
    --Get param
    l_phase    := '10.Get interface config.';
    l_status   := g_success;
    l_message  := NULL;
    l_module   := get_module(g_pkg_name, l_program, l_phase);
    l_para_rec := get_param(p_interface_id, l_status, l_message);
    log_message(l_module, l_status, l_message);
  
    --Get file path
    l_phase            := '20.Get file path.';
    l_status           := NULL;
    l_message          := NULL;
    l_module           := get_module(g_pkg_name, l_program, l_phase);
    l_remote_data_file := get_fix_data_file_name(l_para_rec, p_ledger);
    IF l_remote_data_file IS NULL THEN
      RETURN;
    ELSE
      IF p_ledger IS NOT NULL THEN
        l_ledger_path := REPLACE(upper(p_ledger), ' ', '_') || g_if_path_separator;
      END IF;
      l_remote_file_dir := g_if_base_path || g_if_path_separator || l_para_rec.interface_folder || g_if_path_separator ||
                           l_ledger_path || l_para_rec.unprocess_subfdr || g_if_path_separator;
      log_message(l_module, l_status, l_message);
      l_flag := isfileexists(filename => l_remote_file_dir || l_remote_data_file);
      IF l_flag = 'Y' THEN
        l_status  := g_error;
        l_message := 'File <' || l_remote_file_dir || l_remote_data_file ||
                     '> already exists in file system, Cannot generate again.';
      ELSE
        RETURN;
      END IF;
    END IF;
  
    x_status  := l_status;
    x_message := l_message;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status  := g_error;
      x_message := 'isFileExists Program Unexpected error.' || SQLERRM;
    WHEN fnd_api.g_exc_error THEN
      x_status  := g_warning;
      x_message := 'isFileExists Program error.' || SQLERRM;
  END isfileexists;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  outbound
  *
  *   DESCRIPTION: 
  *      outbound file
  *   ARGUMENT: p_file_id        file id 
  *             p_group_id       group id
  *             x_status         status code
  *             x_message        message data
  *   HISTORY:
  *     1.00 2012-06-13 colin.chen Creation
  * =============================================*/
  PROCEDURE outbound(p_interface_id IN NUMBER,
                     p_group_id     IN NUMBER,
                     p_ledger       IN VARCHAR2,
                     x_status       OUT VARCHAR2,
                     x_message      OUT VARCHAR2) IS
    l_program  VARCHAR2(30) := 'outbound';
    l_phase    VARCHAR2(30);
    l_module   VARCHAR2(400);
    l_para_rec xxfnd_interface_config%ROWTYPE;
    l_status   VARCHAR2(1);
    l_message  VARCHAR2(4000);
  BEGIN
    x_status       := g_success;
    x_message      := NULL;
    g_interface_id := p_interface_id;
    --Get param
    l_phase    := '10.Get interface config.';
    l_status   := g_success;
    l_message  := NULL;
    l_module   := get_module(g_pkg_name, l_program, l_phase);
    l_para_rec := get_param(p_interface_id, l_status, l_message);
    log_message(l_module, l_status, l_message);
  
    --Construct data file
    l_phase   := '20.Construct data file.';
    l_status  := NULL;
    l_message := NULL;
    l_module  := get_module(g_pkg_name, l_program, l_phase);
    construc_file(l_para_rec, p_group_id, p_ledger, l_status, l_message);
    log_message(l_module, l_status, l_message);
  
    x_status  := l_status;
    x_message := l_message;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status  := g_error;
      x_message := 'Outbound Program Unexpected error.' || SQLERRM;
    WHEN fnd_api.g_exc_error THEN
      x_status  := g_warning;
      x_message := 'Outbound Program error.' || SQLERRM;
  END outbound;

END xxfnd_file_pkg;
/
