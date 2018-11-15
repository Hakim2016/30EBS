DECLARE

BEGIN

  SELECT mtl_material_transactions_s.nextval
    INTO ln_transaction_interface_id
    FROM dual;
  --
  IF rec_sos_data.sos_type = 'I' THEN
    rec_trx_interface.transaction_type_id := g_wip_issue_id; --WIP Issue
    l_sign                                := -1;
  ELSE
    rec_trx_interface.transaction_type_id := g_wip_return_id; --WIP Return
    l_sign                                := 1;
  END IF;
  rec_trx_interface.transaction_mode         := 3; -- background <automatic call Process transaction interface>
  rec_trx_interface.process_flag             := 1; -- to be processed
  rec_trx_interface.validation_required      := 1;
  rec_trx_interface.inventory_item_id        := rec_sos_data.inventory_item_id;
  rec_trx_interface.subinventory_code        := rec_sos_data.subinventory_code;
  rec_trx_interface.organization_id          := rec_sos_data.organization_id;
  rec_trx_interface.locator_id               := rec_sos_data.locator_id;
  rec_trx_interface.transaction_header_id    := ln_transaction_interface_id;
  rec_trx_interface.transaction_interface_id := ln_transaction_interface_id;
  rec_trx_interface.transaction_source_id    := rec_sos_data.wip_entity_id; -- wip_entity_id
  rec_trx_interface.transaction_quantity     := rec_sos_data.issue_quantity * l_sign;
  rec_trx_interface.transaction_uom          := rec_sos_data.primary_uom_code;
  rec_trx_interface.transaction_date         := p_transaction_date;
  rec_trx_interface.source_code              := rec_sos_data.sos_header_id;
  rec_trx_interface.source_header_id         := rec_sos_data.sos_header_id;
  rec_trx_interface.source_line_id           := rec_sos_data.sos_dist_id;
  rec_trx_interface.lock_flag                := 1;

  --2012-03-21 add sos number into transaction_reference
  rec_trx_interface.transaction_reference := rec_sos_data.sos_number;
  -- add end
  --
  rec_trx_interface.last_update_date  := g_last_updated_date;
  rec_trx_interface.last_updated_by   := g_last_updated_by;
  rec_trx_interface.creation_date     := g_creation_date;
  rec_trx_interface.created_by        := g_created_by;
  rec_trx_interface.last_update_login := g_last_update_login;
  rec_trx_interface.operation_seq_num := rec_sos_data.operation_seq_num;
  --

  INSERT INTO mtl_transactions_interface
  VALUES rec_trx_interface;

  --Insert into lot information
  IF rec_sos_data.lot_number IS NOT NULL THEN
    rec_trx_lot_interface.transaction_interface_id := ln_transaction_interface_id;
    rec_trx_lot_interface.lot_number               := rec_sos_data.lot_number;
    rec_trx_lot_interface.transaction_quantity     := rec_trx_interface.transaction_quantity;
    rec_trx_lot_interface.last_update_date         := g_last_updated_date;
    rec_trx_lot_interface.last_updated_by          := g_last_updated_by;
    rec_trx_lot_interface.creation_date            := g_creation_date;
    rec_trx_lot_interface.created_by               := g_created_by;
    INSERT INTO mtl_transaction_lots_interface
    VALUES rec_trx_lot_interface;
  END IF;

  --cancel reservation
  IF rec_sos_data.sos_type = 'I' THEN
    proc_cancel_reservation(rec_sos_data.reservation_id);
  END IF;

  ln_retval := inv_txn_manager_pub.process_transactions(p_api_version      => 1,
                                                        p_init_msg_list    => fnd_api.g_false,
                                                        p_commit           => fnd_api.g_false,
                                                        p_validation_level => fnd_api.g_valid_level_full,
                                                        x_return_status    => lv_return_status,
                                                        x_msg_count        => ln_msg_cnt,
                                                        x_msg_data         => lv_msg_data,
                                                        x_trans_count      => ln_trans_count,
                                                        p_table            => 1,
                                                        p_header_id        => ln_transaction_interface_id);

  IF ln_retval <> 0 THEN
    --get error message
    SELECT mti.error_code,
           mti.error_explanation
      INTO lv_error_code,
           lv_error_explanation
      FROM mtl_transactions_interface mti
     WHERE mti.transaction_interface_id = ln_transaction_interface_id;
  
    xxfnd_api.set_message('XXWIP', 'XXWIP_002E_001', 'MESSAGE', lv_error_code);
    RAISE fnd_api.g_exc_error;
  END IF;
  
END;
