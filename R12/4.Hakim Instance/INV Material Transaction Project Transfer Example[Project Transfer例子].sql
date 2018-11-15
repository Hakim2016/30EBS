/*
CREATE TABLE XXINV.XXINV_TRANSFER_TODO
(
       DN_ISSUED                  VARCHAR2(240),
       ORGANIZATION_CODE          VARCHAR2(240),
       MFG                        VARCHAR2(240),
       ITEM                       VARCHAR2(240),
       SUB_INV                    VARCHAR2(240),
       LOCATOR                    VARCHAR2(240),
       TO_SUB_INV                 VARCHAR2(240),
       TO_LOCATOR                 VARCHAR2(240),
       QUANTITY                    VARCHAR2(10),
       ORGANIZATION_ID            NUMBER,
       INVENTORY_ITEM_ID          NUMBER,
       FROM_LOCATOR_ID            NUMBER,
       TO_LOCATOR_ID              NUMBER,
       PROCESS_STATUS             VARCHAR2(1),
       PROCESS_MESSAGE            VARCHAR2(4000)
)tablespace ADDON_TS_TX_DATA;

*/
--set serveroutput on size 1000000000; 

DECLARE
  x_locator_id     NUMBER;
  x_return_status  VARCHAR2(1);
  x_return_message VARCHAR2(4000);

  c_status_success CONSTANT VARCHAR2(1) := 'S';
  c_status_error   CONSTANT VARCHAR2(1) := 'E';
  c_status_pending CONSTANT VARCHAR2(1) := 'P';

  l_onhand_qty       NUMBER;
  l_processd_count   NUMBER;
  l_time_point_start NUMBER;

  g_validate_time NUMBER := 0;
  g_creation_time NUMBER := 0;

  CURSOR cur_data IS
    SELECT t.rowid row_id,
           t.organization_code,
           t.mfg,
           t.item,
           t.sub_inv,
           t.locator,
           t.to_sub_inv,
           t.to_locator,
           t.quantity,
           nvl(t.process_status, c_status_pending) process_status,
           t.process_message,
           t.organization_id,
           t.inventory_item_id,
           t.from_locator_id,
           t.to_locator_id,
           '' primary_uom
      FROM xxinv.xxinv_transfer_todo t
     WHERE 1 = 1
       --AND rownum < 30001
       AND nvl(t.process_status, c_status_pending) = c_status_pending;

  -- ==============
  -- proc_get_locator_id
  -- ==============
  PROCEDURE proc_get_locator_id(p_organization_id       IN NUMBER, -- 86
                                p_subinventory_code     IN VARCHAR2, -- FRM
                                p_locator               IN VARCHAR2, -- FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1
                                x_inventory_location_id OUT NUMBER,
                                x_return_status         OUT VARCHAR2,
                                x_return_message        OUT VARCHAR2) IS
    c_operation        CONSTANT VARCHAR2(100) := 'CHECK_COMBINATION';
    c_appl_short_name  CONSTANT VARCHAR2(100) := 'INV';
    c_key_flex_code    CONSTANT VARCHAR2(100) := 'MTLL';
    c_structure_number CONSTANT NUMBER := 101;
  
    l_boolean           BOOLEAN;
    l_exists_flag       VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_locator_exists    VARCHAR2(1);
    l_organization_code org_organization_definitions.organization_code%TYPE;
    l_time_point        NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    apps.fnd_profile.put('MFG_ORGANIZATION_ID', p_organization_id);
  
    l_time_point := dbms_utility.get_time;
    -- Step 1 : validate
    l_boolean := apps.fnd_flex_keyval.validate_segs(operation        => c_operation, --'CHECK_COMBINATION',
                                                    appl_short_name  => c_appl_short_name, --'INV',
                                                    key_flex_code    => c_key_flex_code, --'MTLL',
                                                    structure_number => c_structure_number, --101,
                                                    concat_segments  => p_locator, --p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                                    values_or_ids    => 'V');
  
    IF NOT l_boolean THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_return_message := ' Locator (' || p_locator || ') segments validate failure';
      RETURN;
    END IF;
    -- Step 2 : get inventory locator id 
    BEGIN
      SELECT mil.inventory_location_id
        INTO x_inventory_location_id
        FROM apps.mtl_item_locations_kfv mil
       WHERE mil.organization_id = p_organization_id
         AND mil.subinventory_code = p_subinventory_code
         AND mil.concatenated_segments = apps.fnd_flex_keyval.concatenated_ids
         AND mil.inventory_location_id = apps.fnd_flex_keyval.combination_id;
    EXCEPTION
      WHEN no_data_found THEN
        l_exists_flag := 'N';
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        x_return_message := ' get inventory locator id error : ' || SQLERRM;
        RETURN;
    END;
    g_validate_time := g_validate_time + (dbms_utility.get_time - l_time_point) / 100;
    l_time_point    := dbms_utility.get_time;
    -- Step 3 :  create locator    
    IF nvl(l_exists_flag, 'Y') = 'N' THEN
      SELECT ood.organization_code
        INTO l_organization_code
        FROM org_organization_definitions ood
       WHERE ood.organization_id = p_organization_id;
      inv_loc_wms_pub.create_locator(x_return_status            => x_return_status,
                                     x_msg_count                => x_msg_count,
                                     x_msg_data                 => x_msg_data,
                                     x_inventory_location_id    => x_inventory_location_id,
                                     x_locator_exists           => x_locator_exists,
                                     p_organization_id          => p_organization_id, --86,
                                     p_organization_code        => l_organization_code, --'TH2',
                                     p_concatenated_segments    => p_locator,
                                     p_description              => NULL,
                                     p_inventory_location_type  => '3', -- Storage Locator
                                     p_picking_order            => NULL,
                                     p_location_maximum_units   => NULL,
                                     p_subinventory_code        => p_subinventory_code, --'FPART',
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
    
      g_creation_time := g_creation_time + (dbms_utility.get_time - l_time_point) / 100;
    
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        x_return_message := x_return_message || ' Locator create error : ' || x_msg_data;
        FOR l_index IN 1 .. x_msg_count
        LOOP
          x_return_message := x_return_message || '  ' || fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
        END LOOP;
        RETURN;
      END IF;
    END IF;
  END proc_get_locator_id;

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
  l_processd_count   := 0;
  l_time_point_start := dbms_utility.get_time;
  fnd_global.apps_initialize(user_id => 2722, resp_id => 50778, resp_appl_id => 20005);
  FOR rec_data IN cur_data
  LOOP
    l_processd_count := l_processd_count + 1;
    -- organization
    BEGIN
      SELECT ood.organization_id
        INTO rec_data.organization_id
        FROM org_organization_definitions ood
       WHERE 1 = 1
         AND ood.organization_code = rec_data.organization_code;
    EXCEPTION
      WHEN OTHERS THEN
        rec_data.process_status  := c_status_error;
        rec_data.process_message := 'The Organization is invalid';
        GOTO next_record;
    END;
    -- Item
    BEGIN
      SELECT msi.inventory_item_id,
             msi.primary_uom_code
        INTO rec_data.inventory_item_id,
             rec_data.primary_uom
        FROM mtl_system_items_b msi
       WHERE 1 = 1
         AND msi.organization_id = rec_data.organization_id
         AND msi.segment1 = rec_data.item;
    EXCEPTION
      WHEN OTHERS THEN
        rec_data.process_status  := c_status_error;
        rec_data.process_message := 'The Item is invalid';
        GOTO next_record;
    END;
  
    -- from sub-inv
    BEGIN
      SELECT msi.secondary_inventory_name
        INTO rec_data.sub_inv
        FROM mtl_secondary_inventories msi
       WHERE 1 = 1
         AND msi.organization_id = rec_data.organization_id
         AND msi.secondary_inventory_name = rec_data.sub_inv;
    EXCEPTION
      WHEN OTHERS THEN
        rec_data.process_status  := c_status_error;
        rec_data.process_message := 'The from sub-inv is invalid';
        GOTO next_record;
    END;
    -- from locator   
    proc_get_locator_id(p_organization_id       => rec_data.organization_id,
                        p_subinventory_code     => rec_data.sub_inv,
                        p_locator               => rec_data.locator, --'FCS.21000065.THA0028-TH\.EQ.', --'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1',
                        x_inventory_location_id => rec_data.from_locator_id,
                        x_return_status         => x_return_status,
                        x_return_message        => x_return_message);
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      rec_data.process_status  := c_status_error;
      rec_data.process_message := 'From Locator : ' || x_return_message;
      GOTO next_record;
    END IF;
  
    -- to sub-inv
    BEGIN
      SELECT msi.secondary_inventory_name
        INTO rec_data.to_sub_inv
        FROM mtl_secondary_inventories msi
       WHERE 1 = 1
         AND msi.organization_id = rec_data.organization_id
         AND msi.secondary_inventory_name = rec_data.to_sub_inv;
    EXCEPTION
      WHEN OTHERS THEN
        rec_data.process_status  := c_status_error;
        rec_data.process_message := 'The to sub-inv is invalid';
        GOTO next_record;
    END;
  
    -- to locator
    proc_get_locator_id(p_organization_id       => rec_data.organization_id,
                        p_subinventory_code     => rec_data.to_sub_inv,
                        p_locator               => rec_data.to_locator, --'FCS.21000065.THA0028-TH\.EQ.', --'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1',
                        x_inventory_location_id => rec_data.to_locator_id,
                        x_return_status         => x_return_status,
                        x_return_message        => x_return_message);
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      rec_data.process_status  := c_status_error;
      rec_data.process_message := 'To Locator : ' || x_return_message;
      GOTO next_record;
    END IF;
  
    -- onhand
    BEGIN
      SELECT nvl(SUM(moqd.primary_transaction_quantity), 0)
        INTO l_onhand_qty
        FROM mtl_onhand_quantities_detail moqd
       WHERE 1 = 1
         AND moqd.organization_id = rec_data.organization_id
         AND moqd.inventory_item_id = rec_data.inventory_item_id
         AND moqd.locator_id = rec_data.from_locator_id;
      IF l_onhand_qty < rec_data.quantity THEN
        rec_data.process_status  := c_status_error;
        rec_data.process_message := 'The onhand is not enough ';
        GOTO next_record;
      END IF;
    END;
  
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
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      rec_data.process_status  := c_status_error;
      rec_data.process_message := ' Process Project Transfer : ' || x_return_message;
      GOTO next_record;
    END IF;
  
    <<next_record>>
    IF rec_data.process_status <> c_status_error THEN
      rec_data.process_status := c_status_success;
    END IF;
    UPDATE xxinv.xxinv_transfer_todo t
       SET t.process_status    = rec_data.process_status, --
           t.process_message   = rec_data.process_message,
           t.organization_id   = rec_data.organization_id,
           t.inventory_item_id = rec_data.inventory_item_id,
           t.from_locator_id   = rec_data.from_locator_id,
           t.to_locator_id     = rec_data.to_locator_id
     WHERE 1 = 1
       AND t.rowid = rec_data.row_id;
  
    IF MOD(l_processd_count, 100) = 0 THEN
      COMMIT;
    END IF;
    IF MOD(l_processd_count, 5000) = 0 THEN
      dbms_output.put_line(l_processd_count || ' rows have been processed. Time-Consuming : ' ||
                           (dbms_utility.get_time - l_time_point_start) / 100);
    END IF;
  END LOOP;
  IF l_processd_count > 0 THEN
    COMMIT;
  END IF;
  dbms_output.put_line(' l_processd_count : ' || l_processd_count);
  dbms_output.put_line('Time-Consuming : ' || (dbms_utility.get_time - l_time_point_start) / 100);

  dbms_output.put_line(' validate locator Time-Consuming : ' || g_validate_time);
  dbms_output.put_line(' creation locator Time-Consuming : ' || g_creation_time);
  /*
  proc_get_locator_id(p_organization_id       => 86,
                      p_subinventory_code     => 'FRM',
                      p_locator               => 'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1', --'FCS.21000065.THA0028-TH\.EQ.', --'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1',
                      x_inventory_location_id => x_locator_id,
                      x_return_status         => x_return_status,
                      x_return_message        => x_return_message);
  
  dbms_output.put_line(' x_locator_id     : ' || x_locator_id);
  dbms_output.put_line(' x_return_status  : ' || x_return_status);
  dbms_output.put_line(' x_return_message : ' || x_return_message);
  */
END;
/

/*  SELECT t.process_status,
         t.process_message,
         COUNT(1)
    FROM xxinv.xxinv_transfer_todo t
   WHERE 1 = 1
  --AND t.process_status IS NOT NULL
   GROUP BY t.process_status,
            t.process_message;*/
