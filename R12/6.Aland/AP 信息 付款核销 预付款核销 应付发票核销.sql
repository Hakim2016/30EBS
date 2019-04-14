/*
BEGIN
  fnd_global.apps_initialize(user_id      => 1670
                            ,resp_id      => 50717
                            ,resp_appl_id => 20003); 
 mo_global.init('CUX');
 mo_global.set_policy_context('M',NULL);
END;
*/

--ar haeder/ line
SELECT

 aph.org_id,
 aph.invoice_id,
 aps.vendor_name,
 --apl.creation_date,
 aph.invoice_date,
 aph.invoice_type_lookup_code h_type, /*
       apl.last_update_date,
       apl.last_updated_by,*/
 --apl.description,
 --apl.amount line_amt,
 aph.invoice_num,
 aph.invoice_amount inv_amt,
 --aph.APPROVED_AMOUNT,
 aph.amount_paid           amt_paid,
 apl.line_number           l_num,
 apl.line_type_lookup_code l_type,
 apl.amount                l_amt,
 aph.attribute_category,
 aph.attribute8,
 aph.*,
 apl.*
  FROM ap_invoices_all aph, ap_invoice_lines_all apl, ap_suppliers aps
--,ap_view_prepays_fr_prepay_v v
 WHERE 1 = 1
   AND aph.invoice_id = apl.invoice_id
   AND aph.org_id = 81 --7905--82 --101 --82
      /*AND aph.invoice_num IN --LIKE 'USD%YUL%'
      ('26934330')*/
   AND aph.vendor_id = aps.vendor_id
      --AND aps.SEGMENT1 = '00000833'
   AND aps.vendor_name = '河北华荣制药有限公司' --'上海祥源生物科技有限公司' --'上海仰空实业有限公司'
      --AND aph.vendor_id = 1799
      --AND trunc(aph.INVOICE_DATE) = to_date('2018-08','yyyy-mm')
      --AND aph.AMOUNT_PAID <> aph.INVOICE_AMOUNT
      
   AND aph.invoice_date >= to_date('2018-08-01', 'yyyy-mm-dd')
   AND aph.invoice_date <= to_date('2018-08-31', 'yyyy-mm-dd') + 0.99999
/*
   --AND aps.SEGMENT1 = '00000833'
AND v.vendor_id = aph.vendor_id
   --AND v.prepay_id = apl.pre
AND v.invoice_id = aph.invoice_id
AND v.invoice_line_number = apl.line_number*/
;

--AP_INVOICE_PAYMENT_HISTORY_V

--ar haeder/ line
SELECT apl.line_number,
       apl.line_type_lookup_code,
       v.invoice_num,
       v.payment_num,
       v.*,
       aph.org_id,
       aph.invoice_id,
       aps.vendor_name,
       --apl.creation_date,
       aph.invoice_date,
       aph.invoice_type_lookup_code h_type, /*
                   apl.last_update_date,
                   apl.last_updated_by,*/
       --apl.description,
       --apl.amount line_amt,
       aph.invoice_num,
       aph.invoice_amount inv_amt,
       --aph.APPROVED_AMOUNT,
       aph.amount_paid           amt_paid,
       apl.line_number           l_num,
       apl.line_type_lookup_code l_type,
       apl.amount                l_amt,
       aph.attribute_category,
       aph.attribute8,
       aph.*,
       apl.*
  FROM ap_invoices_all              aph,
       ap_invoice_lines_all         apl,
       ap_suppliers                 aps,
       ap_invoice_payment_history_v v
--,ap_view_prepays_fr_prepay_v v
 WHERE 1 = 1
   AND v.invoice_id = aph.invoice_id
      --AND v.CHECK_ID
      --AND v.
   AND aph.invoice_id = apl.invoice_id
   AND aph.org_id = 81 --7905--82 --101 --82
   AND aph.invoice_num IN --LIKE 'USD%YUL%'
       ('CLQC201808154')
   AND aph.vendor_id = aps.vendor_id
      --AND aps.SEGMENT1 = '00000833'
   AND aps.vendor_name = '河北华荣制药有限公司' --'上海祥源生物科技有限公司' --'上海仰空实业有限公司'
      --AND aph.vendor_id = 1799
      --AND trunc(aph.INVOICE_DATE) = to_date('2018-08','yyyy-mm')
      --AND aph.AMOUNT_PAID <> aph.INVOICE_AMOUNT
      --AND apl.LINE_NUMBER
   AND apl.line_type_lookup_code = 'ITEM'
   AND aph.invoice_date >= to_date('2018-08-01', 'yyyy-mm-dd')
   AND aph.invoice_date <= to_date('2018-08-31', 'yyyy-mm-dd') + 0.99999
