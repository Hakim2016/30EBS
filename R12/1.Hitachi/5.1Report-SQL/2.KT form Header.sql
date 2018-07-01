--KT From Header
/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;*/

SELECT xxh.invoice_number,
       xxh.invoice_type_code,
       hp.party_name         customer_name, --Customer Name
       xxh.bill_to_address1  bill_to_address, --Bill to Address
       --Customer Code
       hca.account_number customer_code,
       decode(82 /*g_current_org_id*/, 101, hp.duns_number_c, '   ') g_code, -- Modify by HY. at 2016.07.13. v.2.0.
       xxh.attention_party attention, --Attention
       ct.trx_number, --REF  (Transaction Number)
       ct.trx_date, --Date (Transaction Date)
       nvl(al_inv_reason.meaning, al_cm_reason.meaning) reasons, --Reasons
       TRIM(nvl(al_inv_reason.lookup_code, al_cm_reason.lookup_code)) reason_code,
       SYSDATE issuing_date, --Issuing Date
       nvl(rat.name, rtl.name) payment_term, --Payment Term
       ct.internal_notes, --Description of remarks
       ppa.long_name project_name, --Project Name
       zrb.tax_rate_code gst_code,
       ct.invoice_currency_code,
       ct.customer_trx_id,
       xxh.header_id,
       ct.exchange_rate_type,
       ct.exchange_date
  FROM xxar_tax_invoice_headers xxh,
       ra_customer_trx          ct,
       ra_customer_trx          ct1,
       ar_lookups               al_inv_reason,
       ar_lookups               al_cm_reason,
       ra_terms                 rat,
       ra_terms_tl              rtl,
       hz_cust_accounts         hca,
       pa_projects_all          ppa,
       zx_rates_b               zrb,
       hz_parties               hp
 WHERE xxh.customer_id = hca.cust_account_id
   AND hca.party_id = hp.party_id
   AND ct.previous_customer_trx_id = ct1.customer_trx_id
   AND xxh.invoice_number = ct1.trx_number
   AND 'CREDIT_MEMO_REASON' = al_cm_reason.lookup_type(+)
   AND ct.reason_code = al_cm_reason.lookup_code(+)
   AND 'INVOICING_REASON' = al_inv_reason.lookup_type(+)
   AND ct.reason_code = al_inv_reason.lookup_code(+)
   AND ct.term_id = rat.term_id(+)
   AND xxh.payment_term_id = rtl.term_id(+)
   AND rtl.language(+) = userenv('LANG')
   AND xxh.project_id = ppa.project_id(+)
   AND xxh.gst_tax_rate_id = zrb.tax_rate_id
      --AND xxh.invoice_number          = 'SPR-12000007'
      --parameter
   AND ct.customer_trx_id = nvl(4022542 /*p_customer_trx_id*/, ct.customer_trx_id)
--AND hca.cust_account_id = nvl(p_cust_account_id, hca.cust_account_id)
--AND ct.trx_date BETWEEN nvl(p_trx_date_from, ct.trx_date) AND nvl(p_trx_date_to, ct.trx_date)
--AND ct.trx_number               = nvl(p_trx_number,ct.trx_number)
--AND hp.party_number             = nvl(p_customer_name,hp.party_number)
-- AND ct.trx_date                >= nvl(fnd_date.chardate_to_date(p_trx_date_from),ct.trx_date)
--AND ct.trx_date                <= nvl(fnd_date.chardate_to_date(p_trx_date_to),ct.trx_date)
;
