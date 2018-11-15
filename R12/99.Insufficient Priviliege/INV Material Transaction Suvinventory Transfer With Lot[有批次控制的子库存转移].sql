-- set serveroutput on size 1000000000;
/* 
 *  -- Create table
    create table XXINV.XXINV_SUBINV_TRANSFER_20141021
    (
      organization_code    VARCHAR2(3),
      item_code            VARCHAR2(40),
      subinventory_code    VARCHAR2(40),
      locator              VARCHAR2(240),
      lot_number           VARCHAR2(80),
      to_subinventory_code VARCHAR2(40),
      to_locator           VARCHAR2(240),
      uom                  VARCHAR2(10),
      quantity             NUMBER,
      process_status       VARCHAR2(1),
      process_message      VARCHAR2(4000)
    )
    tablespace ADDON_TS_TX_DATA;
    
    1、delete all records in table XXINV.XXINV_SUBINV_TRANSFER_20141021
    2、insert into table pending data
    3、run this script
    
    NOTE : If anyone record validate with error , this script will be doing nothing.
           The output panel will show the error message.
           Check the result with following script :
                      SELECT *
                    FROM mtl_transactions_interface_v t
                    --FROM mtl_transactions_interface t
                   WHERE t.creation_date > SYSDATE - 0.1
                    ORDER BY t.transaction_interface_id; 
           Show the success result with following script:
                    SELECT *
                    FROM mtl_material_transactions mmt
                   WHERE mmt.transaction_date > SYSDATE - 1
                   ORDER BY mmt.transaction_id;
     4、finally,drop the table and data
            Drop table XXINV.XXINV_SUBINV_TRANSFER_20141021;
*/

DECLARE
  -- constant
  c_transaction_type_id   CONSTANT NUMBER := 2; -- Subinventory Transfer
  c_source_code           CONSTANT apps.mtl_transactions_interface.source_code%TYPE := 'Change Locator(' ||
                                                                                       to_char(SYSDATE, 'DD-MON-YY') || ')'; --'FPART On-hand Clearance';
  c_source_header_id      CONSTANT apps.mtl_transactions_interface.source_header_id%TYPE := -1;
  c_source_line_id        CONSTANT apps.mtl_transactions_interface.source_line_id%TYPE := -1;
  c_transaction_reference CONSTANT apps.mtl_transactions_interface.transaction_reference%TYPE := 'Change Locator(' ||
                                                                                                 to_char(SYSDATE,
                                                                                                         'DD-MON-YY HH24:MI:SS') || ')'; --'FPART On-hand Clearance';
  c_to_subinventory_code  CONSTANT VARCHAR2(40) := 'FCS';
  -- c_expenditure_type      CONSTANT apps.mtl_transactions_interface.expenditure_type%TYPE := 'Material';
  c_operation        CONSTANT VARCHAR2(100) := 'CHECK_COMBINATION';
  c_appl_short_name  CONSTANT VARCHAR2(100) := 'INV';
  c_key_flex_code    CONSTANT VARCHAR2(100) := 'MTLL';
  c_structure_number CONSTANT NUMBER := 101;

  l_item_trx_rec      apps.mtl_transactions_interface%ROWTYPE;
  l_trx_lot_rec       mtl_transaction_lots_interface%ROWTYPE;
  l_project_segment   VARCHAR2(100);
  l_user_id           NUMBER;
  l_msg_error         VARCHAR2(2000);
  l_commit_flag       VARCHAR2(1) := 'Y';
  l_error_code        apps.mtl_transactions_interface.error_code%TYPE;
  l_error_explanation apps.mtl_transactions_interface.error_explanation%TYPE;

  -- inv_txn_manager_pub.process_transactions
  l_retval        NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(4000);
  l_trans_count   NUMBER;

  -- exception
  e_error_raise EXCEPTION;

  -- timer
  l_begin_datetime DATE;
  l_end_datetime   DATE;

  -- counter
  l_success_count NUMBER;
  CURSOR cur_data IS
    SELECT t.rowid row_id,
           t.organization_code,
           t.item_code,
           t.subinventory_code,
           t.locator,
           t.lot_number,
           t.to_subinventory_code,
           t.to_locator,
           t.uom,
           -1 * abs(t.quantity) quantity
      FROM xxinv.xxinv_subinv_transfer_20141021 t
     WHERE t.process_status IS NULL;

