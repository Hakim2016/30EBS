--refer to ORA-00001: unique constraint (INV.MTL_CST_ACTUAL_COST_DETAILS_U1) violated (Doc ID 290868.1)

--To implement the solution, please execute the following steps:

--A) 
--1.Check mtl_transaction_accounts table:
SELECT *
  FROM mtl_transaction_accounts
 WHERE transaction_id IN
       (SELECT transaction_id
          FROM mtl_material_transactions
         WHERE costed_flag = 'E'
           AND error_explanation LIKE '%unique constraint (INV.MTL_CST_ACTUAL_COST_DETAILS_U1)%');
--2.Check mtl_cst_actual_cost_details table:
SELECT *
  FROM mtl_cst_actual_cost_details
 WHERE transaction_id IN
       (SELECT transaction_id
          FROM mtl_material_transactions
         WHERE costed_flag = 'E'
           AND error_explanation LIKE '%unique constraint (INV.MTL_CST_ACTUAL_COST_DETAILS_U1)%');

--In case query 1 returns records means distributions are already created, then apply the below datafix:
CREATE TABLE xxhkm_mmt_bkp AS
  SELECT *
    FROM mtl_material_transactions
   WHERE transaction_id IN
         (SELECT transaction_id
            FROM mtl_transaction_accounts
           WHERE transaction_id IN
                 (SELECT transaction_id
                    FROM mtl_material_transactions
                   WHERE costed_flag = 'E'
                     AND error_explanation LIKE '%unique constraint (INV.MTL_CST_ACTUAL_COST_DETAILS_U1)%'));
                     
UPDATE mtl_material_transactions
   SET costed_flag = NULL, ERROR_CODE = NULL, error_explanation = NULL
 WHERE transaction_id IN (SELECT transaction_id
                            FROM xxhkm_mmt_bkp);
;
--commit;

--In case query 1 does not return any records, it means distributions are not created. If ONLY query 2 returns records, then apply the below datafix:

--Backup MTL_CST_ACTUAL_COST_DETAILS table:

CREATE TABLE xxhkm_mcacd_bkp AS
  SELECT *
    FROM mtl_cst_actual_cost_details
   WHERE transaction_id IN
         (SELECT transaction_id
            FROM mtl_material_transactions
           WHERE costed_flag = 'E'
             AND error_explanation LIKE '%unique constraint (INV.MTL_CST_ACTUAL_COST_DETAILS_U1)%');
--Delete the records from MTL_CST_ACTUAL_COST_DETAILS table:

DELETE FROM mtl_cst_actual_cost_details
 WHERE transaction_id IN (SELECT transaction_id
                            FROM xxhkm_mcacd_bkp);
--Commit;

--B) Resubmit the error rows in mtl_material_transactions. INV: Transactions: Material Transactions: query the erred rows: From the menu, Tools Select All: Tools Submit All
