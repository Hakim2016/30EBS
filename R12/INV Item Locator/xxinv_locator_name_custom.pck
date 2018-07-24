CREATE OR REPLACE PACKAGE xxinv_locator_name_custom IS

  /*==================================================
  Program Name:
      XXINV_LOCATOR_NAME_CUSTOM
  History:
  *** 1.0  Created : 2011-12-17 19:47:43 tyne.zeng
  *** 2.0  Wang.chen   2017-02-17 update
  ==================================================*/

  /*==================================================
  Program Name:
      get_locator_control
  Description:
      judge whether subinventory's or item's locator control is enable.
  History:
       1.00  2011-12-17 tyne.zeng
  ==================================================*/
  FUNCTION get_locator_control(p_item_id         IN NUMBER,
                               p_subinv_code     IN VARCHAR2,
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
      validate_fromto_locator
  Description:
      Validate whether Subinventory segment of From or to  Locator match with Subinventroy.
  History:
       1.00  2011-12-17 tyne.zeng
  ==================================================*/
  FUNCTION validate_fromto_locator(p_from_subinv  IN VARCHAR2,
                                   p_from_locator IN VARCHAR2,
                                   p_to_subinv    IN VARCHAR2,
                                   p_to_locator   IN VARCHAR2) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_locator
  Description:
     set the defalue value for locator
  History:
       1.00  wang.chen@2017-02-17
  ==================================================*/
  FUNCTION get_locator(p_item_id         IN NUMBER,
                       p_subinv          IN VARCHAR2,
                       p_organization_id IN NUMBER,
                       p_project         IN VARCHAR2,
                       p_task            IN VARCHAR2) RETURN VARCHAR2;
END xxinv_locator_name_custom;
/
CREATE OR REPLACE PACKAGE BODY xxinv_locator_name_custom IS

  /*==================================================
  Program Name:
      XXINV_LOCATOR_NAME_CUSTOM
  History:
  *** 1.0  Created : 2011-12-17 19:47:43 tyne.zeng
  *** 2.0  Wang.chen   2017-02-17 update
  ==================================================*/

  /*==================================================
  Program Name:
      get_locator_control
  Description:
      judge whether subinventory's or item's locator control is enable.
  History:
       1.00  2011-12-17 tyne.zeng
  ==================================================*/
  FUNCTION get_locator_control(p_item_id         IN NUMBER,
                               p_subinv_code     IN VARCHAR2,
                               p_organization_id IN NUMBER) RETURN VARCHAR2 IS
    l_subinv_ctl VARCHAR2(10);
    l_item_ctl   VARCHAR2(10);
    CURSOR csr_org IS
      SELECT mp.stock_locator_control_code
        FROM mtl_parameters mp
       WHERE mp.organization_id = p_organization_id;
  BEGIN
    OPEN csr_org;
    FETCH csr_org
      INTO l_subinv_ctl;
    CLOSE csr_org;
    --if LOCATOR CTL=Determined at Subinventroy
    --lookup type=MTL_LOCATION_CONTROL
    IF l_subinv_ctl = 4 THEN
      l_subinv_ctl := xxinv_common_utl.get_subinv_locator_control(p_subinv_code, p_organization_id);
      IF l_subinv_ctl <> 1 THEN
        --locator control=5 item level lookup type=MTL_ITEM_LOCATOR_CONTROL
        IF l_subinv_ctl = 5 AND p_item_id IS NOT NULL THEN
          l_item_ctl   := xxinv_common_utl.get_item_locator_control(p_item_id, p_organization_id);
          l_subinv_ctl := l_item_ctl;
        END IF;
      END IF;
    END IF;
    RETURN l_subinv_ctl;
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
      validate_fromto_locator
  Description:
      Validate whether Subinventory segment of From or to  Locator matchs with Subinventroy.
  History:
       1.00  2011-12-17 tyne.zeng
  ==================================================*/
  FUNCTION validate_fromto_locator(p_from_subinv  IN VARCHAR2,
                                   p_from_locator IN VARCHAR2,
                                   p_to_subinv    IN VARCHAR2,
                                   p_to_locator   IN VARCHAR2) RETURN VARCHAR2 IS
    l_rtn_flag  VARCHAR2(10) := 'Y';
    l_from_flag VARCHAR2(10);
    l_to_flag   VARCHAR2(10);
    l_cnt       NUMBER := 0;
  BEGIN
    IF p_from_locator IS NOT NULL THEN
      l_from_flag := validate_locator_name(p_subinv_code => p_from_subinv, p_locator_name => p_from_locator);
      IF l_from_flag = 'N' THEN
        l_cnt := l_cnt + 1;
      END IF;
    END IF;

    IF p_to_locator IS NOT NULL THEN
      l_to_flag := validate_locator_name(p_subinv_code => p_to_subinv, p_locator_name => p_to_locator);
      IF l_to_flag = 'N' THEN
        l_cnt := l_cnt + 1;
      END IF;
    END IF;
    IF l_cnt > 0 THEN
      l_rtn_flag := 'N';
    END IF;
    RETURN l_rtn_flag;
  END validate_fromto_locator;

  /*==================================================
  Program Name:
      get_locator
  Description:
     set the defalue value for locator
  History:
       1.00  wang.chen@2017-02-17
  ==================================================*/
  FUNCTION get_locator(p_item_id         IN NUMBER,
                       p_subinv          IN VARCHAR2,
                       p_organization_id IN NUMBER,
                       p_project         IN VARCHAR2,
                       p_task            IN VARCHAR2) RETURN VARCHAR2 IS
    l_locator VARCHAR2(240);
  BEGIN
    IF (p_project IS NULL AND p_task IS NULL) THEN
      BEGIN
        SELECT l.concatenated_segments
          INTO l_locator
          FROM mtl_item_sub_inventories s,
               mtl_system_items         i,
               mtl_secondary_locators   msl,
               mtl_item_locations_kfv   l
         WHERE 1 = 1
           AND s.inventory_item_id = i.inventory_item_id
           AND s.organization_id = i.organization_id
           AND i.inventory_item_id = msl.inventory_item_id(+)
           AND i.organization_id = msl.organization_id(+)
           AND msl.secondary_locator = l.inventory_location_id(+)
           AND msl.organization_id = l.organization_id(+)
           AND i.inventory_item_id = p_item_id
           AND s.organization_id = p_organization_id
           AND s.secondary_inventory = p_subinv
           AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_locator := NULL;
      END;
    ELSE
      l_locator := p_subinv || '.' || p_project || '.' || REPLACE(p_task, '.', '\.') || '.';
    END IF;

    IF (l_locator IS NULL) THEN
      l_locator := p_subinv || '...';
    END IF;

    RETURN l_locator;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_locator;

END xxinv_locator_name_custom;
/
