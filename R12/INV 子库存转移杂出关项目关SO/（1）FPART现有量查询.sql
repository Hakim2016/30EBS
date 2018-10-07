/*
BEGIN
  fnd_profile.put('MFG_ORGANIZATION_ID', 86);
END;
*/
SELECT moqd.organization_id,
       moqd.inventory_item_id,
       msi.segment1 item_num,
       moqd.subinventory_code,
       pa.long_name,
       pt.task_number,
       SUM(moqd.primary_transaction_quantity),
       moqd.locator_id,
       inv_project.get_locator(milk.inventory_location_id, milk.organization_id) concatenated_seg_values,
       inv_project.get_locator(milk1.inventory_location_id, milk1.organization_id) to_concatenated_seg_values,
       milk1.inventory_location_id to_locator_id
  FROM mtl_onhand_quantities_detail moqd,
       xxom_wf_projects_all         t,--流程第一步会清空的表
       mtl_item_locations_kfv       milk,
       mtl_system_items_b           msi,
       pa_tasks                     pt,
       pa_projects_all              pa,
       mtl_item_locations_kfv       milk1
 WHERE 1 = 1
   AND moqd.task_id = t.task_id
   AND t.task_id = pt.task_id
   AND pt.project_id = pa.project_id
   AND moqd.inventory_item_id = msi.inventory_item_id
   AND moqd.organization_id = msi.organization_id
   AND moqd.organization_id = milk.organization_id(+)
   AND moqd.locator_id = milk.inventory_location_id(+)
   AND moqd.organization_id = 86
   AND moqd.subinventory_code = 'FPART'
      --AND pa.segment1 = '212110005'
   AND milk1.subinventory_code = 'FCS'
   AND milk1.organization_id = 86
   AND milk1.segment1 = 'FCS'
   AND milk1.segment19 = pa.project_id
   AND milk1.segment20 = pt.task_id
 GROUP BY moqd.organization_id,
          moqd.inventory_item_id,
          msi.segment1,
          moqd.subinventory_code,
          pt.task_number,
          pa.long_name,
          moqd.locator_id,
          inv_project.get_locator(milk.inventory_location_id, milk.organization_id),
          inv_project.get_locator(milk1.inventory_location_id, milk1.organization_id),
          milk1.inventory_location_id
 ORDER BY 3,
          4,
          5,
          6;
