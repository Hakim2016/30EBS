SELECT mmt.costed_flag,
       msi.segment1,
       mmt.*
  FROM mtl_material_transactions mmt,
       mtl_system_items_b        msi
 WHERE 1 = 1
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
   AND mmt.transaction_id = 8915869;

SELECT src.user_defined_flag src_usr,
       src.transaction_source_type_name trx_src,
       --src.description,
       mttc.user_defined_flag typ_usr,
       mttc.transaction_type_name trx_typ,
       mttc.description
  FROM mtl_transaction_types mttc,
       mtl_txn_source_types  src
 WHERE 1 = 1
   AND mttc.transaction_source_type_id = src.transaction_source_type_id

;
--1.transaction_type_id refer to mtl_transaction_types
SELECT *
  FROM mtl_transaction_types mttc
 WHERE 1 = 1
      --AND mtt.transaction_type_id
   AND upper(mttc.transaction_type_name) LIKE upper('%issue%')
 ORDER BY mttc.creation_date --mtt.transaction_type_id
;

--2.transaction_action_id refer to lookup 'MTL_TRANSACTION_ACTION'
SELECT *
  FROM mfg_lookups v
 WHERE lookup_type = 'MTL_TRANSACTION_ACTION';

--3.transaction_source_type_id refer to mtl_txn_source_types

SELECT *
  FROM mtl_txn_source_types;
