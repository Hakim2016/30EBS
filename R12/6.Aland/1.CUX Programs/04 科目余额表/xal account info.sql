--base SQL
SELECT gcc.segment2,
       xte.ledger_id,
       xah.accounting_date,
       xah.description,
       xte.transaction_number,
       xte.entity_code,
       xte.source_id_int_1,
       xah.je_category_name,
       xah.accounting_entry_status_code,
       xal.entered_dr,
       xal.entered_cr,
       xal.accounted_dr,
       xal.accounted_cr,
       xal.currency_code/*,
       xah.*,
       xal.*,
       gcc.**/
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl,
       gl_code_combinations         gcc
 WHERE 1 = 1
   AND xal.code_combination_id = xal.code_combination_id
   AND xte.entity_id = xah.entity_id
   AND xte.ledger_id = xah.ledger_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
      /* AND xte.entity_code = 'AP_INVOICES'
      AND xah.application_id = 200
      AND xal.application_id = 200
      AND xte.application_id = 200
      AND xdl.application_id = 200*/
   AND xte.ledger_id = 2021
   AND (gcc.segment3 LIKE '6602%' /*管理费用*/
       OR gcc.segment3 LIKE '6601%' /*销售费用*/
       )
      
   AND trunc(xah.accounting_date) = to_date('2018-08', 'yyyy-mm')
