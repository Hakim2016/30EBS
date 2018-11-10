SELECT aia.created_by,
       aia.last_updated_by,
       aia.invoice_id,
       aia.org_id
  FROM ap_invoices_all aia
 WHERE 1 = 1
   AND aia.invoice_num = '0612001'
   FOR UPDATE;
-- 279380

SELECT ail.created_by,
       ail.last_updated_by
  FROM ap_invoice_lines_all ail
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM ap_invoices_all aia
         WHERE 1 = 1
           AND aia.invoice_id = ail.invoice_id
           AND aia.invoice_num = '0612001')
   FOR UPDATE;

SELECT aid.created_by,
       aid.last_updated_by,
       aid.last_update_date
  FROM ap_invoice_distributions_all aid
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM ap_invoices_all aia
         WHERE 1 = 1
           AND aia.invoice_id = aid.invoice_id
           AND aia.invoice_num = '0612001')
   FOR UPDATE;

SELECT xte.created_by,
       xte.last_updated_by,
       xte.last_update_date
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM ap_invoices_all aia
         WHERE 1 = 1
           AND xte.application_id = 200
           AND aia.invoice_id = xte.source_id_int_1
           AND aia.invoice_num = '0612001')
   FOR UPDATE;

SELECT xe.created_by,
       xe.last_updated_by,
       xe.last_update_date
  FROM xla.xla_events xe
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM xla.xla_transaction_entities xte,
               ap_invoices_all              aia
         WHERE 1 = 1
           AND xte.entity_id = xe.entity_id
           AND xte.application_id = xe.application_id
           AND xte.application_id = 200
           AND aia.invoice_id = xte.source_id_int_1
           AND aia.invoice_num = '0612001')
   FOR UPDATE;

SELECT xah.created_by,
       xah.last_updated_by,
       xah.last_update_date
  FROM xla.xla_ae_headers xah
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM xla.xla_events               xe,
               xla.xla_transaction_entities xte,
               ap_invoices_all              aia
         WHERE 1 = 1
           AND xah.event_id = xe.event_id
           AND xah.entity_id = xe.entity_id
           AND xah.application_id = xe.application_id
           AND xte.entity_id = xe.entity_id
           AND xte.application_id = xe.application_id
           AND xte.application_id = 200
           AND aia.invoice_id = xte.source_id_int_1
           AND aia.invoice_num = '0612001');

SELECT xal.created_by,
       xal.last_updated_by,
       xal.last_update_date
  FROM xla.xla_ae_lines xal
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM xla.xla_ae_headers           xah,
               xla.xla_events               xe,
               xla.xla_transaction_entities xte,
               ap_invoices_all              aia
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND xah.event_id = xe.event_id
           AND xah.entity_id = xe.entity_id
           AND xah.application_id = xe.application_id
           AND xte.entity_id = xe.entity_id
           AND xte.application_id = xe.application_id
           AND xte.application_id = 200
           AND aia.invoice_id = xte.source_id_int_1
           AND aia.invoice_num = '0612001') /* FOR UPDATE*/
;

SELECT fu.*
  FROM fnd_user     fu,
       hr_employees he
 WHERE 1 = 1
      --   AND fu.user_id = 2283 -- 1143 -- 1149
   AND fu.user_name = '70240448'
   AND fu.employee_id = he.employee_id;
