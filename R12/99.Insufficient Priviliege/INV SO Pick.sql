SELECT mmt.organization_id,
       msi.segment1,
       mtt.transaction_type_name,
       mmt.primary_quantity qty,
       inv_project.get_locator(mmt.locator_id, mmt.organization_id) locator, --
       mmt.costed_flag,
       mmt.pm_cost_collected prj_costed,
       mmt.source_code,
       mmt.project_id,
       mmt.task_id,
       mmt.*
  FROM mtl_material_transactions  mmt,
       mtl_system_items_b         msi,
       apps.mtl_transaction_types mtt
 WHERE 1 = 1
   AND mmt.transaction_type_id = mtt.transaction_type_id
   AND mtt.transaction_type_name IN ('Sales Order Pick')
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
      --AND mmt.transaction_id = 54868663--60911685--8915869
   AND mmt.last_update_date >= trunc(SYSDATE) - 365 --SYSDATE - 2
   AND mmt.organization_id = 86
      --AND mmt.created_by = 4270
      --AND mmt.organization_id = 83
      --AND msi.segment1 = '1000EX-EN'
      AND rownum = 1
   /*AND mmt.source_code --= 'DN In'
       IN ('DN In', 'DN Out')*/
 ORDER BY mmt.transaction_id;
