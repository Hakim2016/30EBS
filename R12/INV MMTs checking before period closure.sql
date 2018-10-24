--before insert 
SELECT *
  FROM mtl_material_transactions_temp tmp
 WHERE 1 = 1
   AND tmp.creation_date >= SYSDATE - 60
   AND tmp.organization_id = 83; --(MMTT)
SELECT *
  FROM mtl_transactions_interface tmp
 WHERE 1 = 1
   AND tmp.creation_date >= SYSDATE - 60
   AND tmp.organization_id = 83; --(MTI)
SELECT *
  FROM wip_move_txn_interface_v tmp
 WHERE 1 = 1
   AND tmp.creation_date >= SYSDATE - 60
   AND tmp.organization_id = 83; --(WMTI)
SELECT *
  FROM wip_cost_txn_interface_v tmp
 WHERE 1 = 1
   AND tmp.creation_date >= SYSDATE - 60
   AND tmp.organization_id = 83; --(WCTI)

-----MTL_TRANSACTIONS_INTERFACE_V
SELECT *
  FROM mtl_transactions_interface_v mti
 WHERE 1 = 1
   AND mti.organization_id = 83
   AND mti.creation_date >= SYSDATE - 36;
