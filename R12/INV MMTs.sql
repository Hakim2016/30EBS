--before insert 
SELECT *
  FROM mtl_material_transactions_temp tmp
  WHERE 1=1
  AND tmp.organization_id = 83; --(MMTT)
SELECT *
  FROM mtl_transactions_interface tmp
  WHERE 1=1
  AND tmp.organization_id = 83; --(MTI)
SELECT *
  FROM wip_move_txn_interface tmp
  WHERE 1=1
  AND tmp.organization_id = 83; --(WMTI)
SELECT *
  FROM wip_cost_txn_interface tmp
  WHERE 1=1
  AND tmp.organization_id = 83; --(WCTI)
