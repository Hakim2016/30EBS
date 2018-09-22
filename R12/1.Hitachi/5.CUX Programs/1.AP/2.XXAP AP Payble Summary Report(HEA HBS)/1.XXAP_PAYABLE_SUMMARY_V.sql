CREATE OR REPLACE VIEW XXAP_PAYABLE_SUMMARY_V AS
SELECT invoice_id
      ,vendor_number
      ,vendor_name
      ,po_number
      ,invoice_num
      ,invoice_date
      ,gl_date
      ,invoice_currency_code
      ,SUM(decode(line_type,
                  'ITEM',
                  decode(invoice_currency_code,
                         'SGD',
                         nvl(amount, 0),
                         nvl(base_amount, 0)),
                  -- add by gusenlin 20130521 start
                  'MISCELLANEOUS',
                  decode(invoice_currency_code,
                         'SGD',
                         nvl(amount, 0),
                         nvl(base_amount, 0)),
                  -- add by gusenlin 20130521 start
                  0)) amount
      /*,SUM(decode(line_type,
                  'TAX',
                  decode(invoice_currency_code,
                         'SGD',
                         nvl(amount, 0),
                         nvl(base_amount, 0)),
                  0)) gst*/
      ,DECODE(invoice_currency_code,
              'SGD', SUM(decode(line_type,
                         'TAX',
                         nvl(amount, 0), 0)),
              decode(SUM(decode(line_type,
                         'TAX',
                         nvl(base_amount, 0), 0)), 0, 0, nvl(decode((sign(SUM(decode(line_type,
                                                                                         'TAX',
                                                                                         nvl(base_amount, 0), 0)))),
                                                                      -1,
                                                                      -abs(gst_amount),  --update by gusenlin 2013-09-04
                                                                      abs(gst_amount))   --update by gusenlin 2013-09-04
                                                                  , SUM(decode(line_type,
                                                                               'TAX',
                                                                               nvl(base_amount, 0), 0))))) gst
      ,SUM(decode(line_type,
                  'FREIGHT',
                  decode(invoice_currency_code,
                         'SGD',
                         nvl(amount, 0),
                         nvl(base_amount, 0)),
                  0)) freight
      ,SUM(decode(invoice_currency_code,
                  'SGD',
                  nvl(amount, 0),
                  nvl(base_amount, 0))) grand_total
      ,SUM(nvl(amount, 0)) foreign_grand_total
  FROM (
SELECT ai.invoice_id,
       NVL(pv.vendor_name, hp.party_name) vendor_name,
       pv.attribute1                      vendor_type,
       pv.segment1                        vendor_number,
       NVL(ph.clm_document_number, ph.segment1) po_number,
       ai.invoice_num invoice_num,
       ai.invoice_date,
       /*ai.gl_date,*/
       aid.accounting_date gl_date,
       ai.invoice_currency_code,
       upper(ALC1.DISPLAYED_FIELD) line_type,
       nvl(aid.amount, 0)             amount,
       DECODE(ai.invoice_currency_code,
              'SGD',nvl(aid.amount,0),
              nvl(aid.base_amount,0)) base_amount,
       DECODE(ai.attribute_category,
              'HEA Ledger',
              to_number(ai.attribute8)) gst_amount
  FROM ap_invoices_all      ai,
       po_headers_all       ph,
       hz_parties           hp,
       ap_invoice_lines_all ail,
       AP_LOOKUP_CODES      ALC1,
       po_vendors           pv,
       ap_invoice_distributions_all aid,
       po_distributions_all         pod
 WHERE ai.org_id = 101--fnd_profile.value('ORG_ID')
   AND ai.party_id = hp.party_id
   AND ai.approval_ready_flag <> 'S'
   AND ail.invoice_id = ai.invoice_id
   AND ALC1.lookup_type (+)   = 'INVOICE LINE TYPE'
   AND ALC1.lookup_code (+)   = AIL.line_type_lookup_code
   AND pv.vendor_id(+) = ai.vendor_id
   /*and decode(ai.invoice_currency_code,'SGD',ail.amount,ail.base_amount) <> 0
   AND ap_invoices_pkg.get_approval_status(ai.invoice_id,
                                           ai.invoice_amount,
                                           ai.payment_status_flag,
                                           ai.invoice_type_lookup_code) NOT IN ('NEVER APPROVED', 'NEEDS REAPPROVAL')*/
   AND ap_invoices_pkg.get_posting_status(ai.invoice_id) = 'Y'
   AND ail.invoice_id = aid.invoice_id
   AND ail.line_number = aid.invoice_line_number
   AND aid.po_distribution_id = pod.po_distribution_id (+)
   AND aid.posted_flag = 'Y'
   AND decode(ai.invoice_currency_code,'SGD',aid.amount,aid.base_amount) <> 0
   AND pod.po_header_id = ph.po_header_id (+)
   --AND ph.po_header_id = 2903166
   AND ai.invoice_num = 
   --'HKM2018091001'
   'HKM-2018090602'
) GROUP BY
       invoice_id
      ,vendor_number
      ,vendor_name
      ,po_number
      ,invoice_num
      ,invoice_date
      ,gl_date
      ,invoice_currency_code
      ,gst_amount
;

