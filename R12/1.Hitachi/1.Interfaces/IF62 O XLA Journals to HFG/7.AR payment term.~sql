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

--ar
SELECT xx.creation_date,
       xx.name "PaymentTerm in GSCM",
       xx.description,
       substrb(xx.attribute10, 1, 4) "PaymentTerm in HFA",
       xx.attribute10,
       xx.created_by /*,
       xx.*/
  FROM ra_terms xx
 WHERE 1 = 1
   AND nvl(xx.end_date_active, SYSDATE) <= SYSDATE
   --AND xx.attribute10 IS NOT NULL
   --AND xx.created_by = 4411
 ORDER BY xx.attribute10;

/*Scripts to change payment term*/
SELECT *
  FROM ra_terms_b xx
 WHERE 1 = 1
   AND xx.created_by = 4411
 ORDER BY xx.attribute10;
--ap
SELECT xx.name        "PaymentTerm in GSCM",
       xx.description,
       xx.attribute10 "PaymentTerm in HFA",
       xx.created_by
--,xx.*
  FROM ap_terms xx
 WHERE 1 = 1
      --AND xx.name = '85TT'
      --AND xx.created_by = 4411
   AND nvl(xx.end_date_active, SYSDATE) <= SYSDATE
--AND xx.attribute10 IS NOT NULL
 ORDER BY xx.attribute10;

SELECT *
  FROM fnd_user xx
 WHERE 1 = 1
   AND xx.user_id = 4411;

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

SELECT xx.name        "PaymentTerm in GSCM",
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
 ORDER BY xx.attribute10;

----------------------------
--ar payment term
SELECT xx.creation_date,
       xx.name "PaymentTerm in GSCM",
       rtl.due_days,
       xx.description,
       substrb(xx.attribute10, 1, 4) "PaymentTerm in HFA",
       xx.attribute10,
       xx.created_by /*,
       xx.*/
  FROM ra_terms xx,
  ra_terms_lines rtl
 WHERE 1 = 1
 AND xx.term_id = rtl.term_id
   AND nvl(xx.end_date_active, SYSDATE) >= SYSDATE
   AND xx.attribute10 IS NOT NULL
   AND xx.name IN ('IMM','IMMS')
   --AND xx.created_by = 4411
 ORDER BY xx.attribute10;

FUNCTION get_payment_due_days(p_payment_term_id NUMBER) RETURN NUMBER IS
    l_due_days NUMBER;
  BEGIN
    IF p_payment_term_id IS NULL THEN
      RETURN 0;
    END IF;
    SELECT nvl(due_days, 0)
      INTO l_due_days
      FROM ra_terms_lines rtl
     WHERE rtl.term_id = p_payment_term_id
       AND rtl.relative_amount = 100
       AND rownum = 1;
    RETURN l_due_days;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END get_payment_due_days;
  
  
--logic from tax invoice hea
--so number when-validate-item
IF :headers.document_type = 'D' THEN
    :headers.due_date      := xxar_hea_tax_invoice_pvt.get_payment_due_days(:headers.payment_term_id) +
                                  :headers.invoice_date;
    :headers.interest_rate := NULL;
ELSE
    -- Oversea
    :headers.due_date := NULL;
END IF;

--DELIVERY_NUMBER when-validate-item
:headers.due_date := xxar_hea_tax_invoice_pvt.get_payment_due_days(:headers.payment_term_id) + l_etd_date;


--etd_date
SELECT xd.transport_name,
       xd.estimate_arrival_date,--预计到达客户现场时间
       xd.estimate_departure_date,--预计起航时间（发运时间）
       xd.ship_from_country
 /* INTO l_transpotation_code,
       :headers.eta_date,
       :headers.etd_date,
       :headers.ship_from*/
  FROM xxinv_deliveries   xd,
       fnd_territories_vl ft
 WHERE xd.delivery_id = :headers.case_delivery_id
   AND xd.ship_from_country = ft.territory_code(+);
