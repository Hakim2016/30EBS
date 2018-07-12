SELECT msi.segment1,
       msi.description,
       msi.purchasing_item_flag,
        msi.inventory_item_flag,
       msi.*
  FROM mtl_system_items_b msi
 WHERE 1 = 1
   AND msi.creation_date > SYSDATE - 60 --trunc(SYSDATE, 'yyyy')
   --AND msi.organization_id = 83
   --AND msi.segment1 LIKE '34261834%A%000'
   AND msi.organization_id = 86 
   AND msi.purchasing_item_flag = 'Y'
   AND msi.inventory_item_flag = 'Y'
   ;
