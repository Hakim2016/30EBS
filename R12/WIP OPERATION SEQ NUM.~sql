select we.wip_entity_name,
       msib.segment1         assembly_item,
       wro.operation_seq_num,
       msib1.segment1        component_item
  from wip_requirement_operations wro,
       wip_entities               we,
       wip_discrete_jobs          wdj,
       mtl_system_items_b         msib,
       mtl_system_items_b         msib1
 where not exists (select 1
          from wip_operations wo
         where wro.wip_entity_id = wo.wip_entity_id
           and wro.operation_seq_num = wo.operation_seq_num
           and wro.organization_id = wo.organization_id)
   and wro.wip_entity_id = we.wip_entity_id
   and wro.organization_id = we.organization_id
   and wro.wip_entity_id = wdj.wip_entity_id
   and wro.organization_id = wdj.organization_id
   and wdj.primary_item_id = msib.inventory_item_id
   and wdj.organization_id = msib.organization_id
   and wro.inventory_item_id = msib1.inventory_item_id
   and wro.organization_id = msib1.organization_id
   and wro.operation_seq_num > 0
   and wro.operation_seq_num <> 1;
