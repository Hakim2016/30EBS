SELECT /*'2' seq,*/
 xte.transaction_number,
 xte.source_id_int_1,
 xah.accounting_date,
 xah.ae_header_id,
 xah.ledger_id,
 xah.description,
 --xah.description,
 --xal.description,
 decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
 gcc.concatenated_segments,
 gcc.segment3,
 xal.accounted_dr dr,
 xal.accounted_cr cr,
 xah.event_type_code,
 xah.je_category_name,
 xah.product_rule_code,
 xal.accounting_class_code,
 xal.ae_line_num,
 xte.entity_code
/*,xah.*,
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
   AND xte.ledger_id = 2021
   AND xah.accounting_date BETWEEN to_date(20180801, 'YYYY-MM-DD') AND
       to_date(20180930235959, 'YYYY-MM-DD HH24:MI:SS')
      --AND gcc.segment3 IN ('1407020101', '1605020101', '2202020101')
   AND xah.ae_header_id IN
       (SELECT xal.ae_header_id
          FROM xla_ae_lines xal, gl_code_combinations_kfv gcc
         WHERE 1 = 1
           AND xal.code_combination_id = gcc.code_combination_id
           AND gcc.segment3 IN ('1407020101', '1605020101', '2202020101')
           AND xal.accounting_date BETWEEN to_date(20180801, 'YYYY-MM-DD') AND
               to_date(20180831235959, 'YYYY-MM-DD HH24:MI:SS'))
--AND xte.application_id = 200 --SQLAP
--AND xte.source_id_int_1 IN (1952273) --AP invoice
 ORDER BY xah.ae_header_id DESC;
