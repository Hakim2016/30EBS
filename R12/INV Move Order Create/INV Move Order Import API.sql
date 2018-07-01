DECLARE
  l_return_status  VARCHAR2(1);
  l_msg_data       VARCHAR2(4000);
  l_trohdr_rec     inv_move_order_pub.trohdr_rec_type;
  l_ret_trohdr_rec inv_move_order_pub.trohdr_rec_type;
  l_trolin_rec     inv_move_order_pub.trolin_rec_type;
  l_trolin_tbl     inv_move_order_pub.trolin_tbl_type;
  l_ret_trolin_tbl inv_move_order_pub.trolin_tbl_type;

  /*
   *  proc_create_move_order_header
   *  
  */
  PROCEDURE proc_create_move_order_header(p_trohdr_rec    IN inv_move_order_pub.trohdr_rec_type,
                                          x_return_status OUT VARCHAR2,
                                          x_msg_data      OUT VARCHAR2,
                                          x_trohdr_rec    OUT inv_move_order_pub.trohdr_rec_type) IS
    -- Common Declarations
    l_api_version   NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2) := fnd_api.g_true;
    l_return_values VARCHAR2(2) := fnd_api.g_false;
    l_commit        VARCHAR2(2) := fnd_api.g_false;
    x_msg_count     NUMBER := 0;
    l_msg_data      VARCHAR2(4000);
  
    -- API specific declarations
    l_trohdr_rec     inv_move_order_pub.trohdr_rec_type;
    l_trohdr_val_rec inv_move_order_pub.trohdr_val_rec_type;
    -- x_trohdr_rec      inv_move_order_pub.trohdr_rec_type;
    x_trohdr_val_rec  inv_move_order_pub.trohdr_val_rec_type;
    l_validation_flag VARCHAR2(2) := inv_move_order_pub.g_validation_yes;
  BEGIN
    l_trohdr_rec := p_trohdr_rec;
    inv_move_order_pub.create_move_order_header(p_api_version_number => l_api_version,
                                                p_init_msg_list      => l_init_msg_list,
                                                p_return_values      => l_return_values,
                                                p_commit             => l_commit,
                                                x_return_status      => x_return_status,
                                                x_msg_count          => x_msg_count,
                                                x_msg_data           => x_msg_data,
                                                p_trohdr_rec         => l_trohdr_rec,
                                                p_trohdr_val_rec     => l_trohdr_val_rec,
                                                x_trohdr_rec         => x_trohdr_rec,
                                                x_trohdr_val_rec     => x_trohdr_val_rec,
                                                p_validation_flag    => l_validation_flag);
    IF x_msg_count > 0 THEN
      FOR i IN 1 .. x_msg_count
      LOOP
        l_msg_data := l_msg_data || ' [' || fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F') || ']';
      END LOOP;
    END IF;
    x_msg_data := l_msg_data || x_msg_data;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := x_msg_data || '[' || SQLCODE || ':' || SQLERRM || ']';
  END proc_create_move_order_header;

  /*
   *  proc_create_move_order_lines
   *  
  */
  PROCEDURE proc_create_move_order_lines(p_trolin_tbl    IN inv_move_order_pub.trolin_tbl_type,
                                         x_return_status OUT VARCHAR2,
                                         x_msg_data      OUT VARCHAR2,
                                         x_trolin_tbl    OUT inv_move_order_pub.trolin_tbl_type) IS
    -- Common Declarations
    l_api_version   NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2) := fnd_api.g_true;
    l_return_values VARCHAR2(2) := fnd_api.g_false;
    l_commit        VARCHAR2(2) := fnd_api.g_false;
    x_msg_count     NUMBER := 0;
    l_msg_data      VARCHAR2(4000);
  
    -- API specific declarations
    l_trolin_tbl     inv_move_order_pub.trolin_tbl_type;
    l_trolin_val_tbl inv_move_order_pub.trolin_val_tbl_type;
    --x_trolin_tbl      inv_move_order_pub.trolin_tbl_type;
    x_trolin_val_tbl  inv_move_order_pub.trolin_val_tbl_type;
    l_validation_flag VARCHAR2(2) := inv_move_order_pub.g_validation_yes;
  BEGIN
    l_trolin_tbl := p_trolin_tbl;
    inv_move_order_pub.create_move_order_lines(p_api_version_number => l_api_version,
                                               p_init_msg_list      => l_init_msg_list,
                                               p_return_values      => l_return_values,
                                               p_commit             => l_commit,
                                               x_return_status      => x_return_status,
                                               x_msg_count          => x_msg_count,
                                               x_msg_data           => x_msg_data,
                                               p_trolin_tbl         => l_trolin_tbl,
                                               p_trolin_val_tbl     => l_trolin_val_tbl,
                                               x_trolin_tbl         => x_trolin_tbl,
                                               x_trolin_val_tbl     => x_trolin_val_tbl,
                                               p_validation_flag    => l_validation_flag);
    IF x_msg_count > 0 THEN
      FOR i IN 1 .. x_msg_count
      LOOP
        l_msg_data := l_msg_data || ' [' || fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F') || ']';
      END LOOP;
    END IF;
    x_msg_data := l_msg_data || x_msg_data;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := x_msg_data || '[' || SQLCODE || ':' || SQLERRM || ']';
  END proc_create_move_order_lines;