/*
   --AND aps.SEGMENT1 = '00000833'
AND v.vendor_id = aph.vendor_id
   --AND v.prepay_id = apl.pre
AND v.invoice_id = aph.invoice_id
AND v.invoice_line_number = apl.line_number*/
;

SELECT v.period_name,
       v.document_number,
       v.payment_method,
       v.void,
       v.invoice_id,
       v.invoice_num,
       v.invoice_date,
       v.invoice_amount,
       v.amount_paid,
       v.*
  FROM ap_invoice_payment_history_v v,
       ap_invoices_all              aph,
       ap_suppliers                 aps
 WHERE 1 = 1
   AND v.org_id = 81
   AND v.invoice_id = aph.invoice_id
   AND aph.vendor_id = aps.vendor_id
   AND aps.vendor_name = '河北华荣制药有限公司'
   AND v.period_name = '2018-08'
   AND v.void = 'N'
--AND v.invoice_num IN ()
;

--ar haeder/ line / prepay info
SELECT

 aph.org_id,
 aph.invoice_id,
 apl.creation_date, /*
       apl.last_update_date,
       apl.last_updated_by,*/
 --apl.description,
 --apl.amount line_amt,
 aph.invoice_num,
 aph.invoice_amount inv_amnt,
 --aph.APPROVED_AMOUNT,
 aph.amount_paid amt_paid,
 apl.line_number l_num,
 (SELECT aph2.invoice_num
    FROM ap_invoices_all aph2
   WHERE 1 = 1
     AND aph2.invoice_id = v.prepay_invoice_id) pre_inv_num,
 apl.amount l_amnt,
 apl.line_type_lookup_code l_type,
 aph.attribute_category,
 aph.attribute8,
 v.prepay_invoice_id,
 v.*,
 aph.*,
 apl.*
  FROM ap_invoices_all             aph,
       ap_invoice_lines_all        apl,
       ap_view_prepays_fr_prepay_v v,
       ap_suppliers                aps
 WHERE 1 = 1
   AND aph.vendor_id = aps.vendor_id
      --AND aps.SEGMENT1 = '00000833'
   AND v.vendor_id = aph.vendor_id
      --AND v.prepay_id = apl.pre
   AND v.invoice_id = aph.invoice_id
   AND v.invoice_line_number = apl.line_number
   AND aph.invoice_id = apl.invoice_id
   AND aph.org_id = 81 --7905--82 --101 --82
      /*AND aph.invoice_num IN --LIKE 'USD%YUL%'
      ('26934330')*/
      --AND v.invoice_num = '26934330'
      --AND aph.AMOUNT_PAID <> aph.INVOICE_AMOUNT
      
      --AND aph.invoice_id = 33650--30418--19067
   AND aps.vendor_name = '河北华荣制药有限公司' --'上海祥源生物科技有限公司' --'上海仰空实业有限公司'
      --AND trunc(aph.INVOICE_DATE) = to_date('2018-08','yyyy-mm')
      --AND aph.AMOUNT_PAID <> aph.INVOICE_AMOUNT
   AND aph.invoice_date >= to_date('2018-08-01', 'yyyy-mm-dd')
   AND aph.invoice_date <= to_date('2018-08-31', 'yyyy-mm-dd') + 0.99999;

--ap_view_prepays_fr_prepay_v

SELECT app.invoice_id,
       app.invoice_num,
       (SELECT aph.invoice_type_lookup_code
          FROM ap_invoices_all aph
         WHERE 1 = 1
           AND aph.invoice_id = app.invoice_id) inv_typ,
       app.accounting_date,
       app.amount,
       
       apc.check_id,
       apc.check_number,
       apc.amount,
       apc.payment_method_code,
       apc.future_pay_due_date 到期日,
       apc.status_lookup_code,
       apc.void_date,
       apc.*
  FROM ap_checks_all apc, ap_suppliers aps, ap_invoice_payments_v app
 WHERE 1 = 1
   AND apc.vendor_id = aps.vendor_id
      --AND aps.segment1 = '00000619'
   AND app.check_id = apc.check_id
   AND apc.payment_method_code = 'BILLS_PAYABLE'
      --AND aps.vendor_name = '河北华荣制药有限公司'
      --AND apc.status_lookup_code = 'VOIDED'
      --AND apc.check_date >= to_date('2018-08-01', 'yyyy-mm-dd')
      --AND apc.check_date <= to_date('2018-08-31', 'yyyy-mm-dd') + 0.99999
   AND EXISTS
 (SELECT 1
          FROM ap_invoices_all aph
         WHERE 1 = 1
           AND aph.invoice_id = app.invoice_id
           AND aph.invoice_type_lookup_code = 'PREPAYMENT')
           ;

SELECT *
  FROM ap_suppliers aps
 WHERE 1 = 1
   AND aps.vendor_name = '上海祥源生物科技有限公司' --'上海仰空实业有限公司' 
--VENDOR_ID = 33650--33650;
;
