-- Cost Import Process
/*
Step one : Create a process table
          CREATE TABLE xxinv.xxinv_item_cost_update_150409
          (
                 group_id             NUMBER,
                 organization_code    VARCHAR2(100),
                 Item_number          VARCHAR2(100),
                 Cost_type            VARCHAR2(100),
                 cost_element         VARCHAR2(100),
                 sub_element          VARCHAR2(100), -- resource_code
                 basis                VARCHAR2(100),
                 usage_rate_or_amount VARCHAR2(100), -- usage_rate_or_amount
                 organization_id      NUMBER,
                 inventory_item_id    NUMBER,
                 cost_type_id         NUMBER,
                 cost_element_id      NUMBER,
                 basis_type           NUMBER,
                 process_status       VARCHAR2(1),
                 process_date         DATE,
                 process_message      VARCHAR2(2000),
                 action               VARCHAR2(30)    
          );

Step two : Backup Data
        CREATE TABLE xxinv.xxinv_cst_item_costs_BK150409 AS
        SELECT cic.*
          FROM cst_item_costs      cic,
               cst_cost_types      cct,
               mtl_system_items_vl msi,
               -- 
               cst_item_cost_details cicd,
               bom_resources         br,
               cst_cost_elements     cce,
               mfg_lookups           lu1
         WHERE cct.cost_type_id = cic.cost_type_id
           AND msi.inventory_item_id = cic.inventory_item_id
           AND msi.organization_id = cic.organization_id
           AND msi.costing_enabled_flag = 'Y'
           AND br.resource_id(+) = cicd.resource_id
           AND cce.cost_element_id = cicd.cost_element_id
           AND lu1.lookup_type = 'CST_BASIS'
           AND lu1.lookup_code = cicd.basis_type
           AND cicd.inventory_item_id = cic.inventory_item_id -- 263612
           AND cicd.organization_id = cic.organization_id -- 86
           AND cicd.cost_type_id = cic.cost_type_id -- 1000
           AND cicd.rollup_source_type = 1 -- User defined
              --      
           AND (msi.organization_id, --
                msi.concatenated_segments, --
                cct.cost_type, --
                cce.cost_element, --
                br.resource_code) IN (SELECT ood.organization_id,
                                             t.item_number,
                                             t.cost_type,
                                             t.cost_element,
                                             t.sub_element
                                        FROM xxinv.xxinv_item_cost_update_150409 t,
                                             org_organization_definitions        ood
                                       WHERE 1 = 1
                                         AND t.organization_code = ood.organization_code);
                                            
            CREATE TABLE xxinv.xxinv_cst_item_dtl_BK150409 AS
            SELECT cicd.*
              FROM cst_item_costs      cic,
                   cst_cost_types      cct,
                   mtl_system_items_vl msi,
                   -- 
                   cst_item_cost_details cicd,
                   bom_resources         br,
                   cst_cost_elements     cce,
                   mfg_lookups           lu1
             WHERE cct.cost_type_id = cic.cost_type_id
               AND msi.inventory_item_id = cic.inventory_item_id
               AND msi.organization_id = cic.organization_id
               AND msi.costing_enabled_flag = 'Y'
               AND br.resource_id(+) = cicd.resource_id
               AND cce.cost_element_id = cicd.cost_element_id
               AND lu1.lookup_type = 'CST_BASIS'
               AND lu1.lookup_code = cicd.basis_type
               AND cicd.inventory_item_id = cic.inventory_item_id -- 263612
               AND cicd.organization_id = cic.organization_id -- 86
               AND cicd.cost_type_id = cic.cost_type_id -- 1000
               AND cicd.rollup_source_type = 1 -- User defined
                  --      
               AND (msi.organization_id, --
                    msi.concatenated_segments, --
                    cct.cost_type, --
                    cce.cost_element, --
                    br.resource_code) IN (SELECT ood.organization_id,
                                                 t.item_number,
                                                 t.cost_type,
                                                 t.cost_element,
                                                 t.sub_element
                                            FROM xxinv.xxinv_item_cost_update_150409 t,
                                                 org_organization_definitions        ood
                                           WHERE 1 = 1
                                             AND t.organization_code = ood.organization_code);
Step Three : Running Script

Step Four : Running Concurrent Program "Cost Import Process" Including Create and Update

*/

