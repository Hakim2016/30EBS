SELECT '1' seq,
       xte.source_id_int_1,
       xah.ledger_id,
       xah.description,
       xal.description,
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
 --AND xte.creation_date >= to_date('20180401', 'yyyymmdd')
   AND gcc.code_combination_id = xal.code_combination_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 222--707
   --AND xte.source_id_int_1 IN (4654211)--(54834283, 4654211, 4654212, 4654212)
   AND xte.transaction_number = 'DP-18000143'
;
