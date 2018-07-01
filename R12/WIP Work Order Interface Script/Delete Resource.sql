INSERT INTO wip_job_schedule_interface
  (last_update_date,
   last_updated_by,
   creation_date,
   created_by,
   last_update_login,
   group_id,
   organization_id,
   load_type,
   wip_entity_id,
   process_phase,
   process_status,
   header_id,
   allow_explosion,
   /*net_quantity,
   start_quantity,
   primary_item_id,
   completion_subinventory,
   class_code,*/
   first_unit_start_date,
   first_unit_completion_date,
   scheduling_method,
   last_unit_start_date,
   last_unit_completion_date /*,
                     status_type*/)
VALUES
  (SYSDATE, -- LAST UPDATE DATE
   2722, -- LAST UPDATED BY
   SYSDATE, -- CREATION DATE
   2722, -- CREATED BY
   2722, -- LAST UPDATE LOGIN
   12345, -- GROUP ID
   86, -- ORG ID
   3, --3. update standard or non standard job
   1025756, -- WIP ENTITY ID
   2, --2. validation, 3. EXPLOSION, 4. COMPLETION, 5. CREATION
   1, --1. pending 2. running, 3. error 4. complete 5. warning
   1318, --HEADER ID
   'N', --ALLOW EXPLOSION
   --1, --NET QUANTITY
   -- 1, --START QUANTITY
   --1004103, --PRIMARY ITEM ID
   --NULL, --'FGI', -- COMPLETION SUB INVENTORY
   -- 'COMM_STD', --CLASS CODE
   -- 'TESTKKWML4', -- DISCRETE JOB NAME
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS'), -- FIRST UNIT START DATE
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS') + 1, -- FIRST UNIT COMPLETION DATE
   3, --scheduling method 1- Routing based; 2- Lead Time; 3- Manual
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS'), --last unit start date
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS') + 2 --last unit completion date
   -- 1 --STATUS_TYPE
   );

-- resource 
INSERT INTO wip_job_dtls_interface
  (group_id,
   organization_id,
   operation_seq_num,
   resource_seq_num,
   resource_id_old,
   /*RESOURCE_ID_NEW,
   USAGE_RATE_OR_AMOUNT,
   scheduled_flag,
   ASSIGNED_UNITS,
   basis_type,
   autocharge_type,
   standard_rate_flag,
   start_date,
   completion_date,*/
   load_type,
   substitution_type,
   process_phase,
   process_status,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by,
   parent_header_id)
VALUES
  (12345, --group id
   86, -- org id
   20, --operation sequnece number
   10, --RESOURCE_SEQ_NUM
   16, --resource_id_old
   --21, --resource id new(CT)  TNW2 10  PLN 21
   --10.5, -- usage rate
   --2, --SCHEDULE FLAG
   --1, --ASSIGNED_UNITS
   --1, --BASIS_TYPE
   --2, --AUTOCHARGE_TYPE
   --2, --STANDARD_RATE_FLAG
   -- SYSDATE, --START_DATE
   --SYSDATE, --COMPLETION_DATE
   1, --load_type 1. resource 2. component 3. operation 4. multiple resource usage
   1, --substitution_type  1.Delete, 2.Add 3.Change
   2, --process_phase
   1, -- process_status
   SYSDATE, --last update date
   1318, --last updated by
   SYSDATE, -- creation date
   1318, --created by
   1318 --parent header id
   );
