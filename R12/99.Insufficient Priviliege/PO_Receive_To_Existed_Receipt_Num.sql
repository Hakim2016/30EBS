DECLARE
  p_std_group_id         NUMBER;
  p_xxpo_transaction_id  NUMBER;
  p_po_distribution_id   NUMBER := 461218;
  p_transaction_quantity NUMBER;
  p_unit_of_measure      VARCHAR2(10) := 'ea';
  l_sys_receive_group_id NUMBER;
  x_request_id           NUMBER;

  l_iface_header_rec po.rcv_headers_interface%ROWTYPE;
  l_iface_rcv_rec    po.rcv_transactions_interface%ROWTYPE;

  CURSOR cur_data(p_cur_po_distribution_id IN NUMBER) IS
    SELECT pda.po_header_id,
           pda.po_line_id,
           pda.line_location_id,
           pda.po_distribution_id,
           poh.vendor_id,
           poh.vendor_site_id,
           pol.category_id,
           pol.item_id,
           poll.ship_to_organization_id,
           poll.ship_to_location_id,
           poll.unit_meas_lookup_code
      FROM po_distributions_all  pda,
           po_headers_all        poh,
           po_lines_all          pol,
           po_line_locations_all poll
     WHERE pda.po_distribution_id = p_cur_po_distribution_id
       AND pda.po_header_id = poh.po_header_id
       AND pda.po_line_id = pol.po_line_id
       AND pda.line_location_id = poll.line_location_id;
