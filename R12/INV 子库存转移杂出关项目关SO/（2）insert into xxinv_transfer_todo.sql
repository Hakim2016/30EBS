--backup data
CREATE TABLE xxinv.proj_transfer_todo_170713 AS
SELECT * FROM xxinv.xxinv_proj_transfer_todo;

--cleare data
TRUNCATE TABLE xxinv.xxinv_proj_transfer_todo;--备份之后清空表

DECLARE
  CURSOR cur_todo IS
    SELECT moqd.organization_id,
           moqd.inventory_item_id,
           msi.segment1 item_num,
           moqd.subinventory_code,
           pa.long_name,
           pt.task_id,
           pt.task_number,
           SUM(moqd.primary_transaction_quantity) quantity,
           moqd.locator_id,
           milk.concatenated_seg_values,
           milk1.concatenated_seg_values to_concatenated_seg_values,
           milk1.inventory_location_id to_locator_id
      FROM mtl_onhand_quantities_detail moqd,
           xxinv_item_locations_kfv     milk,
           mtl_system_items_b           msi,
           pa_tasks                     pt,
           pa_projects_all              pa,
           xxinv_item_locations_kfv     milk1
     WHERE 1 = 1
       AND moqd.task_id = pt.task_id
       AND pt.project_id = pa.project_id
       AND moqd.inventory_item_id = msi.inventory_item_id
       AND moqd.organization_id = msi.organization_id
       AND moqd.organization_id = milk.organization_id(+)
       AND moqd.locator_id = milk.inventory_location_id(+)
       AND moqd.organization_id IN (85, 86)
       AND moqd.subinventory_code = 'FPART'			--现有量子库存
          --AND pa.segment1 = '212110005'	
		  --AND pt.task_id = 						--task_id 要用.EQ的
       AND milk1.subinventory_code = 'FCS'			--转移到子库存FCS
       AND milk1.organization_id = 86
       AND milk1.segment1 = 'FCS'
       AND milk1.segment19 = pa.project_id
       AND milk1.segment20 = pt.task_id
     GROUP BY moqd.organization_id,
              moqd.inventory_item_id,
              msi.segment1,
              moqd.subinventory_code,
              pt.task_id,
              pt.task_number,
              pa.long_name,
              moqd.locator_id,
              milk.concatenated_seg_values,
              milk1.concatenated_seg_values,
              milk1.inventory_location_id
     ORDER BY 3,
              4,
              5,
              6;
  l_mfg_no VARCHAR2(240);
BEGIN
  --initinalize org
  fnd_profile.put('MFG_ORGANIZATION_ID', 86);
  FOR rec_todo IN cur_todo
  LOOP
    --get mfg no
    l_mfg_no := xxinv_common_utl.get_top_tasknum(rec_todo.task_id);
  
    INSERT INTO xxinv.xxinv_proj_transfer_todo--插入之前要清空
    VALUES
      (to_char(trunc(SYSDATE), 'YYYY-MM-DD'),
       'TH2',
       l_mfg_no,
       rec_todo.item_num,
       'FPART',									--FROM SUB
       rec_todo.concatenated_seg_values,
       'FCS',									--TO SUB
       rec_todo.to_concatenated_seg_values,
       rec_todo.quantity,
       rec_todo.organization_id,
       rec_todo.inventory_item_id,
       rec_todo.locator_id,
       rec_todo.to_locator_id,
       'P',--process_status
       NULL);
  END LOOP;
END;






