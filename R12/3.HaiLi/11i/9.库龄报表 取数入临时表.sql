SELECT b.inventory_item_id, b.organization_id, b.segment1, b.description
  FROM mtl_system_items_b b
 WHERE b.organization_id = p_organization_id
   AND (EXISTS
        (SELECT 'X' --a.inventory_item_id
           FROM mtl_secondary_inventories ca, mtl_item_sub_inventories a
          WHERE ((p_inventory = 'ZC' AND ca.attribute4 = 'ZC') OR
                (p_inventory = 'ALL' AND 1 = 1))
            AND ca.organization_id = b.organization_id
            AND ca.secondary_inventory_name = a.secondary_inventory
            AND a.organization_id = ca.organization_id
            AND a.inventory_item_id = b.inventory_item_id) OR EXISTS
        (SELECT '1'
           FROM mtl_secondary_inventories ca
          WHERE ((ca.attribute4 = 'CP') OR ('CP' = 'ALL'))
            AND ca.organization_id = b.organization_id));
            
--第一个限制
SELECT ca.* --'X' --a.inventory_item_id
  FROM mtl_secondary_inventories ca, mtl_item_sub_inventories a
 WHERE 1 = 1
      /*AND ((p_inventory = 'ZC' AND ca.attribute4 = 'ZC') OR
      (p_inventory = 'ALL' AND 1 = 1))*/
   AND ca.organization_id = 1131 --b.organization_id
   AND ca.secondary_inventory_name = a.secondary_inventory
   AND a.organization_id = ca.organization_id
--AND a.inventory_item_id = --b.inventory_item_id
;

SELECT *
  FROM mtl_secondary_inventories msec
 WHERE 1 = 1
   AND msec.organization_id = 1131
--AND msec.secondary_inventory_name = 'CCC01'
;

SELECT *
  FROM mtl_item_sub_inventories a
 WHERE 1 = 1
--AND a.organization_id = 1131
;

----第二个限制
SELECT ca.attribute4 --'1'
      ,
       ca.organization_id,
       ca.*
  FROM mtl_secondary_inventories ca
 WHERE 1 = 1
   AND ca.attribute4 = 'CP'
   AND ca.organization_id = 1131;
