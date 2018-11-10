CREATE OR REPLACE PACKAGE XXINV_COMMON_UTL IS

  -- Author  : tyne.zeng
  -- Created : 2011-12-15 14:21:57
  -- Purpose : Utility For INV Modual

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
  *     1.00 2010-07-28 
  * =============================================*/
  FUNCTION get_available_qty(p_inventory_item_id NUMBER, --NOT NULL
                             p_organization_id   NUMBER, --NOT NULL
                             p_subinventory      VARCHAR2 DEFAULT NULL,
                             p_locator_id        NUMBER DEFAULT NULL,
                             p_lot_number        VARCHAR2 DEFAULT NULL,
                             p_serial_number     VARCHAR2 DEFAULT NULL,
                             p_qty_type          VARCHAR2 DEFAULT 'QOH')
    RETURN NUMBER;

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description.
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_concatenated_desc(p_appl_short_name VARCHAR2,
                                     p_key_flex_code   VARCHAR2,
                                     p_coa_id          NUMBER,
                                     p_accid           NUMBER,
                                     p_data_set        NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_concatenated_value
  Description:
      Get key flex concatenated value.
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_concatenated_value(p_appl_short_name  VARCHAR2,
                                      p_key_flex_code    VARCHAR2,
                                      p_structure_number NUMBER,
                                      p_combination_id   NUMBER,
                                      p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_value
  Description:
      Get key flex concatenated value for one segment of all .
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_value(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER,
                             p_combination_id   NUMBER,
                             p_seg_num          NUMBER,
                             p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_desc(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_combination_id   NUMBER,
                            p_seg_num          NUMBER,
                            p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_delimiter
  Description:
      Get key flex concatenated segment_delimiter .
  History:
       1.00  2011-12-15 tyne.zeng 
  ==================================================*/
  FUNCTION get_key_seg_delimiter(p_appl_short_name  VARCHAR2,
                                 p_key_flex_code    VARCHAR2,
                                 p_structure_number NUMBER,
                                 p_combination_id   NUMBER,
                                 p_seg_num          NUMBER,
                                 p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex segment count.
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_count(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER) RETURN NUMBER;

  /*==================================================
  Program Name:
      Get_Organization_name
  Description:
      get inv organization name.
  History:
  History:
      1.00 2011-06-16  hand-china    
  ==================================================*/
  FUNCTION get_organization_name(p_organization_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      Get_Organization_code
  Description:
      get inv organization code.
  History:
  History:
      1.00 2011-06-16  hand-china    
  ==================================================*/
  FUNCTION get_organization_code(p_organization_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      Get_subinv_locator_control
  Description:
      judge whether subinventory's locator control is enable.
  History:
      1.00 2011-12-17 tyne.zeng  
  ==================================================*/
  FUNCTION get_subinv_locator_control(p_subinv_code     IN VARCHAR2,
                                      p_organization_id IN NUMBER)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      Get_item_locator_control
  Description:
      judge whether item's locator control is enable.
  History:
      1.00 2011-12-17 tyne.zeng  
  ==================================================*/
  FUNCTION get_item_locator_control(p_item_id         IN NUMBER,
                                    p_organization_id IN NUMBER)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_po_number
  Description:
      get PO Number
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_po_number(p_po_header_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_legal_entity_name
  Description:
      
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/

  FUNCTION get_legal_entity_name(p_legal_entity_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_model_name
  Description:
      get mode flex set value description
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_model_name(p_mode_code IN VARCHAR2) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_territory_NAME
  Description:
      get TERRITORY SHORT NAME
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_territory_name(p_territory_code IN VARCHAR2) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_case_item
  Description:
      get case item
  History:
      1.00 2011-12-29 tyne.zeng  
  ==================================================*/
  FUNCTION get_item_code(p_item_id IN NUMBER, p_organization_id IN NUMBER)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_case_item
  Description:
      get case item
  History:
      1.00 2011-12-29 tyne.zeng  
  ==================================================*/
  FUNCTION get_case_item(p_item_id IN NUMBER, p_organization_id IN NUMBER)
    RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_locator_control
  Description:
      judge whether subinventory's locator control is enable.
  History:
       1.00  2011-12-17 tyne.zeng 
  ==================================================*/
  FUNCTION get_locator_control(p_subinv_code     IN VARCHAR2,
                               p_organization_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      validate_locator_name
  Description:
      Validate whether Subinventory segment of Locator matchs with Subinventroy.
  History:
       1.00  2011-12-17 tyne.zeng 
  ==================================================*/
  FUNCTION validate_locator_name(p_subinv_code  IN VARCHAR2,
                                 p_locator_name IN VARCHAR2) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_top_tasknum
  Description:
      get TOP Task Number
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_top_tasknum(p_task_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_locator_default_seg
  Description:
      get locator default values
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_locator_default_seg(p_subinv_code IN VARCHAR2,
                                   p_project_id  IN NUMBER,
                                   p_task_id     IN NUMBER) RETURN VARCHAR2;

  g_case_item_type VARCHAR2(30) := 'XXINV_CASE_ITEM_TYPE';
  --Function :
  --         Get Case Item Type                          
  FUNCTION get_case_item_type RETURN VARCHAR2;

  g_case_category_set VARCHAR2(30) := 'XXINV_CASE_CATEGORY_SET';
  --Function :
  --         Get Case Category Set
  FUNCTION get_case_category_set RETURN VARCHAR2;

  FUNCTION get_mst_orga RETURN NUMBER;

  g_part_value_set VARCHAR2(30) := 'XXGSCM_INV_ITEM_CATEGORY';
  FUNCTION get_part_desc(p_part_code IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_mfg_number(p_task_id IN NUMBER) RETURN VARCHAR2;

  /*==================================================
  Function Name:
      get_delivery_status
  Description:
      Calculate delivery status for fully delivery
  History:
      1.00  04-JUL-2012   eric.liu   Creation
  ==================================================*/
  FUNCTION get_delivery_status(p_top_task_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION get_delivery_date(p_top_task_id IN NUMBER) RETURN DATE;
  
	/*==================================================
    Procedure Name:
        get_trx_source
    Description:
        This procedure is used to calculate transaction
        source name of one specified material transaction.
    Arguments
        p_material_trx_id  IN  *material transaction id
    History:
        1.00  2012-11-03  eric.liu  Creation
  ==================================================*/
	FUNCTION get_trx_source(p_material_trx_id IN NUMBER)
    RETURN VARCHAR2;
END xxinv_common_utl;
/
CREATE OR REPLACE PACKAGE BODY XXINV_COMMON_UTL IS

  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
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

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description.
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_concatenated_desc(p_appl_short_name VARCHAR2,
                                     p_key_flex_code   VARCHAR2,
                                     p_coa_id          NUMBER,
                                     p_accid           NUMBER,
                                     p_data_set        NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    lv_desc  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_coa_id,
                                              combination_id   => p_accid,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_desc := fnd_flex_keyval.concatenated_descriptions;
    END IF;
  
    RETURN lv_desc;
  END get_key_concatenated_desc;

  /*==================================================
  Program Name:
      get_key_concatenated_value
  Description:
      Get key flex concatenated value.
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_concatenated_value(p_appl_short_name  VARCHAR2,
                                      p_key_flex_code    VARCHAR2,
                                      p_structure_number NUMBER,
                                      p_combination_id   NUMBER,
                                      p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.concatenated_values;
    END IF;
  
    RETURN lv_code;
  END get_key_concatenated_value;

  /*==================================================
  Program Name:
      get_key_seg_value
  Description:
      Get key flex concatenated value for one segment of all .
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_value(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER,
                             p_combination_id   NUMBER,
                             p_seg_num          NUMBER,
                             p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.segment_value(p_seg_num);
    END IF;
  
    RETURN lv_code;
  END get_key_seg_value;

  /*==================================================
  Program Name:
      get_key_seg_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_desc(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_combination_id   NUMBER,
                            p_seg_num          NUMBER,
                            p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.segment_description(p_seg_num);
    END IF;
  
    RETURN lv_code;
  END get_key_seg_desc;

  /*==================================================
  Program Name:
      get_key_seg_delimiter
  Description:
      Get key flex concatenated segment_delimiter .
  History:
       1.00  2011-12-15 tyne.zeng 
  ==================================================*/
  FUNCTION get_key_seg_delimiter(p_appl_short_name  VARCHAR2,
                                 p_key_flex_code    VARCHAR2,
                                 p_structure_number NUMBER,
                                 p_combination_id   NUMBER,
                                 p_seg_num          NUMBER,
                                 p_data_set         NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.segment_delimiter;
    END IF;
  
    RETURN lv_code;
  END get_key_seg_delimiter;

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_info(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_column_name      VARCHAR2,
                            p_info_name        VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_seg IS
      SELECT MAX(decode(p_info_name,
                        'FLEX_VALUE_SET_ID',
                        to_char(fis.flex_value_set_id),
                        'FLEX_VALUE_SET_NAME',
                        fvs.flex_value_set_name,
                        'SEGMENT_NAME',
                        fis.segment_name,
                        'SEGMENT_NUM',
                        to_char(fis.segment_num),
                        'FORM_ABOVE_PROMPT',
                        fis.form_above_prompt,
                        'FORM_LEFT_PROMPT',
                        fis.form_left_prompt)) res_value
        FROM fnd_flex_value_sets     fvs
            ,fnd_id_flex_segments_vl fis
            ,fnd_application         fa
       WHERE fvs.flex_value_set_id = fis.flex_value_set_id
         AND fis.application_id = fa.application_id
         AND fa.application_short_name = p_appl_short_name
         AND fis.enabled_flag = 'Y'
         AND fis.id_flex_code = p_key_flex_code
         AND fis.id_flex_num = p_structure_number
         AND fis.application_column_name = p_column_name;
    l_res VARCHAR2(240);
  BEGIN
    OPEN cur_seg;
    FETCH cur_seg
      INTO l_res;
    CLOSE cur_seg;
    RETURN l_res;
  END get_key_seg_info;

  /*==================================================
  Program Name:
      get_key_seg_count
  Description:
      Get key flex segment count.
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_count(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER) RETURN NUMBER IS
    l_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_id_flex_segments fis, fnd_application fa
     WHERE fis.application_id = fa.application_id
       AND fis.enabled_flag = 'Y'
       AND fis.id_flex_num = p_structure_number
       AND fis.id_flex_code = p_key_flex_code
       AND fa.application_short_name = p_appl_short_name;
  
    RETURN l_count;
  END get_key_seg_count;

  /*==================================================
  Program Name:
      Get_Organization_name
  Description:
      get inv organization name.
  History:
  History:
      1.00 2011-06-16  hand-china    
  ==================================================*/
  FUNCTION get_organization_name(p_organization_id IN NUMBER) RETURN VARCHAR2 AS
    l_org_name VARCHAR2(240);
    CURSOR csr_org IS
      SELECT ood.organization_name
        FROM org_organization_definitions ood
       WHERE ood.organization_id = p_organization_id;
  BEGIN
    OPEN csr_org;
    FETCH csr_org
      INTO l_org_name;
    CLOSE csr_org;
    RETURN l_org_name;
  END get_organization_name;

  /*==================================================
  Program Name:
      Get_Organization_code
  Description:
      get inv organization code.
  History:
  History:
      1.00 2011-06-16  hand-china    
  ==================================================*/
  FUNCTION get_organization_code(p_organization_id IN NUMBER) RETURN VARCHAR2 AS
    l_org_code VARCHAR2(240);
    CURSOR csr_org IS
      SELECT ood.organization_code
        FROM org_organization_definitions ood
       WHERE ood.organization_id = p_organization_id;
  BEGIN
    OPEN csr_org;
    FETCH csr_org
      INTO l_org_code;
    CLOSE csr_org;
    RETURN l_org_code;
  END get_organization_code;

  /*==================================================
  Program Name:
      Get_subinv_locator_control
  Description:
      judge whether subinventory's locator control is enable.
  History:
  History:
      1.00 2011-12-17 tyne.zeng  
  ==================================================*/
  FUNCTION get_subinv_locator_control(p_subinv_code     IN VARCHAR2,
                                      p_organization_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR cur_subinv IS
      SELECT msv.locator_type
        FROM mtl_secondary_inventories msv
       WHERE msv.secondary_inventory_name = p_subinv_code
         AND msv.organization_id = p_organization_id;
    l_locator_control VARCHAR2(10);
  BEGIN
    OPEN cur_subinv;
    FETCH cur_subinv
      INTO l_locator_control;
    CLOSE cur_subinv;
    RETURN nvl(l_locator_control, 1);
  END get_subinv_locator_control;

  /*==================================================
  Program Name:
      Get_item_locator_control
  Description:
      judge whether item's locator control is enable.
  History:
  History:
      1.00 2011-12-17 tyne.zeng  
  ==================================================*/
  FUNCTION get_item_locator_control(p_item_id         IN NUMBER,
                                    p_organization_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR cur_item IS
      SELECT msv.location_control_code
        FROM mtl_system_items_kfv msv
       WHERE msv.inventory_item_id = p_item_id
         AND msv.organization_id = p_organization_id;
    l_locator_control VARCHAR2(10);
  BEGIN
    OPEN cur_item;
    FETCH cur_item
      INTO l_locator_control;
    CLOSE cur_item;
    RETURN nvl(l_locator_control, 1);
  END get_item_locator_control;

  /*==================================================
  Program Name:
      get_flex_meaning
  Description:
      get flex set value description
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_flex_meaning(p_flex_set_name IN VARCHAR2,
                            p_flex_code     IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_model IS
      SELECT ffv.description
        FROM fnd_flex_values_vl ffv, fnd_flex_value_sets ffst
       WHERE ffv.flex_value_set_id = ffst.flex_value_set_id
         AND ffst.flex_value_set_name = p_flex_set_name
         AND ffv.flex_value = p_flex_code;
    l_model_name VARCHAR2(240);
  BEGIN
    OPEN cur_model;
    FETCH cur_model
      INTO l_model_name;
    CLOSE cur_model;
    RETURN l_model_name;
  END get_flex_meaning;

  /*==================================================
  Program Name:
      get_po_number
  Description:
      get PO Number
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_po_number(p_po_header_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR csr_po IS
      SELECT poh.segment1
        FROM po_headers_all poh
       WHERE poh.po_header_id = p_po_header_id;
    l_po_number VARCHAR2(240);
  BEGIN
    OPEN csr_po;
    FETCH csr_po
      INTO l_po_number;
    CLOSE csr_po;
    RETURN l_po_number;
  END get_po_number;

  /*==================================================
  Program Name:
      get_legal_entity_name
  Description:
      
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/

  FUNCTION get_legal_entity_name(p_legal_entity_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_leg IS
      SELECT xep.name
        FROM xle_entity_profiles xep
       WHERE xep.legal_entity_id = p_legal_entity_id;
    l_legal_name VARCHAR2(240);
  BEGIN
    OPEN cur_leg;
    FETCH cur_leg
      INTO l_legal_name;
    CLOSE cur_leg;
    RETURN l_legal_name;
  END get_legal_entity_name;

  /*==================================================
  Program Name:
      get_model_name
  Description:
      get mode flex set value description
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_model_name(p_mode_code IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_model IS
    /*********************************MOD by YSL 20120613****************************/
    /*      SELECT ffv.flex_value_meaning
                                FROM fnd_flex_values_vl ffv, fnd_flex_value_sets ffst
                               WHERE ffv.flex_value_set_id = ffst.flex_value_set_id
                                 AND ffst.flex_value_set_name = 'XXPJM_MFG_MODEL'
                                 AND ffv.flex_value = p_mode_code;*/
      SELECT ffv.flex_value_meaning
        FROM fnd_flex_values_vl ffv
       WHERE ffv.flex_value_set_id =
             fnd_profile.value('XXPJM_MODEL_VALUESET')
         AND ffv.enabled_flag = 'Y'
         AND SYSDATE BETWEEN nvl(ffv.start_date_active, SYSDATE) AND
             nvl(ffv.end_date_active + 0.99999, SYSDATE)
         AND ffv.flex_value = p_mode_code;
    /*********************************MOD by YSL 20120613****************************/
    l_model_name VARCHAR2(240);
  BEGIN
    OPEN cur_model;
    FETCH cur_model
      INTO l_model_name;
    CLOSE cur_model;
    RETURN l_model_name;
  
  END get_model_name;

  /*==================================================
  Program Name:
      get_territory_NAME
  Description:
      get TERRITORY SHORT NAME
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_territory_name(p_territory_code IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_country IS
      SELECT fnt.territory_short_name
        FROM fnd_territories_vl fnt
       WHERE fnt.territory_code = p_territory_code;
    l_short_name VARCHAR2(240);
  BEGIN
    OPEN cur_country;
    FETCH cur_country
      INTO l_short_name;
    CLOSE cur_country;
    RETURN l_short_name;
  END get_territory_name;

  /*==================================================
  Program Name:
      get_case_item
  Description:
      get case item
  History:
      1.00 2011-12-29 tyne.zeng  
  ==================================================*/
  FUNCTION get_item_code(p_item_id IN NUMBER, p_organization_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR csr_item IS
      SELECT msi.concatenated_segments
        FROM mtl_system_items_kfv msi
       WHERE msi.inventory_item_id = p_item_id
         AND msi.organization_id = p_organization_id;
    l_item_code VARCHAR2(240);
  BEGIN
    OPEN csr_item;
    FETCH csr_item
      INTO l_item_code;
    CLOSE csr_item;
    RETURN l_item_code;
  END get_item_code;

  /*==================================================
  Program Name:
      get_case_item
  Description:
      get case item
  History:
      1.00 2011-12-29 tyne.zeng  
  ==================================================*/
  FUNCTION get_case_item(p_item_id IN NUMBER, p_organization_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR csr_item IS
      SELECT msi.concatenated_segments
        FROM mtl_system_items_kfv msi
       WHERE msi.inventory_item_id = p_item_id
         AND msi.organization_id = p_organization_id;
    l_item_code VARCHAR2(240);
  BEGIN
    OPEN csr_item;
    FETCH csr_item
      INTO l_item_code;
    CLOSE csr_item;
    RETURN l_item_code;
  END get_case_item;

  /*==================================================
  Program Name:
      get_locator_control
  Description:
      judge whether subinventory's locator control is enable.
  History:
       1.00  2011-12-17 tyne.zeng 
  ==================================================*/
  FUNCTION get_locator_control(p_subinv_code     IN VARCHAR2,
                               p_organization_id IN NUMBER) RETURN VARCHAR2 IS
    l_subinv_ctl VARCHAR2(10);
    l_item_ctl   VARCHAR2(10);
    CURSOR csr_org IS
      SELECT mp.stock_locator_control_code
        FROM mtl_parameters mp
       WHERE mp.organization_id = p_organization_id;
    l_flag VARCHAR2(10) := 'Y';
  BEGIN
    OPEN csr_org;
    FETCH csr_org
      INTO l_subinv_ctl;
    CLOSE csr_org;
    --if LOCATOR CTL=Determined at Subinventroy
    IF l_subinv_ctl = 4 THEN
      l_subinv_ctl := xxinv_common_utl.get_subinv_locator_control(p_subinv_code,
                                                                  p_organization_id);
    END IF;
    IF l_subinv_ctl NOT IN ('1', '5') THEN
      l_flag := 'Y';
    ELSE
      l_flag := 'N';
    END IF;
    RETURN l_flag;
  END get_locator_control;

  /*==================================================
  Program Name:
      validate_locator_name
  Description:
      Validate whether Subinventory segment of Locator matchs with Subinventroy.
  History:
       1.00  2011-12-17 tyne.zeng 
  ==================================================*/
  FUNCTION validate_locator_name(p_subinv_code  IN VARCHAR2,
                                 p_locator_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_first_dim NUMBER := 0;
    l_segment1  VARCHAR2(240);
    l_rtn_flag  VARCHAR2(10);
    l_delim     VARCHAR2(10);
    CURSOR cur_delim IS
      SELECT concatenated_segment_delimiter
        FROM fnd_id_flex_structures_vl
       WHERE id_flex_structure_code = 'STOCK_LOCATORS';
  BEGIN
    OPEN cur_delim;
    FETCH cur_delim
      INTO l_delim;
    CLOSE cur_delim;
    l_first_dim := instr(p_locator_name, l_delim, 1, 1);
    l_segment1  := substr(p_locator_name, 1, l_first_dim - 1);
    IF p_subinv_code = l_segment1 THEN
      l_rtn_flag := 'Y';
    ELSE
      l_rtn_flag := 'N';
    END IF;
    RETURN l_rtn_flag;
  END validate_locator_name;

  /*==================================================
  Program Name:
      get_top_tasknum
  Description:
      get TOP Task Number
  History:
      1.00 2011-12-23 tyne.zeng  
  ==================================================*/
  FUNCTION get_top_tasknum(p_task_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR csr_lines IS
      SELECT ptk.task_number
        FROM pa_tasks pts, pa_tasks ptk
       WHERE pts.task_id = p_task_id
         AND pts.top_task_id = ptk.task_id;
  
    l_task_num VARCHAR2(100);
  BEGIN
    OPEN csr_lines;
    FETCH csr_lines
      INTO l_task_num;
    CLOSE csr_lines;
    RETURN l_task_num;
  END get_top_tasknum;

  FUNCTION get_locator_default_seg(p_subinv_code IN VARCHAR2,
                                   p_project_id  IN NUMBER,
                                   p_task_id     IN NUMBER) RETURN VARCHAR2 IS
    CURSOR csr_project IS
      SELECT pp.segment1
        FROM pa_projects_all pp
       WHERE pp.project_id = p_project_id;
  
    CURSOR csr_tasks IS
      SELECT pt.task_number FROM pa_tasks pt WHERE pt.task_id = p_task_id;
  
    CURSOR cur_delim IS
      SELECT concatenated_segment_delimiter
        FROM fnd_id_flex_structures_vl
       WHERE id_flex_structure_code = 'STOCK_LOCATORS';
    l_delim          VARCHAR2(10);
    l_project_number VARCHAR2(240);
    l_task_number    VARCHAR2(240);
    l_comp_segs      VARCHAR2(2000);
  BEGIN
  
    OPEN cur_delim;
    FETCH cur_delim
      INTO l_delim;
    CLOSE cur_delim;
  
    OPEN csr_project;
    FETCH csr_project
      INTO l_project_number;
    CLOSE csr_project;
  
    OPEN csr_tasks;
    FETCH csr_tasks
      INTO l_task_number;
    CLOSE csr_tasks;
    l_task_number := REPLACE(l_task_number, l_delim, '\' || l_delim);
    l_comp_segs   := p_subinv_code || l_delim || l_project_number ||
                     l_delim || l_task_number || l_delim;
    RETURN l_comp_segs;
  END get_locator_default_seg;

  FUNCTION get_case_item_type RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_profile.value(g_case_item_type);
  END get_case_item_type;

  FUNCTION get_case_category_set RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_profile.value(g_case_category_set);
  END get_case_category_set;

  FUNCTION get_mst_orga RETURN NUMBER IS
    CURSOR cur_orga IS
      SELECT mp.master_organization_id
        FROM mtl_parameters mp
       WHERE mp.master_organization_id IS NOT NULL;
    l_mst_orga NUMBER;
  BEGIN
    OPEN cur_orga;
    FETCH cur_orga
      INTO l_mst_orga;
    CLOSE cur_orga;
    RETURN l_mst_orga;
  END get_mst_orga;

  FUNCTION get_part_desc(p_part_code IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_part IS
      SELECT ffv.description
        FROM fnd_flex_value_sets ffs, fnd_flex_values_vl ffv
       WHERE ffs.flex_value_set_id = ffv.flex_value_set_id
         AND ffs.flex_value_set_name = g_part_value_set
         AND ffv.flex_value = p_part_code;
    l_part_desc fnd_flex_values_vl.description%TYPE;
  BEGIN
    OPEN cur_part;
    FETCH cur_part
      INTO l_part_desc;
    CLOSE cur_part;
    RETURN l_part_desc;
  END get_part_desc;

  FUNCTION get_mfg_number(p_task_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN get_top_tasknum(p_task_id);
  END get_mfg_number;

  /*==================================================
  Function Name:
      get_delivery_status
  Description:
      Calculate delivery status for fully delivery
  History:
      1.00  04-JUL-2012   eric.liu   Creation
			1.01  09-NOV-2012   hand       Update
			Improve performance
  ==================================================*/
  FUNCTION get_delivery_status(p_top_task_id IN NUMBER) RETURN VARCHAR2 IS
    v_dlv_status fnd_flex_values.flex_value%TYPE := 'Y';
  
    CURSOR dlv_sts_cur IS
    select 'N'
      from pa_tasks             pt,
           oe_order_lines_all   ool,
           oe_transaction_types_all ott
     where pt.top_task_id = p_top_task_id
	     AND pt.project_id = ool.project_id -- add this to use index
       and pt.task_id = ool.task_id
       and ool.flow_status_code NOT IN ('ENTERED', 'CLOSED', 'CANCELLED')
       AND nvl(oOl.attribute1, 'N') != 'Y'
       and ool.line_type_id = ott.TRANSACTION_TYPE_ID
       and ott.attribute5 IN ('EQ', 'PART') -- MFG Number Rule
    ;
  BEGIN
    OPEN dlv_sts_cur;
    FETCH dlv_sts_cur
      INTO v_dlv_status;
    CLOSE dlv_sts_cur;
  
    RETURN(v_dlv_status);
  END get_delivery_status;

  FUNCTION get_delivery_date(p_top_task_id IN NUMBER) RETURN DATE IS
    CURSOR dlv_sts_cur IS
      SELECT ool.attribute4
        from pa_tasks             pt,
             oe_order_lines_all   ool,
             oe_transaction_types_all ott
       where pt.top_task_id = p_top_task_id
			   AND pt.project_id = ool.project_id -- add this to use index
         and pt.task_id = ool.task_id
         and ool.flow_status_code NOT IN ('ENTERED', 'CLOSED', 'CANCELLED')
         and ool.attribute1 = 'Y'
         and ool.attribute4 is not null
         and ool.line_type_id = ott.TRANSACTION_TYPE_ID
         and ott.attribute5 IN ('EQ', 'PART') -- MFG Number Rule
         ORDER BY 1 DESC;
    l_delivery_date VARCHAR2(40);
  BEGIN
    OPEN dlv_sts_cur;
    FETCH dlv_sts_cur
      INTO l_delivery_date;
    CLOSE dlv_sts_cur;
    RETURN fnd_conc_date.string_to_date(l_delivery_date);
  END get_delivery_date;

	FUNCTION get_trx_source(p_material_trx_id IN NUMBER)
    RETURN VARCHAR2
	IS
    PO                   CONSTANT NUMBER  := 1;
    Sales_Order          CONSTANT NUMBER  := 2;
    Account              CONSTANT NUMBER  := 3;
    Move_Order           CONSTANT NUMBER  := 4;
    WIP_Job_or_Schedule  CONSTANT NUMBER  := 5;
    Account_Alias        CONSTANT NUMBER  := 6;
    Requisition          CONSTANT NUMBER  := 7;
    Internal_Order       CONSTANT NUMBER  := 8;
    Cycle_count          CONSTANT NUMBER  := 9;
    Physical_inventory   CONSTANT NUMBER  := 10;
    Cost_update          CONSTANT NUMBER  := 11;
    RMA                  CONSTANT NUMBER  := 12;
    Inventory            CONSTANT NUMBER  := 13;
    --Layer_cost_update    CONSTANT NUMBER  := 15;
    PrjContracts         CONSTANT NUMBER  := 16;

    v_process_phase      varchar2(30);
    n_organization_id    number;
    n_txn_source_type_id number;
    n_txn_source_id      number;
    v_txn_source_name    MTL_MATERIAL_TRANSACTIONS.TRANSACTION_SOURCE_NAME%TYPE;
  begin
    v_process_phase := 'Fetch txn infomation';
    -- get transaction information
    SELECT MMT.ORGANIZATION_ID,
           MMT.TRANSACTION_SOURCE_TYPE_ID,
           MMT.TRANSACTION_SOURCE_ID,
           MMT.TRANSACTION_SOURCE_NAME
      INTO n_organization_id,
           n_txn_source_type_id,
           n_txn_source_id,
           v_txn_source_name
      FROM MTL_MATERIAL_TRANSACTIONS MMT
     WHERE MMT.TRANSACTION_ID = p_material_trx_id
    ;

    if n_txn_source_type_id = Cost_update then
      v_process_phase := 'Cost Update';
      SELECT DESCRIPTION INTO v_txn_source_name
        FROM CST_COST_UPDATES
       WHERE COST_UPDATE_ID = n_txn_source_id
      ;
    elsif n_txn_source_type_id = Cycle_count then
      v_process_phase := 'Cycle Count';
      SELECT CYCLE_COUNT_HEADER_NAME
        INTO v_txn_source_name
        FROM MTL_CYCLE_COUNT_HEADERS
       WHERE CYCLE_COUNT_HEADER_ID = n_txn_source_id
         AND organization_id = n_organization_id
      ;
    elsif (n_txn_source_type_id = Inventory or n_txn_source_type_id >= 100) then
      v_process_phase := 'Inventory';
      --v_txn_source_name := v_txn_source_name;
    elsif  n_txn_source_type_id = Physical_inventory then
      v_process_phase := 'Physical Inventory';
      SELECT PHYSICAL_INVENTORY_NAME
        INTO v_txn_source_name
        FROM MTL_PHYSICAL_INVENTORIES
       WHERE PHYSICAL_INVENTORY_ID = n_txn_source_id
         AND organization_id = n_organization_id
      ;
    elsif n_txn_source_type_id = PO then
      v_process_phase := 'PO';
      select nvl(CLM_DOCUMENT_NUMBER, POH.SEGMENT1)
        INTO v_txn_source_name
        from po_headers_all poh
       where poh.po_header_id = n_txn_source_id
      ;
    elsif n_txn_source_type_id = PrjContracts then
      v_process_phase := 'PrjContracts';
      SELECT contract_number
        INTO v_txn_source_name
        FROM okc_k_headers_b
       WHERE id = n_txn_source_id
      ;
    elsif n_txn_source_type_id = Requisition then
      v_process_phase := 'Requisition';
      SELECT SEGMENT1
        INTO v_txn_source_name
        FROM PO_REQUISITION_HEADERS_ALL
       WHERE REQUISITION_HEADER_ID = n_txn_source_id
      ;
    elsif n_txn_source_type_id = WIP_Job_or_Schedule then
      v_process_phase := 'WIP Job or Schedule';
      SELECT WIP_ENTITY_NAME
        INTO v_txn_source_name
        FROM WIP_ENTITIES
       WHERE WIP_ENTITY_ID = n_txn_source_id
         AND organization_id = n_organization_id
      ;
    elsif n_txn_source_type_id = Move_Order then
      v_process_phase := 'Move Order';
      SELECT REQUEST_NUMBER
        INTO v_txn_source_name
        FROM MTL_TXN_REQUEST_HEADERS
       WHERE HEADER_ID = n_txn_source_id
         AND organization_id = n_organization_id
      ;
    elsif ( (n_txn_source_type_id = Sales_Order) OR
            (n_txn_source_type_id = Internal_Order) OR
            (n_txn_source_type_id = RMA) ) then
      v_process_phase := 'Sales Order';
      select concatenated_segments
        into v_txn_source_name
        from MTL_SALES_ORDERS_KFV
       where SALES_ORDER_ID = n_txn_source_id
      ;
    elsif n_txn_source_type_id = Account_Alias then
      v_process_phase := 'Account Alias';
      select concatenated_segments
        into v_txn_source_name
        from MTL_GENERIC_DISPOSITIONS_KFV
       where disposition_id = n_txn_source_id
      ;
    elsif n_txn_source_type_id = Account then
      v_process_phase := 'Account';
      select concatenated_segments
        into v_txn_source_name
        from GL_CODE_COMBINATIONS_KFV
       where CODE_COMBINATION_ID = n_txn_source_id
      ;
    else
      -- We do not need display txn source for other types.
      -- including Layer_cost_update
      v_process_phase := 'Others';
      v_txn_source_name := null;
    end if;
    
		RETURN v_txn_source_name;
  EXCEPTION
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      if l_debug = 'Y' then
        xxfnd_debug.log('GET_TXN_SOURCE: ' || SQLERRM);
        xxfnd_debug.log('Process phase : ' || v_process_phase);
      end if;
      RETURN to_char(NULL);
  END get_trx_source;
END xxinv_common_utl;
/
