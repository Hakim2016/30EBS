
SELECT gcc.segment2,gcc.segment3,
       SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)) account_amount,
       SUM(nvl(xal.accounted_dr, 0)) DR,
       SUM(nvl(xal.accounted_cr, 0)) CR
  FROM xla.xla_transaction_entities xte,
       xla.xla_ae_headers           xah,
       xla.xla_ae_lines             xal,
       gl.gl_import_references      gir,
       gl.gl_code_combinations         gcc
 WHERE 1 = 1
      /*AND xte.entity_code IN
      ('INVENTORY', 'PRODUCTION', 'PURCHASING', 'ORDERMANAGEMENT')*/
   AND xte.entity_id = xah.entity_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
      --  AND xal.accounting_class_code IN ('INVENTORY_VALUATION', 'XFR')
   AND nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0) <> 0
   AND xal.code_combination_id = gcc.code_combination_id
      --   AND gcc.segment3 = '5001010101'
   AND xal.gl_sl_link_id = gir.gl_sl_link_id
   AND gcc.segment3 LIKE '5001%'
   AND gcc.segment2 = '10112060202'--'10112060202'
   AND NOT EXISTS
 (SELECT 1
          FROM gl.gl_je_headers gjh
         WHERE gjh.je_header_id = gir.je_header_id)
   AND xal.accounting_date BETWEEN to_date(20180801, 'YYYY-MM-DD') AND
       to_date(20180930235959, 'YYYY-MM-DD HH24:MI:SS')
   AND xte.ledger_id = 2021 --g_ledger_id
 GROUP BY gcc.segment2,gcc.segment3
 
 ORDER BY gcc.segment3
