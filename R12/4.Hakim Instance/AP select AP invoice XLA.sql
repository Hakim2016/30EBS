SELECT xdl.*
  FROM ap_invoices_all              aia,
       ap_invoice_distributions_all aid,
       xla.xla_distribution_links   xdl,
       xla.xla_ae_lines             xal,
       xla.xla_ae_headers           xah
 WHERE 1 = 1
   AND aia.invoice_id = aid.invoice_id
   AND aia.invoice_num IN ('CN14030001', 'CN14030001*1')
   AND aid.invoice_distribution_id = xdl.source_distribution_id_num_1
   AND xdl.source_distribution_type = 'AP_INV_DIST'
   AND xdl.application_id = 200
   AND xdl.application_id = xal.application_id
   AND xdl.ae_header_id = xal.ae_header_id
   AND xdl.ae_line_num = xal.ae_line_num
   AND xal.application_id = xah.application_id
   AND xal.ae_header_id = xah.ae_header_id
 ORDER BY xdl.ae_header_id,
          xdl.ae_line_num;
