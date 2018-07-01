CREATE OR REPLACE PACKAGE XXINV_LOCATOR_PUB AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxinv_locator_pub
  Description:
      This program provide concurrent main procedure to perform:

  History:
      1.00  25/05/2012 10:12:58 AM  ouzhiwei  Creation
  ==================================================*/

  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10) || chr(13);
  g_line        VARCHAR2(150) := rpad('-', 150, '-');

  g_last_updated_date DATE := SYSDATE;
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_creation_date     DATE := SYSDATE;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;
  g_num_format        VARCHAR2(30) := 'FM9999999999999999999990.00';
  g_date_format       VARCHAR2(30) := 'YYYY-MM-DD HH24:MI:SS';

  g_request_id NUMBER := fnd_global.conc_request_id;
  g_session_id NUMBER := userenv('sessionid');
  g_appl_name  VARCHAR2(10) := 'XXINV';

  PROCEDURE get_locator_id(p_organization_id             IN NUMBER,
                           p_subinventory_code           IN VARCHAR2,
                           p_locator_concatenated_values IN VARCHAR2,
                           p_inventory_item_id           IN NUMBER,
                           x_inventory_location_id       OUT NUMBER,
                           x_return_status               OUT NOCOPY VARCHAR2,
                           x_msg_count                   OUT NOCOPY NUMBER,
                           x_msg_data                    OUT NOCOPY VARCHAR2);
