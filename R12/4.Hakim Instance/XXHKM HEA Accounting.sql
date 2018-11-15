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
                xte.entity_code /*,
                                                               
                                                               
                                                               xah.*,
                                                               xal.*,
                                                               xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707
           AND xte.source_id_int_1 IN (54834283, 4654211, 4654212, 4654212) 
        
        UNION ALL
        --2.Inventory
        SELECT '2' seq,
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
                xte.entity_code /*,
                                                               
                                                               
                                                               xah.*,
                                                               xal.*,
                                                               xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 200--SQLAP
           AND xte.source_id_int_1 IN (1952273)--AP invoice
        
        UNION ALL
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
                xte.entity_code /*,
                                                               
                                                               
                                                               xah.*,
                                                               xal.*,
                                                               xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15312121 
           
        UNION ALL
        
        --4.Move order
        SELECT '4' seq,
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
                xte.entity_code /*,
                                                       
                                                       
                                                       xah.*,
                                                       xal.*,
                                                       xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 707 --CST
           AND xte.source_id_int_1 = 60911685 
        
        UNION ALL
        
        --5.Import from IF36 Labor hour
        SELECT '5' seq,
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
                xte.entity_code /*,
                                                       
                                                       
                                                       xah.*,
                                                       xal.*,
                                                       xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15312122--Expenditure
                UNION ALL
        
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
                xah.je_category_name,
                xah.product_rule_code,
                xal.accounting_class_code,
                xal.ae_line_num,
                xte.entity_code /*,
                                                       
                                                       
                                                       xah.*,
                                                       xal.*,
                                                       xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15313134--Expenditure
           
           UNION ALL
        
        --7.Import from AP Expense
        SELECT '7' seq,
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
                xte.entity_code /*,
                                                       
                                                       
                                                       xah.*,
                                                       xal.*,
                                                       xte.**/
          FROM xla.xla_transaction_entities xte,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                gl_code_combinations_kfv     gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = xal.code_combination_id
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275
           AND xte.source_id_int_1 = 15313137--Expenditure from expense ap
        ) t
 ORDER BY t.seq,
          t.source_id_int_1,
          t.flag DESC,
          t.ae_line_num;

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
       xte.entity_code /*,
       
       
       xah.*,
       xal.*,
       xte.**/
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       gl_code_combinations_kfv     gcc
 WHERE 1 = 1
   AND gcc.code_combination_id = xal.code_combination_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 707 --CST
   AND xte.source_id_int_1 = 60911685 
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
       xte.entity_code /*,
       
       
       xah.*,
       xal.*,
       xte.**/
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
       xte.entity_code /*,
       
       
       xah.*,
       xal.*,
       xte.**/
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
   AND xte.source_id_int_1 = 15313134 
;

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
   AND ct.customer_trx_id = 3139;
