SELECT SUM(nvl(xal.accounted_dr, 0)) accounted_dr,
       SUM(nvl(xal.accounted_cr, 0)) accounted_cr
  FROM apps.mtl_material_transactions mmt,
       apps.mtl_transaction_accounts  mta,
       xla.xla_distribution_links     xdl,
       xla.xla_ae_lines               xal,
       xla.xla_ae_headers             xah
 WHERE 1 = 1
   AND xdl.application_id = 707
   AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
   AND mmt.source_code = 'FMRB/FPART On-hand Clearance'
   AND xdl.source_distribution_id_num_1 = mta.inv_sub_ledger_id
   AND xal.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xal.application_id = xdl.application_id
   AND xah.ae_header_id = xal.ae_header_id
   AND mmt.transaction_reference = 'FMRB/FPART On-hand Clearance'
   AND mmt.transaction_id = mta.transaction_id
      --AND mmt.transaction_source_type_id = mta.transaction_source_type_id
   AND mmt.transaction_type_id = 2
   AND mmt.transaction_date > to_date('2013-03-10', 'YYYY-MM-DD')
--AND mta.transaction_date > to_date('2013-03-10', 'YYYY-MM-DD')
--AND mmt.transaction_id = 6886985
--AND rownum < 10
;

