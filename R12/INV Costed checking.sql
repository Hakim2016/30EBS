--INV Item costed checking
SELECT mmt.costed_flag,
       msi.segment1,
       mmt.*
  FROM mtl_material_transactions mmt,
       mtl_system_items_b        msi
 WHERE 1 = 1
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
   AND mmt.transaction_id = 55055866 --8915869
;

--check the parameter (cutoff date) of inventory
SELECT 
mp.cost_cutoff_date
,mp.*
  FROM mtl_parameters mp
 WHERE 1 = 1
   --AND mp.organization_id = 83
   ;
