CREATE OR REPLACE PACKAGE xxinv_auto_push_mmt_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxinv_auto_push_mmt_pkg
  Description:
      This program provide concurrent main procedure to perform:
      some MTL_MATERIAL_TRANSACTIONS table error message
  History:
      1.00  2018-04-13 11:41:38  Hakim  Creation
  ==================================================*/

  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10) || chr(13);
  g_line        VARCHAR2(150) := rpad('-', 150, '-');
  g_space       VARCHAR2(40) := '&nbsp';

  g_last_updated_date DATE := SYSDATE;
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_creation_date     DATE := SYSDATE;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;

  g_request_id NUMBER := fnd_global.conc_request_id;
  g_session_id NUMBER := userenv('sessionid');
  g_b_return   BOOLEAN;

  PROCEDURE main(errbuf OUT VARCHAR2, retcode OUT VARCHAR2);

END xxinv_auto_push_mmt_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxinv_auto_push_mmt_pkg AS
  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  /*==================================================
  Program Name:
      xxinv_auto_push_mmt_pkg
  Description:
      This program provide concurrent main procedure to perform:
      some MTL_MATERIAL_TRANSACTIONS table error message
  History:
      1.00  2018-04-13 11:41:38  Hakim  Creation
  ==================================================*/

  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'xxinv_auto_push_mmt_pkg';
  g_type_text   CONSTANT VARCHAR2(40) := 'TEXT';

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

  PROCEDURE output_head(p_title VARCHAR2) IS
    -- report title
    l_title VARCHAR2(2000) := '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" >' ||
                              '<head> <title>p_title</title>' ||
                              ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8">' ||
                              '<style>  .cell{font-family:Arial} *{font-size:10.0pt;mso-font-charset:134;}  .cell{border:solid 1px; border-color:#000000;}</style>' ||
                              ' </head> <body>' ||
                              ' <p align=center style="font-weight:bold;"><font size="4">p_title</font></p>';
  
    -- column title
    l_column_title VARCHAR2(4000) := ' <table width=100% border=1 cellspacing=0 cellpadding=0' ||
                                     ' tyle="BORDER-COLLAPSE: collapse ">';
  
  BEGIN
  
    -- Report Title
    l_title := REPLACE(l_title, 'p_title', p_title);
  
    output(l_title);
  
    output(l_column_title);
  
  END output_head;

  PROCEDURE output_col_title(p_column_title VARCHAR2,
                             p_col_span     NUMBER DEFAULT 1) IS
    l_column_td    VARCHAR2(200) := ' <td align=left colspan=cols_pan ><font size="3">p_column_title</font></td>';
    l_column_title VARCHAR2(300);
  BEGIN
    IF p_column_title IS NOT NULL THEN
    
      l_column_td    := REPLACE(l_column_td, 'cols_pan', p_col_span);
      l_column_title := REPLACE(l_column_td,
                                'p_column_title',
                                nvl(p_column_title, g_space));
      output(l_column_title);
    END IF;
  END;
  
  FUNCTION transform_text(p_column_text VARCHAR2) RETURN VARCHAR2 IS
    l_column_text VARCHAR2(500);
  BEGIN
  
    l_column_text := REPLACE(REPLACE(REPLACE(REPLACE(p_column_text,
                                                     '&',
                                                     '&amp;'),
                                             '>',
                                             '&gt;'),
                                     '<',
                                     '&lt;'),
                             '"',
                             '&quot;');
  
    RETURN l_column_text;
  
  END;

  PROCEDURE output_text(p_column_text VARCHAR2,
                        p_bold_flag   VARCHAR2 := 'N') IS
    l_column_td    VARCHAR2(500) := ' <td align=left >column_text</td>';
    l_column_b_td  VARCHAR2(500) := ' <td align=left ><b>column_text</b></td>';
    l_column_text  VARCHAR2(500);
    l_column_text2 VARCHAR2(500);
  BEGIN
  
    l_column_text := transform_text(p_column_text);
  
    IF p_bold_flag = 'Y' THEN
      l_column_text2 := REPLACE(l_column_b_td,
                                'column_text',
                                nvl(l_column_text, g_space));
    ELSE
      l_column_text2 := REPLACE(l_column_td,
                                'column_text',
                                nvl(l_column_text, g_space));
    END IF;
    output(l_column_text2);
  
  END;

  PROCEDURE output_column(p_column_text VARCHAR2, p_column_type VARCHAR2) IS
  BEGIN
  
    IF p_column_text != chr(0) OR p_column_text IS NULL THEN
      IF p_column_type = g_type_text THEN
        output_text(p_column_text);
      END IF;
    END IF;
  
  END;

  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
  
    l_error_flag VARCHAR2(1);
  
    CURSOR cur_data IS
      SELECT mmt.transaction_id, mmt.error_explanation, mmt.costed_flag
        FROM MTL_MATERIAL_TRANSACTIONS mmt
       WHERE mmt.costed_flag = 'E';
    CURSOR cur_output(p_transaction_id IN NUMBER) IS
      SELECT mmt.transaction_id, mmt.error_explanation, mmt.costed_flag
        FROM MTL_MATERIAL_TRANSACTIONS mmt
       WHERE mmt.transaction_id = p_transaction_id;
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
  
    output_head('Auto Push MMT Report');
  
    output('<tr bgcolor="#a6a6a6">');
    output_col_title('Transaction ID');
    output_col_title('Error Message');
    output_col_title('Cost Flag');
    output_col_title('Process Status');
    output_col_title('Process Time');
    output('</tr>');
  
    -- API start body
    FOR rec_data IN cur_data LOOP
      l_error_flag := 'S';
      BEGIN
        UPDATE MTL_MATERIAL_TRANSACTIONS mmt
           SET mmt.costed_flag = 'N'
         WHERE mmt.transaction_id = rec_data.transaction_id;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          l_error_flag := 'E';
      END;
    
      FOR output_data IN cur_output(rec_data.transaction_id) LOOP
        output_column(output_data.transaction_id,g_type_text);
        output_column(output_data.error_explanation,g_type_text);
        output_column(output_data.costed_flag,g_type_text);
        output_column(l_error_flag,g_type_text);
        output_column(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'),g_type_text);
      END LOOP;
    END LOOP;
  
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
  END process_request;

  PROCEDURE main(errbuf OUT VARCHAR2, retcode OUT VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_error_flag    VARCHAR2(1);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body
  
    -- convert parameter data type, such as varchar2 to date
    -- l_date := fnd_conc_date.string_to_date(p_parameter1);
  
    -- call process request api
    process_request(p_init_msg_list => fnd_api.g_true,
                    p_commit        => fnd_api.g_true,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data);
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  
    IF l_error_flag = 'Y' THEN
      retcode := '1';
    END IF;
  
    -- conc end body
    -- concurrent footer log
    xxfnd_conc_utl.log_footer;
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first,
                                             p_encoded   => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first,
                                             p_encoded   => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END main;

END xxinv_auto_push_mmt_pkg;
/