END xxinv_locator_pub;
/
CREATE OR REPLACE PACKAGE BODY XXINV_LOCATOR_PUB AS

  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'xxinv_locator_pub';
  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
  PROCEDURE raise_exception(p_return_status VARCHAR2) IS
  BEGIN
    IF (p_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (p_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END raise_exception;
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

  --outputtd
  PROCEDURE outputtd(p_content IN VARCHAR2) IS
  BEGIN
    output('<td>' || p_content || '</td>');
  END outputtd;

  --format number
  FUNCTION format(p_content IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(p_content, g_num_format);
  END format;

  --format string
  FUNCTION format(p_content IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '="' || p_content || '"';
  END format;

  --format date
  FUNCTION format(p_content IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(p_content, g_date_format);
  END format;

  PROCEDURE validate_segs(p_concat_segments  IN VARCHAR2,
                          x_concatenated_ids OUT VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2) IS
  BEGIN
    IF fnd_flex_keyval.validate_segs(operation        => 'CHECK_COMBINATION',
                                     appl_short_name  => 'INV',
                                     key_flex_code    => 'MTLL',
                                     structure_number => 101,
                                     concat_segments  => p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                     values_or_ids    => 'V') THEN
      x_concatenated_ids := fnd_flex_keyval.concatenated_ids;
    ELSE
      x_msg_data      := fnd_flex_keyval.error_message;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  END;
  FUNCTION get_message(p_appl_name    IN VARCHAR2,
                       p_message_name IN VARCHAR2,
                       p_token1       IN VARCHAR2 DEFAULT NULL,
                       p_token1_value IN VARCHAR2 DEFAULT NULL,
                       p_token2       IN VARCHAR2 DEFAULT NULL,
                       p_token2_value IN VARCHAR2 DEFAULT NULL,
                       p_token3       IN VARCHAR2 DEFAULT NULL,
                       p_token3_value IN VARCHAR2 DEFAULT NULL,
                       p_token4       IN VARCHAR2 DEFAULT NULL,
                       p_token4_value IN VARCHAR2 DEFAULT NULL,
                       p_token5       IN VARCHAR2 DEFAULT NULL,
                       p_token5_value IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS
    l_message       VARCHAR2(1000);
    l_data          VARCHAR2(1000);
    l_msg_index_out NUMBER;
  BEGIN
    fnd_message.clear;
    fnd_msg_pub.initialize;
    fnd_message.set_name(p_appl_name, p_message_name);

    IF p_token1 IS NOT NULL THEN
      fnd_message.set_token(p_token1, p_token1_value);
    END IF;
    IF p_token2 IS NOT NULL THEN
      fnd_message.set_token(p_token2, p_token2_value);
    END IF;
    IF p_token3 IS NOT NULL THEN
      fnd_message.set_token(p_token3, p_token3_value);
    END IF;
    IF p_token4 IS NOT NULL THEN
      fnd_message.set_token(p_token4, p_token4_value);
    END IF;
    IF p_token5 IS NOT NULL THEN
      fnd_message.set_token(p_token5, p_token5_value);
    END IF;
    fnd_msg_pub.add;
    FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
      l_message := l_message || ' ' || l_data;
    END LOOP;
    RETURN l_message;
  END get_message;

  PROCEDURE get_locator_id(p_organization_id   NUMBER,
                           p_subinventory_code VARCHAR2,
                           p_concat_segments   VARCHAR2,
                           x_locator_id        OUT NUMBER,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2) IS
    CURSOR cur_locator(p_concat_segments VARCHAR2) IS
      SELECT mil.inventory_location_id
        FROM mtl_item_locations_kfv mil
       WHERE mil.organization_id = p_organization_id
         AND mil.subinventory_code = p_subinventory_code
         AND mil.concatenated_segments = p_concat_segments
         AND mil.enabled_flag = 'Y';
    x_concatenated_ids VARCHAR2(1000);
  BEGIN
    validate_segs(p_concat_segments  => p_concat_segments,
                  x_concatenated_ids => x_concatenated_ids,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data);
    raise_exception(x_return_status);
    OPEN cur_locator(x_concatenated_ids);
    FETCH cur_locator
      INTO x_locator_id;
    CLOSE cur_locator;
  END;
  PROCEDURE create_locator(p_organization_id             IN NUMBER,
                           p_locator_concatenated_values IN VARCHAR2,
                           p_subinventory_code           IN VARCHAR2,
                           p_locator_type                IN VARCHAR2,
                           x_inventory_location_id       OUT NUMBER,
                           x_return_status               OUT NOCOPY VARCHAR2,
                           x_msg_count                   OUT NOCOPY NUMBER,
                           x_msg_data                    OUT NOCOPY VARCHAR2) IS
    CURSOR cur_organization IS
      SELECT organization_code
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;
    l_organization_code mtl_parameters.organization_code%TYPE;
    l_locator_exists    VARCHAR2(10);
  BEGIN
    OPEN cur_organization;
    FETCH cur_organization
      INTO l_organization_code;
    CLOSE cur_organization;
    inv_loc_wms_pub.create_locator(x_return_status            => x_return_status,
                                   x_msg_count                => x_msg_count,
                                   x_msg_data                 => x_msg_data,
                                   x_inventory_location_id    => x_inventory_location_id,
                                   x_locator_exists           => l_locator_exists,
                                   p_organization_id          => p_organization_id,
                                   p_organization_code        => l_organization_code,
                                   p_concatenated_segments    => p_locator_concatenated_values, --'MRB.TEST.MFG1\.9\.2.'
                                   p_description              => NULL,
                                   p_inventory_location_type  => p_locator_type,
                                   p_picking_order            => NULL,
                                   p_location_maximum_units   => NULL,
                                   p_subinventory_code        => p_subinventory_code, --'MRB'
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
  END;

  PROCEDURE get_locator_id(p_organization_id             IN NUMBER,
                           p_subinventory_code           IN VARCHAR2,
                           p_locator_concatenated_values IN VARCHAR2,
                           p_inventory_item_id           IN NUMBER,
                           x_inventory_location_id       OUT NUMBER,
                           x_return_status               OUT NOCOPY VARCHAR2,
                           x_msg_count                   OUT NOCOPY NUMBER,
                           x_msg_data                    OUT NOCOPY VARCHAR2) IS
    CURSOR cur_organization IS
      SELECT mp.stock_locator_control_code, organization_code
        FROM mtl_parameters mp
       WHERE mp.organization_id = p_organization_id;
    CURSOR cur_inventory IS
      SELECT locator_type
        FROM mtl_secondary_inventories msi
       WHERE msi.secondary_inventory_name = p_subinventory_code
         AND msi.organization_id = p_organization_id;
    CURSOR cur_item IS
      SELECT location_control_code
        FROM mtl_system_items_b msib
       WHERE msib.organization_id = p_organization_id
         AND msib.inventory_item_id = p_inventory_item_id;
    l_return_status               VARCHAR2(1000);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(1000);
    l_inventory_location_id       NUMBER;
    l_locator_exists              VARCHAR2(100);
    l_organization_code           mtl_parameters.organization_code%TYPE;
    l_no_locator_flag             VARCHAR2(1);
    l_locator_type                mtl_secondary_inventories.locator_type%TYPE;
    l_org_locator_control_code    mtl_parameters.stock_locator_control_code%TYPE;
    l_subinv_locator_control_code mtl_parameters.stock_locator_control_code%TYPE;
    l_item_locator_control_code   mtl_parameters.stock_locator_control_code%TYPE;
  BEGIN
    fnd_profile.put(NAME => 'MFG_ORGANIZATION_ID',
                    val  => p_organization_id);
    --get organization locator_control_code
    OPEN cur_organization;
    FETCH cur_organization
      INTO l_org_locator_control_code, l_organization_code;
    CLOSE cur_organization;
    dbms_output.put_line('l_org_locator_control_code:' ||
                         l_org_locator_control_code);
    --judge organization  stock_locator_control_code
    IF l_org_locator_control_code = 1 THEN
      --None
      RETURN;
    ELSIF l_org_locator_control_code = 2 THEN
      --Prespecified only
      get_locator_id(p_organization_id   => p_organization_id,
                     p_subinventory_code => p_subinventory_code,
                     p_concat_segments   => p_locator_concatenated_values,
                     x_locator_id        => x_inventory_location_id,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data);
      raise_exception(x_return_status);

      IF x_inventory_location_id IS NULL THEN
        x_msg_data      := get_message(g_appl_name,
                                       'XXINV_000E_007',
                                       'ORGANIZATION_CODE',
                                       l_organization_code,
                                       'SUBINVENTORY_CODE',
                                       p_subinventory_code,
                                       'LEVEL',
                                       'ORGANIZATION',
                                       'LOCATOR_CONTROL_CODE',
                                       'Prespecified');
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      RETURN;
    ELSIF l_org_locator_control_code = 3 THEN
      --Dynimic entry allowed
      create_locator(p_organization_id             => p_organization_id,
                     p_locator_concatenated_values => p_locator_concatenated_values,
                     p_subinventory_code           => p_subinventory_code,
                     p_locator_type                => l_org_locator_control_code,
                     x_inventory_location_id       => x_inventory_location_id,
                     x_return_status               => x_return_status,
                     x_msg_count                   => x_msg_count,
                     x_msg_data                    => x_msg_data);
    ELSIF l_org_locator_control_code = 4 THEN
      --Determined at Subinventory level
      --get subinventory locator_control_code
      OPEN cur_inventory;
      FETCH cur_inventory
        INTO l_subinv_locator_control_code;
      CLOSE cur_inventory;
      dbms_output.put_line('l_subinv_locator_control_code:' ||
                           l_subinv_locator_control_code);
      IF l_subinv_locator_control_code = 1 THEN
        RETURN;
      ELSIF l_subinv_locator_control_code = 2 THEN
        --Prespecified
        get_locator_id(p_organization_id   => p_organization_id,
                       p_subinventory_code => p_subinventory_code,
                       p_concat_segments   => p_locator_concatenated_values,
                       x_locator_id        => x_inventory_location_id,
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data);
        raise_exception(x_return_status);
        IF x_inventory_location_id IS NULL THEN
          x_msg_data      := get_message(g_appl_name,
                                         'XXINV_000E_007',
                                         'ORGANIZATION_CODE',
                                         l_organization_code,
                                         'SUBINVENTORY_CODE',
                                         p_subinventory_code,
                                         'LEVEL',
                                         'SUBINVENTORY',
                                         'LOCATOR_CONTROL_CODE',
                                         'Prespecified');
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
        RETURN;
      ELSIF l_subinv_locator_control_code = 3 THEN
        --Dynimic entry
        create_locator(p_organization_id             => p_organization_id,
                       p_locator_concatenated_values => p_locator_concatenated_values,
                       p_subinventory_code           => p_subinventory_code,
                       p_locator_type                => l_org_locator_control_code,
                       x_inventory_location_id       => x_inventory_location_id,
                       x_return_status               => x_return_status,
                       x_msg_count                   => x_msg_count,
                       x_msg_data                    => x_msg_data);
      ELSIF l_subinv_locator_control_code = 5 THEN
        --item level
        OPEN cur_item;
        FETCH cur_item
          INTO l_item_locator_control_code;
        CLOSE cur_item;
        dbms_output.put_line('l_item_locator_control_code:' ||
                             l_item_locator_control_code);
        IF l_item_locator_control_code = 1 THEN
          RETURN;
        ELSIF l_item_locator_control_code = 2 THEN
          --Prespecified
          get_locator_id(p_organization_id   => p_organization_id,
                         p_subinventory_code => p_subinventory_code,
                         p_concat_segments   => p_locator_concatenated_values,
                         x_locator_id        => x_inventory_location_id,
                         x_return_status     => x_return_status,
                         x_msg_count         => x_msg_count,
                         x_msg_data          => x_msg_data);
          raise_exception(x_return_status);
          IF x_inventory_location_id IS NULL THEN
            x_msg_data      := get_message(g_appl_name,
                                           'XXINV_000E_007',
                                           'ORGANIZATION_CODE',
                                           l_organization_code,
                                           'SUBINVENTORY_CODE',
                                           p_subinventory_code,
                                           'LEVEL',
                                           'ITEM',
                                           'LOCATOR_CONTROL_CODE',
                                           'Prespecified');
            x_return_status := fnd_api.g_ret_sts_error;
          END IF;
          RETURN;
        ELSIF l_item_locator_control_code = 3 THEN
          --Dynimic Entry
          create_locator(p_organization_id             => p_organization_id,
                         p_locator_concatenated_values => p_locator_concatenated_values,
                         p_subinventory_code           => p_subinventory_code,
                         p_locator_type                => l_org_locator_control_code,
                         x_inventory_location_id       => x_inventory_location_id,
                         x_return_status               => x_return_status,
                         x_msg_count                   => x_msg_count,
                         x_msg_data                    => x_msg_data);
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF x_msg_data IS NULL THEN
        x_msg_data := 'call xxinv_locator_pub.get_locator_id raise error:' ||
                      SQLERRM;
      END IF;
      IF x_return_status IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;
  END;

END xxinv_locator_pub;
/
