/*CURSOR cur_ar(p_customer_trx_id NUMBER) IS*/
SELECT substrb(rt.attribute10, 1, 4),
       rt.attribute10,
       arpt_sql_func_util.get_first_real_due_date(rct.customer_trx_id, rct.term_id, rct.trx_date) due_date,
       ifa.payment_channel_name
  FROM ra_customer_trx_all           rct,
       ra_terms                      rt,
       ar_receipt_methods            arm,
       iby_fndcpt_all_pmt_channels_v ifa
 WHERE rct.term_id = rt.term_id(+)
   AND rct.customer_trx_id = 4519736 --p_customer_trx_id
   AND arm.receipt_method_id(+) = rct.receipt_method_id
   AND arm.payment_channel_code = ifa.payment_channel_code(+);

SELECT xx.name "PaymentTerm in GSCM",
       xx.description,
       substrb(xx.attribute10, 1, 4) "PaymentTerm in HFA",
       xx.attribute10/*,
       xx.created_by,
       xx.*/
  FROM ra_terms xx
 WHERE 1 = 1
   AND nvl(xx.end_date_active, SYSDATE) <= SYSDATE
   AND xx.attribute10 IS NOT NULL
   ORDER BY xx.attribute10
   --AND xx.created_by = 4411
   ;

/*CURSOR cur_ap(p_invoice_id NUMBER) IS*/
SELECT substrb(ai.attribute9, 1, 1)
       --,substr(ipm.payment_method_name, 1, 1)
      ,
       substrb(at.attribute10, 1, 4),
       aps.due_date
  FROM ap_invoices_all        ai,
       iby_payment_methods_vl ipm,
       ap_payment_schedules   aps,
       ap_terms               at
 WHERE ai.payment_method_code = ipm.payment_method_code(+)
   AND ai.invoice_id = aps.invoice_id
   AND ai.terms_id = at.term_id(+)
   AND ai.invoice_id = p_invoice_id;

SELECT xx.name "PaymentTerm in GSCM",
       xx.description,
       xx.attribute10 "PaymentTerm in HFA",
       xx.created_by
       --,xx.*
  FROM ap_terms xx
 WHERE 1 = 1
 --AND xx.name = '100DD'
   --AND xx.created_by = 4411
   AND nvl(xx.end_date_active, SYSDATE) <= SYSDATE
   AND xx.attribute10 IS NOT NULL
   ORDER BY xx.attribute10
   ;
