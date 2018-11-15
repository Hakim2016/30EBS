DECLARE
  l_transaction_record mtl_transactions_interface%ROWTYPE;

  l_retval        NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(4000);
  l_trans_count   NUMBER;

  CURSOR cur_data IS
  
    SELECT 'PJL Test' source_code,
           123456789 source_line_id,
           123456789 source_header_id,
           67 transaction_type_id,
           212052 inventory_item_id,
           86 organization_id,
           'FRM' subinventory_code,
           231 locator_id,
           1 transaction_quantity,
           'ea' transaction_uom,
           SYSDATE transaction_date,
           86 transfer_organization,
           'FRM' transfer_subinventory,
           27929 transfer_locator
      FROM dual;
BEGIN
  fnd_global.apps_initialize(user_id      => 2657, --
                             resp_id      => 50778,
                             resp_appl_id => 20005);
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
    l_transaction_record.source_code           := rec_data.source_code; -- 'PJL Test';
    l_transaction_record.source_line_id        := rec_data.source_line_id; -- 123456789;
    l_transaction_record.source_header_id      := rec_data.source_header_id; -- 123456789;
    l_transaction_record.process_flag          := 1; -- to be processed
    l_transaction_record.transaction_mode      := 3; -- background <automatic call Process transaction interface>
    l_transaction_record.transaction_header_id := l_transaction_record.transaction_interface_id;
    l_transaction_record.transaction_type_id   := rec_data.transaction_type_id; -- 67;
    l_transaction_record.inventory_item_id     := rec_data.inventory_item_id; -- 212052;
    l_transaction_record.organization_id       := rec_data.organization_id; -- 86;
    l_transaction_record.subinventory_code     := rec_data.subinventory_code; -- 'FRM';
    l_transaction_record.locator_id            := rec_data.locator_id; -- 231;
    l_transaction_record.transaction_quantity  := rec_data.transaction_quantity; -- 1;
    l_transaction_record.transaction_uom       := rec_data.transaction_uom; -- 'ea';
    l_transaction_record.transaction_date      := rec_data.transaction_date; -- SYSDATE;
    l_transaction_record.transfer_organization := rec_data.transfer_organization; -- 86;
    l_transaction_record.transfer_subinventory := rec_data.transfer_subinventory; -- 'FRM';
    l_transaction_record.transfer_locator      := rec_data.transfer_locator; -- 27929;
  
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
-- ==============================================================================

