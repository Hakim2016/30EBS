select ooh.order_number   SO_num,
       ott.NAME           SO_type,
       ooh.transactional_curr_code currency,
       hcsu.location,
       hca.account_number cust_num,
       hp.party_name      cust_name,
       xdih.document_number tax_invoice_num,
       xdih.document_type   
  from apps.OE_ORDER_HEADERS_ALL        ooh,
       apps.oe_transaction_types_vl     ott,
       apps.xxom_do_invoice_headers_all xdih,
       apps.hz_parties                  hp,
       apps.hz_cust_accounts            hca,
       apps.hz_cust_site_uses_all       hcsu,
       apps.hz_cust_acct_sites_all      hcas
 where 1 = 1
   and ooh.order_type_id in ('1413', '1225', '1231', '1221','1410')
   and ooh.order_type_id = ott.TRANSACTION_TYPE_ID
   and ooh.ship_to_org_id = hcsu.site_use_id
   and hcsu.cust_acct_site_id = hcas.cust_acct_site_id
   and hcas.cust_account_id = hca.cust_account_id
   and hca.party_id = hp.party_id
   and ooh.header_id = xdih.oe_header_id(+)
 