BEGIN
  -- l_trohdr_rec.request_number         := 'TEST_TRO1';
  l_trohdr_rec.date_required          := SYSDATE + 2;
  l_trohdr_rec.organization_id        := 86;
  l_trohdr_rec.from_subinventory_code := NULL;
  l_trohdr_rec.to_subinventory_code   := 'FRM';
  l_trohdr_rec.status_date            := SYSDATE;
  l_trohdr_rec.header_status          := inv_globals.g_to_status_preapproved; -- preApproved
  l_trohdr_rec.transaction_type_id    := inv_globals.g_type_transfer_order_subxfr; -- INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;  
  l_trohdr_rec.move_order_type        := inv_globals.g_move_order_requisition; -- G_MOVE_ORDER_PICK_WAVE;
  l_trohdr_rec.db_flag                := fnd_api.g_true;
  l_trohdr_rec.operation              := inv_globals.g_opr_create;
  l_trohdr_rec.created_by             := 2722; --fnd_global.user_id;
  l_trohdr_rec.creation_date          := SYSDATE;
  l_trohdr_rec.last_updated_by        := 2722; --fnd_global.user_id;
  l_trohdr_rec.last_update_date       := SYSDATE;
  l_trohdr_rec.last_update_login      := fnd_global.login_id;

  proc_create_move_order_header(p_trohdr_rec    => l_trohdr_rec,
                                x_return_status => l_return_status,
                                x_msg_data      => l_msg_data,
                                x_trohdr_rec    => l_ret_trohdr_rec);
  dbms_output.put_line(' l_return_status            : ' || l_return_status);
  dbms_output.put_line(' l_msg_data                 : ' || l_msg_data);
  dbms_output.put_line(' l_ret_trohdr_rec.header_id : ' || l_ret_trohdr_rec.header_id);
  dbms_output.put_line(' l_ret_trohdr_rec.request_number : ' || l_ret_trohdr_rec.request_number);

  IF l_return_status = fnd_api.g_ret_sts_success THEN
  
    l_trolin_rec := NULL;
    SELECT mtl_txn_request_lines_s.nextval
      INTO l_trolin_rec.line_id
      FROM dual;
    l_trolin_rec.header_id              := l_ret_trohdr_rec.header_id;
    l_trolin_rec.transaction_type_id    := l_ret_trohdr_rec.transaction_type_id;
    l_trolin_rec.date_required          := SYSDATE;
    l_trolin_rec.organization_id        := 86;
    l_trolin_rec.inventory_item_id      := 685142;
    l_trolin_rec.from_subinventory_code := NULL;
    l_trolin_rec.to_subinventory_code   := 'FRM';
    l_trolin_rec.quantity               := 2;
    l_trolin_rec.status_date            := SYSDATE;
    l_trolin_rec.uom_code               := 'm';
    l_trolin_rec.line_number            := 1;
    l_trolin_rec.line_status            := inv_globals.g_to_status_preapproved;
    l_trolin_rec.db_flag                := fnd_api.g_true;
    l_trolin_rec.operation              := inv_globals.g_opr_create;
    l_trolin_rec.created_by             := l_trohdr_rec.created_by;
    l_trolin_rec.creation_date          := SYSDATE;
    l_trolin_rec.last_updated_by        := l_trohdr_rec.last_updated_by;
    l_trolin_rec.last_update_date       := SYSDATE;
    l_trolin_rec.last_update_login      := fnd_global.login_id;
  
    l_trolin_tbl(1) := l_trolin_rec;
  
    proc_create_move_order_lines(p_trolin_tbl    => l_trolin_tbl,
                                 x_return_status => l_return_status,
                                 x_msg_data      => l_msg_data,
                                 x_trolin_tbl    => l_ret_trolin_tbl);
  
    dbms_output.put_line(' Line Create ');
    dbms_output.put_line(' l_return_status            : ' || l_return_status);
    dbms_output.put_line(' l_msg_data                 : ' || l_msg_data);
  
  END IF;
END;
