/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
END;*/

SELECT substrb(ai.attribute9, 1, 1)
             --,substr(ipm.payment_method_name, 1, 1)
            ,
             substrb(at.attribute10, 1, 4),
             aps.due_date,
             ai.attribute9,
             at.attribute10
        FROM ap_invoices_all        ai,
             iby_payment_methods_vl ipm,
             ap_payment_schedules   aps,
             ap_terms               at
       WHERE ai.payment_method_code = ipm.payment_method_code(+)
         AND ai.invoice_id = aps.invoice_id
         AND ai.terms_id = at.term_id(+)
         AND ai.invoice_id = 1950254--p_invoice_id;
         ;
         SELECT * FROM ap_invoices_all aph
         WHERE 1=1
         AND aph.invoice_id = 1950254;
