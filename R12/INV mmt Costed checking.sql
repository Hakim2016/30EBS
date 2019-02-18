--INV Item costed checking
SELECT mmt.costed_flag,
mmt.pm_cost_collected,
       mmt.organization_id,
       msi.segment1,
       --mmt.,
       mmt.transaction_date,
       mmt.*
  FROM mtl_material_transactions mmt,
       mtl_system_items_b        msi
 WHERE 1 = 1
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
   AND trunc(mmt.transaction_date) = to_date('2019-01-31', 'yyyy-mm-dd')
   AND mmt.transaction_id >= 84331140--= 55055866 --8915869
       --IN (5097)
       --AND mmt.costed_flag = 'N'--'E'
       AND mmt.pm_cost_collected IS NOT NULL
--IN (55055866,55055888)
--AND msi.segment1 = 'R399J00076'
ORDER BY mmt.transaction_id DESC
;

--check the parameter (cutoff date) of inventory
SELECT mp.cost_cutoff_date,
       mp.*
  FROM mtl_parameters mp
 WHERE 1 = 1
--AND mp.organization_id = 83
;

--check the stuck data in mmt
SELECT mmt.organization_id, mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   AND mmt.costed_flag IN ('E','N')
   AND mmt.organization_id= 83;

--How to solve the stuck data

SELECT transaction_id,
       organization_id,
       layer_id,
       cost_element_id,
       level_type,
       transaction_action_id
  FROM mtl_cst_actual_cost_details hca
 WHERE 1 = 1
   AND hca.transaction_id = 5097;
