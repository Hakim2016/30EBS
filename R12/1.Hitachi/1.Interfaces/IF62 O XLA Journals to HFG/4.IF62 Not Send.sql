--发送异常的请求
SELECT *
  FROM xxgl_acct_int_error a
 WHERE a.creation_date > SYSDATE - 20;
--正常的单据查询 应收发票
SELECT xhi.*
  FROM apps.ra_customer_trx_all     aia,
       xla.xla_transaction_entities xta,
       xla_ae_headers               xah,
       xxgl_accounting_hfg_int      xhi
 WHERE aia.trx_number = '65020650'
   AND xta.source_id_int_1 = aia.customer_trx_id
   AND xta.application_id = 222
   AND xta.entity_code = 'TRANSACTIONS'
   AND xah.entity_id = xta.entity_id
   AND xah.ae_header_id = xhi.source_header_id;

--正常的单据查询 应付发票
SELECT xhi.*
  FROM apps.ap_invoices_all         aia,
       xla.xla_transaction_entities xta,
       xla_ae_headers               xah,
       xxgl_accounting_hfg_int      xhi
 WHERE aia.invoice_num = --'SG00043803*7'--'65020650'
   AND xta.source_id_int_1 = aia.invoice_id
   AND xta.application_id = 200
   AND xta.entity_code = 'AP_INVOICES'
   AND xah.entity_id = xta.entity_id
   AND xah.ae_header_id = xhi.source_header_id;

SELECT xhi.xblnr         ap_num,
       xhi.zuonr         po_num,
       xhi.linno,
       xah.event_id,
       aia.creation_date inv_date,
       xhi.creation_date itf_date,
       xah.ae_header_id,
       xhi.dr_cr_flag    d_c,
       xhi.wrbtr         entered,
       xhi.dmbtr         accounted,
       xhi.*
  FROM apps.ap_invoices_all         aia,
       xla.xla_transaction_entities xta,
       xla_ae_headers               xah,
       xxgl_accounting_hfg_int      xhi
 WHERE aia.invoice_num = '210-702-004' --'SG00043803*8'--'SG00043803*7'--'65020650'
   AND xta.source_id_int_1 = aia.invoice_id
   AND xta.application_id = 200
   AND xta.entity_code = 'AP_INVOICES'
   AND xah.entity_id = xta.entity_id
   AND xah.ae_header_id = xhi.source_header_id;
