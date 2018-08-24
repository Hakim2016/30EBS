/*
example 9 as template
*/
/*
--Conbine to one
SELECT t.seq,
       t.entity_code,
       t.source_id_int_1 src_id,
       --t.ledger_id,
       --xah.description,
       --xal.description,
       t.flag,
       t.concatenated_segments,
       t.dr                    dr,
       t.cr                    cr,
       t.event_type_code,
       t.je_category_name,
       t.product_rule_code,
       t.accounting_class_code,
       t.ae_line_num
  FROM (
        --1.Receving
        SELECT '1' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                               xah.*,
                                                                                                                                                                                                                                                                               xal.*,
                                                                                                                                                                                                                                                                               xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707
           AND xte.source_id_int_1 IN (54834283, 4654211, 4654212, 4654212)
        
        UNION ALL
        --2.Inventory
        SELECT '2' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                               xah.*,
                                                                                                                                                                                                                                                                               xal.*,
                                                                                                                                                                                                                                                                               xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 200 --SQLAP
           AND xte.source_id_int_1 IN (1952273) --AP invoice
        
        UNION ALL
        SELECT '3' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                               xah.*,
                                                                                                                                                                                                                                                                               xal.*,
                                                                                                                                                                                                                                                                               xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15312121
        
        UNION ALL
        
        --4.Move order
        SELECT '4' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       xah.*,
                                                                                                                                                                                                                                                                       xal.*,
                                                                                                                                                                                                                                                                       xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707 --CST
           AND xte.source_id_int_1 = 60911685
        
        UNION ALL
        
        --5.Import from IF36 Labor hour
        SELECT '5' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       xah.*,
                                                                                                                                                                                                                                                                       xal.*,
                                                                                                                                                                                                                                                                       xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15312122 --Expenditure
        UNION ALL
        
        --6.Import from WEBADI
        SELECT '6' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       xah.*,
                                                                                                                                                                                                                                                                       xal.*,
                                                                                                                                                                                                                                                                       xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15313134 --Expenditure
        
        UNION ALL
        
        --7.Import from AP Expense
        SELECT '7' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       xah.*,
                                                                                                                                                                                                                                                                       xal.*,
                                                                                                                                                                                                                                                                       xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15313137 --Expenditure from expense ap
        UNION ALL
        
        --8.wip transation(issue resource)
        SELECT '8' seq,
                xe.event_id,
                xe.event_status_code,
                xe.process_status_code,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xah.event_type_code,
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code \*,
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                       xah.*,
                                                                                                                                                                                                                                                                       xal.*,
                                                                                                                                                                                                                                                                       xte.**\
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707
           AND xte.source_id_int_1 = 20771589 --wip transaction
        ) t
 ORDER BY t.seq,
          t.source_id_int_1,
          t.flag DESC,
          t.ae_line_num;

--event class//event type
SELECT *
  FROM xla_event_classes_tl xect,
       xla_event_types_tl   xet
 WHERE 1 = 1
   AND xet.language = userenv('LANG')
   AND xect.application_id = 707 --xe.application_id
   AND xect.entity_code = xet.entity_code
   AND xect.event_class_code = xet.event_class_code
   AND xect.language = userenv('LANG')
   AND xet.event_type_code = 'WIP_COMP_ISSUE';

--accounting class
SELECT *
  FROM xla_lookups xlk
 WHERE 1 = 1
      --AND xlk.lookup_code = 'WIP_VALUATION'--xal.accounting_class_code
   AND xlk.lookup_type = 'XLA_ACCOUNTING_CLASS';

--9.WIP issue(issue material)
SELECT '9' seq,
       xah.je_category_name je_cate, --Subledger Journal Entry
       xe.event_id,
       xect.name event_class,
       xet.name event_type,
       xe.event_type_code event_type,
       \*
       WIP_COMP_ISSUE:WIP Component Issue
       CG_TXFR:Cost Group Transfer
       *\
       --xe.event_status_code,
       --xe.process_status_code,
       --xah.event_type_code   event_type,
       xah.product_rule_code acct_rule,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       xal.accounting_class_code acct_class,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xla_oa_functions_pkg.get_ccid_description( \*xgl.chart_of_accounts_id*\ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xal.ae_line_num,
       xte.entity_code \*,
                                                                                                                                                                               
                                                                                                                                                                               
                                                                                                                                                                               xah.*,
                                                                                                                                                                               xal.*,
                                                                                                                                                                               xte.**\
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       gl_code_combinations_kfv     gcc,
       --event class/event type
       xla_event_classes_tl xect,
       xla_event_types_tl   xet

 WHERE 1 = 1
   AND xah.ae_header_id = xal.ae_header_id
   AND gcc.code_combination_id = xal.code_combination_id
   AND xe.entity_id = xte.entity_id
   AND xe.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 707
   AND xte.source_id_int_1 = 54869415 --material transaction
   AND xte.entity_code = 'MTL_ACCOUNTING_EVENTS'
      --event class/ event type
   AND xet.language = userenv('LANG')
   AND xect.application_id = xe.application_id --707
   AND xect.entity_code = xet.entity_code
   AND xect.event_class_code = xet.event_class_code
   AND xect.language = userenv('LANG')
   AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'

----
 ORDER BY xe.event_id,
          xal.accounted_dr

;

SELECT *
  FROM xla_gl_ledgers_v xgl; --chart_of_accounts_id--50352 SHE

SELECT
\*
xal.accounted_dr    dr,
xal.accounted_cr    cr,*\
 xte.entity_id,
 xte.entity_code,
 xte.source_id_int_1,
 xte.*
  FROM xla.xla_transaction_entities xte \*,
       xla_ae_headers               xah,
       xla_ae_lines                 xal*\
 WHERE 1 = 1
      \*AND xah.ae_header_id = xal.ae_header_id
      AND xah.entity_id = xte.entity_id*\
   AND xte.entity_code = 'MTL_ACCOUNTING_EVENTS'
   AND xte.application_id = 707
   AND xte.ledger_id = 2023
      --AND xte.source_id_int
   AND xte.creation_date >= to_date('20180713', 'yyyymmdd')
   AND xte.source_id_int_1 = 20771589 --54869407 --mmt mtl_material_transactions
;

SELECT xe.event_id,
       xe.event_type_code,
       (SELECT xl.meaning
          FROM xla_lookups xl
         WHERE 1 = 1
           AND xl.lookup_type = 'XLA_ACCOUNTING_CLASS'
           AND xl.lookup_code = xal.accounting_class_code),
       xal.accounting_class_code,
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       \*xe.event_status_code,
       xe.process_status_code,*\
       xte.entity_id,
       xte.entity_code,
       xte.source_id_int_1,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xte.entity_id = xe.entity_id
   AND xe.application_id = xte.application_id
   AND xte.application_id = xah.application_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.entity_id = xte.entity_id
   AND xte.entity_code = 'WIP_ACCOUNTING_EVENTS' --'MTL_ACCOUNTING_EVENTS'
   AND xte.application_id = 707
   AND xte.ledger_id = 2023
   AND xte.source_id_int_1 = 20771589 --wip transaction
--AND xte.creation_date >= to_date('20180720', 'yyyymmdd')
--AND xte.source_id_int_1 = 54869407--mmt mtl_material_transactions
;
SELECT a.event_id,
       b.event_type_code
  FROM xla_events                   a,
       xla_event_types_b            b,
       xla_transaction_entities_upg c
 WHERE 1 = 1
   AND a.event_date <= SYSDATE
   AND a.event_date >= to_date('20180720', 'yyyymmdd')
   AND a.application_id = 707
   AND a.event_status_code = 'U'
   AND a.process_status_code = 'U'
   AND b.application_id = 707
   AND b.entity_code IN ('MTL_ACCOUNTING_EVENTS', 'WIP_ACCOUNTING_EVENTS')
   AND b.event_type_code = a.event_type_code
   AND c.application_id = 707
   AND c.entity_id = a.entity_id
   AND ((b.entity_code = 'MTL_ACCOUNTING_EVENTS' AND NOT EXISTS
        (SELECT NULL
            FROM mtl_transaction_accounts
           WHERE transaction_id = c.source_id_int_1)) OR
       (b.entity_code = 'WIP_ACCOUNTING_EVENTS' AND NOT EXISTS
        (SELECT NULL
            FROM wip_transaction_accounts
           WHERE transaction_id = c.source_id_int_1)));

SELECT *
  FROM xla_ae_headers xah,
       xla_ae_lines   xal
 WHERE 1 = 1
   AND xah.ae_header_id = xal.ae_header_id
      --AND xah.application_id = 401--707
   AND xah.entity_id IN (29944967, 29944968);

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id = 401;
--1.Move order
SELECT '3' seq,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xah.event_type_code,
       xah.je_category_name,
       xah.product_rule_code,
       xal.accounting_class_code,
       xal.ae_line_num,
       xte.entity_code \*,
       
       
       xah.*,
       xal.*,
       xte.**\
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       gl_code_combinations_kfv     gcc
 WHERE 1 = 1
   AND gcc.code_combination_id = xal.code_combination_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 707 --CST
   AND xte.source_id_int_1 = 20771589 --60911685
;

--2.Import from IF36 Labor hour
SELECT '3' seq,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xah.event_type_code,
       xt.event_type_code,
       xah.je_category_name,
       xah.product_rule_code,
       xal.accounting_class_code,
       xal.ae_line_num,
       xte.entity_code \*,
       
       
       xah.*,
       xal.*,
       xte.**\
  FROM xla.xla_transaction_entities xte,
       xla_events                   xt,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       gl_code_combinations_kfv     gcc
 WHERE 1 = 1
   AND xt.entity_id = xte.entity_id
   AND xt.event_id = xah.event_id
   AND xt.application_id = xte.application_id
   AND gcc.code_combination_id = xal.code_combination_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 275
   AND xte.source_id_int_1 = 15312122;

--6.Import from WEBADI
SELECT '6' seq,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xah.event_type_code,
       xt.event_type_code,
       xah.je_category_name,
       xah.product_rule_code,
       xal.accounting_class_code,
       xal.ae_line_num,
       xte.entity_code \*,
       
       
       xah.*,
       xal.*,
       xte.**\
  FROM xla.xla_transaction_entities xte,
       xla_events                   xt,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       gl_code_combinations_kfv     gcc
 WHERE 1 = 1
   AND xt.entity_id = xte.entity_id
   AND xt.event_id = xah.event_id
   AND xt.application_id = xte.application_id
   AND gcc.code_combination_id = xal.code_combination_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 275
   AND xte.source_id_int_1 = 15313134;

SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND xte.application_id = 707
   AND xte.source_id_int_1 = 60911685
   AND xte.creation_date > SYSDATE - 1;

---------------Others--------------------
--PA 275
SELECT xe.event_id,
       xte.entity_id,
       xe.event_date,
       xe.creation_date,
       xah.je_category_name,
       xah.gl_transfer_status_code posted,
       xah.gl_transfer_date,
       xal.ae_header_id,
       xal.ae_line_num,
       xal.accounting_class_code   acc_clss_cd,
       xal.accounted_dr            acc_dr,
       xal.accounted_cr            acc_cr,
       xal.accounting_date,
       xte.entity_id,
       xte.entity_code,
       xte.creation_date,
       xte.transaction_number,
       xte.ledger_id,
       xah.event_id,
       xah.accounting_date,
       xah.gl_transfer_date,
       xah.description,
       xah.completed_date,
       xah.period_name,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xte.application_id = 275
   AND xte.ledger_id = 2021
   AND xte.entity_id = xe.entity_id
   AND xte.application_id = xe.application_id
   AND xe.event_id = xah.event_id
   AND xte.entity_id = xah.entity_id
   AND xah.application_id = xte.application_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xte.source_id_int_1 = 15429305 --15486489--15312121 --pei.expenditure_item_id
      --AND xah.je_category_name
      --AND xah.description LIKE --'53020155.JAC0084-IN.5031616'
      --'53020400.JED0210-VN%'
      --'53020165%'
      --'53020261%'
      --'11001299%'
      --'53020261%'
      --'10101647%'
   AND (nvl(xal.accounted_dr, 0) + nvl(xal.accounted_cr, 0)) <> 0;

--AR 222
SELECT xe.event_id,
       xte.entity_id,
       xe.event_date,
       xe.creation_date,
       xah.je_category_name,
       xah.description,
       xah.gl_transfer_status_code posted,
       xah.gl_transfer_date,
       xal.ae_header_id,
       xal.ae_line_num,
       xal.accounting_class_code   acc_clss_cd,
       xal.accounted_dr            acc_dr,
       xal.accounted_cr            acc_cr,
       xal.accounting_date,
       xte.entity_id,
       xte.entity_code,
       xte.creation_date,
       xte.transaction_number,
       xte.ledger_id,
       xah.event_id,
       xah.accounting_date,
       xah.gl_transfer_date,
       xah.description,
       xah.completed_date,
       xah.period_name,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xte.application_id = 222 --275
   AND xte.ledger_id = 2021 --HEA
   AND xte.entity_id = xe.entity_id
   AND xte.application_id = xe.application_id
   AND xe.event_id = xah.event_id
   AND xte.entity_id = xah.entity_id
   AND xah.application_id = xte.application_id
   AND xah.ae_header_id = xal.ae_header_id
      --AND xah.accounting_date = to_date('2015-01-06','yyyy-mm-dd')
      --AND xah.je_category_name = 'Sales Invoices'
      --AND xe.event_id = 6107822
      --AND xah.je_category_name
      --AND xah.description LIKE --'53020155.JAC0084-IN.5031616'
      --'53020400.JED0210-VN%'
      --'53020165%'
      --'53020261%'
      --'11001299%'
      --'53020261%'
      --'10101647%'
   AND (nvl(xal.accounted_dr, 0) + nvl(xal.accounted_cr, 0)) <> 0;

--------
SELECT ct.trx_number,
       ctl.description,
       fnd_flex_ext,
       gcc.chart_of_accounts_id,
       gcc.code_combination_id) account_number, gd.gl_date, to_number(decode(gd.account_class, 'REC', decode(sign(nvl(gd.amount, 0)), -1, NULL, nvl(gd.amount, 0)), decode(sign(nvl(gd.amount, 0)), -1, -nvl(gd.amount, 0), NULL))) entered_dr, to_number(decode(gd.account_class, 'REC', decode(sign(nvl(gd.amount, 0)), -1, -nvl(gd.amount, 0), NULL), decode(sign(nvl(gd.amount, 0)), -1, NULL, nvl(gd.amount, 0)))) entered_cr
  FROM ra_customer_trx_all          ct,
       ra_customer_trx_lines_all    ctl,
       ra_cust_trx_line_gl_dist_all gd,
       gl_code_combinations         gcc
 WHERE gd.customer_trx_id = ct.customer_trx_id
   AND gd.customer_trx_line_id = ctl.customer_trx_line_id(+)
   AND gcc.code_combination_id = gd.code_combination_id
   AND ct.customer_trx_id = &customer_trx_id;

-----
SELECT ct.trx_number,
       l.accounting_class_code,
       l.entered_dr,
       l.entered_cr,
       fnd_flex_ext.get_segs('SQLGL', 'GL#', 50328, l.code_combination_id) account_number,
       xla_oa_functions_pkg.get_ccid_description(50328, l.code_combination_id) account_description
  FROM xla_ae_headers               h,
       xla_ae_lines                 l,
       xla_events                   e,
       xla.xla_transaction_entities te,
       ra_customer_trx_all          ct
 WHERE h.application_id = l.application_id
   AND h.ae_header_id = l.ae_header_id
   AND h.application_id = e.application_id
   AND h.event_id = e.event_id
   AND h.application_id = te.application_id
   AND h.entity_id = te.entity_id
   AND te.application_id = 222
   AND te.entity_code = 'TRANSACTIONS'
   AND nvl(te.source_id_int_1, (-99)) = ct.customer_trx_id
   AND ct.customer_trx_id = 3139;*/

