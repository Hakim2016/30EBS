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

-- operation 
INSERT INTO wip_job_dtls_interface
  (group_id,
   organization_id,
   operation_seq_num,
   department_id,
   load_type,
   substitution_type,
   process_phase,
   process_status,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by,
   parent_header_id /*,
   count_point_type,
   backflush_flag,
   first_unit_start_date,
   first_unit_completion_date,
   last_unit_start_date,
   last_unit_completion_date */)
VALUES
  (12345, --group id
   86, -- ORG ID
   10, --operation sequence number
   2, --department id (CAMASSY)  2 TNW2 8 MA1
   3, --load_type  --load_type 1. resource 2. component 3. operation 4. multiple resource usage
   3, --substitution_type --substitution_type 1.Delete, 2.Add 3.Change
   2, --process_phase
   1, -- process_status
   SYSDATE, --last update date
   2722, --last updated by
   SYSDATE, --creation date
   2722, --created by
   1318 --, --header id
   /*   1,
   1,
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS'),
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS'),
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS'),
   to_date('20-JUN-2015 14:18:00', 'DD-MON-YYYY HH24:MI:SS')*/
   
   );
