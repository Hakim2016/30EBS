SELECT '1 ra_customer_trx_all' src,
       ct.trx_number num2,
       COUNT(*) counts,
       ct.bill_to_customer_id cust_account_id, --ct.sold_to_customer_id cust_account_id 用收单方作为客户  modify by Orne.Dai 2019-01-25
       rac_bill_party.party_number --单位编号
      ,
       rac_bill_party.party_name --单位名称
      ,
       ct.invoice_currency_code currency_code,
       fc.name currency_name --币种
      ,
       nvl(SUM(xal.entered_dr), 0) entered_dr,
       nvl(SUM(xal.entered_cr), 0) entered_cr,
       nvl(SUM(xal.accounted_dr), 0) accounted_dr,
       nvl(SUM(xal.accounted_cr), 0) accounted_cr,
       to_char(xah.accounting_date, 'YYYY-MM') period --add by Orne.Dai 2019-01-25  增加期间区分期初和本期金额
  FROM apps.ra_customer_trx_all ct,
       apps.fnd_currencies_tl   fc,
       apps.hz_cust_accounts    rac_bill,
       apps.hz_parties          rac_bill_party
       
      ,
       xla.xla_transaction_entities  xle,
       xla.xla_ae_headers            xah,
       xla.xla_ae_lines              xal,
       apps.gl_code_combinations_kfv gcc,
       apps.hr_operating_units       hou
 WHERE fc.currency_code = ct.invoice_currency_code
   AND fc.language = userenv('LANG')
      --AND rac_bill.cust_account_id = ct.sold_to_customer_id
   AND rac_bill.cust_account_id = ct.bill_to_customer_id --modify by Orne.Dai 2019-01-25 用收单方作为客户
      
   AND rac_bill_party.party_id = rac_bill.party_id
   AND xle.source_id_int_1 = ct.customer_trx_id
   AND xle.ledger_id = ct.set_of_books_id
   AND xle.entity_code = 'TRANSACTIONS'
   AND xah.entity_id = xle.entity_id
   AND xah.application_id = xle.application_id
   AND xal.ae_header_id = xah.ae_header_id
   AND xal.application_id = xah.application_id
   AND gcc.code_combination_id = xal.code_combination_id
      --Modify By Kevin.Liu@2018/10/26 将hardcode的会计科目替换为动态参数
   AND gcc.segment3 = '1122010101' /*'1122010101'*/
      --Modify End
   AND hou.organization_id = ct.org_id
   AND hou.set_of_books_id = 2021
      --为避免日后调账后无法正确取值,修改创建日期为入账日期
      /*AND trunc(xah.creation_date) BETWEEN trunc(g_start_date) AND
      trunc(to_date('2018-09-30','YYYY-MM-DD'))*/
      --AND trunc(xah.accounting_date) BETWEEN trunc(g_start_date) AND trunc(to_date('2018-09-30','YYYY-MM-DD'))
   AND trunc(xah.accounting_date) <=
       trunc(to_date('2018-09-30', 'YYYY-MM-DD')) --modify by Orne.Dai 2019-01-25 同时取期初和本期的数据
      --Modify End
   AND ct.invoice_currency_code = nvl('CNY', ct.invoice_currency_code)
   AND rac_bill_party.party_number = '7467'

 GROUP BY ct.trx_number,
          ct.bill_to_customer_id, --ct.sold_to_customer_id, modify by Orne.Dai 2019-01-25
          rac_bill_party.party_number --单位编号
         ,
          rac_bill_party.party_name --单位名称
         ,
          ct.invoice_currency_code,
          fc.name, --币种
          to_char(xah.accounting_date, 'YYYY-MM') --add by Orne.Dai 2019-01-25
