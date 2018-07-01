CREATE OR REPLACE PACKAGE xxhkm_send_mail_pkg IS

  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxhkm_send_mail_pkg
  Description:
       Sent Email 
  History:
      1.00  2018/03/14 Hakim   Creation
  ==================================================*/
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
  g_space      VARCHAR2(10) := '&nbsp;';
  PROCEDURE main(errbuf     OUT VARCHAR2,
                 retcode    OUT VARCHAR2,
                 p_group_id IN NUMBER);

END xxhkm_send_mail_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxhkm_send_mail_pkg IS

  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxhkm_send_mail_pkg
  Description:
       Sent Email 
  History:
      1.00  2018/03/14 steven   Creation
  ==================================================*/
  c_yes_flag CONSTANT VARCHAR2(1) := 'Y';
  c_no_flag  CONSTANT VARCHAR2(1) := 'N';
  c_file_ext CONSTANT VARCHAR2(30) := 'xls';
  g_pkg_name VARCHAR2(30) := 'xxhkm_send_mail_pkg';
  --g_encoding    VARCHAR2(30) := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
  g_debug       VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_send_flag   VARCHAR2(1) := c_no_flag;
  g_date_format VARCHAR2(40) := 'DD-MON-YYYY';
  --g_group_id_from NUMBER;
  --g_group_id_to   NUMBER;
  g_exist_data NUMBER := 0;
  g_group_id   NUMBER;

  PROCEDURE raise_exception(p_return_status VARCHAR2) IS
  BEGIN
    IF (p_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (p_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END raise_exception;

  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    --fnd_file.put_line(fnd_file.log, REPLACE(p_content, chr(0), ' '));
    dbms_output.put_line(p_content);
  END log;

  PROCEDURE output(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, REPLACE(p_content, chr(0), ' '));
  END output;

  PROCEDURE init_global(x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        x_receipt_list  OUT xxfnd_utl_smtp_helper.recipient_list,
                        x_smtp_host     OUT VARCHAR2,
                        x_from_email    OUT VARCHAR2) IS
    i                   NUMBER := 0;
    l_api_name          VARCHAR2(40) := 'init_global';
    l_email_lookup_type VARCHAR2(40) := 'XXWIP_PULL_ITEM_ONHAND_MAIL';
    --p_receipt_list      xxfnd_utl_smtp_helper.recipient_list;
    CURSOR cur_to_receiver IS
      SELECT emadd.lookup_code,
             emadd.meaning,
             emadd.description
        FROM fnd_lookup_values_vl emadd
       WHERE emadd.lookup_type = l_email_lookup_type
         AND emadd.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(emadd.start_date_active, trunc(SYSDATE)) AND
             nvl(emadd.end_date_active, trunc(SYSDATE))
       ORDER BY emadd.lookup_code;
  
    CURSOR cur_from_sender IS
      SELECT MAX(decode(lkp.lookup_code, 'OUTBOUND_SERVER_NAME', lkp.meaning)),
             MAX(decode(lkp.lookup_code, 'REPLY_TO', lkp.meaning))
        FROM xxfnd_lookups lkp
       WHERE lkp.lookup_type = 'XXFND_WF_MAILER_PARAMETER'
         AND lkp.enabled_flag = 'Y'
         AND SYSDATE >= nvl(lkp.start_date_active, trunc(SYSDATE))
         AND SYSDATE < nvl(lkp.end_date_active, trunc(SYSDATE) + 1);
  BEGIN
    OPEN cur_from_sender;
    FETCH cur_from_sender
      INTO x_smtp_host,
           x_from_email;
    CLOSE cur_from_sender;
    IF x_smtp_host IS NULL OR x_from_email IS NULL THEN
      x_msg_data      := 'Lookup XXFND_WF_MAILER_PARAMETER is not setup properly.';
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  
    /*    FOR rec_receiver IN cur_to_receiver LOOP
      i := i + 1;
      x_receipt_list(i).recipient := rec_receiver.meaning;
      x_receipt_list(i).email_address := rec_receiver.description;
    END LOOP;*/
    x_receipt_list(1).recipient := 'HKM01';
    x_receipt_list(1).email_address := 'jingjing.he@hand-china.com';
    x_receipt_list(2).recipient := 'HKM02';
    x_receipt_list(2).email_address := 'hejingjing012@foxmail.com';
    IF x_receipt_list.count = 0 THEN
      x_msg_data      := 'Lookup ' || l_email_lookup_type || ' is not setup properly.';
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data      := l_api_name || SQLERRM;
      log('Error in ' || g_pkg_name || '.' || l_api_name || ':' || to_char(SQLCODE) || '-' || SQLERRM);
  END init_global;

  PROCEDURE generate_email_attachment(x_email_clob    IN OUT CLOB,
                                      x_out_path      OUT VARCHAR2,
                                      x_out_file_name OUT VARCHAR2,
                                      x_return_status OUT VARCHAR2,
                                      x_msg_data      OUT VARCHAR2) IS
    l_api_name      VARCHAR2(40) := 'generate_email_attachment';
    l_save_point    VARCHAR2(40) := 'sp_generate_email_attachment';
    l_email_subject VARCHAR2(90) := 'Pull Item Can Not Have Enough Quantity To Issue';
    l_style         VARCHAR2(200) := 'table{border: none; border-collapse: collapse; width: 100%}' ||
                                     'th, td{border:1px solid gray; padding: 5px;}';
    x_email_content VARCHAR2(32767) := '<html xmlns:v="urn:schemas-microsoft-com:vml" 
             xmlns:o="urn:schemas-microsoft-com:office:office" 
             xmlns:x="urn:schemas-microsoft-com:office:excel" >
             <head><meta http-equiv="content-type" content="text/html; charset=' ||
                                       g_encoding || '"/> <style type="text/css">' || l_style ||
                                       '</style></head><body>' ||
                                       '<p align=center style="font-weight:bold;"><font size="4">' || l_email_subject ||
                                       '</font></p><p align=left style="font-weight:bold;">Request Date:' ||
                                       to_char(SYSDATE, g_date_format) || '</p><table>';
    l_header        VARCHAR2(32767) := '<tr><td align=left NOWRAP>MFG</td>' || '<td align=left NOWRAP>Job</td>' ||
                                       '<td align=left NOWRAP>Assembly item</td>' ||
                                       '<td align=left NOWRAP>Job quantity</td>' ||
                                       '<td align=left NOWRAP>Component item</td>' ||
                                       '<td align=left NOWRAP>Open quantity</td>' ||
                                       '<td align=left NOWRAP>Onhand in FSHF</td>' ||
                                       '<td align=left NOWRAP>Onhand in FRM</td>' ||
                                       '<td align=left NOWRAP>Supply Subinv</td></tr>';
  
    CURSOR cur_data IS
      SELECT wmm.mfg_num,
             wmm.job,
             wmm.component_item_num,
             wdj.start_quantity job_quantity,
             wmm.attribute1,
             (wro.required_quantity - wro.quantity_issued) open_quantity,
             nvl(xxwip_wo_issue_pkg.get_onhand_qty(p_inventory_item_id => wro.inventory_item_id,
                                                   p_organization_id   => wmm.organization_id,
                                                   p_subinventory      => 'FSHF'),
                 0) onhand_quantity_on_fshf,
             nvl(xxwip_wo_issue_pkg.get_onhand_qty(p_inventory_item_id => wro.inventory_item_id,
                                                   p_organization_id   => wmm.organization_id,
                                                   p_subinventory      => 'FRM'),
                 0) onhand_quantity_on_frm,
             wmm.attribute2 supply_subinv
        FROM xxwip_mail_message         wmm,
             wip_requirement_operations wro,
             wip_discrete_jobs          wdj
       WHERE 1 = 1
         AND wro.wip_entity_id = wdj.wip_entity_id
         AND wro.organization_id = wdj.organization_id
         AND wmm.component_wo_id = wdj.wip_entity_id
         AND wmm.pull_item_id = wro.inventory_item_id
         AND wdj.organization_id = wmm.organization_id
            --and (wro.required_quantity - wro.quantity_issued) > 0
         AND (((wro.required_quantity - wro.quantity_issued) > 0 AND wmm.attribute2 = 'FSHF') OR
             (wmm.attribute2 <> 'FSHF'))
         AND wmm.group_id = g_group_id
       GROUP BY wmm.mfg_num,
                wmm.job,
                wmm.component_item_num,
                wdj.start_quantity,
                wmm.attribute1,
                (wro.required_quantity - wro.quantity_issued),
                nvl(xxwip_wo_issue_pkg.get_onhand_qty(p_inventory_item_id => wro.inventory_item_id,
                                                      p_organization_id   => wmm.organization_id,
                                                      p_subinventory      => 'FSHF'),
                    0),
                nvl(xxwip_wo_issue_pkg.get_onhand_qty(p_inventory_item_id => wro.inventory_item_id,
                                                      p_organization_id   => wmm.organization_id,
                                                      p_subinventory      => 'FRM'),
                    0),
                wmm.attribute2
       ORDER BY mfg_num,
                job,
                attribute1;
  BEGIN
    SAVEPOINT l_save_point;
    x_return_status := fnd_api.g_ret_sts_success;
    x_email_content := x_email_content || l_header;
    dbms_lob.writeappend(lob_loc => x_email_clob, amount => length(x_email_content), buffer => x_email_content);
    FOR rec_data IN cur_data
    LOOP
      g_exist_data    := 1;
      x_email_content := '<tr><td align=left NOWRAP>' || rec_data.mfg_num || '</td>';
      x_email_content := x_email_content || '<td align=left style = "vnd.ms-excel.numberformat;@" NOWRAP>' ||
                         rec_data.job || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.component_item_num || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.job_quantity || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.attribute1 || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.open_quantity || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.onhand_quantity_on_fshf || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.onhand_quantity_on_frm || '</td>';
      x_email_content := x_email_content || '<td align=left NOWRAP>' || rec_data.supply_subinv || '</td></tr>';
      dbms_lob.writeappend(lob_loc => x_email_clob, amount => length(x_email_content), buffer => x_email_content);
    END LOOP;
    g_send_flag     := c_yes_flag;
    x_email_content := '</table></body></html>';
    IF g_exist_data = 1 THEN
      dbms_lob.writeappend(lob_loc => x_email_clob, amount => length(x_email_content), buffer => x_email_content);
    END IF;
    IF g_send_flag = c_yes_flag AND g_exist_data = 1 THEN
      log('Data need to be sent!');
      xxfnd_common_util.create_attachment(p_file_name     => 'Pull Item Can Not Have Enough Quantity To Issue',
                                          p_file_ext      => c_file_ext,
                                          p_file_data     => x_email_clob,
                                          x_out_path      => x_out_path,
                                          x_out_file_name => x_out_file_name);
    
    ELSE
      log('No data will be sent!');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO l_save_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data      := l_api_name || SQLERRM;
      log('Error in ' || g_pkg_name || '.' || l_api_name || ':' || to_char(SQLCODE) || '-' || SQLERRM);
  END generate_email_attachment;

  PROCEDURE send_email_attachment(p_email_subject IN VARCHAR2,
                                  p_email_body    IN VARCHAR2,
                                  p_smtp_host     IN VARCHAR2,
                                  p_from_email    IN VARCHAR2,
                                  p_rcpt_list     IN xxfnd_utl_smtp_helper.recipient_list,
                                  p_file_path     IN VARCHAR2,
                                  p_file_name     IN VARCHAR2) IS
    smtp_conn xxfnd_utl_smtp_helper.smtp_connection;
    successed BOOLEAN;
  BEGIN
    IF g_debug = 'Y' THEN
      xxfnd_conc_utl.log_msg('Entering procedure send_email');
    END IF;
    log('create one smtp connection');
    successed := xxfnd_utl_smtp_helper.create_smtp_connection(p_smtp_hostname => p_smtp_host, x_smtp_conn => smtp_conn);
    IF successed THEN
      xxfnd_utl_smtp_helper.set_header(p_smtp_conn      => smtp_conn,
                                       p_from           => p_from_email,
                                       p_recipient_list => p_rcpt_list,
                                       p_subject        => p_email_subject,
                                       p_db_charset     => fnd_profile.value('FND_NATIVE_CLIENT_ENCODING'));
      log('Append mail body');
      xxfnd_utl_smtp_helper.add_body(p_smtp_conn    => smtp_conn,
                                     p_content_type => xxfnd_utl_smtp_helper.g_html_content,
                                     p_body         => p_email_body);
      xxfnd_utl_smtp_helper.add_attachment(p_smtp_conn => smtp_conn,
                                           p_file_path => p_file_path,
                                           p_file_name => p_file_name);
      log('send email now');
      xxfnd_utl_smtp_helper.send(p_smtp_conn => smtp_conn);
      log('disconnect');
      xxfnd_utl_smtp_helper.disconnect(smtp_conn);
    ELSE
      xxfnd_conc_utl.log_msg('Mailer init failed(Outbound server name=' || p_smtp_host || ')');
    END IF;
  
    IF g_debug = 'Y' THEN
      xxfnd_conc_utl.log_msg('Leaving procedure send_email');
    END IF;
  END send_email_attachment;

  PROCEDURE send_email(p_email_subject IN VARCHAR2,
                       p_email_body    IN VARCHAR2,
                       p_smtp_host     IN VARCHAR2,
                       p_from_email    IN VARCHAR2,
                       p_rcpt_list     IN xxfnd_utl_smtp_helper.recipient_list /*,
                                                         p_file_path     IN VARCHAR2,
                                                         p_file_name     IN VARCHAR2*/) IS
    smtp_conn xxfnd_utl_smtp_helper.smtp_connection;
    successed BOOLEAN;
  BEGIN
    IF g_debug = 'Y' THEN
      xxfnd_conc_utl.log_msg('Entering procedure send_email');
    END IF;
    log('create one smtp connection');
    log('smtp_conn = ' || smtp_conn);
    successed := xxfnd_utl_smtp_helper.create_smtp_connection(p_smtp_hostname => p_smtp_host, x_smtp_conn => smtp_conn);
    --log(to_char(successed));
    log('is successful');
    IF successed THEN
      log('hakim1');
      log('smtp_conn = '||smtp_conn);
      log('p_from_email = '||p_from_email);
      --log(p_rcpt_list);
      --log('p_rcpt_list = '||p_rcpt_list(1)||','||p_rcpt_list(2));
      log('p_email_subject = '||p_email_subject);
      log(fnd_profile.value('FND_NATIVE_CLIENT_ENCODING'));
      xxfnd_utl_smtp_helper.set_header(p_smtp_conn      => smtp_conn,
                                       p_from           => p_from_email,
                                       p_recipient_list => p_rcpt_list,
                                       p_subject        => p_email_subject,
                                       p_db_charset     => fnd_profile.value('FND_NATIVE_CLIENT_ENCODING'));
      log('Append mail body');
      xxfnd_utl_smtp_helper.add_body(p_smtp_conn    => smtp_conn,
                                     p_content_type => xxfnd_utl_smtp_helper.g_html_content,
                                     p_body         => p_email_body); /*
          xxfnd_utl_smtp_helper.add_attachment(p_smtp_conn => smtp_conn,
                                               p_file_path => p_file_path,
                                               p_file_name => p_file_name);*/
      log('send email now');
      xxfnd_utl_smtp_helper.send(p_smtp_conn => smtp_conn);
      log('disconnect');
      xxfnd_utl_smtp_helper.disconnect(smtp_conn);
    ELSE
      xxfnd_conc_utl.log_msg('Mailer init failed(Outbound server name=' || p_smtp_host || ')');
    END IF;
  
    IF g_debug = 'Y' THEN
      xxfnd_conc_utl.log_msg('Leaving procedure send_email');
    END IF;
  END send_email;

  PROCEDURE process_request(x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request';
    l_receipt_list  xxfnd_utl_smtp_helper.recipient_list;
    l_smtp_host     VARCHAR2(240);
    l_from_email    VARCHAR2(240);
    l_email_content VARCHAR2(32767);
    l_email_clob    CLOB;
    l_file_path     VARCHAR2(200);
    l_file_name     VARCHAR2(200);
  BEGIN
    SAVEPOINT l_savepoint_name;
    log('001 init_global');
    init_global(x_return_status => x_return_status,
                x_msg_data      => x_msg_data,
                x_receipt_list  => l_receipt_list,
                x_smtp_host     => l_smtp_host,
                x_from_email    => l_from_email);
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    dbms_lob.createtemporary(l_email_clob, TRUE);
    dbms_lob.open(l_email_clob, dbms_lob.lob_readwrite);
    /*    generate_email_attachment(x_email_clob    => l_email_clob,
    x_out_path      => l_file_path,
    x_out_file_name => l_file_name,
    x_return_status => x_return_status,
    x_msg_data      => x_msg_data);*/
    log(' x_return_status : ' || x_return_status);
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      raise_exception(x_return_status);
    END IF;
    log('003 send_email');
    log('g_send_flag : ' || g_send_flag);
    --IF g_send_flag = c_yes_flag AND g_exist_data = 1 THEN
    IF g_send_flag = c_no_flag AND g_exist_data = 0 THEN
      log('email sent��');
      FOR i IN 1 .. nvl(l_receipt_list.count, 0)
      LOOP
        log('receipter :');
        log(l_receipt_list(i).recipient || l_receipt_list(i).email_address);
      END LOOP;
      l_email_content := '<p align=left><font size ="4">' || 'Test email from hitachi. No reply! Thanks!' ||
                         '</font></p>';
      /*      send_email_attachment(p_email_subject => 'Pull Item Can Not Have Enough Quantity To Issue',
      p_email_body    => l_email_content,
      p_file_path     => l_file_path,
      p_file_name     => l_file_name,
      p_smtp_host     => l_smtp_host,
      p_from_email    => l_from_email,
      p_rcpt_list     => l_receipt_list);*/
      send_email(p_email_subject => 'Hakim Test 20180609',
                 p_email_body    => l_email_content,
                 /*p_file_path     => l_file_path,
                                             p_file_name     => l_file_name,*/
                 p_smtp_host  => l_smtp_host,
                 p_from_email => l_from_email,
                 p_rcpt_list  => l_receipt_list);
    ELSE
      log('     no email sent��');
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      raise_exception(x_return_status);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO l_savepoint_name;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := l_api_name || x_msg_data;
      log('Error in ' || g_pkg_name || '.' || l_api_name || ':' || x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO l_savepoint_name;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data      := l_api_name || SQLERRM;
      log('Error in ' || g_pkg_name || '.' || l_api_name || ':' || to_char(SQLCODE) || '-' || SQLERRM);
  END process_request;

  /*==================================================
    Procedure Name :
        main
    Description:
        main:
    History:
        1.00  2014/03/28  hand   Creation
  ==================================================*/
  PROCEDURE main(errbuf     OUT VARCHAR2,
                 retcode    OUT VARCHAR2,
                 p_group_id IN NUMBER) IS
    l_return_status VARCHAR2(30);
    l_msg_data      VARCHAR2(2000);
    l_api_name      VARCHAR2(40) := 'main';
  BEGIN
    retcode := '0';
    xxfnd_conc_utl.log_header;
  
    g_group_id := p_group_id;
    --g_group_id_to   := p_group_id_to;
    process_request(x_return_status => l_return_status, x_msg_data => l_msg_data);
    xxfnd_conc_utl.log_footer;
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      errbuf := l_api_name || l_msg_data;
      log('Error in ' || g_pkg_name || '.' || l_api_name || ':' || l_msg_data);
    WHEN OTHERS THEN
      errbuf := l_api_name || SQLERRM;
      log('Error in ' || g_pkg_name || '.' || l_api_name || ':' || to_char(SQLCODE) || '-' || SQLERRM);
  END main;
END xxhkm_send_mail_pkg;
/
