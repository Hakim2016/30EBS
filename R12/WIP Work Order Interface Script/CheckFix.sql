-- data
SELECT *
  FROM xxwip.xxwip_wo_update_datafix t
   FOR UPDATE;
DELETE xxwip.xxwip_wo_update_datafix t;

-- interface
SELECT *
  FROM wip_job_schedule_interface t
 WHERE t.group_id IN (12345, 54321); -- 54321  12345

SELECT *
  FROM wip_job_dtls_interface t
 WHERE t.group_id IN (12345, 54321); -- 54321  12345

-- delete
DELETE FROM wip_job_schedule_interface t
 WHERE 1 = 1
   AND t.group_id IN (12345, 54321);
DELETE FROM wip_job_dtls_interface t
 WHERE 1 = 1
   AND t.group_id IN (12345, 54321);
DELETE FROM xxwip.xxwip_operations_bk150612 t;
DELETE FROM xxwip.xxwip_resources_bk150612 t;
-- backup
SELECT *
  FROM xxwip.xxwip_operations_bk150612 t;
SELECT *
  FROM xxwip.xxwip_resources_bk150612 t;

-- error 
SELECT *
  FROM wip_interface_errors wie
 WHERE 1 = 1
   AND wie.created_by = 2722
 ORDER BY wie.interface_id,
          wie.error_type;

-- result comfire
SELECT wor.organization_id,
       we.wip_entity_name,
       --wor.wip_entity_id,
       wor.operation_seq_num,
       bd.department_code,
       wo.count_point_type,
       wo.backflush_flag,
       wor.resource_seq_num,
       --wor.resource_id,
       --wo.department_id,
       br.resource_code,
       wor.basis_type,
       wor.usage_rate_or_amount,
       wor.scheduled_flag,
       --wor.autocharge_type,
       mfl.meaning autocharge
  FROM wip_operation_resources wor,
       wip_entities            we,
       wip_operations          wo,
       bom_departments         bd,
       bom_resources           br,
       mfg_lookups             mfl
 WHERE 1 = 1
   AND wor.resource_id = br.resource_id
   AND wor.wip_entity_id = wo.wip_entity_id
   AND wor.operation_seq_num = wo.operation_seq_num
   AND wo.department_id = bd.department_id
   AND wo.wip_entity_id = we.wip_entity_id
   AND mfl.lookup_type = 'BOM_AUTOCHARGE_TYPE'
   AND mfl.lookup_code = wor.autocharge_type
   AND we.wip_entity_name = '10171936'
   AND EXISTS (SELECT 1
          FROM xxwip.xxwip_wo_update_datafix t
         WHERE wor.wip_entity_id = t.wip_entity_id
           AND wor.operation_seq_num = t.operation_seq_num)
 ORDER BY wor.wip_entity_id,
          wor.operation_seq_num,
          wor.resource_seq_num;

-- invalid operation
SELECT we.organization_id,
       we.wip_entity_name,
       wo.operation_seq_num,
       bd.department_code,
       wo.count_point_type,
       wo.backflush_flag
  FROM wip_entities    we,
       wip_operations  wo,
       bom_departments bd
 WHERE 1 = 1
   AND wo.department_id = bd.department_id
   AND wo.wip_entity_id = we.wip_entity_id
   AND EXISTS (SELECT 1
          FROM xxwip.xxwip_wo_update_datafix t
         WHERE we.wip_entity_id = t.wip_entity_id)
   AND NOT EXISTS (SELECT 1
          FROM xxwip.xxwip_wo_update_datafix t
         WHERE we.wip_entity_id = t.wip_entity_id
           AND wo.operation_seq_num = t.operation_seq_num)
 ORDER BY wo.wip_entity_id,
          wo.operation_seq_num;

SELECT COUNT(1)
  FROM wip_operation_resources wor
 WHERE 1 = 1
   AND (wor.wip_entity_id, wor.operation_seq_num) IN
       (SELECT t.wip_entity_id,
               t.operation_seq_num
          FROM xxwip.xxwip_wo_update_datafix t);
