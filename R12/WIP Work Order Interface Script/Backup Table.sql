CREATE TABLE XXWIP.XXWIP_OPERATIONS_BK150612 AS
SELECT *
  FROM wip_operations wo
 WHERE 1 = 1
   AND ROWNUM <1;
/*   AND wo.wip_entity_id IN (SELECT t.wip_entity_id
                              FROM xxwip.xxwip_wo_update_datafix t);*/

CREATE TABLE XXWIP.XXWIP_RESOURCES_BK150612 AS
SELECT *
  FROM wip_operation_resources wor
 WHERE 1 = 1
   AND rownum < 1;
/*   AND (wor.wip_entity_id, wor.operation_seq_num) IN
       (SELECT t.wip_entity_id,
               t.operation_seq_num
          FROM xxwip.xxwip_wo_update_datafix t);*/