--20180728

--Conbine to one
SELECT t.seq,
       t.je_cate,
       (SELECT jc.user_je_category_name
  FROM gl_je_categories jc
 WHERE 1 = 1
   AND jc.je_category_name = t.je_cate --LIKE '%COGS%'
   --AND jc.user_je_category_name LIKE '%COGS%'
   ) u_je_cate,
       t.event_id,
       t.entity_id,
       t.source_id_int_1 src_id,
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
       t.dr                    dr,
       t.cr                    cr,
       t.acct_rule,
       t.ae_line_num,
       t.ledger_id,
       t.concatenated_segments,
       t.account_desc
  FROM (
  /*
        --8.wip transation(issue resource)
        SELECT 8 seq,
                xah.je_category_name je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name event_class,
                xet.name event_type,
                --xe.event_type_code event_type,
                \*
                WIP_COMP_ISSUE:WIP Component Issue
                CG_TXFR:Cost Group Transfer
                *\
                --xe.event_status_code,
                --xe.process_status_code,
                --xah.event_type_code   event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description( \*xgl.chart_of_accounts_id*\ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
       xte.transaction_number,
       xah.accounting_date,
       xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707
           AND xte.source_id_int_1 = 20771589 --wip transaction
           AND xte.entity_code = 'WIP_ACCOUNTING_EVENTS'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code
        UNION ALL
        
        --9.WIP issue(issue material)
        SELECT 9 seq,
                xah.je_category_name je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name event_class,
                xet.name event_type,
                --xe.event_type_code event_type,
                \*
                WIP_COMP_ISSUE:WIP Component Issue
                CG_TXFR:Cost Group Transfer
                *\
                --xe.event_status_code,
                --xe.process_status_code,
                --xah.event_type_code   event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description( \*xgl.chart_of_accounts_id*\ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
       xte.transaction_number,
       xah.accounting_date,
       xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707
           AND xte.source_id_int_1 = 54869415 --material transaction
           AND xte.entity_code = 'MTL_ACCOUNTING_EVENTS'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS' --'AP_INV_DIST'
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
        
        UNION ALL*/
        ----10.CUX FG Completion(PA Expenditure)
        SELECT 10 seq, --xdl.source_distribution_type,
                xah.je_category_name je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name event_class,
                xet.name event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description( /*xgl.chart_of_accounts_id*/ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
       xte.transaction_number,
       xah.accounting_date,
       xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275 --PA
           AND xte.source_id_int_1 --= 15315881--15316832 --pa expenditure items
           IN (15315881, 15316880, 15317881)
           AND xte.entity_code = 'EXPENDITURES'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'R' --pa_expenditure_items_all
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
           
           UNION ALL
           
----11.CUX EQ COGS
SELECT 11 seq, --xdl.source_distribution_type,
       xah.je_category_name je_cate, --Subledger Journal Entry
       xe.event_id,
       xect.name event_class,
       xet.name event_type,
       xah.product_rule_code acct_rule,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       xal.accounting_class_code acct_class,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xla_oa_functions_pkg.get_ccid_description( /*xgl.chart_of_accounts_id*/ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xal.ae_line_num,
       xte.entity_code,
       xte.entity_id,
       xte.transaction_number,
       xah.accounting_date,
       xdl.source_distribution_type
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl, --improve efficient
       gl_code_combinations_kfv     gcc,
       --event class/event type
       xla_event_classes_tl xect,
       xla_event_types_tl   xet

 WHERE 1 = 1
   AND xah.ae_header_id = xal.ae_header_id
   AND gcc.code_combination_id = xal.code_combination_id
   AND xe.entity_id = xte.entity_id
   AND xe.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 275 --PA
   --AND xte.source_id_int_1 = 15316832 --pa expenditure items
   AND xte.transaction_number = 'C15317881'
   AND xte.entity_code = 'MANUAL'--'EXPENDITURES'
      --improve efficient
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xdl.application_id = xte.application_id
      ----
   AND xdl.source_distribution_type = 'XLA_MANUAL'--'R' --pa_expenditure_items_all
      --event class/ event type
   AND xet.language = userenv('LANG')
   AND xect.application_id = xe.application_id --707
   AND xet.application_id = xe.application_id --707
   AND xect.entity_code = xet.entity_code
   AND xet.entity_code = xte.entity_code
   AND xect.event_class_code = xet.event_class_code
   AND xect.language = userenv('LANG')
   AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
 
        
        ) t
 ORDER BY t.seq,
          t.event_id,
          t.flag DESC,
          t.ae_line_num;

----11.CUX EQ COGS
SELECT 11 seq, --xdl.source_distribution_type,
       xah.je_category_name je_cate, --Subledger Journal Entry
       xe.event_id,
       xect.name event_class,
       xet.name event_type,
       xah.product_rule_code acct_rule,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       xal.accounting_class_code acct_class,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xla_oa_functions_pkg.get_ccid_description( /*xgl.chart_of_accounts_id*/ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xal.ae_line_num,
       xte.entity_code,
       xte.entity_id,
       xte.transaction_number,
       xah.accounting_date,
       xte.source_id_int_1,
       xdl.source_distribution_type
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl, --improve efficient
       gl_code_combinations_kfv     gcc,
       --event class/event type
       xla_event_classes_tl xect,
       xla_event_types_tl   xet

 WHERE 1 = 1
   AND xah.ae_header_id = xal.ae_header_id
   AND gcc.code_combination_id = xal.code_combination_id
   AND xe.entity_id = xte.entity_id
   AND xe.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 275 --PA
   --AND xte.source_id_int_1 = 15316832 --pa expenditure items
   AND xte.transaction_number = 'C15317881'
   AND xte.entity_code = 'MANUAL'--'EXPENDITURES'
      --improve efficient
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xdl.application_id = xte.application_id
      ----
   AND xdl.source_distribution_type = 'XLA_MANUAL'--'R' --pa_expenditure_items_all
      --event class/ event type
   AND xet.language = userenv('LANG')
   AND xect.application_id = xe.application_id --707
   AND xet.application_id = xe.application_id --707
   AND xect.entity_code = xet.entity_code
   AND xet.entity_code = xte.entity_code
   AND xect.event_class_code = xet.event_class_code
   AND xect.language = userenv('LANG')
   AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
   
   --AND xah.ae_header_id = 24596702
;

SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   --AND xte.entity_code = 'EXPENDITURES'
   AND xte.application_id = 275
   AND xte.creation_date >= to_date('03-AUG-2018 17:00:23', 'dd-mon-yyyy hh24:mi:ss')
   AND xte.creation_date >= to_date('03-AUG-2018 19:20:54', 'dd-mon-yyyy hh24:mi:ss')
   --AND xte.created_by = 4270
   ;
/*
--INSTR()   
SELECT instr('SHE.Default.Manufacturing Department .RES ABSORP FIELD COST_PRO.Default.Default.Default', '.', 1, 3)
  FROM dual;

\*
t.concatenated_segments
start:instr(t.concatenated_segments, '.',1,2)+1
end:(t.concatenated_segments, '.',1,3)-1
length of string:end-start

substr(t.concatenated_segments,instr(t.concatenated_segments, '.',1,2)+1,
instr(t.concatenated_segments, '.',1,3)-instr(t.concatenated_segments, '.',1,2)
) acc
*\
SELECT instr('GS00.0.1145500000.421103030.215110107.0.0', '.', 1, 2)
  FROM dual;
SELECT instr('GS00.0.1145500000.421103030.215110107.0.0', '.', 1, 3)
  FROM dual;
SELECT substr('GS00.0.1145500000.421103030.215110107.0.0', 8, 10)
  FROM dual;
*/
