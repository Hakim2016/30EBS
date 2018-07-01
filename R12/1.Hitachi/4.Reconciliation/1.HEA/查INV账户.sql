SELECT --xah.period_name,
 xah.je_category_name,
 xte.entity_code,
 xte.security_id_int_1,
 --xte.transaction_number,
 xal.accounting_class_code,
 SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0))
  FROM apps.xla_ae_lines             xal,
       apps.gl_code_combinations_kfv gcc,
       apps.xla_ae_headers           xah,
       xla.xla_transaction_entities  xte /*,
        apps.xla_events                  xe*/
 WHERE 1 = 1
      /* AND xal.accounting_class_code = 'RECEIVING_INSPECTION'
      AND xal.accounting_date < to_date('20131130', 'yyyymmdd')*/
   AND gcc.code_combination_id = xal.code_combination_id
   AND gcc.segment3 = '1145400000'
   --AND concatenated_segments LIKE '%1145400000.111103070%'
   AND xal.accounting_date BETWEEN to_date('2015-12-01', 'YYYY-MM-DD') AND to_date('2015-12-03', 'YYYY-MM-DD') + 0.99999
   AND xah.ae_header_id = xal.ae_header_id
      --AND xah.period_name = 'MAY-14'
   AND xah.ledger_id = 2021
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
--AND xte.entity_code = 'WIP_ACCOUNTING_EVENTS'
--AND xal.accounting_class_code='OFFSET'
 GROUP BY --xah.period_name,
          xah.je_category_name,
          xte.entity_code,
          xte.security_id_int_1,
          xal.accounting_class_code --xte.security_id_int_1
--xte.entity_code
--xah.je_category_name