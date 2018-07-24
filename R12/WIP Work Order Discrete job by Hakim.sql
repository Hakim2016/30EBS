SELECT we.wip_entity_name,
       we.description,
       decode(we.organization_id, 86, 'FAC', 85, 'HO', we.organization_id) orga,
       we.primary_item_id,
       --wdj.primary_item_id,
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = we.primary_item_id
           AND msi.organization_id = we.organization_id) assembly,
       (SELECT msi.description
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = we.primary_item_id
           AND msi.organization_id = we.organization_id) assembly_desc,
       --wdj.project_id,
       (SELECT ppa.segment1 prj_num
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = wdj.project_id) prj_num,
       (SELECT ppa.project_type
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = wdj.project_id) prj_type,
       --wdj.task_id,
       (SELECT pt.task_number
          FROM pa_tasks pt
         WHERE 1 = 1
           AND pt.task_id = wdj.task_id) task,
       wdj.job_type,
       we.*,
       wdj.*
  FROM wip_discrete_jobs wdj,
       wip_entities      we
 WHERE 1 = 1
   AND wdj.wip_entity_id = we.wip_entity_id
   AND wdj.wip_entity_id = 1289126;

SELECT
wro.creation_date,
--------Main--------
 wro.concatenated_segments item,
 wro.item_description,
 wro.operation_seq_num     seq,
 wro.department_code       dprtmt,
 wro.date_required,
 --------Qty
 wro.item_primary_uom_code uom,
 --wro.basis_type,
 wro.basis_type_meaning    basis_type,
 wro.quantity_per_assembly qty,
 --INVERSE_USAGE
 ------
 wro.wip_supply_meaning  wip_supply,
 wro.supply_subinventory,
 wro.supply_locator_id,
 wro.unit_price,
 wro.*
  FROM wip_requirement_operations_v wro
 WHERE 1 = 1
   AND wro.wip_entity_id = 1289126
--AND 
 ORDER BY wro.concatenated_segments;
