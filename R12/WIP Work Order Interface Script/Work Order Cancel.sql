/*In this scenario I am planning to cancel an existing job. Hence I choose the load type as 3 and
STATUS_TYPE as 7 in WIP_JOB_SCHEDULE_INTERFACE which mean we are updating the existing discrete job
with job status as cancelled.
*/

--create table 

/*create table xxwip.xxwip_discrete_jobs  
(wip_entity_id number, 
organization_id number,
wip_entity_name varchar2(240))*/


select * from xxwip.xxwip_discrete_jobs for update ;


DECLARE

  l_user_id NUMBER := 4088;
  l_group_id NUMBER := 4088;
BEGIN
  FOR rec IN (SELECT * FROM xxwip.xxwip_discrete_jobs) LOOP
    INSERT INTO WIP_JOB_SCHEDULE_INTERFACE
      (last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       Last_update_login,
       group_id,
       organization_id,
       load_type,
       wip_entity_id,
       process_phase,
       process_status,
       --header_id,
       -- allow_explosion,
       --net_quantity,
       --start_quantity,
       --primary_item_id,
       --COMPLETION_SUBINVENTORY,
       --CLASS_CODE,
       --JOB_NAME,
       --first_unit_start_date,
       --FIRST_UNIT_COMPLETION_DATE,
       -- scheduling_method,
       --last_unit_start_date,
       -- LAST_UNIT_COMPLETION_DATE,
       STATUS_TYPE)
    VALUES
      (SYSDATE, -- LAST UPDATE DATE
       l_user_id, -- LAST UPDATED BY
       SYSDATE, -- CREATION DATE
       l_user_id, -- CREATED BY
       l_user_id, -- LAST UPDATE LOGIN
       l_group_id, -- GROUP ID
       rec.organization_id, -- ORG ID
       3, --1. create standard DJ, 2.creative pending repetitive schedule, 3. update standard or non standard job,
       --4. create non standard job
       rec.wip_entity_id, -- WIP ENTITY ID
       2, --2. validation, 3. EXPLOSION, 4. COMPLETION, 5. CREATION
       1 --1. pending 2. running, 3. error 4. complete 5. warning
       --,4088 --HEADER ID
       /*    ,
        'N' --ALLOW EXPLOSION
       ,
        1 --NET QUANTITY
       ,
        1 --START QUANTITY
       ,
        323963 --PRIMARY ITEM ID
       ,
        'FGI' -- COMPLETION SUB INVENTORY
       ,
        'Discrete' --CLASS CODE
       ,
        'TESTKKWML4' -- DISCRETE JOB NAME
       ,
        SYSDATE -- FIRST UNIT START DATE
       ,
        SYSDATE + 1 -- FIRST UNIT COMPLETION DATE
       ,
        3 --scheduling method 1- Routing based; 2- Lead Time; 3- Manual
       ,
        SYSDATE --last unit start date
       ,
        SYSDATE + 1 --last unit completion date*/,
       7 --STATUS_TYPE
       );
  END LOOP;
END;

DECLARE
  l_trx_request_id NUMBER;
  l_wait_req       BOOLEAN;
  l_child_phase    VARCHAR2(80);
  l_child_status   VARCHAR2(80);
  l_dev_phase      VARCHAR2(80);
  l_dev_status     VARCHAR2(80);
  l_message        VARCHAR2(2000);
  x_request_id     NUMBER;
BEGIN

  fnd_global.APPS_INITIALIZE(user_id      => 4088,
                             resp_id      => 50778,
                             resp_appl_id => 20005);

  x_request_id := fnd_request.submit_request('WIP',
                                             'WICMLP',
                                             NULL,
                                             NULL,
                                             FALSE,
                                             to_char(4088), /* grp id*/
                                             to_char(wip_constants.full), /*validation lvl*/
                                             to_char(wip_constants.yes)); /* print report */

  -- Commit the insert
  COMMIT;
  dbms_output.put_line('---------------- ----------------' || x_request_id);
  IF x_request_id > 0 THEN
    l_wait_req := fnd_concurrent.wait_for_request(request_id => x_request_id,
                                                  INTERVAL   => 1,
                                                  max_wait   => 0,
                                                  phase      => l_child_phase,
                                                  status     => l_child_status,
                                                  dev_phase  => l_dev_phase,
                                                  dev_status => l_dev_status,
                                                  message    => l_message);
    dbms_output.put_line('---------------- ----------------');
    dbms_output.put_line('  x_request_id   : ' || x_request_id);
    dbms_output.put_line('  phase          : ' || l_child_phase);
    dbms_output.put_line('  status         : ' || l_child_status);
    dbms_output.put_line('  dev_phase      : ' || l_dev_phase);
    dbms_output.put_line('  dev_status     : ' || l_dev_status);
    dbms_output.put_line('  message        : ' || l_message);
    dbms_output.put_line('---------------- ----------------');
  END IF;
END proc_submit_req;
