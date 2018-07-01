/* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :
  *       check_available_qty
  *   DESCRIPTION: 
  *       Get onhand quantity(QOH) or available quantity(ATT)
  *       Note: If there is a lock on serial number,It would no
  *             count into ATT.
  *   ARGUMENT:
  *       p_inventory_item_id      : item id
  *       p_organization_id        : organization_id
  *       p_subinventory           : subinventory_code
  *       p_lot_number             : lot number
  *       p_serial_number          : serial number
  *       p_qty_type               : QOH  quantity of ON-hand\ 
                                     ATT availabel quantity of item \
                                     ATR preservable quantity of ITEM
  *   RETURN: 
  *       Number
  *   HISTORY: 
  *     1.00 20/08/2009 hand-china
  * =============================================*/
  FUNCTION get_available_qty(p_inventory_item_id NUMBER, --NOT NULL
                             p_organization_id   NUMBER, --NOT NULL
                             p_subinventory      VARCHAR2 DEFAULT NULL,
                             p_locator_id        NUMBER DEFAULT NULL,
                             p_lot_number        VARCHAR2 DEFAULT NULL,
                             p_serial_number     VARCHAR2 DEFAULT NULL,
                             p_qty_type          VARCHAR2 DEFAULT 'QOH')
    RETURN NUMBER IS
    l_quantity NUMBER;
    l_sql      VARCHAR2(3500);
  
    --ref cursor
    TYPE c_ref_cursor IS REF CURSOR;
  
    l_ref_cur c_ref_cursor;
  
    -- reutnr msg parameter
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  
    -- return quantity parameter
    l_qty_on_hand               NUMBER;
    l_qty_res_on_hand           NUMBER;
    l_qty_res                   NUMBER;
    l_qty_sug                   NUMBER;
    l_qty_att                   NUMBER;
    l_qty_available_to_reserve  NUMBER;
    l_sqty_on_hand              NUMBER;
    l_sqty_res_on_hand          NUMBER;
    l_sqty_res                  NUMBER;
    l_sqty_sug                  NUMBER;
    l_sqty_att                  NUMBER;
    l_sqty_available_to_reserve NUMBER;
  
    l_revision_control         mtl_system_items_b.revision_qty_control_code%TYPE;
    l_lot_control_type         mtl_system_items_b.lot_control_code%TYPE;
    l_item_serial_control_code mtl_system_items_b.serial_number_control_code%TYPE;
  
    --contorl parameter
    l_is_revision_control BOOLEAN;
    l_is_lot_control      BOOLEAN;
    l_is_serial_control   BOOLEAN;
  BEGIN
  
    --
    --
    IF p_serial_number IS NOT NULL THEN
      SELECT COUNT(1)
        INTO l_quantity
        FROM mtl_serial_numbers msn
       WHERE msn.status_id = 1
         AND msn.current_status = 3
         AND msn.lot_number = p_lot_number
         AND msn.current_locator_id = p_locator_id
         AND msn.current_subinventory_code = p_subinventory
         AND msn.serial_number = p_serial_number
         AND msn.current_organization_id = p_organization_id
         AND msn.inventory_item_id = p_inventory_item_id;
    
      l_sql := 'SELECT COUNT(1)' || ' FROM mtl_serial_numbers msn' ||
               ' WHERE msn.status_id = 1' || ' AND msn.current_status = 3';
    
      IF p_subinventory IS NOT NULL THEN
        l_sql := l_sql || ' AND msn.current_subinventory_code = ' ||
                 chr(39) || p_subinventory || chr(39);
      END IF;
    
      IF p_locator_id IS NOT NULL THEN
        l_sql := l_sql || ' AND msn.current_locator_id = to_number(' ||
                 chr(39) || p_locator_id || chr(39) || ')';
      END IF;
      IF p_lot_number IS NOT NULL THEN
        l_sql := l_sql || ' AND msn.lot_number = ' || chr(39) ||
                 p_lot_number || chr(39);
      END IF;
    
      l_sql := l_sql ||
               ' AND (msn.group_mark_id IS NULL OR msn.group_mark_id = to_number(' ||
               chr(39) || '-1' || chr(39) || '))' ||
               ' AND msn.serial_number = :p_serial_number' ||
               ' AND msn.current_organization_id = :p_organization_id' ||
               ' AND msn.inventory_item_id = :p_inventory_item_id';
    
      IF l_debug = 'Y' THEN
        xxfnd_debug.log(p_msg => l_sql);
      END IF;
    
      OPEN l_ref_cur FOR l_sql
        USING p_serial_number, p_organization_id, p_inventory_item_id;
    
      FETCH l_ref_cur
        INTO l_quantity;
      CLOSE l_ref_cur;
    
      RETURN l_quantity;
    END IF;
  
    --
    -- get attribute of the item
    --
    SELECT msi.revision_qty_control_code
          ,msi.lot_control_code
          ,msi.serial_number_control_code
      INTO l_revision_control
          ,l_lot_control_type
          ,l_item_serial_control_code
      FROM mtl_system_items_b msi
     WHERE msi.inventory_item_id = p_inventory_item_id
       AND msi.organization_id = p_organization_id;
  
    IF l_revision_control = 2 THEN
      l_is_revision_control := TRUE;
    ELSE
      l_is_revision_control := FALSE;
    END IF;
  
    IF l_lot_control_type <> 1 AND p_lot_number IS NOT NULL THEN
      l_is_lot_control := TRUE;
    ELSE
      l_is_lot_control := FALSE;
    END IF;
  
    IF l_item_serial_control_code = 2 THEN
      l_is_serial_control := TRUE;
    ELSE
      l_is_serial_control := FALSE;
    END IF;
  
    --at first ,clear cache
    inv_quantity_tree_pub.clear_quantity_cache;
    inv_quantity_tree_pub.query_quantities(p_api_version_number      => 1.0,
                                           p_init_msg_lst            => fnd_api.g_false,
                                           x_return_status           => l_return_status,
                                           x_msg_count               => l_msg_count,
                                           x_msg_data                => l_msg_data,
                                           p_organization_id         => p_organization_id,
                                           p_inventory_item_id       => p_inventory_item_id,
                                           p_tree_mode               => 3,
                                           p_is_revision_control     => l_is_revision_control,
                                           p_is_lot_control          => l_is_lot_control,
                                           p_is_serial_control       => l_is_serial_control,
                                           p_grade_code              => NULL,
                                           p_demand_source_type_id   => -1,
                                           p_demand_source_header_id => -1,
                                           p_demand_source_line_id   => -1,
                                           p_demand_source_name      => NULL,
                                           p_lot_expiration_date     => SYSDATE,
                                           p_revision                => NULL,
                                           p_lot_number              => p_lot_number,
                                           p_subinventory_code       => p_subinventory,
                                           p_locator_id              => p_locator_id,
                                           p_onhand_source           => 3,
                                           x_qoh                     => l_qty_on_hand,
                                           x_rqoh                    => l_qty_res_on_hand,
                                           x_qr                      => l_qty_res,
                                           x_qs                      => l_qty_sug,
                                           x_att                     => l_qty_att,
                                           x_atr                     => l_qty_available_to_reserve,
                                           x_sqoh                    => l_sqty_on_hand,
                                           x_srqoh                   => l_sqty_res_on_hand,
                                           x_sqr                     => l_sqty_res,
                                           x_sqs                     => l_sqty_sug,
                                           x_satt                    => l_sqty_att,
                                           x_satr                    => l_sqty_available_to_reserve);
  
    IF l_return_status = fnd_api.g_ret_sts_success THEN
      IF p_qty_type = 'QOH' THEN
        l_quantity := l_qty_on_hand;
      ELSIF p_qty_type = 'ATR' THEN
        l_quantity := l_qty_available_to_reserve;
      ELSE
        l_quantity := l_qty_att;
      END IF; --IF p_qty_type = 'QOH' THEN
    ELSE
      l_quantity := NULL;
    END IF; --IF l_return_status = fnd_api.G_RET_STS_SUCCESS THEN  
    RETURN(l_quantity);
  EXCEPTION
    WHEN OTHERS THEN
      IF l_ref_cur%ISOPEN THEN
        CLOSE l_ref_cur;
      END IF;
      l_quantity := NULL;
      RETURN(l_quantity);
  END get_available_qty;
