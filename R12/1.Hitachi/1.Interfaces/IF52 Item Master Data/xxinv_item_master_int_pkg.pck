CREATE OR REPLACE PACKAGE xxinv_item_master_int_pkg is

   /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      Exchange Rate (G-SCM-> G-OE)
  Description:
      This program provide item master inf main procedure to perform:
      Item Master (DI/E-Chat)
  History:
      1.00  2013-11-4 00:00:00 jiaming.zhou
  ==================================================*/

  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10) || chr(13);
  g_line        VARCHAR2(150) := rpad('-', 150, '-');
  g_space       VARCHAR2(40) := '&nbsp';

  g_session_id NUMBER := userenv('sessionid');

  PROCEDURE main(errbuf           OUT VARCHAR2,
                 retcode          OUT VARCHAR2,
                 p_group_id       IN  NUMBER,
                 p_interface_date IN  VARCHAR2); 
END xxinv_item_master_int_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxinv_item_master_int_pkg IS

  g_pkg_name CONSTANT VARCHAR2(30) := 'xxinv_item_master_int_pkg';
  g_user_id         NUMBER := fnd_global.user_id;
  g_login_id        NUMBER := fnd_global.login_id;
  g_conc_program_id NUMBER := fnd_global.conc_program_id;
  g_prog_appl_id    NUMBER := fnd_global.prog_appl_id;
  g_request_id      NUMBER := fnd_global.conc_request_id;

  PROCEDURE output(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_content);
  END output;

  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_content);
  END log;

  FUNCTION get_mrp_code(p_mrg_organization_id IN NUMBER) RETURN VARCHAR2 IS
    l_mfg_code VARCHAR2(3);
  BEGIN
    SELECT organization_code
      INTO l_mfg_code
      FROM mtl_parameters
     WHERE organization_id = p_mrg_organization_id;
    RETURN l_mfg_code;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  PROCEDURE delete_item_master_int(p_group_id IN NUMBER) IS
  BEGIN
    DELETE FROM xxinv_item_master_int WHERE group_id <> p_group_id;
  END;

  PROCEDURE print_record_msg(p_group_id IN NUMBER) IS
    CURSOR cur_item IS
      SELECT xxim.unique_id
            ,xxim.group_id
            ,xxim.inventory_organization
            ,xxim.item_number
            ,xxim.status_code
            ,xxim.make_or_buy
            ,xxim.wip_supply_type
            ,xxim.pegging
            ,data_export_date
        FROM xxinv_item_master_int xxim
       WHERE group_id = p_group_id;
    l_count NUMBER;
  BEGIN
    log('Print records begin !');
    xxfnd_html_pub2.output_head(p_title         => 'Item Master Data',
                                p_column_title1 => 'Seq',
                                p_column_title2 => 'Inventory Organization',
                                p_column_title3 => 'Item Number',
                                p_column_title4 => 'Item Status',
                                p_column_title5 => 'Make Or Buy',
                                p_column_title6 => 'Wip Supply Type',
                                p_column_title7 => 'End Assembly Pegging Attribute',
                                p_column_title8 => 'Data Export Date');
    l_count := 0;
    FOR rec_item IN cur_item LOOP
      l_count := l_count + 1;
      xxfnd_html_pub2.output_body(p_column1_text => l_count,
                                  p_column2_text => rec_item.inventory_organization,
                                  p_column3_text => rec_item.item_number,
                                  p_column4_text => rec_item.status_code,
                                  p_column5_text => rec_item.make_or_buy,
                                  p_column6_text => rec_item.wip_supply_type,
                                  p_column7_text => rec_item.pegging,
                                  p_column8_text => to_char(rec_item.data_export_date,
                                                            'yyyy-mon-dd hh24:mi:ss'));
    END LOOP;
    xxfnd_html_pub2.output_end;
    log('Print records end !');
  END print_record_msg;

  PROCEDURE process_record(x_return_status  OUT VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           p_group_id       IN VARCHAR2,
                           p_interface_date IN VARCHAR2) IS
  
    l_api_name       CONSTANT VARCHAR2(30) := 'process_record';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_record01';
  
    CURSOR cur_item IS
      SELECT mp.organization_code           inventory_organization
            ,msi.segment1                   item_number
            ,msi.inventory_item_status_code status_code
            ,flv1.meaning                   make_or_buy
            ,flv2.meaning                   wip_supply_type
            ,msi.end_assembly_pegging_flag  pegging
            ,SYSDATE                        data_export_date
        FROM mtl_system_items_vl  msi
            ,mtl_parameters       mp
            ,xxinv_lookups        xlv
            ,fnd_application_vl   fa
            ,fnd_lookup_values_vl flv1
            ,fnd_lookup_values_vl flv2
       WHERE mp.organization_id = msi.organization_id
         AND flv1.lookup_code = msi.planning_make_buy_code
         AND flv1.view_application_id = fa.application_id
         AND flv1.security_group_id = 0
         AND flv1.lookup_type = 'MTL_PLANNING_MAKE_BUY'
         AND flv2.lookup_code = msi.wip_supply_type
         AND flv2.view_application_id = fa.application_id
         AND flv2.security_group_id = 0
         AND flv2.lookup_type = 'WIP_SUPPLY'
         AND fa.application_short_name = 'MFG'
         AND xlv.lookup_code = mp.organization_code
         AND xlv.lookup_type = 'XXINV_IF52_DATA_SCOPE'
         AND nvl(xlv.enabled_flag, 'N') = 'Y';
  
  BEGIN
  
    log('****Interface_date :' || p_interface_date || '------Group id : ' ||
        p_group_id || '----------');
  
    x_return_status := fnd_api.g_ret_sts_success;
    delete_item_master_int(p_group_id);
  
    FOR rec_item IN cur_item LOOP
      INSERT INTO xxinv_item_master_int
        (unique_id
        ,inventory_organization
        ,item_number
        ,status_code
        ,make_or_buy
        ,wip_supply_type
        ,pegging
        ,data_export_date
        ,group_id
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,program_application_id
        ,program_id
        ,request_id)
      VALUES
        (xxinv_item_master_int_s.nextval
        ,rec_item.inventory_organization
        ,rec_item.item_number
        ,rec_item.status_code
        ,rec_item.make_or_buy
        ,rec_item.wip_supply_type
        ,rec_item.pegging
        ,rec_item.data_export_date
        ,p_group_id
        ,g_user_id
        ,g_user_id
        ,g_login_id
        ,g_prog_appl_id
        ,g_conc_program_id
        ,g_request_id);
    END LOOP;
  
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
    
  END process_record;

  PROCEDURE process_request(p_init_msg_list  IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit         IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            p_group_id       IN NUMBER,
                            p_interface_date IN VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
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
  
    process_record(x_return_status,
                   x_msg_count,
                   x_msg_data,
                   p_group_id,
                   p_interface_date);
  
    print_record_msg(p_group_id);
  
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

  PROCEDURE main(errbuf           OUT VARCHAR2,
                 retcode          OUT VARCHAR2,
                 p_group_id       IN NUMBER,
                 p_interface_date IN VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
    retcode := '0';
  
    xxfnd_conc_utl.log_header;
  
    process_request(p_init_msg_list  => fnd_api.g_true,
                    p_commit         => fnd_api.g_true,
                    x_return_status  => l_return_status,
                    x_msg_count      => l_msg_count,
                    x_msg_data       => l_msg_data,
                    p_group_id       => p_group_id,
                    p_interface_date => p_interface_date);
  
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  
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
END xxinv_item_master_int_pkg;
/
