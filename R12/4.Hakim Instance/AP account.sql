---------------------------------------------
/*ALTER SESSION SET nls_language = american;*/
/*ALTER SESSION SET nls_language = 'SIMPLIFIED CHINESE';*/
--Conbine to one
SELECT t.seq,
       000 xxx,
       t.je_cate,
       (SELECT jc.user_je_category_name
          FROM gl_je_categories jc
         WHERE 1 = 1
           AND jc.je_category_name = t.je_cate --LIKE '%COGS%'
        --AND jc.user_je_category_name LIKE '%COGS%'
        ) u_je_cate,
       
       decode(t.je_cate,
              'Miscellaneous Transaction',
              (SELECT pei.expenditure_type
                 FROM pa_expenditure_items_all pei
                WHERE 1 = 1
                  AND pei.expenditure_item_id = t.source_id_int_1
               
               ),
              'WIP',
              (SELECT pei.expenditure_type
                 FROM pa_expenditure_items_all pei
                WHERE 1 = 1
                  AND pei.orig_transaction_reference = to_char(t.source_id_int_1)
                  AND pei.acct_burdened_cost = nvl(t.dr, t.cr)),
              t.je_cate) expen_type,
       decode(t.je_cate,
              'Miscellaneous Transaction',
              (SELECT pet.expenditure_category
                 FROM pa_expenditure_items_all pei,
                      pa_expenditure_types     pet
                WHERE 1 = 1
                  AND pet.expenditure_type = pei.expenditure_type
                  AND pei.expenditure_item_id = t.source_id_int_1
               
               ),
              'WIP',
              (SELECT pet.expenditure_category
                 FROM pa_expenditure_items_all pei,
                      pa_expenditure_types     pet
                WHERE 1 = 1
                  AND pet.expenditure_type = pei.expenditure_type
                  AND pei.orig_transaction_reference = to_char(t.source_id_int_1)
                  AND pei.acct_burdened_cost = nvl(t.dr, t.cr)),
              t.je_cate) expen_cate,
       t.accounting_date acc_date,
       --t.description,
       t.event_id,
       t.entity_id,
       t.transaction_number trx_num,
       t.source_id_int_1    src_id,
       t.event_class,
       t.event_type,
       t.entity_code,
       --t.source_id_int_1 src_id,
       --t.ledger_id,
       --xah.description,
       --xal.description,
       (SELECT meaning
          FROM xla_lookups xlk
         WHERE 1 = 1
           AND xlk.lookup_code = t.acct_class --'WIP_VALUATION'--xal.accounting_class_code
           AND xlk.lookup_type = 'XLA_ACCOUNTING_CLASS') accouting_class,
       --t.acct_class,
       t.flag,
       xxhkm_common_utl.get_acc_cate(t.chart_of_accounts_id /*50352*/, t.code_combination_id) acc_cate,
       substr(t.concatenated_segments,
              instr(t.concatenated_segments, '.', 1, 2) + 1,
              instr(t.concatenated_segments, '.', 1, 3) - instr(t.concatenated_segments, '.', 1, 2) - 1) acc,
       substr(t.account_desc,
              instr(t.account_desc, '.', 1, 2) + 1,
              instr(t.account_desc, '.', 1, 3) - instr(t.account_desc, '.', 1, 2) - 1) acc,
       substr(t.concatenated_segments,
              instr(t.concatenated_segments, '.', 1, 3) + 1,
              instr(t.concatenated_segments, '.', 1, 4) - instr(t.concatenated_segments, '.', 1, 3) - 1) subacc,
       substr(t.account_desc,
              instr(t.account_desc, '.', 1, 3) + 1,
              instr(t.account_desc, '.', 1, 4) - instr(t.account_desc, '.', 1, 3) - 1) subacc,
       substr(t.concatenated_segments,
              instr(t.concatenated_segments, '.', 1, 4) + 1,
              instr(t.concatenated_segments, '.', 1, 5) - instr(t.concatenated_segments, '.', 1, 4) - 1) seg3,
       substr(t.account_desc,
              instr(t.account_desc, '.', 1, 4) + 1,
              instr(t.account_desc, '.', 1, 5) - instr(t.account_desc, '.', 1, 4) - 1) seg3,
       --t.concatenated_segments,
       --t.account_desc,
       t.dr                       dr,
       t.cr                       cr,
       t.acct_rule,
       t.ae_line_num,
       t.ledger_id,
       t.concatenated_segments,
       NULL,
       NULL,
       t.account_desc,
       t.source_distribution_type,
       t.gl_transfer_status_code,
       t.gl_transfer_date
  FROM (
        
        ----30.AP invoice
        SELECT 3                           seq, --xdl.source_distribution_type,
                xah.je_category_name        je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name                   event_class,
                xet.name                    event_type,
                xah.product_rule_code       acct_rule,
                xah.gl_transfer_status_code,
                xah.gl_transfer_date,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id /*50352*/, xal.code_combination_id) account_desc, --账户说明, --账户说明
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xal.description,
                xte.entity_code,
                xte.entity_id,
                xte.transaction_number,
                xah.accounting_date,
                gcc.chart_of_accounts_id,
                xal.code_combination_id,
                NULL source_distribution_type --xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                --xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 200 --222--707
              --AND xte.source_id_int_1 = 54834283
           AND xte.transaction_number = 'HKMAP0001'--'34137970'--'HKM18060401'
              
              --AND xte.entity_code = 'MTL_ACCOUNTING_EVENTS'
              --improve efficient
              --AND xah.ae_header_id = xdl.ae_header_id
              --AND xal.ae_line_num = xdl.ae_line_num
              --AND xdl.application_id = xte.application_id
              ----
              --AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code
           AND xte.ledger_id = 1020--1--2021
           --AND xte.entity_id = 29936954
        
        ) t
 WHERE 1 = 1
   --AND t.seq NOT IN (4, 5, 6, 7, 13, 15)
--AND t.seq IN (3,8)
--AND t.seq = 7.5
 ORDER BY t.seq,
          t.event_id,
          t.flag DESC
--t.ae_line_num
;

SELECT * FROM gl_ledgers gl
WHERE 1=1
AND gl.name = 'HKM Ledger';

SELECT xte.transaction_number,
       xe.event_status_code,
       xe.process_status_code,
       xe.transaction_date,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla.xla_events               xe
 WHERE 1 = 1
      --AND xe.event_id
   AND xe.entity_id = xte.entity_id
   AND xte.ledger_id = 2021
   AND xte.source_id_int_1 = 54869415 --54897910 --54897273-- 54897907--15312121--54897273 --54896869--54868663
      --AND xte.transaction_number LIKE 'HKM18060401%'--54834283
   AND xte.application_id = 707 --275 --200--707
   AND xte.entity_id >= 29067072 --29960000
--AND xte.entity_code = 'RCV_ACCOUNTING_EVENTS'
;
