DECLARE

  l_header_rec     oe_order_pub.header_rec_type;
  l_org_id         NUMBER := NULL; --MOAC
  l_operating_unit VARCHAR2(20) := NULL; -- MOAC
  l_header_out_rec oe_order_pub.header_rec_type;
  l_return_status  VARCHAR2(20);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  PROCEDURE create_so_header(p_header_rec     IN oe_order_pub.header_rec_type,
                             p_org_id         IN NUMBER := NULL, --MOAC
                             p_operating_unit IN VARCHAR2 := NULL, -- MOAC
                             x_header_out_rec OUT NOCOPY oe_order_pub.header_rec_type,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2) IS
  
    l_api_version_number NUMBER := 1.0;
  
    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    /*****************PARAMETERS****************************************************/
    l_debug_level        NUMBER := 1; -- OM DEBUG LEVEL (MAX 5)
    l_header_rec         oe_order_pub.header_rec_type;
    l_line_tbl           oe_order_pub.line_tbl_type;
    l_action_request_tbl oe_order_pub.request_tbl_type;
    /***OUT VARIABLES FOR PROCESS_ORDER API***************************/
    /*l_header_rec_out             oe_order_pub.header_rec_type;*/
    l_header_val_rec_out         oe_order_pub.header_val_rec_type;
    l_header_adj_tbl_out         oe_order_pub.header_adj_tbl_type;
    l_header_adj_val_tbl_out     oe_order_pub.header_adj_val_tbl_type;
    l_header_price_att_tbl_out   oe_order_pub.header_price_att_tbl_type;
    l_header_adj_att_tbl_out     oe_order_pub.header_adj_att_tbl_type;
    l_header_adj_assoc_tbl_out   oe_order_pub.header_adj_assoc_tbl_type;
    l_header_scredit_tbl_out     oe_order_pub.header_scredit_tbl_type;
    l_header_scredit_val_tbl_out oe_order_pub.header_scredit_val_tbl_type;
    l_line_tbl_out               oe_order_pub.line_tbl_type;
    l_line_val_tbl_out           oe_order_pub.line_val_tbl_type;
    l_line_adj_tbl_out           oe_order_pub.line_adj_tbl_type;
    l_line_adj_val_tbl_out       oe_order_pub.line_adj_val_tbl_type;
    l_line_price_att_tbl_out     oe_order_pub.line_price_att_tbl_type;
    l_line_adj_att_tbl_out       oe_order_pub.line_adj_att_tbl_type;
    l_line_adj_assoc_tbl_out     oe_order_pub.line_adj_assoc_tbl_type;
    l_line_scredit_tbl_out       oe_order_pub.line_scredit_tbl_type;
    l_line_scredit_val_tbl_out   oe_order_pub.line_scredit_val_tbl_type;
    l_lot_serial_tbl_out         oe_order_pub.lot_serial_tbl_type;
    l_lot_serial_val_tbl_out     oe_order_pub.lot_serial_val_tbl_type;
    l_action_request_tbl_out     oe_order_pub.request_tbl_type;
    l_msg_index                  NUMBER;
    l_data                       VARCHAR2(2000);
    l_loop_count                 NUMBER;
    l_debug_file                 VARCHAR2(200);
    -- book API vars
  
    b_return_status VARCHAR2(200);
    b_msg_count     NUMBER;
    b_msg_data      VARCHAR2(2000);
  BEGIN
    /*dbms_application_info.set_client_info(l_org);*/
    /* fnd_global.APPS_INITIALIZE(1254,50657,660);
    mo_global.init('ONT');*/
    /*****************INITIALIZE DEBUG INFO*************************************/
    IF (l_debug_level > 0) THEN
      l_debug_file := oe_debug_pub.set_debug_mode('FILE');
      oe_debug_pub.initialize;
      oe_debug_pub.setdebuglevel(l_debug_level);
      oe_msg_pub.initialize;
    END IF;
    /*****************INITIALIZE ENVIRONMENT*************************************/
    --fnd_global.apps_initialize(l_user, l_resp, l_appl); -- pass in user_id, responsibility_id, and application_id
    /*****************INITIALIZE HEADER RECORD******************************/
  
    /* l_header_rec.operation               := oe_globals.g_opr_create;
    l_header_rec.order_type_id           := 1065; --1430;
    l_header_rec.sold_to_org_id          := 6044; --1006;
    l_header_rec.ship_to_org_id          := 1151; --1026;
    l_header_rec.order_number :='0306017';*/
    --l_header_rec.price_list_id           := p_price_list_id; --1000;
    --l_header_rec.pricing_date            := SYSDATE;
    -- l_header_rec.transactional_curr_code := p_curr_code; --'USD';
    -- l_header_rec.flow_status_code        := p_flow_status_code; --'ENTERED';
    -- l_header_rec.cust_po_number          := p_po_num; --'06112009-08';
    /* l_header_rec.order_source_id         := 0; --0 ;
    l_header_rec.org_id :=82;
    l_header_rec.payment_term_id :=4;
    l_header_rec.salesrep_id :=-3;*/
    --l_header_rec.attribute1 := 'ABC';
    /*******INITIALIZE ACTION REQUEST RECORD*************************************/
   /* l_action_request_tbl(1) := oe_order_pub.g_miss_request_rec;
    l_action_request_tbl(1).request_type := oe_globals.g_book_order;
    l_action_request_tbl(1).entity_code := oe_globals.g_entity_header;*/
    /*****************INITIALIZE LINE RECORD********************************/
  
    /*****************CALLTO PROCESS ORDER API*********************************/
    oe_order_pub.process_order(p_api_version_number => l_api_version_number,
                               p_header_rec         => p_header_rec,
                               p_org_id             => p_org_id,
                               p_line_tbl           => l_line_tbl,
                               p_action_request_tbl => l_action_request_tbl,
                               --OUT variables
                               x_header_rec             => x_header_out_rec,
                               x_header_val_rec         => l_header_val_rec_out,
                               x_header_adj_tbl         => l_header_adj_tbl_out,
                               x_header_adj_val_tbl     => l_header_adj_val_tbl_out,
                               x_header_price_att_tbl   => l_header_price_att_tbl_out,
                               x_header_adj_att_tbl     => l_header_adj_att_tbl_out,
                               x_header_adj_assoc_tbl   => l_header_adj_assoc_tbl_out,
                               x_header_scredit_tbl     => l_header_scredit_tbl_out,
                               x_header_scredit_val_tbl => l_header_scredit_val_tbl_out,
                               x_line_tbl               => l_line_tbl_out,
                               x_line_val_tbl           => l_line_val_tbl_out,
                               x_line_adj_tbl           => l_line_adj_tbl_out,
                               x_line_adj_val_tbl       => l_line_adj_val_tbl_out,
                               x_line_price_att_tbl     => l_line_price_att_tbl_out,
                               x_line_adj_att_tbl       => l_line_adj_att_tbl_out,
                               x_line_adj_assoc_tbl     => l_line_adj_assoc_tbl_out,
                               x_line_scredit_tbl       => l_line_scredit_tbl_out,
                               x_line_scredit_val_tbl   => l_line_scredit_val_tbl_out,
                               x_lot_serial_tbl         => l_lot_serial_tbl_out,
                               x_lot_serial_val_tbl     => l_lot_serial_val_tbl_out,
                               x_action_request_tbl     => l_action_request_tbl_out,
                               x_return_status          => x_return_status,
                               x_msg_count              => x_msg_count,
                               x_msg_data               => x_msg_data);
  
    /*****************CHECK RETURN STATUS***********************************/
    IF x_return_status = fnd_api.g_ret_sts_success THEN
      dbms_output.put_line('Return status is success ');
      dbms_output.put_line('debug level ' || l_debug_level);
      IF (l_debug_level > 0) THEN
        dbms_output.put_line('success');
      END IF;
      /*COMMIT;*/
    ELSE
      dbms_output.put_line('Return status failure ');
      IF (l_debug_level > 0) THEN
        dbms_output.put_line('failure');
      END IF;
      /* ROLLBACK;*/
    END IF;
  
    /*****************DISPLAY RETURN STATUS FLAGS******************************/
    IF (l_debug_level > 0) THEN
      dbms_output.put_line('process ORDER ret status IS: ' || x_return_status);
      dbms_output.put_line('process ORDER msg data IS: ' || x_msg_data);
      dbms_output.put_line('process ORDER msg COUNT IS: ' || x_msg_count);
      dbms_output.put_line('header.order_number IS: ' || to_char(x_header_out_rec.order_number));
      dbms_output.put_line('header.return_status IS: ' || x_header_out_rec.return_status);
      dbms_output.put_line('header.booked_flag IS: ' || x_header_out_rec.booked_flag);
      dbms_output.put_line('header.header_id IS: ' || x_header_out_rec.header_id);
      dbms_output.put_line('header.order_source_id IS: ' || x_header_out_rec.order_source_id);
      dbms_output.put_line('header.flow_status_code IS: ' || x_header_out_rec.flow_status_code);
    END IF;
    /*****************DISPLAY ERROR MSGS*************************************/
    IF (l_debug_level > 0) THEN
      FOR l_index IN 1 .. x_msg_count
      LOOP
        x_msg_data := fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
        dbms_output.put_line(' x_msg_data 1 ' || l_index || ' : ' || x_msg_data);
      END LOOP;
    
      FOR i IN 1 .. x_msg_count
      LOOP
        oe_msg_pub.get(p_msg_index     => i,
                       p_encoded       => fnd_api.g_false,
                       p_data          => l_data,
                       p_msg_index_out => l_msg_index);
        dbms_output.put_line('message is: ' || l_data);
        dbms_output.put_line('message index is: ' || l_msg_index);
        x_msg_data := x_msg_data || l_data;
      END LOOP;
    END IF;
    IF (l_debug_level > 0) THEN
      dbms_output.put_line('Debug = ' || oe_debug_pub.g_debug);
      dbms_output.put_line('Debug Level = ' || to_char(oe_debug_pub.g_debug_level));
      dbms_output.put_line('Debug File = ' || oe_debug_pub.g_dir || '/' || oe_debug_pub.g_file);
      dbms_output.put_line('****************************************************');
    
      oe_debug_pub.debug_off;
    END IF;
  END create_so_header;

