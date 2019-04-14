SELECT mmt.costed_flag, msi.segment1, mmt.*
  FROM mtl_material_transactions mmt, mtl_system_items_b msi
 WHERE 1 = 1
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
   AND mmt.transaction_id = 8915869;

SELECT src.user_defined_flag            src_usr,
       src.transaction_source_type_name trx_src,
       --src.description,
       mttc.user_defined_flag     typ_usr,
       mttc.transaction_type_name trx_typ,
       mttc.description,
       v.lookup_code act_id,
       v.meaning act_name,
       v.DESCRIPTION a
  FROM mtl_transaction_types mttc, mtl_txn_source_types src, mfg_lookups v

 WHERE 1 = 1
   AND mttc.transaction_source_type_id = src.transaction_source_type_id
   AND mttc.TRANSACTION_ACTION_ID = v.LOOKUP_CODE
   AND v.lookup_type = 'MTL_TRANSACTION_ACTION'

;
--1.mmt.transaction_type_id refer to mtl_transaction_types
SELECT 
mttc.TRANSACTION_TYPE_ID,
mttc.TRANSACTION_TYPE_NAME,
mttc.DESCRIPTION,

mttc.*
  FROM mtl_transaction_types mttc
 WHERE 1 = 1
      --AND mtt.transaction_type_id
   --AND upper(mttc.transaction_type_name) LIKE upper('%Account alias%')
 ORDER BY mttc.creation_date --mtt.transaction_type_id
;

--2.mmt.transaction_action_id refer to mfg_lookups.lookup_code 'MTL_TRANSACTION_ACTION'
SELECT *
  FROM mfg_lookups v
 WHERE lookup_type = 'MTL_TRANSACTION_ACTION'
 ORDER BY v.lookup_code;

--3.mmt.transaction_source_type_id refer to mtl_txn_source_types

SELECT * FROM mtl_txn_source_types;

--4.Account Alias meant for transaction type mmt.
SELECT t.disposition_id aa_id,
       t.description,
       t.segment1,
       --t.distribution_account,
       t.concatenated_segments1,
       substr(t.concatenated_segments1,
              instr(t.concatenated_segments1, '.', 1, 1) + 1,
              instr(t.concatenated_segments1, '.', 1, 2) -
              instr(t.concatenated_segments1, '.', 1, 1) - 1) dprt,
       substr(t.concatenated_segments2,
              instr(t.concatenated_segments2, '.', 1, 1) + 1,
              instr(t.concatenated_segments2, '.', 1, 2) -
              instr(t.concatenated_segments2, '.', 1, 1) - 1) dprt,
       substr(t.concatenated_segments1,
              instr(t.concatenated_segments1, '.', 1, 2) + 1,
              instr(t.concatenated_segments1, '.', 1, 3) -
              instr(t.concatenated_segments1, '.', 1, 2) - 1) acc,
       substr(t.concatenated_segments2,
              instr(t.concatenated_segments2, '.', 1, 2) + 1,
              instr(t.concatenated_segments2, '.', 1, 3) -
              instr(t.concatenated_segments2, '.', 1, 2) - 1) acc,
       substr(t.concatenated_segments1,
              instr(t.concatenated_segments1, '.', 1, 3) + 1,
              instr(t.concatenated_segments1, '.', 1, 4) -
              instr(t.concatenated_segments1, '.', 1, 3) - 1) subacc,
       substr(t.concatenated_segments2,
              instr(t.concatenated_segments2, '.', 1, 3) + 1,
              instr(t.concatenated_segments2, '.', 1, 4) -
              instr(t.concatenated_segments2, '.', 1, 3) - 1) subacc
  FROM (SELECT mgd.disposition_id,
               mgd.description,
               mgd.segment1,
               mgd.distribution_account,
               gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' ||
               gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' ||
               gcc.segment7 || '.' || gcc.segment8 || '.' || gcc.segment9 || '.' ||
               gcc.segment10 concatenated_segments1,
               xla_oa_functions_pkg.get_ccid_description( /*p_coa_id*/50388, /*p_ccid*/
                                                         gcc.code_combination_id) concatenated_segments2
        --,mgd.*
          FROM mtl_generic_dispositions mgd, gl_code_combinations gcc
         WHERE 1 = 1
           AND mgd.distribution_account = gcc.code_combination_id
           AND mgd.organization_id = 87) t
 WHERE 1 = 1
   AND t.disposition_id IN
       (SELECT mmt.transaction_source_id
          FROM mtl_material_transactions mmt
         WHERE mmt.transaction_type_id = 41
           AND mmt.organization_id = 87);
;
