-- cst_period_close_summary : 
-- 库存期间关闭后，存储物料期间汇总值
-- Concurrent Program : Period Close Reconciliation Report
/*
 This concurrent program and report is used to create summarized transaction records, 
 the final step in closing your accounting period. It displays the differences between 
 accounted value and inventory in the Discrepancy column. The inventory value is used as 
 the baseline for calculation for the next period summarization values.
*/

SELECT oap.status,
       oap.period_name,
       oap.start_date,
       oap.end_date,
       oap.organization_id,
       cpcs.inventory_item_id,
       cpcs.subinventory_code,
       cpcs.cost_group_id,
       cpcs.rollback_quantity,
       (SELECT SUM(mmt.primary_quantity)
          FROM mtl_material_transactions mmt
         WHERE 1 = 1
           AND mmt.organization_id = cpcs.organization_id
           AND mmt.inventory_item_id = cpcs.inventory_item_id
           AND mmt.subinventory_code = cpcs.subinventory_code
           AND mmt.cost_group_id = cpcs.cost_group_id
           AND mmt.transaction_date < oap.end_date + 1),
       cpcs.rollback_value,
       cpcs.cumulative_onhand_mta,
       (SELECT SUM(mta.base_transaction_value)
          FROM mtl_material_transactions mmt,
               mtl_transaction_accounts  mta
         WHERE 1 = 1
           AND (mmt.transaction_id = mta.transaction_id OR mmt.transfer_transaction_id = mta.transaction_id)
           AND mta.accounting_line_type = '1'
           AND sign(mmt.primary_quantity) = sign(mta.primary_quantity)
           AND mmt.organization_id = cpcs.organization_id
           AND mmt.inventory_item_id = cpcs.inventory_item_id
           AND mmt.subinventory_code = cpcs.subinventory_code
           AND mmt.cost_group_id = cpcs.cost_group_id
           AND mmt.transaction_date < oap.end_date + 1),
       cpcs.*
  FROM cst_period_close_summary cpcs,
       org_acct_periods_v       oap
 WHERE 1 = 1
   AND cpcs.acct_period_id = oap.acct_period_id
      -- AND oap.start_date > SYSDATE - 200
      -- AND oap.period_name = 'APR-14'
   AND cpcs.cost_group_id = 1001
   AND cpcs.organization_id = 83
   AND cpcs.subinventory_code = 'RM'
   AND cpcs.inventory_item_id = 7345
-- AND oap.period_name = 'SEP-14'
--AND rownum = 1

 ORDER BY oap.start_date
