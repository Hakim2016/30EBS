SELECT ara.org_id,
       ara.applied_customer_trx_id,
       ct.cust_trx_type_id,
       ct.trx_number applied_trx_number,
       ctt.type,
       ara.customer_trx_id,
       ct_cm.trx_number,
       ara.cash_receipt_id,
       cr.receipt_number,
       ara.application_type,
       ara.amount_applied
  FROM ar_receivable_applications_all ara,
       ra_customer_trx_all            ct,
       ra_cust_trx_types_all          ctt,
       ra_customer_trx_all            ct_cm,
       ar_cash_receipts_all           cr
 WHERE 1 = 1
   AND ct.cust_trx_type_id = ctt.cust_trx_type_id
   AND ct.org_id = ctt.org_id
   AND ara.applied_customer_trx_id = ct.customer_trx_id
      --AND ara.application_type = 'CM'
   AND ara.customer_trx_id = ct_cm.customer_trx_id(+)
   AND ara.cash_receipt_id = cr.cash_receipt_id(+)
   AND ctt.type = 'CM'
   AND ara.display = 'Y'
 ORDER BY ara.org_id,
          ara.application_type;
