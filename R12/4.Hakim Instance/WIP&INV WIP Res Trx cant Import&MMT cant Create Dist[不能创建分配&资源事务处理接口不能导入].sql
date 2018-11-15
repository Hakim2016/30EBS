-- material transaction can't create distribution.
-- Pending WIP resource transaction can't be processed.
-- Error : CST_INVALID_WIP error The wip entity is either not defined or does not have a period balance entry
-- Once some error occur, cost manager can't process later transaction.
/*
 SYMPTOMS:
    Some WIP resource transaction stay in interface table wip_cost_txn_interface, they can't be processed.
    Some Material Transaction can't create distribution.
*/

-- Refer : 
-- CST_INVALID_WIP error The wip entity is either not defined or does not have a period balance entry (Doc ID 1531200.1)

/*
 Solution :
          Step 1 : process material transaction(statement one : clear error flag, cost manager processes again)
          Step 2 : if Step1 doesn't work, check work order WPB(statement two : if work order in Open Period)
          Step 3 : if WO isn't in Open Period, insert a open period into WPB(statement three) and execute step1 again
*/

-- Monitor
SELECT MAX(t.creation_date),
       MIN(t.creation_date),
       --MAX(t.transaction_date),MIN(t.transaction_date), 
       COUNT(1),
       decode(t.transaction_id, NULL, 'N', 'Y'),
       --trunc(t.transaction_date, 'MM'),
       t.source_code,
       t.process_phase,
       t.process_status,
       t.transaction_type,
       t.organization_id
  FROM wip_cost_txn_interface t
 GROUP BY decode(t.transaction_id, NULL, 'N', 'Y'),
          --trunc(t.transaction_date, 'MM'),
          t.source_code,
          t.process_phase,
          t.process_status,
          t.transaction_type,
          t.organization_id;

SELECT COUNT(1),
       costed_flag,
       MIN(creation_date),
       MAX(creation_date),
       MIN(last_update_date),
       MAX(last_update_date),
       organization_id
  FROM mtl_material_transactions
 WHERE 1 = 1
   AND transaction_id >= 21083132
 GROUP BY costed_flag,
          organization_id;

-- Statement One
CREATE TABLE xxinv.xxinv_mmt_bk20151126 AS
  SELECT mmt.*
    FROM mtl_material_transactions mmt
   WHERE 1 = 1
     AND mmt.costed_flag = 'E';

/*   
INSERT INTO xxinv.xxinv_mmt_bk20151126 
SELECT mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   AND mmt.costed_flag = 'E';
 */
SELECT *
  FROM xxinv.xxinv_mmt_bk20151126;

UPDATE mtl_material_transactions
   SET costed_flag          = 'N',
       ERROR_CODE           = NULL,
       error_explanation    = NULL,
       transaction_group_id = NULL,
       transaction_set_id   = NULL
 WHERE costed_flag = 'E'
   AND transaction_id IN (SELECT t.transaction_id
                            FROM xxinv.xxinv_mmt_bk20151126 t);

-- Statement Two
SELECT wpb.acct_period_id,
       wpb.wip_entity_id,
       oap.open_flag,
       oap.period_set_name,
       oap.period_year,
       oap.period_num,
       oap.period_name,
       oap.period_start_date,
       oap.period_close_date
  FROM wip_period_balances wpb,
       org_acct_periods    oap
 WHERE 1 = 1
   AND wpb.acct_period_id = oap.acct_period_id
   AND wpb.wip_entity_id = 1200048 -- wip_entity_id
 ORDER BY wpb.acct_period_id;

-- Statement Three

INSERT INTO wip_period_balances
  (acct_period_id,
   wip_entity_id,
   repetitive_schedule_id,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by,
   last_update_login,
   organization_id,
   class_type,
   tl_resource_in,
   tl_overhead_in,
   tl_outside_processing_in,
   pl_material_in,
   pl_material_overhead_in,
   pl_resource_in,
   pl_overhead_in,
   pl_outside_processing_in,
   tl_material_out,
   tl_material_overhead_out,
   tl_resource_out,
   tl_overhead_out,
   tl_outside_processing_out,
   pl_material_out,
   pl_material_overhead_out,
   pl_resource_out,
   pl_overhead_out,
   pl_outside_processing_out,
   pl_material_var,
   pl_material_overhead_var,
   pl_resource_var,
   pl_outside_processing_var,
   pl_overhead_var,
   tl_material_var,
   tl_material_overhead_var,
   tl_resource_var,
   tl_outside_processing_var,
   tl_overhead_var)
  SELECT oap.acct_period_id,
         wdj.wip_entity_id,
         NULL,
         SYSDATE,
         0,
         SYSDATE,
         0,
         0,
         wdj.organization_id,
         wac.class_type,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
    FROM wip_accounting_classes wac,
         org_acct_periods       oap,
         wip_discrete_jobs      wdj
   WHERE wdj.status_type IN (3, 4, 5, 6, 7, 14, 15)
     AND wdj.wip_entity_id = 1200048 -- wip_entity_id
     AND wac.class_code = wdj.class_code
     AND wdj.organization_id = wac.organization_id
     AND oap.organization_id = wdj.organization_id
     AND oap.open_flag = 'Y'
     AND oap.period_close_date IS NULL
     AND oap.schedule_close_date >= nvl(wdj.date_released, wdj.creation_date)
     AND wac.class_type != 2
     AND NOT EXISTS (SELECT 'X'
            FROM wip_period_balances wpb
           WHERE wpb.repetitive_schedule_id IS NULL
             AND wpb.wip_entity_id = wdj.wip_entity_id
             AND wpb.organization_id = wdj.organization_id
             AND wpb.acct_period_id = oap.acct_period_id);