BEGIN
  fnd_global.apps_initialize(user_id => 1393, resp_id => 50676, resp_appl_id => 660);
  SELECT po.rcv_interface_groups_s.nextval
    INTO l_sys_receive_group_id
    FROM dual;
  dbms_output.put_line(' l_sys_receive_group_id : ' || l_sys_receive_group_id);
  FOR rec_data IN cur_data(p_cur_po_distribution_id => p_po_distribution_id)
  LOOP
    SELECT rcv_transactions_interface_s.nextval
      INTO l_iface_rcv_rec.interface_transaction_id
      FROM dual;
  
    l_iface_rcv_rec.last_update_date  := SYSDATE;
    l_iface_rcv_rec.last_updated_by   := fnd_global.user_id;
    l_iface_rcv_rec.creation_date     := SYSDATE;
    l_iface_rcv_rec.created_by        := fnd_global.user_id;
    l_iface_rcv_rec.last_update_login := fnd_global.login_id;
    -- l_iface_rcv_rec.header_interface_id          := l_iface_header_rec.header_interface_id;
    l_iface_rcv_rec.shipment_header_id           := 293031;
    l_iface_rcv_rec.group_id                     := l_sys_receive_group_id; --l_iface_header_rec.group_id;
    l_iface_rcv_rec.processing_status_code       := 'PENDING';
    l_iface_rcv_rec.transaction_status_code      := 'PENDING';
    l_iface_rcv_rec.processing_mode_code         := 'BATCH';
   -- l_iface_rcv_rec.validation_flag              := 'Y'; --c_yes_flag;
    l_iface_rcv_rec.receipt_source_code          := 'VENDOR';
    l_iface_rcv_rec.vendor_id                    := rec_data.vendor_id;
    l_iface_rcv_rec.vendor_site_id               := rec_data.vendor_site_id; --Optional    
    l_iface_rcv_rec.source_document_code         := 'PO';
    l_iface_rcv_rec.po_header_id                 := rec_data.po_header_id;
    l_iface_rcv_rec.po_line_id                   := rec_data.po_line_id;
    l_iface_rcv_rec.po_line_location_id          := rec_data.line_location_id;
    l_iface_rcv_rec.po_distribution_id           := rec_data.po_distribution_id;
    l_iface_rcv_rec.po_release_id                := NULL;
    l_iface_rcv_rec.transaction_type             := 'RECEIVE';
    l_iface_rcv_rec.auto_transact_code           := 'RECEIVE';
    l_iface_rcv_rec.destination_type_code        := 'RECEIVING';
    l_iface_rcv_rec.category_id                  := rec_data.category_id;
    l_iface_rcv_rec.item_id                      := rec_data.item_id;
    l_iface_rcv_rec.transaction_date             := SYSDATE;
    l_iface_rcv_rec.quantity                     := 1; --p_transaction_quantity;
    l_iface_rcv_rec.unit_of_measure              := rec_data.unit_meas_lookup_code; --p_unit_of_measure;
    l_iface_rcv_rec.to_organization_id           := rec_data.ship_to_organization_id;
    l_iface_rcv_rec.ship_to_location_id          := rec_data.ship_to_location_id;
    l_iface_rcv_rec.attribute_category           := 'HEA_OU';
    l_iface_rcv_rec.attribute2                   := 'N'; --c_no_flag; -- First Article
    l_iface_rcv_rec.attribute3                   := 'R'; --c_no_flag; -- New/Resubmission
    l_iface_rcv_rec.attribute5                   := NULL; -- Correction Remarks
    l_iface_rcv_rec.ship_head_attribute_category := 'HEA_ORG';
    l_iface_rcv_rec.interface_source_code        := 'Test'; -- c_interface_source_code;
    l_iface_rcv_rec.interface_source_line_id     := 123456789; --p_xxpo_transaction_id; --g_transaction_tbl(p_po_distribution_id).xxpo_transaction_id;
  
    INSERT INTO po.rcv_transactions_interface
    VALUES l_iface_rcv_rec;
  END LOOP;

  x_request_id := fnd_request.submit_request(application => 'PO',
                                             program     => 'RVCTP',
                                             description => '',
                                             start_time  => '',
                                             sub_request => FALSE,
                                             argument1   => 'BATCH',
                                             argument2   => l_sys_receive_group_id, --l_iface_header_rec.group_id,
                                             argument3   => '',
                                             argument4   => '',
                                             argument5   => '',
                                             argument6   => '',
                                             argument7   => '',
                                             argument8   => '',
                                             argument9   => '',
                                             argument10  => '',
                                             argument11  => '',
                                             argument12  => '',
                                             argument13  => '',
                                             argument14  => '',
                                             argument15  => '',
                                             argument16  => '',
                                             argument17  => '',
                                             argument18  => '',
                                             argument19  => '',
                                             argument20  => '',
                                             argument21  => '',
                                             argument22  => '',
                                             argument23  => '',
                                             argument24  => '',
                                             argument25  => '',
                                             argument26  => '',
                                             argument27  => '',
                                             argument28  => '',
                                             argument29  => '',
                                             argument30  => '',
                                             argument31  => '',
                                             argument32  => '',
                                             argument33  => '',
                                             argument34  => '',
                                             argument35  => '',
                                             argument36  => '',
                                             argument37  => '',
                                             argument38  => '',
                                             argument39  => '',
                                             argument40  => '',
                                             argument41  => '',
                                             argument42  => '',
                                             argument43  => '',
                                             argument44  => '',
                                             argument45  => '',
                                             argument46  => '',
                                             argument47  => '',
                                             argument48  => '',
                                             argument49  => '',
                                             argument50  => '',
                                             argument51  => '',
                                             argument52  => '',
                                             argument53  => '',
                                             argument54  => '',
                                             argument55  => '',
                                             argument56  => '',
                                             argument57  => '',
                                             argument58  => '',
                                             argument59  => '',
                                             argument60  => '',
                                             argument61  => '',
                                             argument62  => '',
                                             argument63  => '',
                                             argument64  => '',
                                             argument65  => '',
                                             argument66  => '',
                                             argument67  => '',
                                             argument68  => '',
                                             argument69  => '',
                                             argument70  => '',
                                             argument71  => '',
                                             argument72  => '',
                                             argument73  => '',
                                             argument74  => '',
                                             argument75  => '',
                                             argument76  => '',
                                             argument77  => '',
                                             argument78  => '',
                                             argument79  => '',
                                             argument80  => '',
                                             argument81  => '',
                                             argument82  => '',
                                             argument83  => '',
                                             argument84  => '',
                                             argument85  => '',
                                             argument86  => '',
                                             argument87  => '',
                                             argument88  => '',
                                             argument89  => '',
                                             argument90  => '',
                                             argument91  => '',
                                             argument92  => '',
                                             argument93  => '',
                                             argument94  => '',
                                             argument95  => '',
                                             argument96  => '',
                                             argument97  => '',
                                             argument98  => '',
                                             argument99  => '',
                                             argument100 => '');
  dbms_output.put_line(' x_request_id : ' || x_request_id);
  IF x_request_id > 0 THEN
    COMMIT;
  END IF;
END;