DECLARE
  c_create_flag     CONSTANT VARCHAR2(10) := 'CREATE';
  c_update_flag     CONSTANT VARCHAR2(10) := 'UPDATE';
  c_undo_flag       CONSTANT VARCHAR2(10) := 'UNDO';
  c_process_error   CONSTANT VARCHAR2(1) := 'E';
  c_process_success CONSTANT VARCHAR2(1) := 'S';
  l_group_id             cst_item_cst_dtls_interface.group_id%TYPE;
  l_group_description    cst_item_cst_dtls_interface.group_description%TYPE;
  l_inventory_item_id    cst_item_cst_dtls_interface.inventory_item_id%TYPE;
  l_organization_id      cst_item_cst_dtls_interface.organization_id%TYPE;
  l_cost_type_id         cst_item_cst_dtls_interface.cost_type_id%TYPE;
  l_resource_code        cst_item_cst_dtls_interface.resource_code%TYPE;
  l_usage_rate_or_amount cst_item_cst_dtls_interface.usage_rate_or_amount%TYPE;
  l_cost_element_id      cst_item_cst_dtls_interface.cost_element_id%TYPE;
  l_process_flag         cst_item_cst_dtls_interface.process_flag%TYPE;
  l_basis_type           cst_item_cst_dtls_interface.basis_type%TYPE;
  l_cst_rec              cst_item_cst_dtls_interface%ROWTYPE;
  l_create_update_flag   VARCHAR2(10); -- 1 create/ 2 update
  l_update_rownum        NUMBER;
  l_create_rownum        NUMBER;
  l_undo_rownum          NUMBER;
  l_update_group_id      NUMBER;
  l_create_group_id      NUMBER;
  l_timer                NUMBER;

  CURSOR cur_data(p_cur_group_id IN NUMBER) IS
    SELECT t.rowid row_id,
           t.*
      FROM xxinv.xxinv_item_cost_update_150409 t
     WHERE 1 = 1
       AND t.group_id = p_cur_group_id
       AND nvl(t.process_status, c_process_success) = c_process_success;
