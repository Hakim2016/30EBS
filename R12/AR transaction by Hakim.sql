--ar transaction
--ar header

SELECT rct.org_id,rct.trx_number,rbs.name trx_source, rct.last_update_date,
       rct.*
  FROM ra_customer_trx_all rct,
  ra_batch_sources_all rbs
 WHERE 1 = 1
 AND rct.batch_source_id = rbs.batch_source_id
   --AND rct.trx_number IN ('JPE-18000050')--('10000017753')
   AND rct.trx_number LIKE '%TE1001894'
   AND rbs.name = 'SHE_TAX INVOICE'
   --AND rct.trx_date >= to_date('2018-02-01','yyyy-mm-dd')
   --AND rct.trx_date <= to_date('2018-02-28 23:59:59','yyyy-mm-dd hh24:mi:ss')
--AND rct.customer_trx_id = 4022542
;

SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND xte.application_id = 222
   AND xte.source_id_int_1 = 4292291--3586252
   ;

SELECT *
  FROM xla_ae_headers xah
 WHERE 1 = 1
   AND xah.application_id = 222
   AND xah.entity_id = 25134577;

SELECT rct.customer_trx_id,
       rct.trx_number,
       rct.creation_date    rct_created,
       rct.last_update_date rct_update,
       xte.creation_date    xte_created,
       xah.creation_date    xah_created,
       xah.gl_transfer_date
  FROM ra_customer_trx_all          rct,
       xla.xla_transaction_entities xte,
       xla_ae_headers               xah
 WHERE 1 = 1
   AND rct.customer_trx_id = xte.source_id_int_1
   AND xte.entity_id = xah.entity_id
   AND xte.application_id = 222 --AR
   AND rct.trx_number IN ('JPE-18000050') --('JPE-17000146', 'JPE-17000461')
;

SELECT *
  FROM ra_customer_trx_all       rct,
       ra_customer_trx_lines_all rctl
 WHERE 1 = 1
   AND rct.customer_trx_id = rctl.customer_trx_id
   AND rct.trx_number = 'JPE-17000146';