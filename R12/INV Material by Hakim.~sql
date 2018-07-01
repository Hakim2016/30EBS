SELECT msi.segment1,
       msi.description,
       msi.*
  FROM mtl_system_items_b msi
 WHERE 1 = 1
   AND msi.creation_date > trunc(SYSDATE, 'yyyy')
   AND msi.organization_id = 83
   AND msi.purchasing_item_flag = 'Y'
   AND msi.inventory_item_flag = 'Y';