BEGIN
  l_timer             := dbms_utility.get_time;
  l_group_id          := 10000;
  l_group_description := 'PJL Test group';
  --l_inventory_item_id    := 263612;
  --l_organization_id      := 86;
  --l_cost_type_id         := 1000;
  --l_resource_code        := 'SHE_CL';
  --l_usage_rate_or_amount := 0.03;
  --l_cost_element_id      := 2;
  l_process_flag := 1;

  l_update_group_id := l_group_id * 10 + 1;
  l_create_group_id := l_group_id * 10 + 2;

  -- ORGANIZATION
  UPDATE xxinv.xxinv_item_cost_update_150409 t
     SET t.organization_id =
         (SELECT ood.organization_id
            FROM org_organization_definitions ood
           WHERE 1 = 1
             AND ood.organization_code = t.organization_code)
   WHERE t.group_id = l_group_id
     AND nvl(t.process_status, c_process_success) = c_process_success;

  -- INVENTORY ITEM
  UPDATE xxinv.xxinv_item_cost_update_150409 t
     SET t.inventory_item_id =
         (SELECT msi.inventory_item_id
            FROM mtl_system_items_b msi
           WHERE 1 = 1
             AND msi.organization_id = t.organization_id
             AND msi.segment1 = t.item_number)
   WHERE t.group_id = l_group_id
     AND nvl(t.process_status, c_process_success) = c_process_success;

  -- COST TYPE
  UPDATE xxinv.xxinv_item_cost_update_150409 t
     SET t.cost_type_id =
         (SELECT cct.cost_type_id
            FROM cst_cost_types cct
           WHERE 1 = 1
                --AND cct.organization_id = t.organization_id
             AND cct.cost_type = t.cost_type)
   WHERE t.group_id = l_group_id
     AND nvl(t.process_status, c_process_success) = c_process_success;

  -- COST_ELEMENT
  UPDATE xxinv.xxinv_item_cost_update_150409 t
     SET t.cost_element_id =
         (SELECT cce.cost_element_id
            FROM cst_cost_elements cce
           WHERE cce.cost_element = t.cost_element)
   WHERE t.group_id = l_group_id
     AND nvl(t.process_status, c_process_success) = c_process_success;

  -- BASIS
  UPDATE xxinv.xxinv_item_cost_update_150409 t
     SET t.basis_type =
         (SELECT ml.lookup_code
            FROM mfg_lookups ml
           WHERE ml.lookup_type = 'CST_BASIS'
             AND ml.meaning = t.basis)
   WHERE t.group_id = l_group_id
     AND nvl(t.process_status, c_process_success) = c_process_success;

  UPDATE xxinv.xxinv_item_cost_update_150409 t
     SET t.action          = c_undo_flag,
         t.process_status  = c_process_error,
         t.process_date    = SYSDATE,
         t.process_message = decode(t.organization_id,
                                    NULL,
                                    'Organization is invalid',
                                    decode(t.inventory_item_id,
                                           NULL,
                                           'Item is invalid',
                                           decode(t.cost_type_id,
                                                  NULL,
                                                  'Cost Type is invalid',
                                                  decode(t.cost_element_id,
                                                         NULL,
                                                         'Cost Element is invalid',
                                                         decode(t.basis_type, NULL, 'basis is invalid', 'Some error causes')))))
   WHERE 1 = 1
     AND (t.organization_id IS NULL OR --
         t.inventory_item_id IS NULL OR --
         t.cost_type_id IS NULL OR --
         t.cost_element_id IS NULL OR --
         t.basis_type IS NULL)
     AND t.group_id = l_group_id
     AND nvl(t.process_status, c_process_success) = c_process_success;

  -- validate end 
  l_create_rownum := 0;
  l_update_rownum := 0;
  l_undo_rownum   := 0;
  FOR rec IN cur_data(p_cur_group_id => l_group_id)
  LOOP
    l_create_update_flag := NULL;
    BEGIN
      l_inventory_item_id    := NULL;
      l_organization_id      := NULL;
      l_cost_type_id         := NULL;
      l_resource_code        := NULL;
      l_usage_rate_or_amount := NULL;
      l_cost_element_id      := NULL;
      l_basis_type           := NULL;
    
      SELECT cic.inventory_item_id,
             cic.organization_id,
             cic.cost_type_id,
             br.resource_code,
             cicd.usage_rate_or_amount,
             cicd.cost_element_id,
             cicd.basis_type
        INTO l_inventory_item_id,
             l_organization_id,
             l_cost_type_id,
             l_resource_code,
             l_usage_rate_or_amount,
             l_cost_element_id,
             l_basis_type
      
      /*cic.inventory_item_id,
      cic.organization_id,
      msi.concatenated_segments,
      msi.description,
      cic.cost_type_id,
      cct.cost_type,
      cic.item_cost,
      cic.material_cost,
      cic.material_overhead_cost,
      cic.resource_cost,
      cic.outside_processing_cost,
      cic.overhead_cost,
      lu1_mb.meaning planning_make_buy_meaing,
      -- 
      cicd.inventory_item_id,
      cicd.organization_id,
      cicd.cost_type_id,
      cicd.resource_id,
      br.resource_code,
      cicd.resource_rate,
      cicd.usage_rate_or_amount,
      cicd.basis_type,
      lu1.meaning               basis_meaning,
      cicd.item_cost,
      cicd.cost_element_id,
      cce.cost_element,
      cicd.rollup_source_type,
      lu2.meaning               rollup_source_meaning,
      cicd.request_id*/
        FROM cst_item_costs      cic,
             cst_cost_types      cct,
             mtl_system_items_vl msi,
             mfg_lookups         lu1_mb,
             -- 
             cst_item_cost_details cicd,
             bom_resources         br,
             cst_cost_elements     cce,
             mfg_lookups           lu1,
             mfg_lookups           lu2
       WHERE cct.cost_type_id = cic.cost_type_id
         AND msi.inventory_item_id = cic.inventory_item_id
         AND msi.organization_id = cic.organization_id
         AND msi.costing_enabled_flag = 'Y'
         AND lu1_mb.lookup_code(+) = msi.planning_make_buy_code
         AND lu1_mb.lookup_type(+) = 'MTL_PLANNING_MAKE_BUY'
            --AND msi.concatenated_segments = '12506665-A-0000'
         AND br.resource_id(+) = cicd.resource_id
         AND cce.cost_element_id = cicd.cost_element_id
         AND lu1.lookup_type = 'CST_BASIS'
         AND lu1.lookup_code = cicd.basis_type
         AND lu2.lookup_type = 'CST_SOURCE_TYPE'
         AND lu2.lookup_code = cicd.rollup_source_type
         AND cicd.inventory_item_id = cic.inventory_item_id -- 263612
         AND cicd.organization_id = cic.organization_id -- 86
         AND cicd.cost_type_id = cic.cost_type_id -- 1000
         AND cicd.rollup_source_type = 1 -- User defined
            -- 
         AND cic.organization_id = rec.organization_id
         AND cic.inventory_item_id = rec.inventory_item_id
         AND cct.cost_type_id = rec.cost_type_id
         AND br.resource_code = rec.sub_element
         AND cicd.cost_element_id = rec.cost_element_id
         AND cicd.basis_type = rec.basis_type
      --AND cct.cost_type = 'GSCM_AVG'
      -- AND cic.organization_id = 86
      --AND br.resource_code = 'SHE_CL'
      /*AND cic.inventory_item_id = l_inventory_item_id
      AND cic.organization_id = l_organization_id
      AND cic.cost_type_id = l_cost_type_id
      AND br.resource_code = l_resource_code
      AND cicd.cost_element_id = l_cost_element_id*/
      ;
    
      IF l_usage_rate_or_amount = 0.03 THEN
        l_create_update_flag := c_undo_flag;
        l_undo_rownum        := l_undo_rownum + 1;
      ELSE
        l_create_update_flag := c_update_flag;
        l_update_rownum      := l_update_rownum + 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- new cost
        l_create_update_flag := c_create_flag;
        l_create_rownum      := l_create_rownum + 1;
    END;
  
    UPDATE xxinv.xxinv_item_cost_update_150409 t
       SET t.action         = l_create_update_flag, --
           t.process_status = c_process_success
     WHERE 1 = 1
       AND t.rowid = rec.row_id;
  
    IF l_create_update_flag IN (c_update_flag, c_create_flag) THEN
      IF l_create_update_flag = c_update_flag THEN
        l_cst_rec.group_id := l_update_group_id;
      ELSE
        l_cst_rec.group_id := l_create_group_id;
      END IF;
    
      l_cst_rec.group_description    := l_group_description;
      l_cst_rec.inventory_item_id    := rec.inventory_item_id;
      l_cst_rec.organization_id      := rec.organization_id;
      l_cst_rec.cost_type_id         := rec.cost_type_id;
      l_cst_rec.cost_element_id      := rec.cost_element_id;
      l_cst_rec.basis_type           := rec.basis_type;
      l_cst_rec.resource_code        := rec.sub_element;
      l_cst_rec.usage_rate_or_amount := rec.usage_rate_or_amount; -- l_usage_rate_or_amount;
      l_cst_rec.process_flag         := l_process_flag;
      l_cst_rec.rollup_source_type   := 1; -- User defined
      INSERT INTO cst_item_cst_dtls_interface
      VALUES l_cst_rec;
    END IF;
  END LOOP;
  l_timer := (dbms_utility.get_time - l_timer) / 100;
  dbms_output.put_line(' Time-consuming   : ' || l_timer);
  dbms_output.put_line(' Create Item Cost : ' || l_create_rownum || '  create_group_id  ' || l_create_group_id);
  dbms_output.put_line(' Update Item Cost : ' || l_update_rownum || '  update_group_id  ' || l_update_group_id);
  dbms_output.put_line(' Undo   Item Cost : ' || l_undo_rownum);

END;
