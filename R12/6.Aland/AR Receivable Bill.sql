/*
BEGIN
  fnd_global.apps_initialize(user_id      => 1670
                            ,resp_id      => 50717
                            ,resp_appl_id => 20003); 
 mo_global.init('CUX');
 mo_global.set_policy_context('M',NULL);
END;
*/

SELECT cr.receipt_number,
       cr.amount,
       ra.org_id,
       ra.trx_number,
       ar.amount_applied,
       ar.status
  FROM apps.ar_cash_receipts_all           cr,
       apps.ar_receivable_applications_all ar,
       apps.ra_customer_trx_all            ra
 WHERE 1 = 1
   AND cr.cash_receipt_id = ar.cash_receipt_id
      --AND cr.cash_receipt_id = 
   AND cr.receipt_number = '131073100001320181220310353773' --'121' --'50011220150703917'
      --and ar.amount_applied = -3817.5
      --and ar.status = 'APP'
   AND ar.applied_customer_trx_id = ra.customer_trx_id(+);

SELECT cr.receipt_method_id,
       cr.org_id,
       cr.cash_receipt_id,
       cr.receipt_number,
       cr.amount,
       cr.status /*,
       ra.org_id,
       ra.trx_number,
       ar.amount_applied,
       ar.status*/
  FROM apps.ar_cash_receipts_all cr --,
 WHERE 1 = 1
   AND cr.receipt_number = 'HAKIM20190319001' --'131073100001320181220310353773'
   AND cr.org_id = 81
   AND cr.receipt_method_id = 3000;

SELECT * FROM apps.ar_receipt_methods WHERE 1 = 1;
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

--Remittance 汇款
SELECT aba.type                       批类型,
       aba.name                       批号,
       aba.batch_date,
       aba.gl_date,
       aba.remittance_bank_branch_id,
       aba.remittance_bank_account_id,
       aba.remit_method_code, --汇款方法 factoring 贴现收款
       aba.receipt_class_id, --分类
       aba.receipt_method_id, --方法
       aba.batch_applied_status       处理状态,
       aba.control_count,
       aba.control_amount,
       aba.operation_request_id       请求编号,
       --aba.status,
       aba.*
  FROM apps.ar_batches_all aba
 WHERE 1 = 1
   AND aba.name = 1063;
--AR_BATCHES_V

--汇款行
--boe_remit_receipts

  SELECT /*+ 
                   push_pred(AR_BOE_REMIT_RECEIPTS_CBR_V.BB )
                   push_pred(AR_BOE_REMIT_RECEIPTS_CBR_V.IBY )
                   push_pred(AR_BOE_REMIT_RECEIPTS_CBR_V.PS)
                   push_pred(AR_BOE_REMIT_RECEIPTS_CBR_V.BA)
                   push_pred(AR_BOE_REMIT_RECEIPTS_CBR_V.BA.OU )
                   */
   receipt_method_name,
   receipt_number,
   override_flag,
   remit_bank_account_number,
   customer_bank_account_number,
   receipt_date,
   maturity_date,
   remit_bank_name,
   remit_bank_branch_name,
   bank_charges,
   customer_bank_name,
   customer_bank_branch_name,
   customer_name,
   customer_number,
   row_id,
   remittance_bank_branch_id,
   remittance_bank_account_id,
   customer_bank_account_id,
   customer_bank_branch_id,
   batch_bank_account_id,
   receipt_method_id,
   amount,
   batch_id,
   remit_method_code,
   selection_type,
   currency_code,
   selected_remittance_batch_id,
   pay_from_customer,
   customer_site_use_id,
   cash_receipt_id,
   cash_receipt_history_id,
   payment_schedule_id,
   payment_trxn_extension_id,
   payment_channel_code,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15
    FROM ar_boe_remit_receipts_cbr_v
   WHERE (batch_id = 4023)
     AND (selection_type LIKE 'CURRENT_BATCH_REMITTED');
     
     
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
