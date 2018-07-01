SELECT --xah.period_name,
xte.application_id,
xah.application_id,
 concatenated_segments,
 gcc.segment5 Project,
 xah.je_category_name,
 xte.entity_code,
 xte.security_id_int_1,
 xte.transaction_number,
 xal.accounting_date,
 xal.accounting_class_code,
 nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)
  FROM apps.xla_ae_lines             xal,
       apps.gl_code_combinations_kfv gcc,
       apps.xla_ae_headers           xah,
       xla.xla_transaction_entities  xte
 WHERE 1 = 1
   AND gcc.code_combination_id = xal.code_combination_id
   AND gcc.segment3 in ('1145500000','1161500990')
   AND gcc.segment5 in ('11001262')--('112100048', '12001478') 
   --���Բ��ϵ�Project Number(��ƿ�Ŀ�е��������У���ʾproject number)
   AND xah.ae_header_id = xal.ae_header_id
 AND xah.application_id = xal.application_id 
      AND xah.period_name = 'APR-17'
   AND xah.ledger_id = 2021--HEA
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
order by gcc.segment5,
xte.entity_code,
xte.security_id_int_1,
xte.transaction_number
