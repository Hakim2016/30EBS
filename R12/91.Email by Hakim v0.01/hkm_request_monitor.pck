CREATE OR REPLACE PACKAGE hkm_request_monitor IS

  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/

  /*==========================================================================+
  *        Name : hkm_request_monitor
  * Description :                                                                
  *       
  +==========================================================================*/

  /*FUNCTION get_sequences_name(p_doc_sequence_id IN NUMBER) RETURN VARCHAR2;*/

  /*==========================================================================+
  *       Name  :   
  *              main                                                                                
  * Description :     
  *              ������ں���
  *                1�������־ͷ
  *                2����������
  *                3�������־β    
  *   Arguments :  
  *              retcode              -- 1:����/2����                                                           
  *              p_ledger_id          -- ������
  *              p_period_name        -- ����ڼ�
  *              p_doc_sequence_id    -- ��������  
  *              p_post_flag          -- �Ƿ���˱�ʶ     
  *               
  *       Notes :  
  *            
  *    History  :                                                              
  *             YYYY-MM-DD   Developer          Change   
  *             -----------  --------------     ------------      
  *             2013-12-21   liqing.liu         Created                    
  +==========================================================================*/
  PROCEDURE main(errbuf  OUT NOCOPY VARCHAR2,
                 retcode OUT NOCOPY VARCHAR2);

