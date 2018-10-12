CREATE OR REPLACE PACKAGE xxom_item_intf_pkg is

   /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      Item Interface (G-SCM->G-OE)
  Description:
      This program provide concurrent main procedure to perform:
      Item Interface (G-SCM->G-OE)
  History:
      1.00  2012-06-21 00:00:00 yanling.wang
  ==================================================*/

  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10) || chr(13);
  g_line        VARCHAR2(150) := rpad('-', 150, '-');
  g_space       VARCHAR2(40) := '&nbsp';

  g_session_id NUMBER := userenv('sessionid');

--main
  PROCEDURE main(errbuf            OUT VARCHAR2,
                 retcode           OUT VARCHAR2,
                 p_group_id        IN  NUMBER,
                 p_interface_date  IN  VARCHAR2 ); --wyl
END xxom_item_intf_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxom_item_intf_pkg is
  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'XXOM_ITEM_INTF';
  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.VALUE('AFLOG_ENABLED'), 'N');

  --g_org_id             NUMBER ; /*:= fnd_global.org_id;*/
  g_org_id             NUMBER  := fnd_global.org_id;
  g_user_id            NUMBER  := fnd_global.user_id;
  g_login_id           NUMBER  := fnd_global.login_id;
  g_conc_program_id    NUMBER  := fnd_global.conc_program_id;
  g_prog_appl_id       NUMBER  := fnd_global.prog_appl_id;
  g_request_id         NUMBER  := fnd_global.conc_request_id;
  
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
  
  --print_html_td_rowspan
  PROCEDURE print_html_td_rowspan(p_width    IN  NUMBER,
                                  p_para     IN VARCHAR2) IS 
  BEGIN 
   
    output('<td class="body_other" align="left" width="' || p_width || 'px">' || p_para || '</td>');  
  
  END print_html_td_rowspan;
  
  PROCEDURE print_record_msg(p_group_id IN NUMBER)IS
    CURSOR cur_cust IS 
      SELECT xii.unique_id,
             xii.group_id_goe,
             xii.action,
             xii.org_code,
             xii.inventory_item_id,
             xii.itme_number,
             xii.description,
             xii.uom,
             xii.item_type,
             xii.item_category,
             xii.status,
             xii.interface_date,
             xii.creation_date,
             xii.last_update_date,
             xii.group_id  
        FROM xxom_item_intf xii
       WHERE xii.group_id = p_group_id;

    l_header VARCHAR2(2500) :='<html>
                               <head>
                               <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                               <title>Item Upload</title>
                               <style type="text/css">
                                 *{font-size:9.0pt;mso-font-charset:134;}
                                 .titlefont{font-size:18px; text-align:center}
                                 .boydtr .body_other{border-right:.5pt solid windowtext;
                                                     border-bottom:.5pt solid windowtext;}
                                 .boydtr .body_first{border-left:.5pt solid windowtext;
                                                     border-right:.5pt solid windowtext;
                                                     border-bottom:.5pt solid windowtext;}
                                 table .boydtr {border-top:.5pt solid #FFFFFF;}
                  
                                 .bordertr td{mso-style-parent:style0;
                                              border-top:.5pt solid windowtext;
                                              border-right:.5pt solid windowtext;
                                              border-bottom:.5pt solid windowtext;
                                              border-left:none;}
                                 .bordertr .td_first{border-left:.5pt solid windowtext;}    
                                </style>
                                </head>
                                <body>
                                <table align="center" width="100%" cellspacing="0" cellpadding="0">';

    l_footer  VARCHAR2(2500)  := '</table></body></html>';
    
    -- report title
    l_title                 VARCHAR2(1000);
    -- column title
    l_column_title1         VARCHAR2(100) DEFAULT NULL;
    l_column_title2         VARCHAR2(100) DEFAULT NULL;
    l_column_title3         VARCHAR2(100) DEFAULT NULL;
    l_column_title4         VARCHAR2(100) DEFAULT NULL;
    l_column_title5         VARCHAR2(100) DEFAULT NULL;
    l_column_title6         VARCHAR2(100) DEFAULT NULL;
    l_column_title7         VARCHAR2(100) DEFAULT NULL;
    l_column_title8         VARCHAR2(100) DEFAULT NULL;
    l_column_title9         VARCHAR2(100) DEFAULT NULL;
    l_column_title10        VARCHAR2(100) DEFAULT NULL;
    l_column_title11        VARCHAR2(100) DEFAULT NULL;
    l_column_title12        VARCHAR2(100) DEFAULT NULL;
    l_column_title13        VARCHAR2(100) DEFAULT NULL;
    l_column_title14        VARCHAR2(100) DEFAULT NULL;
  
    l_request_parameter1_colspan VARCHAR2(20);

    l_count NUMBER DEFAULT 0;
  BEGIN 
    log('Print records begin !');

    l_title   := '<strong>Item Upload</strong>';
    l_column_title1  := 'Unique_id';
    l_column_title2   := 'Group_id';
    l_column_title3   := 'Action';
    l_column_title4   := 'Org_code';
    l_column_title5   := 'Inventory_item_id';
    l_column_title6   := 'Itme_number';
    l_column_title7   := 'Description';
    l_column_title8   := 'UOM';
    l_column_title9   := 'Item_type';
    l_column_title10  := 'Item_category';
    l_column_title11  := 'Status';
    l_column_title12  := 'Interface_date';
    l_column_title13  := 'Creation_date';
    l_column_title14  := 'Last_update_date';

    l_request_parameter1_colspan := 14;
    output(l_header);
    -- title
    output('<tr><td class="titlefont" aling="center" colspan="' || l_request_parameter1_colspan || '">' || l_title || '</td></tr>');   
    -- header 
    output('<tr><td align="left" colspan="' || l_request_parameter1_colspan || '">' || SYSDATE || '</td>');
   
    output('<tr class="bordertr" ><td align="center" width="10px" class="td_first">' || l_column_title1 || '</td>');
    output('<td align="center" width="10px">'  || l_column_title2   || '</td>');
    output('<td align="center" width="20px">'  || l_column_title3   || '</td>');
    output('<td align="center" width="20px">'  || l_column_title4   || '</td>');
    output('<td align="center" width="20px">'  || l_column_title5   || '</td>');
    output('<td align="center" width="60px">'  || l_column_title6   || '</td>');
    output('<td align="center" width="80px">'  || l_column_title7   || '</td>');
    output('<td align="center" width="30px">'  || l_column_title8   || '</td>');
    output('<td align="center" width="40px">'  || l_column_title9   || '</td>');
    output('<td align="center" width="30px">'  || l_column_title10   || '</td>');
    output('<td align="center" width="30px">'  || l_column_title11   || '</td>');
    output('<td align="center" width="40px">'  || l_column_title12   || '</td>');
    output('<td align="center" width="40px">'  || l_column_title13   || '</td>');
    output('<td align="center" width="40px">'  || l_column_title14   || '</td>');
  
    FOR rec IN cur_cust LOOP
     l_count := 1;
     output('<tr class="boydtr">');
     output('<td class="body_first" align="left" width="10px">' || NVL(to_char(rec.unique_id), '&nbsp;') || '</td>');   
     print_html_td_rowspan(10,  NVL(to_char(rec.group_id),          '&nbsp;'));
     print_html_td_rowspan(20,  NVL(rec.action,                     '&nbsp;'));
     print_html_td_rowspan(20,  NVL(rec.org_code,                   '&nbsp;'));
     print_html_td_rowspan(20,  NVL(to_char(rec.inventory_item_id), '&nbsp;'));
     print_html_td_rowspan(60,  NVL(rec.itme_number,                '&nbsp;'));
     print_html_td_rowspan(80,  NVL(rec.description,                '&nbsp;'));
     print_html_td_rowspan(30,  NVL(rec.uom,                        '&nbsp;'));
     print_html_td_rowspan(40,  NVL(rec.item_type,                  '&nbsp;'));
     print_html_td_rowspan(30,  NVL(rec.item_category ,             '&nbsp;'));
     print_html_td_rowspan(30,  NVL(rec.status,                     '&nbsp;'));
     print_html_td_rowspan(40,  NVL(to_char(rec.interface_date),    '&nbsp;'));
     print_html_td_rowspan(40,  NVL(to_char(rec.creation_date),     '&nbsp;'));
     print_html_td_rowspan(40,  NVL(to_char(rec.last_update_date),  '&nbsp;'));
     
     output('</tr>'); 

    END LOOP;
     
    IF l_count = 0 THEN 
      output('<tr class="boydtr">');
      output('<td class="body_first" align="center" width="100px" colspan="'|| l_request_parameter1_colspan||' ">' 
             ||'<strong>There are no Items Changed or Created !</strong>' || '</td>');
      output('</tr>');
    END IF;
    output(l_footer);
    log('Print records end !');
  END print_record_msg;

  --add by wyl 20120916 
  FUNCTION is_print_item(p_item_type     IN VARCHAR2,
                         p_item_status   IN VARCHAR2,
                         p_item_desc     IN VARCHAR2,
                         p_item_category IN VARCHAR2,
                         p_inv_item_id   IN NUMBER,
                         p_org_id        IN VARCHAR)
  RETURN VARCHAR2 IS
  
    CURSOR cur_print_item IS 
      SELECT COUNT(1)
        FROM xxom_item_intf xii
       WHERE xii.inventory_item_id = p_inv_item_id
         AND xii.attribute5        = p_org_id
         AND xii.status            = p_item_status
         AND xii.item_type         = p_item_type
         AND xii.description       = p_item_desc
         AND xii.item_category     = p_item_category;
          
    l_count    NUMBER;
    l_exist    VARCHAR2(1);   
      
  BEGIN
    l_count := 0;
    l_exist := 'N';
    OPEN cur_print_item;
    FETCH cur_print_item
      INTO l_count;
    IF l_count > 0 THEN
      l_exist := 'Y';
    END IF;
    CLOSE cur_print_item;
    
    RETURN l_exist;
  EXCEPTION 
    WHEN OTHERS THEN
      log('is_print_item : ' || SQLERRM);
      l_exist := 'E';
      RETURN l_exist;  
  END is_print_item;
  
  FUNCTION is_item(p_inv_item_id IN NUMBER,
                   p_org_id      IN VARCHAR2)
  RETURN VARCHAR2 IS
    CURSOR cur_item IS
      SELECT NULL
        FROM xxom_item_intf xii
       WHERE xii.inventory_item_id = p_inv_item_id
         AND xii.attribute5        = p_org_id;
         
    l_dummy    VARCHAR2(1);
    l_exist    VARCHAR2(1);     
  BEGIN
    l_exist := 'N';
    OPEN cur_item;
    FETCH cur_item
      INTO l_dummy;
    IF cur_item%FOUND THEN
      l_exist := 'Y';
    END IF;
    CLOSE cur_item;
    
    RETURN l_exist;
  END is_item;
  --process_record
  PROCEDURE process_record( x_return_status  OUT VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,                            
                            p_group_id       IN  VARCHAR2,
                            p_interface_date IN  VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'process_record';
    l_savepoint_name      CONSTANT VARCHAR2(30) := '';   
  
    CURSOR cur_item IS 
      SELECT msiv.inventory_item_id          inventory_item_id,
             msiv.organization_id            organization_id,
             msiv.segment1                   item_number,
             msiv.description                description,
             msiv.primary_unit_of_measure    uom,
             msiv.item_type                  item_code,
             msiv.creation_date              creation_date,
             msiv.last_update_date           last_update_date,
             micv.category_concat_segs       item_category,
             msiv.inventory_item_status_code status,
             a.meaning                       item_type,
             mp.attribute6                   org_code,
             mp.organization_id              inv_org_id

        FROM mtl_system_items_vl                                msiv,
             mtl_item_categories_v                              micv,
             mtl_default_category_sets_fk_v                     m1,
             (SELECT lookup_code ,meaning
                FROM fnd_lookup_values_VL
               WHERE lookup_type = 'ITEM_TYPE')                 a,
             (SELECT organization_id
                FROM org_organization_definitions bb
               WHERE bb.operating_unit = g_org_id
                 AND NVL(bb.disable_date,SYSDATE) > = SYSDATE ) b,
              mtl_parameters                                    mp,
              (SELECT lookup_code
                 FROM xxinv_lookups
                WHERE lookup_type = 'XXINV_GOE_ITEM_TYPE'
                  AND enabled_flag = 'Y') c

      WHERE  msiv.inventory_item_id    = micv.inventory_item_id
        AND  msiv.organization_id      = micv.organization_id
        AND  m1.category_set_id        = micv.category_set_id
        AND  msiv.item_type            = a.lookup_code(+)
        AND  msiv.organization_id      = b.organization_id    
        AND  b.organization_id         = mp.organization_id
        AND  msiv.customer_order_flag  = 'Y'
        AND  m1.functional_area_desc   = 'Inventory'
        AND  a.lookup_code             = c.lookup_code
        AND  NOT EXISTS (SELECT 1
                           FROM xxpjm_mfg_numbers_v 
                          WHERE organization_id = g_org_id
                            AND msiv.segment1   = mfg_number)
        AND  msiv.last_update_date > = fnd_conc_date.string_to_date(p_interface_date)
        AND  msiv.inventory_item_status_code <> 'Created';                           --add by wyl 20120913
      
    l_action                     VARCHAR2(10);
    l_interface_date             DATE;
    l_group_id_goe               VARCHAR2(200);
    l_inventory_item_status_code VARCHAR2(10);
    l_count                      NUMBER DEFAULT 0;
    l_print_flag1                VARCHAR2(1);
    l_print_flag2                VARCHAR2(1);
    l_org_id                     VARCHAR2(50);
  BEGIN
    log('Org_id : ' || g_org_id);
  
    log('****Interface_date :' || p_interface_date);

    x_return_status := fnd_api.g_ret_sts_success;    
        
    FOR rec_item IN cur_item LOOP
      l_count := 1;
      l_group_id_goe := NULL;
      l_print_flag1  := 'N';
      l_print_flag2  := 'N';
      l_org_id       := NULL;
      
      log('-----------------------Inventory_id : ' || rec_item.inventory_item_id);
      log('item_number : '  || rec_item.item_number);
      log('Group_id : ' || p_group_id);
      
      l_org_id := to_char(rec_item.organization_id);
      l_action := NULL;

      IF is_item(rec_item.inventory_item_id,
                 l_org_id) = 'N' THEN
        l_action := 'Create';
      ELSE 
        l_action := 'Update';
      END IF;
 
      /*IF rec_item.status = 'Created' THEN
        l_inventory_item_status_code := 'Active';
      ELSE*/
        l_inventory_item_status_code := rec_item.status;
      /*END IF;*/

      l_interface_date := to_date(to_char(SYSDATE,'MMDDYYYY'),'MMDDYYYY');
      --l_group_id       := g_org_id || rec_item.item_number || l_interface_date ;
      l_group_id_goe   := rec_item.inv_org_id || rec_item.item_number || l_interface_date ;

      log('Group_id_GOE : ' || l_group_id_goe );
      log('Org_Code : ' || rec_item.org_code);
      --add by wyl 20120913 begin
      IF rec_item.org_code IS NOT NULL THEN
        l_print_flag1 := 'Y';
      END IF;
      --add by wyl 20120913 end
      
      --add by wyl 20120916 begin
      
      log('rec_item.item_type : ' || rec_item.item_type);
      log('l_inventory_item_status_code : ' || l_inventory_item_status_code );  
      log('rec_item.description : ' || rec_item.description); 
      log('rec_item.item_category : ' || rec_item.item_category); 
      log('rec_item.inventory_item_id : ' || rec_item.inventory_item_id);  
       
      IF is_print_item(rec_item.item_type,                     
                       l_inventory_item_status_code,          
                       rec_item.description,                  
                       rec_item.item_category,
                       rec_item.inventory_item_id,
                       l_org_id) = 'N' THEN
        l_print_flag2 := 'Y';
      END IF; 
     
      --add by wyl 20120916 end
      
      log('Print_flag1 : ' || l_print_flag1);
      log('Print_flag2 : ' || l_print_flag2);
      IF l_print_flag1 = 'Y' AND l_print_flag2 = 'Y' THEN 
        
        IF l_action = 'Create' THEN
          INSERT INTO xxom_item_intf(
            unique_id,    
            group_id_goe,
            group_id,
            action,
            org_code, 
            inventory_item_id,
            itme_number,
            description,
            uom,
            item_type,
            item_category, 
            status,
            interface_date,
            created_by,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            request_id,
            process_status,
            attribute5)                       --add by wyl 20120916      org id
          VALUES( 
            xxom_item_intf_s.nextval,  
            l_group_id_goe,
            p_group_id,
            l_action,
            rec_item.org_code,   
            rec_item.inventory_item_id,
            rec_item.item_number,
            rec_item.description,
            rec_item.uom,
            rec_item.item_type,
            rec_item.item_category,
            l_inventory_item_status_code,
            l_interface_date,
            g_user_id,
            g_user_id,
            g_login_id,
            g_prog_appl_id,
            g_conc_program_id,
            g_request_id,
            'P',
            l_org_id);                              --add by wyl 20120916
          
        ELSIF l_action = 'Update' THEN
          UPDATE xxom_item_intf 
            SET unique_id            = xxom_item_intf_s.nextval    
                ,group_id_goe        = l_group_id_goe
                ,group_id            = p_group_id
                ,action              = l_action
                ,org_code            = rec_item.org_code
                ,inventory_item_id   = rec_item.inventory_item_id
                ,itme_number         = rec_item.item_number
                ,description         = rec_item.description
                ,uom                 = rec_item.uom 
                ,item_type           = rec_item.item_type
                ,item_category       = rec_item.item_category
                ,status              = l_inventory_item_status_code
                ,interface_date      = l_interface_date
                ,created_by          = g_user_id
                ,last_updated_by     = g_user_id
                ,last_update_login   = g_login_id
                ,program_application_id = g_prog_appl_id
                ,program_id             = g_conc_program_id
                ,request_id             = g_request_id
                ,process_status         = 'P'   
                ,attribute5             = l_org_id
          WHERE inventory_item_id = rec_item.inventory_item_id
            AND attribute5        = l_org_id;      
           
        END IF;
      END IF;

    END LOOP;

    IF l_count = 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
      log('There are no Items Changed or Created!'); 
    END IF;

    log('print_record_msg begin');
    print_record_msg(p_group_id);
    log('print_record_msg end');
    

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
    log('print_record_msg begin');
    print_record_msg(p_group_id);
    log('print_record_msg end');

  END process_record;

  PROCEDURE process_request(p_init_msg_list  IN  VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit         IN  VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            p_group_id       IN  NUMBER,
                            p_interface_date IN  VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
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
    -- API body

    -- logging parameters
    IF l_debug = 'Y' THEN
      xxfnd_debug.log('p_group_id : '       || p_group_id);
      xxfnd_debug.log('p_interface_date : ' || p_interface_date);
    END IF;

    -- todo
    process_record(x_return_status,
                   x_msg_count,
                   x_msg_data,                            
                   p_group_id,
                   p_interface_date);

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

  PROCEDURE main(errbuf           OUT VARCHAR2,
                 retcode          OUT VARCHAR2,
                 p_group_id       IN  NUMBER,
                 p_interface_date IN  VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body

    -- convert parameter data type, such as varchar2 to date
    -- l_date := fnd_conc_date.string_to_date(p_parameter1);

    -- call process request api
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
END xxom_item_intf_pkg;
/
