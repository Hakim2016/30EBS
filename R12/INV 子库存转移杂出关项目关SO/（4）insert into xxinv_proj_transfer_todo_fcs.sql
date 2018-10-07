--insert into xxinv_proj_transfer_todo_fcs

--backup data
CREATE TABLE xxinv.proj_transfer_todo_fcs_170713 AS
SELECT * FROM xxinv.xxinv_proj_transfer_todo_fcs;

--cleare data
TRUNCATE TABLE xxinv.xxinv_proj_transfer_todo_fcs;


DECLARE
  CURSOR cur_todo IS
    SELECT moqd.organization_id,
           moqd.inventory_item_id,
           msi.segment1 item_num,
           moqd.subinventory_code,
           moqd.transaction_uom_code,
           pa.long_name,
           pt.task_number,
           SUM(moqd.primary_transaction_quantity) quantity,
           moqd.locator_id,
           moqd.task_id,
           pa.project_id,
           inv_project.get_locator(milk.inventory_location_id, milk.organization_id) concatenated_seg_values
      FROM mtl_onhand_quantities_detail moqd,
           xxom_wf_projects_all         t,--WORD文档里流程第一步会清空的表
           mtl_item_locations_kfv       milk,
           mtl_system_items_b           msi,
           pa_tasks                     pt,
           pa_projects_all              pa
     WHERE 1 = 1
       AND moqd.task_id = pt.task_id
       AND pt.project_id = pa.project_id
       AND pt.task_id = t.task_id
       AND pt.project_id = t.project_id
       AND moqd.inventory_item_id = msi.inventory_item_id
       AND moqd.organization_id = msi.organization_id
       AND moqd.organization_id = milk.organization_id(+)
       AND moqd.locator_id = milk.inventory_location_id(+)
       AND moqd.organization_id IN (85, 86)
       AND moqd.subinventory_code = 'FCS'
    --AND pa.segment1 = '212110005'
     GROUP BY moqd.organization_id,
              moqd.inventory_item_id,
              msi.segment1,
              moqd.subinventory_code,
              moqd.transaction_uom_code,
              pa.long_name,
              pt.task_number,
              moqd.locator_id,
              moqd.task_id,
              pa.project_id,
              inv_project.get_locator(milk.inventory_location_id, milk.organization_id);

BEGIN
  --initinalize org
  fnd_profile.put('MFG_ORGANIZATION_ID', 86);
  FOR rec_todo IN cur_todo
  LOOP
  
    INSERT INTO xxinv.xxinv_proj_transfer_todo_fcs--插入前要备份后清空数据
    VALUES
      (rec_todo.organization_id,
       rec_todo.inventory_item_id,
       rec_todo.item_num,
       rec_todo.transaction_uom_code,
       rec_todo.subinventory_code,
       rec_todo.long_name,
       rec_todo.task_number,
       rec_todo.task_id,
       rec_todo.project_id,
       rec_todo.quantity,
       rec_todo.locator_id,
       rec_todo.concatenated_seg_values,
       'P',
       NULL);
  END LOOP;
END;

SELECT *
  FROM xxinv.xxinv_proj_transfer_todo_fcs;