DECLARE
  x_return_status  VARCHAR2(1);
  x_return_message VARCHAR2(4000);
  -- ==============
  -- proc_project_transfer
  -- ==============
  PROCEDURE proc_project_transfer(p_organization_id       IN NUMBER,
                                  p_inventory_item_id     IN NUMBER,
                                  p_subinventory_code     IN VARCHAR2,
                                  p_locator_id            IN NUMBER,
                                  p_transfer_subinventory IN VARCHAR2,
                                  p_transfer_locator      IN NUMBER,
                                  p_transaction_quantity  IN NUMBER,
                                  p_transaction_uom       IN VARCHAR2,
                                  p_transaction_date      IN DATE DEFAULT SYSDATE,
                                  p_source_header_id      IN NUMBER,
                                  p_source_line_id        IN NUMBER,
                                  p_source_code           IN VARCHAR2 DEFAULT 'HAND BULK Transfer(' ||
                                                                              to_char(SYSDATE, 'DD-MON-YY') || ')',
                                  p_transaction_reference IN VARCHAR2 DEFAULT 'HAND BULK Transfer(' ||
                                                                              to_char(SYSDATE, 'DD-MON-YY') || ')',
                                  x_return_status         OUT VARCHAR2,
                                  x_return_message        OUT VARCHAR2) IS
    -- constant
    c_transaction_type_id CONSTANT NUMBER := 67; -- Project Transfer
  
    l_item_trx_rec  apps.mtl_transactions_interface%ROWTYPE;
    l_retval        NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_trans_count   NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  
    l_item_trx_rec                   := NULL;
    l_item_trx_rec.last_update_date  := SYSDATE;
    l_item_trx_rec.last_updated_by   := fnd_global.user_id;
    l_item_trx_rec.creation_date     := SYSDATE;
    l_item_trx_rec.created_by        := fnd_global.user_id;
    l_item_trx_rec.last_update_login := fnd_global.login_id;
  
    SELECT apps.mtl_material_transactions_s.nextval
      INTO l_item_trx_rec.transaction_interface_id
      FROM dual;
    l_item_trx_rec.transaction_type_id   := c_transaction_type_id;
    l_item_trx_rec.transaction_mode      := 3;
    l_item_trx_rec.process_flag          := 1;
    l_item_trx_rec.transaction_header_id := l_item_trx_rec.transaction_interface_id;
    l_item_trx_rec.organization_id       := p_organization_id;
    l_item_trx_rec.inventory_item_id     := p_inventory_item_id;
    l_item_trx_rec.subinventory_code     := p_subinventory_code;
    l_item_trx_rec.locator_id            := p_locator_id;
    l_item_trx_rec.transfer_subinventory := p_transfer_subinventory;
    l_item_trx_rec.transfer_locator      := p_transfer_locator;
    l_item_trx_rec.transaction_quantity  := p_transaction_quantity;
    l_item_trx_rec.transaction_uom       := p_transaction_uom;
    l_item_trx_rec.transaction_date      := p_transaction_date;
    l_item_trx_rec.source_code           := p_source_code; --'TEST_ONLY';
    l_item_trx_rec.source_header_id      := p_source_header_id; --987654321;
    l_item_trx_rec.source_line_id        := p_source_line_id; --987654321;
    l_item_trx_rec.transaction_reference := p_transaction_reference;
  
    INSERT INTO inv.mtl_transactions_interface
    VALUES l_item_trx_rec;
  
    /*l_retval := inv_txn_manager_pub.process_transactions(p_api_version      => 1,
                                                           p_init_msg_list    => fnd_api.g_false,
                                                           p_commit           => fnd_api.g_false,
                                                           p_validation_level => fnd_api.g_valid_level_full,
                                                           x_return_status    => l_return_status,
                                                           x_msg_count        => l_msg_count,
                                                           x_msg_data         => l_msg_data,
                                                           x_trans_count      => l_trans_count,
                                                           p_table            => 1,
                                                           p_header_id        => l_item_trx_rec.transaction_interface_id);
      IF l_retval <> 0 THEN
        --get error message
        SELECT mti.error_code,
               mti.error_explanation
          INTO l_item_trx_rec.error_code,
               l_item_trx_rec.error_explanation
          FROM mtl_transactions_interface mti
         WHERE mti.transaction_interface_id = l_item_trx_rec.transaction_interface_id;
      
        DELETE mtl_transactions_interface mti
         WHERE 1 = 1
           AND mti.transaction_interface_id = l_item_trx_rec.transaction_interface_id;
        x_return_status  := fnd_api.g_ret_sts_error;
        x_return_message := l_msg_data || chr(10) || --
                            ' ERROR_CODE : ' || l_item_trx_rec.error_code || chr(10) || -- 
                            ' ERROR_EXPLANATION : ' || l_item_trx_rec.error_explanation;
      END IF;
    */
  END proc_project_transfer;
BEGIN
  fnd_global.apps_initialize(user_id => 2722, resp_id => 50778, resp_appl_id => 20005);
  -- handle project transfer
  proc_project_transfer(p_organization_id       => TRIM(rec_data.organization_id),
                        p_inventory_item_id     => TRIM(rec_data.inventory_item_id),
                        p_subinventory_code     => TRIM(rec_data.sub_inv),
                        p_locator_id            => TRIM(rec_data.from_locator_id),
                        p_transfer_subinventory => TRIM(rec_data.to_sub_inv),
                        p_transfer_locator      => TRIM(rec_data.to_locator_id),
                        p_transaction_quantity  => TRIM(rec_data.quantity),
                        p_transaction_uom       => TRIM(rec_data.primary_uom),
                        p_transaction_date      => SYSDATE,
                        p_source_header_id      => -1,
                        p_source_line_id        => -1,
                        p_source_code           => 'HAND BULK Transfer',
                        p_transaction_reference => 'HAND BULK Transfer(' || to_char(SYSDATE, 'DD-MON-YYYY') || ')',
                        x_return_status         => x_return_status,
                        x_return_message        => x_return_message);
END;
/
