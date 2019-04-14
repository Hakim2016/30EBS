SELECT cr.receipt_number,
cr.RECEIPT_DATE �տ�����,
cr.MATURITY_DATE,
       cr.amount,
       ra.org_id,
       ra.trx_number,
       ar.amount_applied,
       ar.status
  FROM apps.AR_CASH_RECEIPTS_V           cr,
       apps.ar_receivable_applications_all ar,
       apps.ra_customer_trx_all            ra
 WHERE 1 = 1
   AND cr.cash_receipt_id = ar.cash_receipt_id
   AND cr.ORG_ID = 81
      --AND cr.cash_receipt_id = 
      AND cr.receipt_number --= '131073100001320181220310353773'--'121' --'50011220150703917'
      IN ('30500053 27128379')
      --and ar.amount_applied = -3817.5
      --and ar.status = 'APP'
   AND ar.applied_customer_trx_id = ra.customer_trx_id(+);

--Receipt with AR trx
SELECT acr.receipt_date,
       acr.receipt_number,
       v.customer_trx_id,
       acr.amount,
       acr.*
  FROM ar_cash_receipts_all acr, ar_receivable_applications_all v
 WHERE 1 = 1
   AND v.cash_receipt_id = acr.cash_receipt_id
   AND v.org_id = acr.org_id
      --AND acr.cash_receipt_id = 1004 --1000
   AND acr.receipt_number = '121' --'1700000592' --'HKMTOAP013160' --'2800000018'
   AND acr.org_id = 81 --7905--82
--AND acr.creation_date >= to_date('20180925','yyyymmdd')
;

SELECT * FROM hr_operating_units WHERE 1 = 1;
SELECT acr.receipt_date, acr.receipt_number, acr.amount, acr.*
  FROM ar_cash_receipts_all acr
 WHERE 1 = 1
      --AND acr.cash_receipt_id = 1004 --1000
      --AND ACR.RECEIPT_NUMBER = '1700000592' --'HKMTOAP013160' --'2800000018'
   AND acr.org_id = 7905 --82
--AND acr.creation_date >= to_date('20180925','yyyymmdd')

;

SELECT xe.event_id,
       xe.entity_id,
       xe.event_type_code,
       xte.entity_code,
       xte.transaction_number,
       xe.event_status_code   evt_sts,
       xe.process_status_code prc_sts,
       xte.*
  FROM xla_events xe, xla.xla_transaction_entities xte, xla_ae_headers xah
 WHERE 1 = 1
   AND xte.entity_id = xah.entity_id
   AND xte.application_id = xah.application_id
   AND xe.entity_id = xte.entity_id
   AND xe.application_id = xte.application_id
   AND xe.application_id = 222 --707
      --AND xe.creation_date >= trunc(SYSDATE)
   AND xe.event_id > 29975865;

SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND xte.application_id = 222
      --AND xte.entity_code = 'RECEIPTS'
      --AND xte.source_id_int_1 = 1297914
   AND xte.creation_date >= trunc(SYSDATE) - 2;

SELECT xe.creation_date, xe.*
  FROM xla_events xe
 WHERE 1 = 1
   AND xe.application_id = 222 --707
   AND xe.creation_date >= trunc(SYSDATE) - 2
   AND xe.event_id > 29975865;
