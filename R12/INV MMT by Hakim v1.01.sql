SELECT msi.segment1,
       mmt.costed_flag,
       mmt.pm_cost_collected,
       mmt.source_code,
       mmt.*
  FROM mtl_material_transactions mmt,
       mtl_system_items_b        msi
 WHERE 1 = 1
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
   AND mmt.transaction_id = 54868663--60911685--8915869
   AND mmt.creation_date > SYSDATE - 2
   --AND mmt.organization_id = 83
   --AND msi.segment1 = '1000EX-EN'
   ;

--1.transaction_type_id refer to mtl_transaction_types
SELECT *
  FROM mtl_transaction_types mtt
 WHERE 1 = 1
--AND mtt.transaction_type_id
 ORDER BY mtt.creation_date --mtt.transaction_type_id
;

--2.transaction_action_id refer to lookup 'MTL_TRANSACTION_ACTION'
SELECT *
  FROM mfg_lookups v
 WHERE v.lookup_type = 'MTL_TRANSACTION_ACTION'
 ORDER BY v.lookup_code;

--3.transaction_source_id refer to 
SELECT *
  FROM wip_discrete_jobs wdj;

--4.transaction_source_type_id refer to mtl_txn_source_types
SELECT mts.transaction_source_type_id   trx_src_id,
       mts.transaction_source_type_name trx_src,
       --mts.transaction_source_category trx_cate,
       mts.description des,
       mts.*
  FROM mtl_txn_source_types mts;

--xla
SELECT xte.source_id_int_1,
       xte.*
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
      --AND xte.source_id_int_1 = 43901381
   AND xte.application_id = 707
   AND xte.security_id_int_1 = 83
   AND xte.creation_date > SYSDATE - 2;

SELECT xte.source_id_int_1,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xte.entity_id(+) = xah.entity_id
   AND xte.application_id(+) = xah.application_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xte.source_id_int_1 = 43901381
   AND xte.application_id = 707
   AND xte.security_id_int_1 = 83
   AND xte.creation_date > SYSDATE - 2;
