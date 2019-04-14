SELECT cr.receipt_number "票号",
       cr.currency_code "币种",
       cr.amount "金额",
       cr.receipt_date "收款日期",
       crh_first_posted.gl_date "GL日期",
       ps.due_date "到期日",
       crh_current.status "收款状态",
       cust.account_number "客户编码",
       party.party_name "客户名称",
       rem_bat.name "汇款批",
       rem_bat.remit_method_code "汇款分类",
       cba.bank_account_num "汇款账户",
       decode(rem_bat.remit_method_code,
              'FACTORING',
              '贴现收款',
              'STANDARD',
              '标准',
              rem_bat.remit_method_code) "汇款方法",
       apc.check_number "支付编号",
       apc.bank_account_name "支付账户",
       apc.check_date "支付日期",
       /*apc.state,
       apc.status_lookup_code,*/
       decode(cba.bank_account_num,
              '背书中转',
              decode(apc.check_number, NULL, '持有', '转让'),
              decode(crh_current.status,
                     'CONFIRMED',
                     '持有',
                     'REMITTED',
                     '持有',
                     'CLEARED',
                     '到期',
                     'RISK_ELIMINATED',
                     '到期')) "状态"
  FROM ar.ar_cash_receipts_all        cr,
       ar.ar_cash_receipt_history_all crh_current,
       ar.ar_cash_receipt_history_all crh_rem,
       ar.ar_batches_all              rem_bat,
       ar.ar_cash_receipt_history_all crh_first_posted,
       ar.ar_payment_schedules_all    ps,
       ar.hz_cust_accounts            cust,
       ar.hz_parties                  party,
       ce.ce_bank_acct_uses_all       ba,
       ce.ce_bank_accounts            cba,
       ap.ap_checks_all               apc
 WHERE cr.receipt_method_id = 3000
   AND crh_current.cash_receipt_id = cr.cash_receipt_id
   AND crh_current.org_id = cr.org_id
   AND crh_current.current_record_flag = nvl('Y', cr.receipt_number)
   AND crh_rem.cash_receipt_id(+) = cr.cash_receipt_id
   AND crh_rem.org_id(+) = cr.org_id
   AND NOT EXISTS
 (SELECT cash_receipt_history_id
          FROM ar.ar_cash_receipt_history_all crh3
         WHERE crh3.status = 'REMITTED'
           AND crh3.cash_receipt_id = cr.cash_receipt_id
           AND crh3.cash_receipt_history_id <
               crh_rem.cash_receipt_history_id)
   AND crh_rem.status(+) = 'REMITTED'
   AND crh_rem.batch_id = rem_bat.batch_id(+)
   AND crh_rem.org_id = rem_bat.org_id(+)
   AND rem_bat.type(+) = 'REMITTANCE'
   AND crh_first_posted.cash_receipt_id(+) = cr.cash_receipt_id
   AND crh_first_posted.org_id(+) = cr.org_id
   AND crh_first_posted.first_posted_record_flag(+) = 'Y'
   AND ps.cash_receipt_id(+) = cr.cash_receipt_id
   AND ps.org_id(+) = cr.org_id
   AND cr.pay_from_customer = cust.cust_account_id(+)
   AND cust.party_id = party.party_id(+)
   AND ba.bank_acct_use_id(+) = rem_bat.remit_bank_acct_use_id
   AND ba.org_id(+) = rem_bat.org_id
   AND ba.bank_account_id = cba.bank_account_id(+)
   AND cr.receipt_number = apc.attribute3(+)
      AND apc.status_lookup_code(+) <> 'VOIDED'·
   AND cr.org_id = 81
   AND apc.org_id(+) = 81
   AND cr.receipt_number IN ( 
   '110233201600020181128296585366',
'131322760701020180827244422693',
'131317500108020181012268995193',
'131316403002720181130299037407',
'131345100184320180511193100830',
'132311000000820181022273686831',
'131322100002820181129297314252',
'110259200231120181224312351380',
'150211000001420181211304040793',
'130865301805920181225312971187'

   --'110387101440220180816239902276'
   --'130661100002820190110323389474'
   --'30500053 27128379'
   --'HAKIM20190319001','HAKIM20190330002'
   --'131329001009620190124336961053'
   --'110233201600020181128296585366'
   /*'130661100002820190110323389474',
   '110555100408420190129342166157',
   '110382100311020190125337338247',
   '130565301102520190129342202508',
   '130661100002820190125337963504',
   '130661100002820190214348701831'*/
                             
                             );
