SELECT aid.base_amount,
       ai.invoice_id,
       nvl(pv.vendor_name, hp.party_name) vendor_name,
       pv.attribute1 vendor_type,
       pv.segment1 vendor_number,
       nvl(ph.clm_document_number, ph.segment1) po_number,
       ai.invoice_num invoice_num,
       --ai.invoice_currency_code,
       ai.invoice_date,
       /*ai.gl_date,*/
       aid.accounting_date gl_date,
       ai.invoice_currency_code,
       upper(alc1.displayed_field) line_type,
       nvl(aid.amount, 0) amount,
       decode(ai.invoice_currency_code, 'SGD', nvl(aid.amount, 0), nvl(aid.base_amount, 0)) base_amount,
       decode(ai.attribute_category, 'HEA Ledger', to_number(ai.attribute8)) gst_amount
  FROM ap_invoices_all              ai,
       po_headers_all               ph,
       hz_parties                   hp,
       ap_invoice_lines_all         ail,
       ap_lookup_codes              alc1,
       po_vendors                   pv,
       ap_invoice_distributions_all aid,
       po_distributions_all         pod
 WHERE ai.org_id = 101 --fnd_profile.value('ORG_ID')
   AND ai.party_id = hp.party_id
   AND ai.approval_ready_flag <> 'S'
   AND ail.invoice_id = ai.invoice_id
   AND alc1.lookup_type(+) = 'INVOICE LINE TYPE'
   AND alc1.lookup_code(+) = ail.line_type_lookup_code
   AND pv.vendor_id(+) = ai.vendor_id
      /*and decode(ai.invoice_currency_code,'SGD',ail.amount,ail.base_amount) <> 0
      AND ap_invoices_pkg.get_approval_status(ai.invoice_id,
                                              ai.invoice_amount,
                                              ai.payment_status_flag,
                                              ai.invoice_type_lookup_code) NOT IN ('NEVER APPROVED', 'NEEDS REAPPROVAL')*/
   AND ap_invoices_pkg.get_posting_status(ai.invoice_id) = 'Y'
   AND ail.invoice_id = aid.invoice_id
   AND ail.line_number = aid.invoice_line_number
   AND aid.po_distribution_id = pod.po_distribution_id(+)
      --AND aid.base_amount = 0.01
      --AND aid.posted_flag = 'Y'
      --AND decode(ai.invoice_currency_code,'SGD',aid.amount,aid.base_amount) <> 0
   AND pod.po_header_id = ph.po_header_id(+)
      --AND ph.po_header_id = 2903166
   AND ai.invoice_num = 'HKM-2018090601'
   ;

SELECT *
  FROM ap_invoice_distributions_all aid
 WHERE 1 = 1 AND
