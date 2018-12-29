(SELECT primary_quantity
                  ,m.transaction_id
              FROM mtl_material_transactions m
                  ,mtl_secondary_inventories ca
             WHERE ((p_inventory = 'ZC' AND ca.attribute4 = 'ZC') OR
                   (p_inventory = 'ALL' AND 1 = 1))
               AND ca.organization_id = p_organization_id
               AND ca.organization_id = m.organization_id
               AND ca.secondary_inventory_name = m.subinventory_code
               AND m.inventory_item_id = p_item_id
               AND ca.secondary_inventory_name                                              ,41) AND
 = p_sub_inv
               AND (m.transaction_type_id IN (18
                                             ,36
                                             ,71 /*,31,41*/) OR
                   (m.transaction_type_id IN (31
                   m.transaction_source_type_id = 6 AND
                   m.transaction_source_id = 11967 --账户别名：HNET海立新能源.期初库存导入
                   ))
               AND trunc(m.transaction_date
                        ,'DD') BETWEEN
                   trunc(nvl(p_start_date
                            ,SYSDATE)) - nvl(p_dayto
                                            ,999999) AND
                   trunc(nvl(p_start_date
                            ,SYSDATE)) - nvl(p_dayfrom
                                            ,0) --update by cyh 20170103
            
            )
