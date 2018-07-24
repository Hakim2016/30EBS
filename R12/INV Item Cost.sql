SELECT mp.organization_code "Organization",
       mc.segment1 || '.' || mc.segment2 || '.' || mc.segment3 "Category",
       mc.description "Category Description",
       cict.inventory_item_id,
       mic.category_set_id,
       cict.item_number "Item name",
       cict.description "Item description",
       cict.cost_type "Cost type",
       
       cict.item_cost               "Item cost",--from cst_item_costs
       cict.material_cost,
       cict.material_overhead_cost,
       cict.resource_cost,
       cict.outside_processing_cost,
       cict.overhead_cost,
       --cict.item_number, --msi.concatenated_segments,
       --cict.padded_item_number,       --msi.padded_concatenated_segments,
       /*msi.*/cict.cost_of_sales_account,
       /*msi.*/cict.sales_account
  FROM apps.cst_item_cost_type_v cict,
       inv.mtl_parameters        mp,
       inv.mtl_item_categories   mic,
       apps.mtl_categories_vl    mc,
       inv.mtl_system_items_b    msi
 WHERE 1 = 1
   AND cict.organization_id = mp.organization_id
   AND cict.organization_id = msi.organization_id
   AND cict.inventory_item_id = msi.inventory_item_id
   AND cict.category_id = mic.category_id
   AND cict.inventory_item_id = mic.inventory_item_id
   AND cict.organization_id = mic.organization_id
   AND mic.category_id = mc.category_id
      --AND    mic.category_set_id = 3
      --AND    cict.item_cost = 0
      --AND    cict.organization_id = 614
      --AND    cict.cost_type_id = 2 --Æ½¾ù
      --AND    cict.INVENTORY_ITEM_ID = 25759
   AND cict.inventory_item_id = 1621957
/*IN (SELECT mmt.inventory_item_id
FROM   inv.mtl_material_transactions mmt
WHERE  1 = 1
AND    mmt.transaction_type_id IN (35,44)--(18,36)
--AND    mmt.organization_id = 614
AND    mmt.transaction_cost = 0
AND    mmt.rcv_transaction_id --= 2134136
IN (54869415, 54869414, 54869413, 54869412, 54869411, 54869410, 54869409, 54869408, 54869407)
--AND    mmt.transaction_date > to_date('2018-07-16', 'yyyy-mm-dd')
GROUP  BY mmt.inventory_item_id)*/
;
SELECT mmt.inventory_item_id
  FROM inv.mtl_material_transactions mmt
 WHERE 1 = 1
      --AND mmt.transaction_type_id IN (35, 44) --(18,36)
      --AND    mmt.organization_id = 614
      --AND mmt.transaction_cost = 0
      --AND mmt.rcv_transaction_id --= 2134136
   AND mmt.transaction_id IN (54869415, 54869414, 54869413, 54869412, 54869411, 54869410, 54869409, 54869408, 54869407)
--AND    mmt.transaction_date > to_date('2018-07-16', 'yyyy-mm-dd')
 GROUP BY mmt.inventory_item_id;
