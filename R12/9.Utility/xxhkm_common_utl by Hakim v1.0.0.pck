CREATE OR REPLACE PACKAGE xxhkm_common_utl IS

  -- $Header: XXHKM_COMMON_UTL 2018/6/4 15:05:40 1.0.0 $
  -- ====================================================
  -- Copyright (C) HAND Enterprise Solutions Company Ltd.                                 
  --              All Rights Reserved $YEAR.                                            
  -- ====================================================

  -- ======================================================
  -- System       : Oracle Applications Add_on Development
  -- Module       : PACKAGE
  -- Package Name : XXHKM_COMMON_UTL
  -- Discription  : For convienience
  -- Language     : PL/SQL
  -- Version      : 1.0.0
  -- Modify       :

  -- Create       :
  --     Argument : New Development
  --     Date     : 2018/6/4 15:05:40
  --     Author   : 71346904
  --     Note     :
  -- modify       £º
  -- Version
  -- 
  -- ======================================================
  g_encoding    VARCHAR2(40) := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10) || chr(13);
  g_line        VARCHAR2(150) := rpad('-', 150, '-');

  g_last_updated_date DATE := SYSDATE;
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_creation_date     DATE := SYSDATE;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;

  g_request_id NUMBER := fnd_global.conc_request_id;
  g_session_id NUMBER := userenv('sessionid');

  PROCEDURE get_account_info(p_gl_code_combine_id IN NUMBER,
                             x_acc_num            OUT VARCHAR2,
                             x_acc_desc           OUT VARCHAR2);

  PROCEDURE main(errbuf       OUT VARCHAR2,
                 retcode      OUT VARCHAR2,
                 p_xxxxxxxxx1 IN VARCHAR2,
                 p_xxxxxxxxx2 IN VARCHAR2,
                 p_xxxxxxxxx3 IN VARCHAR2);
END xxhkm_common_utl;
/
CREATE OR REPLACE PACKAGE BODY xxhkm_common_utl IS

  -- $Header: XXHKM_COMMON_UTL 2018/6/4 15:05:40 1.0.0 $
  -- ====================================================
  -- Copyright (C) HAND Enterprise Solutions Company Ltd.                                 
  --              All Rights Reserved $YEAR.                                            
  -- ====================================================

  -- ======================================================
  -- System       : Oracle Applications Add_on Development
  -- Module       : PACKAGE
  -- Package Name : XXHKM_COMMON_UTL
  -- Discription  : For convienience
  -- Language     : PL/SQL
  -- Version      : 1.0.0
  -- Modify       :

  -- Create       :
  --     Argument : New Development
  --     Date     : 2018/6/4 15:05:40
  --     Author   : 71346904
  --     Note     :
  -- modify       £º
  -- Version
  -- 
  -- ======================================================
  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'XXHKM_COMMON_UTL';
  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');

  --output
  PROCEDURE output(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_content);
  END output;

  --log
  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_content);
  END log;

  --process_request
  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_start_date  IN DATE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_start_date DATE := trunc(fnd_conc_date.string_to_date(p_start_date));
  BEGIN
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
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
  END;
  PROCEDURE get_account_info(p_gl_code_combine_id IN NUMBER,
                             x_acc_num            OUT VARCHAR2,
                             x_acc_desc           OUT VARCHAR2) IS
  
  BEGIN
    NULL;
  END get_account_info;

  PROCEDURE main(errbuf       OUT VARCHAR2,
                 retcode      OUT VARCHAR2,
                 p_xxxxxxxxx1 IN VARCHAR2,
                 p_xxxxxxxxx2 IN VARCHAR2,
                 p_xxxxxxxxx3 IN VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body
  
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  
    -- conc end body
    -- concurrent footer log
    xxfnd_conc_utl.log_footer;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END;
END xxhkm_common_utl;
/