BEGIN
  mo_global.init('ONT');
  l_header_rec := oe_order_pub.g_miss_header_rec;

  l_header_rec.order_source_id       := 0;
  l_header_rec.orig_sys_document_ref := 'import order';
  l_header_rec.salesrep_id           := 100002049; -- p_temp_type.salesrep_id;  100002049 100002052
  l_header_rec.booked_date           := SYSDATE;
  l_header_rec.operation             := oe_globals.g_opr_create;
  l_header_rec.cust_po_number        := NULL;
  l_header_rec.sold_to_org_id        := 8087; -- p_temp_type.customer_id;
  l_header_rec.ship_to_org_id        := 15448; -- p_temp_type.ship_to_id;
  l_header_rec.invoice_to_org_id     := 15434; --p_temp_type.bill_to_id;
  l_header_rec.order_category_code   := 'ORDER';
  l_header_rec.order_type_id         := 1011; -- p_temp_type.sales_type_id;
  l_header_rec.org_id                := 84; --p_temp_type.org_id;
  l_header_rec.payment_term_id       := 5; --p_temp_type.payment_term_id;
  l_header_rec.cust_po_number        := NULL; --p_temp_type.customer_po_number;
  l_header_rec.order_number          := '10021000002'; --p_temp_type.so_number;
  l_header_rec.price_list_id         := 6107; --p_temp_type.price_list_id;
  l_header_rec.ordered_date          := SYSDATE; --nvl(p_temp_type.issue_date, SYSDATE);
  l_header_rec.shipping_method_code  := '000001_HITACHI-C_R_LTL'; --p_temp_type.shipping_method_code;

  create_so_header(p_header_rec => l_header_rec,
                   p_org_id     => l_header_rec.org_id,
                   -- p_operating_unit => l_operating_unit,
                   x_header_out_rec => l_header_out_rec,
                   x_return_status  => l_return_status,
                   x_msg_count      => l_msg_count,
                   x_msg_data       => l_msg_data);

  dbms_output.put_line(' l_return_status : ' || l_return_status);
  dbms_output.put_line(' l_msg_count     : ' || l_msg_count);
  dbms_output.put_line(' l_msg_data      : ' || l_msg_data);
  dbms_output.put_line(' order_number    : ' || l_header_out_rec.order_number);
END;
