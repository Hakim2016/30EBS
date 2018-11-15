DECLARE
  l_transaction_record mtl_transactions_interface%ROWTYPE;

  l_retval        NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(4000);
  l_trans_count   NUMBER;

  CURSOR cur_data IS
  
    SELECT params.transaction_type_id,
           ood.organization_id,
           ood.organization_code,
           msib.inventory_item_id,
           params.subinventory_code,
           params.locator_id,
           -params.transaction_quantity transaction_quantity,
           params.transaction_uom,
           params.transaction_date,
           gcc.code_combination_id      distribution_account_id,
           params.source_code,
           params.source_header_id,
           params.source_line_id
      FROM org_organization_definitions ood,
           mtl_system_items_b msib,
           gl_code_combinations_kfv gcc,
           (SELECT 32 transaction_type_id, -- Miscellaneous issue           
                   'SG1' organization_code,
                   'H3005422-D-0000' item_number,
                   'MRB2' subinventory_code,
                   28182 locator_id,
                   1 transaction_quantity,
                   'ea' transaction_uom,
                   SYSDATE transaction_date,
                   'FB00.000.1186210000.1186000000.0.0.0' distribution_account,
                   'PJL Test' source_code,
                   123456789 source_line_id,
                   123 source_header_id
              FROM dual
            
            ) params
     WHERE 1 = 1
       AND ood.organization_id = msib.organization_id
       AND gcc.concatenated_segments = TRIM(params.distribution_account)
       AND msib.segment1 = TRIM(params.item_number)
       AND ood.organization_code = TRIM(params.organization_code);

BEGIN
  fnd_global.apps_initialize(user_id      => 2657, --
                             resp_id      => 50676,
                             resp_appl_id => 660);
  l_transaction_record.last_update_date  := SYSDATE;
  l_transaction_record.last_updated_by   := fnd_global.user_id;
  l_transaction_record.creation_date     := SYSDATE;
  l_transaction_record.created_by        := fnd_global.user_id;
  l_transaction_record.last_update_login := fnd_global.login_id;

  FOR rec_data IN cur_data
  LOOP
    SELECT mtl_material_transactions_s.nextval
      INTO l_transaction_record.transaction_interface_id
      FROM dual;
    l_transaction_record.source_code             := rec_data.source_code; -- 'PJL Test';
    l_transaction_record.source_line_id          := rec_data.source_line_id; -- 123456789;
    l_transaction_record.source_header_id        := rec_data.source_header_id; -- 123456789;
    l_transaction_record.process_flag            := 1; -- to be processed
    l_transaction_record.transaction_mode        := 3; -- background <automatic call Process transaction interface>
    l_transaction_record.transaction_header_id   := l_transaction_record.transaction_interface_id;
    l_transaction_record.transaction_type_id     := rec_data.transaction_type_id; -- 67;
    l_transaction_record.inventory_item_id       := rec_data.inventory_item_id; -- 212052;
    l_transaction_record.organization_id         := rec_data.organization_id; -- 86;
    l_transaction_record.subinventory_code       := rec_data.subinventory_code; -- 'FRM';
    l_transaction_record.locator_id              := rec_data.locator_id; -- 231;
    l_transaction_record.transaction_quantity    := rec_data.transaction_quantity; -- 1;
    l_transaction_record.transaction_uom         := rec_data.transaction_uom; -- 'ea';
    l_transaction_record.transaction_date        := rec_data.transaction_date; -- SYSDATE;
    l_transaction_record.distribution_account_id := rec_data.distribution_account_id;
    --l_transaction_record.transfer_organization := rec_data.transfer_organization; -- 86;
    --l_transaction_record.transfer_subinventory := rec_data.transfer_subinventory; -- 'FRM';
    --l_transaction_record.transfer_locator      := rec_data.transfer_locator; -- 27929;
  
    INSERT INTO mtl_transactions_interface
    VALUES l_transaction_record;
  
    l_retval := inv_txn_manager_pub.process_transactions(p_api_version      => 1,
                                                         p_init_msg_list    => fnd_api.g_false,
                                                         p_commit           => fnd_api.g_false,
                                                         p_validation_level => fnd_api.g_valid_level_full,
                                                         x_return_status    => l_return_status,
                                                         x_msg_count        => l_msg_count,
                                                         x_msg_data         => l_msg_data,
                                                         x_trans_count      => l_trans_count,
                                                         p_table            => 1,
                                                         p_header_id        => l_transaction_record.transaction_interface_id);
    dbms_output.put_line(' l_return_status : ' || l_return_status);
    dbms_output.put_line(' l_msg_count     : ' || l_msg_count);
    dbms_output.put_line(' l_msg_data      : ' || l_msg_data);
    dbms_output.put_line(' l_trans_count   : ' || l_trans_count);
  
    IF l_retval <> 0 THEN
      --get error message
      SELECT mti.error_code,
             mti.error_explanation
        INTO l_transaction_record.error_code,
             l_transaction_record.error_explanation
        FROM mtl_transactions_interface mti
       WHERE mti.transaction_interface_id = l_transaction_record.transaction_interface_id;
    
      dbms_output.put_line(' error_code        : ' || l_transaction_record.error_code);
      dbms_output.put_line(' error_explanation : ' || l_transaction_record.error_explanation);
      RAISE fnd_api.g_exc_error;
    END IF;
  END LOOP;
END;
