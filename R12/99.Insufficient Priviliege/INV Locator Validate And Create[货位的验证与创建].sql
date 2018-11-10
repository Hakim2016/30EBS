DECLARE
  c_operation        CONSTANT VARCHAR2(100) := 'CHECK_COMBINATION';
  c_appl_short_name  CONSTANT VARCHAR2(100) := 'INV';
  c_key_flex_code    CONSTANT VARCHAR2(100) := 'MTLL';
  c_structure_number CONSTANT NUMBER := 101;

  x_inventory_location_id mtl_item_locations.inventory_location_id%TYPE;
  l_subinventory_code     mtl_item_locations.subinventory_code%TYPE;
  l_organization_code     org_organization_definitions.organization_code%TYPE;
  l_organization_id       mtl_item_locations.organization_id%TYPE;
  l_locator               mtl_item_locations_kfv.concatenated_segments%TYPE;

  l_boolean        BOOLEAN;
  x_return_status  VARCHAR2(1);
  x_msg_count      NUMBER;
  l_msg_error      VARCHAR2(2000);
  x_msg_data       VARCHAR2(2000);
  l_exists_flag    VARCHAR2(1);
  x_locator_exists VARCHAR2(1);

BEGIN
  l_subinventory_code := 'FRM';
  l_locator           := 'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1';
  l_organization_id   := 86;

  apps.fnd_profile.put('MFG_ORGANIZATION_ID', l_organization_id);

  -- Step 1 : validate
  l_boolean := apps.fnd_flex_keyval.validate_segs(operation        => c_operation, --'CHECK_COMBINATION',
                                                  appl_short_name  => c_appl_short_name, --'INV',
                                                  key_flex_code    => c_key_flex_code, --'MTLL',
                                                  structure_number => c_structure_number, --101,
                                                  concat_segments  => l_locator, --p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                                  values_or_ids    => 'V');

  IF l_boolean THEN
    dbms_output.put_line(' Locator (' || l_locator || ') segments validate success');
    dbms_output.put_line(' concatenated_ids : ' || apps.fnd_flex_keyval.concatenated_ids);
  ELSE
    dbms_output.put_line(' Locator (' || l_locator || ') segments validate failure');
    RETURN;
  END IF;

  -- Step 2 : get inventory locator id 
  BEGIN
    SELECT mil.inventory_location_id
      INTO x_inventory_location_id
      FROM apps.mtl_item_locations_kfv mil
     WHERE mil.organization_id = l_organization_id --86 /*p_organization_id*/
       AND mil.subinventory_code = l_subinventory_code --'FPART' /*p_subinventory_code*/
       AND mil.concatenated_segments = apps.fnd_flex_keyval.concatenated_ids -- p_concat_segments
    --AND mil.enabled_flag = 'Y'
    ;
    IF x_inventory_location_id IS NOT NULL THEN
      dbms_output.put_line(' x_inventory_location_id : ' || x_inventory_location_id);
      dbms_output.put_line(' Locator (' || l_locator || ') has been in system');
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      l_exists_flag := 'N';
      dbms_output.put_line(' Locator (' || l_locator || ') is not existed in system');
    WHEN OTHERS THEN
      dbms_output.put_line(' get inventory locator id error : ' || SQLERRM);
  END;

  -- Step 3 :  create locator
  IF nvl(l_exists_flag, 'Y') = 'N' THEN
    SELECT ood.organization_code
      INTO l_organization_code
      FROM org_organization_definitions ood
     WHERE ood.organization_id = l_organization_id;
    inv_loc_wms_pub.create_locator(x_return_status            => x_return_status,
                                   x_msg_count                => x_msg_count,
                                   x_msg_data                 => x_msg_data,
                                   x_inventory_location_id    => x_inventory_location_id, --x_inventory_location_id,
                                   x_locator_exists           => x_locator_exists,
                                   p_organization_id          => l_organization_id, --86,
                                   p_organization_code        => l_organization_code, --'TH2',
                                   p_concatenated_segments    => l_locator,
                                   p_description              => NULL,
                                   p_inventory_location_type  => '3', -- Storage Locator
                                   p_picking_order            => NULL,
                                   p_location_maximum_units   => NULL,
                                   p_subinventory_code        => l_subinventory_code, --'FPART',
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
    /*dbms_output.put_line(' x_return_status         : ' || x_return_status);
    dbms_output.put_line(' x_msg_count             : ' || x_msg_count);
    dbms_output.put_line(' x_msg_data              : ' || x_msg_data);
    dbms_output.put_line(' x_inventory_location_id : ' || x_inventory_location_id);
    dbms_output.put_line(' x_locator_exists        : ' || x_locator_exists);*/
    IF x_return_status <> 'S' THEN
      dbms_output.put_line(' Locator create error : ' || x_msg_data);
    ELSE
      dbms_output.put_line(' x_inventory_location_id : ' || x_inventory_location_id);
      dbms_output.put_line(' Locator create successfully');
      /*dbms_output.put_line('  created new locator : ' || rec_data.to_locator ||
      '   inventory_location_id : ' || l_item_trx_rec.transfer_locator);*/
    END IF;
  END IF;
  /*
  IF apps.fnd_flex_keyval.validate_segs(operation        => c_operation, --'CHECK_COMBINATION',
                                        appl_short_name  => c_appl_short_name, --'INV',
                                        key_flex_code    => c_key_flex_code, --'MTLL',
                                        structure_number => c_structure_number, --101,
                                        concat_segments  => l_locator, --p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                        values_or_ids    => 'V') THEN
  
    dbms_output.put_line(' concatenated_ids : ' || apps.fnd_flex_keyval.concatenated_ids);
    BEGIN
      SELECT mil.inventory_location_id
        INTO x_inventory_location_id
        FROM apps.mtl_item_locations_kfv mil
       WHERE mil.organization_id = l_organization_id --86 \*p_organization_id*\
         AND mil.subinventory_code = l_subinventory_code --'FPART' \*p_subinventory_code*\
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
          SELECT ood.organization_code
            INTO l_organization_code
            FROM org_organization_definitions ood
           WHERE ood.organization_id = l_organization_id;
          inv_loc_wms_pub.create_locator(x_return_status            => x_return_status,
                                         x_msg_count                => x_msg_count,
                                         x_msg_data                 => x_msg_data,
                                         x_inventory_location_id    => x_inventory_location_id, --x_inventory_location_id,
                                         x_locator_exists           => x_locator_exists,
                                         p_organization_id          => l_organization_id, --86,
                                         p_organization_code        => l_organization_code, --'TH2',
                                         p_concatenated_segments    => l_locator,
                                         p_description              => NULL,
                                         p_inventory_location_type  => '3', -- Storage Locator
                                         p_picking_order            => NULL,
                                         p_location_maximum_units   => NULL,
                                         p_subinventory_code        => l_subinventory_code, --'FPART',
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
          IF x_return_status <> 'S' THEN
            l_msg_error := l_msg_error || '[locator create error : ' || x_msg_data || ']';
          ELSE
            NULL;
            \*dbms_output.put_line('  created new locator : ' || rec_data.to_locator ||
            '   inventory_location_id : ' || l_item_trx_rec.transfer_locator);*\
          END IF;
        END;
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '[transfer_locator SQLERRM : ' || SQLERRM || ']';
    END;
  ELSE
    l_msg_error := l_msg_error || '[transfer_locator doesn''t exist]';
  END IF;*/
END;
/

DECLARE x_msg_data VARCHAR2(2000);
BEGIN
  FOR l_index IN 1 .. 5
  LOOP
    x_msg_data := fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
    dbms_output.put_line(' x_msg_data ' || l_index || ' : ' || x_msg_data);
  END LOOP;
END;
/

DECLARE x_locator_id NUMBER;
x_return_status VARCHAR2(1);
x_return_message VARCHAR2(4000);

PROCEDURE proc_get_locator_id(p_organization_id IN NUMBER, -- 86
p_subinventory_code IN VARCHAR2, -- FRM
p_locator IN VARCHAR2, -- FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1
x_inventory_location_id OUT NUMBER, x_return_status OUT VARCHAR2, x_return_message OUT VARCHAR2) IS c_operation CONSTANT VARCHAR2(100) := 'CHECK_COMBINATION';
c_appl_short_name CONSTANT VARCHAR2(100) := 'INV';
c_key_flex_code CONSTANT VARCHAR2(100) := 'MTLL';
c_structure_number CONSTANT NUMBER := 101;

l_boolean BOOLEAN;
l_exists_flag VARCHAR2(1);
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_locator_exists VARCHAR2(1);
l_organization_code org_organization_definitions.organization_code%TYPE;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  apps.fnd_profile.put('MFG_ORGANIZATION_ID', p_organization_id);

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
       AND mil.inventory_location_id = apps.fnd_flex_keyval.combination_id
       AND mil.concatenated_segments = apps.fnd_flex_keyval.concatenated_ids;
  EXCEPTION
    WHEN no_data_found THEN
      l_exists_flag := 'N';
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_return_message := ' get inventory locator id error : ' || SQLERRM;
      RETURN;
  END;

  -- Step 3 :  create locator
  IF nvl(l_exists_flag, 'Y') = 'N' THEN
    DBMS_OUTPUT.PUT_LINE('CREATE');
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
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_message := x_return_message || ' Locator create error : ' || x_msg_data;
      FOR l_index IN 1 .. x_msg_count
      LOOP
        x_return_message := x_return_message || '  ' || fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
      END LOOP;
    
      RETURN;
    END IF;
  END IF;
END proc_get_locator_id;

BEGIN
  proc_get_locator_id(p_organization_id       => 86,
                      p_subinventory_code     => 'FRM',
                      p_locator               => 'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1',--/*'FCS.21000065.THA0028-TH\.EQ.', --*/ 'FRM.202844.DT0086-2\.EQ.S2RM_DUMMY-1',
                      x_inventory_location_id => x_locator_id,
                      x_return_status         => x_return_status,
                      x_return_message        => x_return_message);
  dbms_output.put_line('apps.fnd_flex_keyval.concatenated_values : ' || apps.fnd_flex_keyval.concatenated_values);
  dbms_output.put_line('apps.fnd_flex_keyval.concatenated_ids : ' || apps.fnd_flex_keyval.concatenated_ids);
  dbms_output.put_line('apps.fnd_flex_keyval.concatenated_descriptions : ' ||
                       apps.fnd_flex_keyval.concatenated_descriptions);
  dbms_output.put_line('apps.fnd_flex_keyval.combination_id : ' || apps.fnd_flex_keyval.combination_id);

  dbms_output.put_line(' x_locator_id     : ' || x_locator_id);
  dbms_output.put_line(' x_return_status  : ' || x_return_status);
  dbms_output.put_line(' x_return_message : ' || x_return_message);
END;
/