UNION ALL
SELECT '2 ar_cash_receipts_all' src,
       acr.receipt_number num2,
       
       COUNT(*) counts,
       hca.cust_account_id,
       hp.party_number,
       hp.party_name,
       acr.currency_code,
       fc.name currency_name,
       nvl(SUM(xal.entered_dr), 0) entered_dr,
       nvl(SUM(xal.entered_cr), 0) entered_cr,
       nvl(SUM(xal.accounted_dr), 0) accounted_dr,
       nvl(SUM(xal.accounted_cr), 0) accounted_cr,
       to_char(xah.accounting_date, 'YYYY-MM') --add by Orne.Dai 2019-01-25 增加期间区分期初和本期金额
  FROM apps.ar_cash_receipts_all acr,
       apps.fnd_currencies_tl    fc
       /*,ar_receivable_applications_all app
       ,ar_payment_schedules_all       sche*/,
       apps.hz_cust_site_uses_all su
       
      ,
       apps.hz_cust_acct_sites_all   bb,
       apps.hz_cust_accounts         hca,
       apps.hz_parties               hp,
       xla.xla_transaction_entities  xle,
       xla.xla_ae_headers            xah,
       xla.xla_ae_lines              xal,
       apps.gl_code_combinations_kfv gcc,
       apps.hr_operating_units       hou
 WHERE fc.currency_code = acr.currency_code
   AND fc.language = userenv('LANG')
      /*AND app.cash_receipt_id = acr.cash_receipt_id
      AND app.display = 'Y'
      AND sche.payment_schedule_id = app.applied_payment_schedule_id*/
   AND su.site_use_id = acr.customer_site_use_id
   AND bb.cust_acct_site_id = su.cust_acct_site_id
   AND hca.cust_account_id = bb.cust_account_id
      --AND hca.cust_account_id = sche.customer_id
   AND hp.party_id = hca.party_id
   AND xle.source_id_int_1 = acr.cash_receipt_id
   AND xle.ledger_id = acr.set_of_books_id
   AND xle.entity_code = 'RECEIPTS'
   AND xah.entity_id = xle.entity_id
   AND xah.application_id = xle.application_id
   AND xal.ae_header_id = xah.ae_header_id
   AND xal.application_id = xah.application_id
   AND gcc.code_combination_id = xal.code_combination_id
      --Modify By Kevin.Liu@2018/10/26 将hardcode的会计科目替换为动态参数
   AND gcc.segment3 = '1122010101' /*'1122010101'*/
      --AND (1 = 1 AND '1122010101' <> '2203010101' OR ('1122010101' = '2203010101' AND acr.status = 'UNAPP')) delete by Orne.Dai 2019-02-26 去掉未核销限制
      --Modify End
   AND hou.organization_id = acr.org_id
   AND hou.set_of_books_id = 2021
      --Modify By Kevin.Liu@2018/11/5
      --为避免日后调账后无法正确取值,修改创建日期为入账日期
      /*AND trunc(xah.creation_date) BETWEEN trunc(g_start_date) AND
      trunc(to_date('2018-09-30','YYYY-MM-DD'))*/
   AND trunc(xah.accounting_date) <=
       trunc(to_date('2018-09-30', 'YYYY-MM-DD')) --modify by Orne.Dai 2019-01-25 同时取期初和本期的数据
      --  AND trunc(xah.accounting_date) BETWEEN trunc(g_start_date) AND trunc(to_date('2018-09-30','YYYY-MM-DD'))
      --Modify End
   AND acr.currency_code = nvl('CNY', acr.currency_code)
   AND hp.party_number = '7467'

 GROUP BY acr.receipt_number,
          hca.cust_account_id,
          hp.party_number,
          hp.party_name,
          acr.currency_code,
          fc.name,
          to_char(xah.accounting_date, 'YYYY-MM') --add by Orne.Dai 2019-01-25
UNION ALL
SELECT '3 gl_je_headers' src,
       to_char(jh.doc_sequence_value) num2,
       COUNT(*) counts,
       hca.cust_account_id,
       hzp.party_number,
       hzp.party_name,
       jh.currency_code,
       fc.name currency_name,
       nvl(SUM(jl.entered_dr), 0) entered_dr,
       nvl(SUM(jl.entered_cr), 0) entered_cr,
       nvl(SUM(jl.accounted_dr), 0) accounted_dr,
       nvl(SUM(jl.accounted_cr), 0) accounted_cr,
       to_char(jh.default_effective_date, 'YYYY-MM') period --add by Orne.Dai 2019-01-25 增加期间区分期初和本期金额
  FROM apps.gl_je_headers            jh,
       apps.gl_je_lines              jl,
       apps.gl_code_combinations_kfv gcc,
       apps.hz_parties               hzp,
       apps.hz_cust_accounts         hca,
       apps.fnd_currencies_tl        fc
 WHERE jh.je_header_id = jl.je_header_id
   AND jh.je_source <> 'Receivables'
   AND gcc.code_combination_id = jl.code_combination_id
   AND hzp.party_id = hca.party_id
   AND hca.cust_account_id = jl.attribute2
   AND jh.status = 'P'
   AND gcc.segment3 = '1122010101' /*'1122010101'*/
   AND fc.currency_code = jh.currency_code
   AND fc.language = userenv('LANG')
   AND jh.ledger_id = 2021
   AND jh.currency_code = nvl('CNY', jh.currency_code)
      /*   AND trunc(jh.default_effective_date) BETWEEN trunc(nvl(g_start_date
                                                            ,jh.default_effective_date)) AND
      trunc(nvl(to_date('2018-09-30','YYYY-MM-DD')
               ,jh.default_effective_date))*/
   AND trunc(jh.default_effective_date) <=
       trunc(to_date('2018-09-30', 'YYYY-MM-DD')) --modify by Orne.Dai 2019-01-25 同时取期初和本期的数据
   AND hzp.party_number = '7467'
 GROUP BY jh.doc_sequence_value,
          hca.cust_account_id,
          hzp.party_number,
          hzp.party_name,
          jh.currency_code,
          fc.name,
          to_char(jh.default_effective_date, 'YYYY-MM') --add by Orne.Dai 2019-01-25
;