END hkm_request_monitor;
/
CREATE OR REPLACE PACKAGE BODY hkm_request_monitor IS

  ------------------- Global variables ------------------------  
  g_pkg_name CONSTANT VARCHAR2(30) := 'hkm_request_monitor';
  g_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_report_title CONSTANT VARCHAR2(100) := 'Requests Monitor';
  --------------------------------------------------------------

  ---------------------- Who variables -------------------------
  -- g_last_updated_by   NUMBER := fnd_global.user_id;
  -- g_last_update_login NUMBER := fnd_global.conc_login_id;
  -- g_prog_appl_id      NUMBER := fnd_global.prog_appl_id;
  -- g_prog_id           NUMBER := fnd_global.conc_program_id;
  -- g_request_id NUMBER := fnd_global.conc_request_id;
  --------------------------------------------------------------

  -- mask
  g_date_mask   VARCHAR2(100);
  g_day_mask    VARCHAR2(100);
  g_month_mask  VARCHAR2(100);
  g_number_mask VARCHAR2(100);

  --constant by Hakim
  g_yes_no VARCHAR2(4) := NULL;
  TYPE l_data_type IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  g_data_rec l_data_type;

  -- paramter
  g_ledger_id       NUMBER;
  g_period_name     VARCHAR2(20);
  g_doc_sequence_id NUMBER;
  g_post_flag       VARCHAR2(1);

  --�趨ֵ
  g_print_header0 VARCHAR2(300) := '<html>
                                <head>
                                <meta http-equiv="Content-Language" content="zh-cn">
                                <meta http-equiv="Content-Type" content="text/html; charset=G_CHARSET">';
  g_print_header1 CONSTANT VARCHAR2(5000) := '<title>' || g_report_title || '</title>
                                <style type="text/css">
                                <-- $header: porstyl2.css 115.9 2011/05/31 09:21:42 Hand ship ${  }
                                <!--
                                   body         {background-color: #ffffff;}

                                   .subheader1  {font-family: Arial, Helvetica, Geneva, sans-serif;
                                                 font-size: 13pt;
                                                 font-weight: bold;
                                                 color: #336699;}
                                   .subheader2  {font-family: Arial, Helvetica, Geneva, sans-serif;
                                                 font-size: 10pt;
                                                 font-weight: bold;
                                                 color: #336699;}
                                   .tableheader {font-family: Arial, Helvetica, Geneva, sans-serif;
                                                 font-size: 10pt;
                                                 font-weight: bold;
                                                 background: #E0ECF8;
                                                 color: #336699;
                                                 text-align: center;}
                                   .tabledata   {font-family: Arial, Helvetica, Geneva, sans-serif;
                                                 font-size: 9pt;
                                                 background: #EFF5FB;
                                                 color: #000000;
                                                 mso-number-format: "\@"}
                                   .tablenumber {font-family: Arial, Helvetica, Geneva, sans-serif;
                                                 font-size: 9pt;
                                                 background: #EFF5FB;
                                                 color: #000000;
                                                 text-align: right}
                                    .footer  {font-family: Arial, Helvetica, Geneva, sans-serif;
                                                 font-size: 10pt;
                                                 font-weight: bold;
                                                 color: #336699;}
                                -->
                                </style>
                                </head>';

  g_table_title VARCHAR2(5000);
  g_table_width NUMBER := 400;
  g_table_body  VARCHAR2(32767);
  g_html        VARCHAR2(32767);

  g_print_footer CONSTANT VARCHAR2(500) := '<TABLE border=0 cellpadding=0 cellspacing=0 width=' || g_table_width || '>
                                <TR><TD colspan=5 class=subheader2>��ӡ����:' ||
                                           to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss') ||
                                           '</TD></TR>
                                <TR><TD colspan=5 class=subheader2>Sent By:' ||
                                           'Unknown' ||
                                          --cux_pub_common_utl.get_employee_name(p_user_id => fnd_global.user_id) ||
                                           '</TD></TR>
                                </TABLE></body></html>';

  PROCEDURE raise_exception(x_return_status VARCHAR2) IS
  BEGIN
  
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
  END raise_exception;

  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    dbms_output.put_line(p_content);
  END log;

  PROCEDURE remove_monitor IS
  BEGIN
    FOR i IN 1 .. g_data_rec.count
    LOOP
      UPDATE hkm_conc_req_summary crs
         SET crs.printer = 'N'
       WHERE 1 = 1
         AND crs.request_id = g_data_rec(i);
      log('Hakim: remove monitor of ' || g_data_rec(i));
    END LOOP;
  END remove_monitor;

  PROCEDURE delete_jobs IS
    CURSOR cur_jobs IS
      SELECT *
        FROM user_jobs uj
       WHERE 1 = 1
         AND upper(uj.what) LIKE upper('%hkm_request_monitor%');
  BEGIN
    FOR rec_job IN cur_jobs
    LOOP
      dbms_job.remove(rec_job.job);
    END LOOP;
  END delete_jobs;

  /*==================================================
  --���ߣ�Hand
  --���ڣ�2011-05-31
  --�����������������ͷ��Ϣ
  --������ʷ��¼��
  ==================================================*/
  PROCEDURE out_report_header(x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) := 'out_report_header';
  
    l_table_column  NUMBER;
    l_print_header2 VARCHAR2(5000);
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name      => g_pkg_name,
                                                p_api_name      => l_api_name,
                                                p_init_msg_list => fnd_api.g_false);
    raise_exception(x_return_status);
  
    l_table_column  := 9;
    l_print_header2 := '<body>';
    /*    l_print_header2 := '<body>
     <TABLE border=0 cellpadding=0 cellspacing=0 width=' || g_table_width || '>
     <TR><th colspan=' || l_table_column || ' class=subheader1 align=center style="margin-top: 0">' ||
    g_report_title || '</th></TR>
     <TR><td colspan=' || l_table_column || ' class=subheader2>
     ������:' || cux_gl_utl.get_ledger_name(g_ledger_id) || '</td>
     </TR>
     <TR><td colspan=' || l_table_column || ' class=subheader2>
     ����ڼ�:' || g_period_name || '</td>
     </TR>
     <TR><td colspan=' || l_table_column || ' class=subheader2>
     ��������:' || get_sequences_name(p_doc_sequence_id => g_doc_sequence_id) ||
    '</td>
     <TR><td colspan=' || l_table_column || ' class=subheader2>
     �Ƿ����δ����:' || g_post_flag || '</td>
     </TR>
     </TABLE>';*/
  
    --print report header-------------------------------------
    --xxfnd_conc_utl.out_msg(REPLACE(g_print_header0, 'G_CHARSET', fnd_profile.value('ICX_CLIENT_IANA_ENCODING'))); --gb2312
    --log(REPLACE(g_print_header0, 'G_CHARSET', fnd_profile.value('ICX_CLIENT_IANA_ENCODING')));
    g_print_header0 := REPLACE(g_print_header0, 'G_CHARSET', fnd_profile.value('ICX_CLIENT_IANA_ENCODING'));
    --xxfnd_conc_utl.out_msg(g_print_header1);
    --log(g_print_header1);
    --XXFND_CONC_UTL.out_msg(l_print_header2);
    --log(l_print_header2);
  
    g_table_title := '<TABLE width=' || g_table_width || ' border=1 cellpadding=3 cellspacing=1>
                     <tr>
                          <td class="tableheader" nowrap="" width="50">Request id
                          </td><td class="tableheader" nowrap="" width="100">Request Date
                          </td><td class="tableheader" nowrap="" width="100">Complete Date
                          </td><td class="tableheader" nowrap="" width="100">Time Spent
                          </td><td class="tableheader" nowrap="" width="50">Phase
                          </td><td class="tableheader" nowrap="" width="50">Status
                          </td><td class="tableheader" nowrap="" width="200">Program
                          </td><td class="tableheader" nowrap="" width="50">Requestor
                          </td><td class="tableheader" nowrap="" width="200">Email
                          </td><td class="tableheader" nowrap="" width="100">Name
                          </td><td class="tableheader" nowrap="" width="200">Arguments
                          </td><td class="tableheader" nowrap="" width="100">Responsibility
                        </td></tr>';
  
    g_table_body := '<tr>
                       <td class="tabledata">TEXT01</td>
                       <td class="tabledata">TEXT02</td>
                       <td class="tabledata">TEXT03</td>
                       <td class="tabledata">TEXT04</td>
                       <td class="tabledata">TEXT05</td>
                       <td class="tabledata">TEXT06</td>
                       <td class="tabledata">TEXT07</td>
                       <td class="tabledata">TEXT08</td>
                       <td class="tabledata">TEXT09</td>
                       <td class="tabledata">TEXT10</td>
                       <td class="tabledata">TEXT11</td>
                       <td class="tabledata">TEXT12</td>
                     </tr>';
  
    --xxfnd_conc_utl.out_msg(g_table_title);
    --log(g_table_title);
  
    g_html := g_print_header0 || g_print_header1 || l_print_header2 || g_table_title;
  
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_error,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_others,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
  END out_report_header;

  -- ���ݶ�������
  /*FUNCTION get_sequences_name(p_doc_sequence_id IN NUMBER) RETURN VARCHAR2 IS
  
    CURSOR cur_line IS
      SELECT fds.name
        FROM fnd_document_sequences fds
       WHERE fds.doc_sequence_id = p_doc_sequence_id;
  
    l_sequences_name VARCHAR2(30) := NULL;
  BEGIN
    OPEN cur_line;
    FETCH cur_line
      INTO l_sequences_name;
    CLOSE cur_line;
  
    RETURN l_sequences_name;
  
  END get_sequences_name;*/

  -- ƾ֤�н��
  /*PROCEDURE get_je_line_amount(p_je_header_id IN NUMBER,
                               x_dr_amount    OUT NOCOPY NUMBER,
                               x_cr_amount    OUT NOCOPY NUMBER) IS
  
    CURSOR cur_line IS
      SELECT nvl(SUM(gjl.accounted_dr),
                 0) accounted_dr,
             nvl(SUM(gjl.accounted_cr),
                 0) accounted_cr
        FROM gl_je_lines gjl
       WHERE gjl.je_header_id = p_je_header_id;
  
  BEGIN
    x_dr_amount := 0;
    x_cr_amount := 0;
  
    OPEN cur_line;
    FETCH cur_line
      INTO x_dr_amount,
           x_cr_amount;
    CLOSE cur_line;
  
  END get_je_line_amount;*/

  /*==========================================================================+
  *       Name  :   
  *              process_data                                                                                
  * Description :     
  *              ��������
  *                      
  *   Arguments :                                                                              
  *
  *       Notes :  
  *            
  *    History  :                                                              
  *             YYYY-MM-DD   Developer          Change   
  *             -----------  --------------     ------------      
  *             2013-12-21   liqing.liu         Created                    
  +==========================================================================*/
  PROCEDURE process_data(x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2) IS
  
    CURSOR cur_monitor IS
      SELECT crs.*
        FROM hkm_conc_req_summary   crs,
             fnd_conc_req_summary_v v
       WHERE 1 = 1
         AND crs.request_id = v.request_id
            --AND crs.status_code IN ('R', 'P')
         AND v.phase_code IN ('C')
         AND crs.printer <> 'N';
  
    CURSOR cur_htmls(p_request_id NUMBER) IS
      SELECT v.request_id,
             v.actual_start_date,
             v.actual_completion_date,
             decode(v.actual_completion_date, NULL, trunc((SYSDATE - v.actual_start_date) * 24, 3), NULL) during,
             trunc((v.actual_completion_date - v.actual_start_date) * 24) hours,
             round(((v.actual_completion_date - v.actual_start_date) * 24 -
                   trunc((v.actual_completion_date - v.actual_start_date) * 24)) * 60,
                   2) minutes,
             decode(v.phase_code, 'R', 'Running', 'P', 'Pending', 'C', 'Completed', v.phase_code) phase_code,
             decode(v.status_code,
                    'R',
                    'Running',
                    'Q',
                    'Standby',
                    'C',
                    'Completed',
                    'X',
                    'Terminated',
                    'E',
                    'Error',
                    'G',
                    'Warning',
                    'I',
                    'Scheduled',
                    v.status_code) status_code,
             --v.status_code,
             v.program_short_name,
             v.user_concurrent_program_name,
             v.requestor,
             v.requested_by,
             pap.email_address,
             pap.full_name,
             v.argument_text,
             v.responsibility_application_id app_id,
             (SELECT fa.application_short_name
                FROM fnd_application fa
               WHERE 1 = 1
                 AND fa.application_id = v.responsibility_application_id) app_name,
             v.responsibility_id,
             fr.responsibility_key
        FROM fnd_conc_req_summary_v v,
             fnd_responsibility     fr,
             fnd_user               fu,
             per_all_people_f       pap
       WHERE 1 = 1
         AND fu.user_id = v.requested_by
         AND fu.employee_id = pap.person_id(+)
         AND pap.effective_end_date > SYSDATE
         AND fr.responsibility_id = v.responsibility_id
         AND v.request_id = p_request_id
       ORDER BY v.request_id DESC;
  
    l_api_name CONSTANT VARCHAR2(30) := 'process_data';
    l_table_body VARCHAR2(32767);
  
    l_dr_amount NUMBER := 0;
    l_cr_amount NUMBER := 0;
  
    l_doc_sequence_id NUMBER := NULL;
    l_current_number  NUMBER;
    l_loop_number     NUMBER;
    i                 NUMBER := 1;
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name => g_pkg_name, p_api_name => l_api_name);
    raise_exception(x_return_status);
  
    FOR rec_monitor IN cur_monitor
    LOOP
      FOR rec_line IN cur_htmls(rec_monitor.request_id)
      LOOP
        g_data_rec(i) := rec_monitor.request_id;
        i := i + 1;
        l_table_body := g_table_body;
        l_table_body := REPLACE(l_table_body, 'TEXT01', rec_line.request_id);
        l_table_body := REPLACE(l_table_body, 'TEXT02', to_char(rec_line.actual_start_date, 'yyyy-mm-dd hh24:mi:ss'));
        l_table_body := REPLACE(l_table_body,
                                'TEXT03',
                                to_char(rec_line.actual_completion_date, 'yyyy-mm-dd hh24:mi:ss'));
        l_table_body := REPLACE(l_table_body, 'TEXT04', rec_line.hours || 'h' || rec_line.minutes || 'min');
        l_table_body := REPLACE(l_table_body, 'TEXT05', rec_line.phase_code);
        l_table_body := REPLACE(l_table_body, 'TEXT06', rec_line.status_code);
        l_table_body := REPLACE(l_table_body, 'TEXT07', rec_line.user_concurrent_program_name);
        l_table_body := REPLACE(l_table_body, 'TEXT08', rec_line.requestor);
        l_table_body := REPLACE(l_table_body, 'TEXT09', rec_line.email_address);
        l_table_body := REPLACE(l_table_body, 'TEXT10', rec_line.full_name);
        l_table_body := REPLACE(l_table_body, 'TEXT11', rec_line.argument_text);
        l_table_body := REPLACE(l_table_body, 'TEXT12', rec_line.responsibility_key);
        NULL;
      END LOOP;
    
      g_html := g_html || l_table_body;
    END LOOP;
  
    IF l_table_body IS NULL THEN
      log('There is no data was generated.');
      g_yes_no := 'NO';
      RETURN; --exit PROCEDURE process_data and continue what left.
    END IF;
  
    log('Get monitor data sucessfully.');
    --log(l_table_body);
    --g_html := g_html || l_table_body;
    /*
      -- 1����������
      FOR rec_html IN cur_htmls
      LOOP
      
        l_table_body := g_table_body;
        -- 01 ��������
        l_table_body := REPLACE(l_table_body, 'TEXT01', get_sequences_name(p_doc_sequence_id => rec_html.doc_sequence_id));
        -- 02 ƾ֤���
        l_table_body := REPLACE(l_table_body, 'TEXT02', rec_html.doc_number);
        -- 03 ƾ֤��Դ
        l_table_body := REPLACE(l_table_body, 'TEXT03', rec_html.user_je_source_name);
        -- 04 ƾ֤���
        l_table_body := REPLACE(l_table_body, 'TEXT04', rec_html.user_je_category_name);
      
        -- 05 ����״̬
        l_table_body := REPLACE(l_table_body, 'TEXT05', rec_html.batch_status_desc);
        -- 06 ����״̬
        l_table_body := REPLACE(l_table_body, 'TEXT06', rec_html.approval_status_desc);
        -- 07 �ռ���ժҪ
        l_table_body := REPLACE(l_table_body, 'TEXT07', rec_html.description);
        get_je_line_amount(p_je_header_id => rec_html.je_header_id,
                           x_dr_amount    => l_dr_amount,
                           x_cr_amount    => l_cr_amount);
        -- 08 �跽���
        l_table_body := REPLACE(l_table_body, 'TEXT08', l_dr_amount);
        -- 09 �������
        l_table_body := REPLACE(l_table_body, 'TEXT09', l_cr_amount);
        xxfnd_conc_utl.out_msg(l_table_body);
      
      END LOOP;
    */
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_error,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_others,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
  END process_data;

  /*================================================
  -- ���ߣ�liqing.liu
  -- ���ڣ�2013-12-21
  -- ������������֤����
  -- ������ʷ��¼��
  ==================================================*/
  PROCEDURE validate_parameter(x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2,
                               p_ledger_id       IN NUMBER,
                               p_period_name     IN VARCHAR2,
                               p_doc_sequence_id IN NUMBER,
                               p_post_flag       IN VARCHAR2) IS
  
    l_api_name CONSTANT VARCHAR2(30) := 'validate_parameter';
  
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name => g_pkg_name, p_api_name => l_api_name);
    raise_exception(x_return_status);
  
    -- 1��mask
    g_date_mask   := 'YYYY-MM-DD HH24:MI:SS';
    g_month_mask  := 'YYYY-MM';
    g_day_mask    := 'YYYY-MM-DD';
    g_number_mask := 'FM999,999,999,999.00';
  
    -- 2��inite
    g_ledger_id       := p_ledger_id;
    g_period_name     := p_period_name;
    g_doc_sequence_id := p_doc_sequence_id;
    g_post_flag       := p_post_flag;
  
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_error,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                     p_api_name  => l_api_name,
                                                     p_exc_name  => xxfnd_api.g_exc_name_others,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data  => x_msg_data);
  END validate_parameter;

  /*==========================================================================+
  *       Name  :   
  *              process_request                                                                                
  * Description :     
  *              ��������
  *                1����֤����
  *                2����������     
  *   Arguments :                                                                
  *              retcode              -- 1:����/2����                                                           
  *              p_ledger_id          -- ������
  *              p_business_type      -- ҵ������
  *              p_acc_code           -- ��Ŀ��  
  *              p_date_from          -- ���������
  *              p_date_to            -- ���������
  *              p_post_flag          -- �Ƿ���˱�ʶ       
  *               
  *
  *       Notes :  
  *            
  *    History  :                                                              
  *             YYYY-MM-DD   Developer          Change   
  *             -----------  --------------     ------------      
  *             2013-12-21   liqing.liu         Created                    
  +==========================================================================*/
  PROCEDURE process_request(x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2) IS
  
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
  
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => fnd_api.g_true);
    raise_exception(x_return_status);
  
    -- 1����֤����
    /*    validate_parameter(x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_ledger_id       => p_ledger_id,
                       p_period_name     => p_period_name,
                       p_doc_sequence_id => p_doc_sequence_id,
                       p_post_flag       => p_post_flag);
    raise_exception(x_return_status);*/
  
    -- 2����ӡ����ͷ
    out_report_header(x_return_status, x_msg_count, x_msg_data);
    raise_exception(x_return_status);
  
    -- 3�������������
    process_data(x_return_status, x_msg_count, x_msg_data);
    raise_exception(x_return_status);
    log('Hakim: What about g_yes_no = ' || g_yes_no);
    IF g_yes_no = 'NO' THEN
      RETURN;
    END IF;
    log('prepare to send email');
  
    -- 4����ӡ�����β
    --xxfnd_conc_utl.out_msg(g_print_footer);
    --log(g_print_footer);
    g_html := g_html || g_print_footer;
    -- end activity, include debug message hint to exit api
  
    --send emails
    xxhkm_send_mail_pkg.main(errbuf    => x_msg_data,
                             retcode   => x_msg_count,
                             p_content => g_html,
                             p_subject => to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss') || ' ' || g_report_title);
  
    --update what is completed, next time it will not be monitored
    remove_monitor;
  
    --log('HAKIM ==== ' || g_html);
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
  END process_request;

  PROCEDURE main(errbuf  OUT NOCOPY VARCHAR2,
                 retcode OUT NOCOPY VARCHAR2) AS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_api_name CONSTANT VARCHAR2(30) := 'main';
  BEGIN
    -- 1�������־ͷ
    xxfnd_conc_utl.log_header;
  
    -- 2���������� 
    process_request(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data);
  
    raise_exception(l_return_status);
  
    -- 3�������־β
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
                              p_procedure_name => l_api_name,
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END main;

END hkm_request_monitor;
/
