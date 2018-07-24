SELECT *
  FROM dba_policies dp
 WHERE 1 = 1
   AND dp.object_name IN upper('pa_expenditures')
--('XLA_TRANSACTION_ENTITIES', 'XLA_AE_HEADERS', 'XLA_AE_LINES')
;

SELECT *
  FROM xla.xla_transaction_entities xte, --need to add owner(Oracle VPD)
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl,
       ap_invoices_all              aph,
       ap_invoice_lines_all         apl,
       ap_invoice_distributions_all apd
 WHERE 1 = 1
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
      
   AND apd.invoice_distribution_id = xdl.source_distribution_id_num_1
      
   AND aph.invoice_id = apl.invoice_id
   AND aph.invoice_id = apd.invoice_id
   AND apl.line_number = apd.invoice_line_number
   AND xah.application_id = 200
   AND xal.application_id = 200
   AND xte.application_id = 200
   AND xdl.application_id = 200
   AND xte.entity_code = 'AP_INVOICES'
   AND xdl.source_distribution_type = 'AP_INV_DIST' --improve the efficient
   AND aph.invoice_num = '10005873';
