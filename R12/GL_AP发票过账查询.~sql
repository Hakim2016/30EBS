--ap_invoice_distributions_all到xla_ae_lines. 到了XLA_AE_LINES后,会by科目和描述汇总.所以,不能一对一
SELECT h.creation_date,
h.description,
c.code_combination_id,
       h.je_header_id,
       h.name,
       l.ae_header_id,
       l.ae_line_num,
       te.source_id_int_1,
       te.application_id,
       te.entity_id,
       h.je_source,
       h.je_category,
       i.gl_date,
       s.vendor_name,
       s.segment1 AS supplier_no,
       l.event_class_code AS event_class,
       i.invoice_id,
       ad.invoice_distribution_id,
       i.invoice_num AS transaction_number,
       i.invoice_date,
       initcap(jl.description) description,
       jl.accounted_dr AS debit,
       jl.accounted_cr AS credit,
       nvl(jl.accounted_dr, 0) - nvl(jl.accounted_cr, 0) net_amount
  FROM apps.gl_je_headers                h,
       apps.gl_je_lines                  jl,
       apps.gl_code_combinations         c,
       apps.gl_import_references         r,
       apps.xla_ae_lines                 al,
       apps.xla_ae_headers               ah,
       apps.xla_distribution_links       l,
       apps.ap_invoices_all              i,
       apps.ap_invoice_distributions_all ad,
       apps.ap_suppliers                 s,
       apps.xla_events                   e,
       xla.xla_transaction_entities     te
 WHERE ad.invoice_id = 1944244--1942629--10194
   AND jl.je_header_id = h.je_header_id
   AND jl.code_combination_id = c.code_combination_id
   AND al.gl_sl_link_id = r.gl_sl_link_id
   AND al.ae_header_id = ah.ae_header_id
   AND al.application_id = ah.application_id
   AND ah.application_id = e.application_id
   AND ah.event_id = e.event_id
   AND e.application_id = te.application_id(+)
   AND e.entity_id = te.entity_id(+)
   AND r.je_header_id = jl.je_header_id
   AND r.je_line_num = jl.je_line_num
   AND l.ae_header_id = al.ae_header_id
   AND l.ae_line_num = al.ae_line_num
   AND l.applied_to_source_id_num_1 = i.invoice_id
   AND l.source_distribution_id_num_1 = ad.invoice_distribution_id
   AND ad.invoice_id = i.invoice_id
   AND i.vendor_id = s.vendor_id
   AND l.source_distribution_type = 'AP_INV_DIST'--improve the efficient
   AND l.application_id = 200
 ORDER BY i.gl_date, h.je_header_id DESC
