SELECT wdj.organization_id,
       we.wip_entity_name,
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
      --AND wdj.wip_entity_id = 1289126
      --AND wdj.creation_date >= to_date('20170601','yyyymmdd')
      --AND wdj.created_by = 4554--hand_ly
   AND wdj.task_id IS NOT NULL
   AND we.wip_entity_name = '10463050'--'10463049'
       --IN ('10753102', '10753103', '10753104', '10753105', '10753106', '10753107', '10753108', '10753110')

;

--wo, project, task
SELECT wdj.organization_id,
       we.wip_entity_name,
       ppa.segment1 prj_num,
       (SELECT ooh.order_number
          FROM oe_order_headers_all ooh
         WHERE 1 = 1
           AND ooh.header_id = ool.header_id),
       pt.task_number,
       wdj.status_type,
       ool.ordered_item,
       we.description,
       decode(we.organization_id, 86, 'FAC', 85, 'HO', we.organization_id) orga,
       we.primary_item_id,
       msi.segment1 assembly,
       msi.description assembly_desc,
       ppa.segment1 prj_num,
       ppa.project_type,
       pt.task_number,
       wdj.job_type,
       we.*,
       wdj.*,
       ool.*
  FROM wip_discrete_jobs  wdj,
       wip_entities       we,
       pa_projects_all    ppa,
       pa_tasks           pt,
       pa_tasks           top,
       mtl_system_items_b msi,
       oe_order_lines_all ool
 WHERE 1 = 1
   AND ool.project_id = ppa.project_id
   AND ool.task_id = pt.task_id
   AND ppa.project_id = pt.project_id
   AND pt.top_task_id = top.task_id
   AND ppa.project_id = wdj.project_id
   AND wdj.wip_entity_id = we.wip_entity_id
   AND pt.task_id = wdj.task_id
   AND msi.inventory_item_id = we.primary_item_id
   AND msi.organization_id = we.organization_id
      --AND wdj.wip_entity_id = 1289126
      --AND wdj.creation_date >= to_date('20170601','yyyymmdd')
      --AND wdj.created_by = 4554--hand_ly
   AND wdj.task_id IS NOT NULL
      --AND we.wip_entity_name = '10463049'
   AND ppa.project_type = 'SHE FAC_Assy Parts'
   AND wdj.status_type = 3 --released
--AND wdj.creation_date>=to_date('20180101','yyyymmdd')
--AND ppa.project_type = ''
;

SELECT wro.creation_date,
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
   AND wro.wip_entity_id = 1416845 --1289126
      --AND wro.inventory_item_id = 55986
   AND wro.organization_id = 86
 ORDER BY wro.concatenated_segments;

SELECT *
  FROM fnd_user fu
 WHERE 1 = 1
   AND fu.user_name = 'HAND_LY';
