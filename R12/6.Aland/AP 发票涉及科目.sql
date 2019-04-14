SELECT ai.invoice_num inv_num,
       --ai.cancelled_date,
       xal.accounting_date acc_dt,
       xal.accounting_class_code typ,
       gcc.segment3,
       xal.accounted_dr,
       xal.accounted_cr,
       sup.vendor_name,
       sups.vendor_site_code
  FROM xla.xla_ae_headers           xah,
       xla.xla_ae_lines             xal,
       xla.xla_transaction_entities xte,
       ap.ap_invoices_all           ai,
       gl.gl_code_combinations      gcc,
       apps.ap_suppliers            sup,
       apps.ap_supplier_sites_all   sups
 WHERE ai.invoice_type_lookup_code = 'PREPAYMENT'
   AND nvl(xte.source_id_int_1, -99) = ai.invoice_id
   AND xte.entity_code = 'AP_INVOICES'
   AND xte.ledger_id = 2021
   AND xte.entity_id = xah.entity_id
   AND xte.application_id = xah.application_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
   AND xal.code_combination_id = gcc.code_combination_id
   AND ai.vendor_id = sup.vendor_id
   AND ai.vendor_id = sups.vendor_id
   AND ai.vendor_site_id = sups.vendor_site_id
   AND xal.accounted_cr IS NULL
   AND gcc.segment3 NOT IN ('1123010101')
   --AND xah.period_name <> '2018-08'
   AND xal.accounting_class_code NOT IN ('RTAX','NRTAX')
   --AND ai.invoice_num = 'QTYSQC201808053'
   AND ai.cancelled_date IS NULL
   ORDER BY xal.accounting_date 
