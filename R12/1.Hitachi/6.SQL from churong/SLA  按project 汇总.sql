--SLA��Project����
SELECT gcc.segment5,
 SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0))
  FROM apps.xla_ae_lines             xal,
       apps.gl_code_combinations_kfv gcc,
       apps.xla_ae_headers           xah,
       xla.xla_transaction_entities  xte
 WHERE 1 = 1
   AND gcc.code_combination_id = xal.code_combination_id
   AND gcc.segment3 in ('1145500000','1161500990')
  AND xal.accounting_date <= to_date('2015-06-30', 'YYYY-MM-DD') + 0.99999
  AND xal.accounting_date >= to_date('2015-06-01', 'YYYY-MM-DD')
   AND xah.ae_header_id = xal.ae_header_id
AND xah.application_id = xal.application_id  
      AND xah.period_name = 'JUN-15'
   AND xah.ledger_id = 2021
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
 GROUP BY gcc.segment5
Order by gcc.segment5