BEGIN
  l_begin_datetime                 := SYSDATE;
  l_success_count                  := 0;
  l_msg_error                      := NULL;
  l_item_trx_rec                   := NULL;
  l_item_trx_rec.last_update_date  := SYSDATE;
  l_item_trx_rec.last_updated_by   := fnd_global.user_id;
  l_item_trx_rec.creation_date     := SYSDATE;
  l_item_trx_rec.created_by        := fnd_global.user_id;
  l_item_trx_rec.last_update_login := fnd_global.login_id;

  dbms_output.put_line(rpad('ORG_CODE', 10, ' ') || --
                       rpad('ITEM_CODE', 30, ' ') || --
                       rpad('SUBINV', 10, ' ') || --
                       rpad('LOCATOR', 30, ' ') || --
                       rpad('TO_SUBINV', 10, ' ') || --
                       rpad('TO_LOCATOR', 30, ' ') || --
                       rpad('UOM', 5, ' ') || --
                       rpad('QTY', 5, ' '));
  FOR rec_data IN cur_data
  LOOP
    l_msg_error := NULL;
    -- dbms_output.put_line(rpad(' ', 50, '='));
    /*dbms_output.put_line(rpad(rec_data.organization_code, 10, ' ') || --
    rpad(rec_data.item_code, 30, ' ') || --
    rpad(rec_data.subinventory_code, 10, ' ') || --
    rpad(rec_data.locator, 30, ' ') || --
    rpad(rec_data.to_subinventory_code, 10, ' ') || --
    rpad(rec_data.to_locator, 30, ' ') || --
    rpad(rec_data.uom, 5, ' ') || --
    rpad(rec_data.quantity, 5, ' '));*/
    -- organization validation
    BEGIN
      SELECT ood.organization_id
        INTO l_item_trx_rec.organization_id
        FROM apps.org_organization_definitions ood
       WHERE ood.organization_code = rec_data.organization_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '[organization_code(' || rec_data.organization_code || ')is not existed!]';
    END;
  
    -- item validation
    BEGIN
      SELECT msi.inventory_item_id
        INTO l_item_trx_rec.inventory_item_id
        FROM apps.mtl_system_items_b msi
       WHERE msi.segment1 = rec_data.item_code
         AND msi.organization_id = l_item_trx_rec.organization_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [organization_code(' || rec_data.organization_code ||
                       ') doesn''t exist this item(' || rec_data.item_code || ')]';
    END;
  
    -- secondary_inventory_name validation
    BEGIN
      SELECT msi.secondary_inventory_name
        INTO l_item_trx_rec.subinventory_code
        FROM apps.mtl_secondary_inventories msi
       WHERE msi.organization_id = l_item_trx_rec.organization_id
         AND msi.secondary_inventory_name = rec_data.subinventory_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '    [organization_code(' || rec_data.organization_code ||
                       ') doesn''t exist this subinventory code(' || rec_data.subinventory_code || ')]';
    END;
  
    BEGIN
      SELECT msi.secondary_inventory_name
        INTO l_item_trx_rec.transfer_subinventory
        FROM apps.mtl_secondary_inventories msi
       WHERE msi.organization_id = l_item_trx_rec.organization_id
         AND msi.secondary_inventory_name = rec_data.to_subinventory_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '    [organization_code(' || rec_data.organization_code ||
                       ') doesn''t exist this TRANSFER_SUBINVENTORY(' || rec_data.subinventory_code || ')]';
    END;
    -- locator validation
    IF rec_data.locator IS NOT NULL THEN
      apps.fnd_profile.put('MFG_ORGANIZATION_ID', l_item_trx_rec.organization_id);
      IF apps.fnd_flex_keyval.validate_segs(operation        => c_operation, --'CHECK_COMBINATION',
                                            appl_short_name  => c_appl_short_name, --'INV',
                                            key_flex_code    => c_key_flex_code, --'MTLL',
                                            structure_number => c_structure_number, --101,
                                            concat_segments  => rec_data.locator, --p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                            values_or_ids    => 'V') THEN
      
        --dbms_output.put_line(' concatenated_ids : ' || apps.fnd_flex_keyval.concatenated_ids);
        SELECT mil.inventory_location_id
          INTO l_item_trx_rec.locator_id
          FROM apps.mtl_item_locations_kfv mil
         WHERE mil.organization_id = l_item_trx_rec.organization_id --86 \*p_organization_id*\
           AND mil.subinventory_code = rec_data.subinventory_code --'FPART' \*p_subinventory_code*\
           AND mil.concatenated_segments = apps.fnd_flex_keyval.concatenated_ids -- p_concat_segments
           AND mil.enabled_flag = 'Y';
        --dbms_output.put_line(' locator_id : ' || l_item_trx_rec.locator_id);
      ELSE
        l_msg_error := l_msg_error || '[locator doesn''t exist]';
      END IF;
    ELSE
      l_msg_error := l_msg_error || '[locator IS NULL]';
    END IF;
  
    IF rec_data.to_locator IS NOT NULL THEN
      --dbms_output.put_line(' organization_id : ' || l_item_trx_rec.organization_id);
      apps.fnd_profile.put('MFG_ORGANIZATION_ID', l_item_trx_rec.organization_id);
      IF apps.fnd_flex_keyval.validate_segs(operation        => c_operation, --'CHECK_COMBINATION',
                                            appl_short_name  => c_appl_short_name, --'INV',
                                            key_flex_code    => c_key_flex_code, --'MTLL',
                                            structure_number => c_structure_number, --101,
                                            concat_segments  => rec_data.to_locator, --p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                            values_or_ids    => 'V') THEN
      
        -- dbms_output.put_line(' concatenated_ids : ' || apps.fnd_flex_keyval.concatenated_ids);
        BEGIN
          SELECT mil.inventory_location_id
            INTO l_item_trx_rec.transfer_locator
            FROM apps.mtl_item_locations_kfv mil
           WHERE mil.organization_id = l_item_trx_rec.organization_id --86 \*p_organization_id*\
             AND mil.subinventory_code = rec_data.to_subinventory_code --'FPART' \*p_subinventory_code*\
             AND mil.concatenated_segments = apps.fnd_flex_keyval.concatenated_ids -- p_concat_segments
             AND mil.enabled_flag = 'Y';
          --dbms_output.put_line(' transfer_locator : ' || l_item_trx_rec.transfer_locator);
        EXCEPTION
          WHEN no_data_found THEN
            -- create new locator
            DECLARE
              x_return_status  VARCHAR2(1);
              x_msg_count      NUMBER;
              x_msg_data       VARCHAR2(32767);
              x_locator_exists VARCHAR2(1);
            BEGIN
              inv_loc_wms_pub.create_locator(x_return_status            => x_return_status,
                                             x_msg_count                => x_msg_count,
                                             x_msg_data                 => x_msg_data,
                                             x_inventory_location_id    => l_item_trx_rec.transfer_locator, --x_inventory_location_id,
                                             x_locator_exists           => x_locator_exists,
                                             p_organization_id          => l_item_trx_rec.organization_id, --86,
                                             p_organization_code        => rec_data.organization_code, --'TH2',
                                             p_concatenated_segments    => rec_data.to_locator,
                                             p_description              => NULL,
                                             p_inventory_location_type  => '3', -- Storage Locator
                                             p_picking_order            => NULL,
                                             p_location_maximum_units   => NULL,
                                             p_subinventory_code        => rec_data.to_subinventory_code, --'FPART',
                                             p_location_weight_uom_code => NULL,
                                             p_max_weight               => NULL,
                                             p_volume_uom_code          => NULL,
                                             p_max_cubic_area           => NULL,
                                             p_x_coordinate             => NULL,
                                             p_y_coordinate             => NULL,
                                             p_z_coordinate             => NULL,
                                             p_physical_location_id     => NULL,
                                             p_pick_uom_code            => NULL,
                                             p_dimension_uom_code       => NULL,
                                             p_length                   => NULL,
                                             p_width                    => NULL,
                                             p_height                   => NULL,
                                             p_status_id                => 1,
                                             p_dropping_order           => NULL);
              IF x_return_status <> 'S' OR l_item_trx_rec.transfer_locator IS NULL THEN
                l_msg_error := l_msg_error || '[transfer_locator create error : ' || x_msg_data || ']';
              ELSE
                NULL;
                /*dbms_output.put_line('  created new locator : ' || rec_data.to_locator ||
                '   inventory_location_id : ' || l_item_trx_rec.transfer_locator);*/
              END IF;
            END;
          WHEN OTHERS THEN
            l_msg_error := l_msg_error || '[transfer_locator SQLERRM : ' || SQLERRM || ']';
        END;
      ELSE
        l_msg_error := l_msg_error || '[transfer_locator doesn''t exist]';
      END IF;
    ELSE
      l_msg_error := l_msg_error || '[transfer_locator IS NULL]';
    END IF;
    -- transfer inter task validation
    DECLARE
      l_count NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO l_count
        FROM apps.mtl_item_locations_kfv mil_from,
             apps.mtl_item_locations_kfv mil_to
       WHERE mil_from.inventory_location_id = l_item_trx_rec.locator_id
         AND mil_to.inventory_location_id = l_item_trx_rec.transfer_locator
         AND nvl(mil_from.segment19, '##$$') = nvl(mil_to.segment19, '##$$')
         AND nvl(mil_from.segment20, '##$$') = nvl(mil_to.segment20, '##$$');
      IF l_count = 0 THEN
        l_msg_error := l_msg_error || '[locator and transfer_locator is not in same task]';
      END IF;
    END;
    -- uom validation
    BEGIN
      SELECT t.uom_code
        INTO l_item_trx_rec.transaction_uom
        FROM apps.mtl_units_of_measure t
       WHERE t.uom_code = rec_data.uom;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [transaction_uom(' || rec_data.uom || ') doesn''t exist]';
    END;
  
    -- on-hand quantity validation
    DECLARE
      l_count NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO l_count
        FROM mtl_onhand_quantities_detail moqd
       WHERE 1 = 1
         AND moqd.organization_id = l_item_trx_rec.organization_id
         AND moqd.inventory_item_id = l_item_trx_rec.inventory_item_id
         AND moqd.subinventory_code = l_item_trx_rec.subinventory_code
         AND moqd.locator_id = l_item_trx_rec.locator_id
         AND nvl(moqd.lot_number, '####') = nvl(rec_data.lot_number, '####')
         AND moqd.primary_transaction_quantity <> 0;
      IF l_count = 0 THEN
        l_msg_error := l_msg_error || '   [on-hand quantity don''t exist]';
      END IF;
    END;
  
    IF l_msg_error IS NULL THEN
      SELECT apps.mtl_material_transactions_s.nextval
        INTO l_item_trx_rec.transaction_interface_id
        FROM dual;
      l_item_trx_rec.transaction_type_id   := c_transaction_type_id;
      l_item_trx_rec.transaction_mode      := 3;
      l_item_trx_rec.process_flag          := 1;
      l_item_trx_rec.transaction_header_id := l_item_trx_rec.transaction_interface_id;
      -- l_item_trx_rec.subinventory_code     := rec_data.subinventory_code;
      l_item_trx_rec.transaction_quantity := rec_data.quantity;
      l_item_trx_rec.transaction_uom      := rec_data.uom;
      l_item_trx_rec.transaction_date     := SYSDATE;
      --l_item_trx_rec.expenditure_type      := c_expenditure_type;
      --l_item_trx_rec.pa_expenditure_org_id := l_item_trx_rec.organization_id;
      --l_item_trx_rec.transaction_source_id := l_item_trx_rec.distribution_account_id;
      /*l_item_trx_rec.distribution_account_id := l_distribution_account_id;
      l_item_trx_rec.locator_id              := l_locator_id;
      l_item_trx_rec.source_project_id       := 1;
      l_item_trx_rec.source_task_id          := 1;*/
      l_item_trx_rec.source_code           := c_source_code; --'TEST_ONLY';
      l_item_trx_rec.source_header_id      := c_source_header_id; --987654321;
      l_item_trx_rec.source_line_id        := c_source_line_id; --987654321;
      l_item_trx_rec.transaction_reference := c_transaction_reference;
    
      INSERT INTO inv.mtl_transactions_interface
      VALUES l_item_trx_rec;
    
      --Insert into lot information
      IF rec_data.lot_number IS NOT NULL THEN
        l_trx_lot_rec.transaction_interface_id := l_item_trx_rec.transaction_interface_id;
        l_trx_lot_rec.lot_number               := rec_data.lot_number;
        l_trx_lot_rec.transaction_quantity     := l_item_trx_rec.transaction_quantity;
        l_trx_lot_rec.last_update_date         := l_item_trx_rec.last_update_date;
        l_trx_lot_rec.last_updated_by          := l_item_trx_rec.last_updated_by;
        l_trx_lot_rec.creation_date            := l_item_trx_rec.creation_date;
        l_trx_lot_rec.created_by               := l_item_trx_rec.created_by;
        INSERT INTO mtl_transaction_lots_interface
        VALUES l_trx_lot_rec;
      END IF;
    
      l_retval := inv_txn_manager_pub.process_transactions(p_api_version      => 1,
                                                           p_init_msg_list    => fnd_api.g_false,
                                                           p_commit           => fnd_api.g_false,
                                                           p_validation_level => fnd_api.g_valid_level_full,
                                                           x_return_status    => l_return_status,
                                                           x_msg_count        => l_msg_count,
                                                           x_msg_data         => l_msg_data,
                                                           x_trans_count      => l_trans_count,
                                                           p_table            => 1,
                                                           p_header_id        => l_item_trx_rec.transaction_interface_id);
      dbms_output.put_line(' l_return_status : ' || l_return_status);
      dbms_output.put_line(' l_msg_count     : ' || l_msg_count);
      dbms_output.put_line(' l_msg_data      : ' || l_msg_data);
      dbms_output.put_line(' l_trans_count   : ' || l_trans_count);
    
      IF l_retval <> 0 THEN
        --get error message
        SELECT mti.error_code,
               mti.error_explanation
          INTO l_item_trx_rec.error_code,
               l_item_trx_rec.error_explanation
          FROM mtl_transactions_interface mti
         WHERE mti.transaction_interface_id = l_item_trx_rec.transaction_interface_id;
      
        dbms_output.put_line(' error_code        : ' || l_item_trx_rec.error_code);
        dbms_output.put_line(' error_explanation : ' || l_item_trx_rec.error_explanation);
      
        UPDATE xxinv.xxinv_subinv_transfer_20141021 t
           SET t.process_status  = fnd_api.g_ret_sts_success,
               t.process_message = substrb('error_code : ' || l_item_trx_rec.error_code || ' error_explanation : ' ||
                                           l_item_trx_rec.error_explanation,
                                           1,
                                           4000)
         WHERE t.rowid = rec_data.row_id;
        RAISE fnd_api.g_exc_error;
      ELSE
        UPDATE xxinv.xxinv_subinv_transfer_20141021 t
           SET t.process_status = fnd_api.g_ret_sts_success
         WHERE t.rowid = rec_data.row_id;
      END IF;
    
    ELSE
      dbms_output.put_line(rpad(rec_data.organization_code, 10, ' ') || --
                           rpad(rec_data.item_code, 30, ' ') || --
                           rpad(rec_data.subinventory_code, 10, ' ') || --
                           rpad(rec_data.locator, 30, ' ') || --
                           rpad(rec_data.to_subinventory_code, 10, ' ') || --
                           rpad(rec_data.to_locator, 30, ' ') || --
                           rpad(rec_data.uom, 5, ' ') || --
                           rpad(rec_data.quantity, 5, ' '));
      sys.dbms_output.put_line('             l_msg_error : ' || l_msg_error);
      l_commit_flag := 'N';
      RAISE e_error_raise;
    END IF;
    --dbms_output.put_line('');
    l_success_count := l_success_count + 1;
  END LOOP;
  IF l_commit_flag <> 'Y' THEN
    ROLLBACK;
  END IF;
  l_end_datetime := SYSDATE;
  dbms_output.put_line(' Time-consuming : ' || (to_char(l_end_datetime, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')));
  dbms_output.put_line(' success_count : ' || l_success_count);
EXCEPTION
  WHEN e_error_raise THEN
    sys.dbms_output.put_line(' EXCEPTION : ' || l_msg_error);
    ROLLBACK;
    l_end_datetime := SYSDATE;
    dbms_output.put_line(' Time-consuming : ' ||
                         (to_char(l_end_datetime, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')));
    dbms_output.put_line(' success_count : ' || l_success_count);
  WHEN OTHERS THEN
    sys.dbms_output.put_line(' EXCEPTION : ' || l_msg_error);
    sys.dbms_output.put_line(' SQLCODE   : ' || SQLCODE);
    sys.dbms_output.put_line(' SQLERRM   : ' || SQLERRM);
    ROLLBACK;
    l_end_datetime := SYSDATE;
    dbms_output.put_line(' Time-consuming : ' ||
                         (to_char(l_end_datetime, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')));
    dbms_output.put_line(' success_count : ' || l_success_count);
END;
/
