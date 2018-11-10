--base SQL
SELECT *
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl
 WHERE 1 = 1
   AND xte.entity_id = xah.entity_id
   AND xte.ledger_id = xah.ledger_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xte.entity_code = 'AP_INVOICES'
   AND xah.application_id = 200
   AND xal.application_id = 200
   AND xte.application_id = 200
   AND xdl.application_id = 200;

--Oracle VPD   
--AP by Hakim 
SELECT *
  FROM dba_policies dp
 WHERE 1 = 1
   AND dp.object_name IN ('XLA_TRANSACTION_ENTITIES', 'XLA_AE_HEADERS', 'XLA_AE_LINES');

SELECT *
  FROM xla.xla_transaction_entities xte, --need to add owner(Oracle VPD)
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl,
       ap_invoices_all              aph,
       ap_invoice_lines_all         apl,
       ap_invoice_distributions_all apd
 WHERE 1 = 1
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
      
   AND apd.invoice_distribution_id = xdl.source_distribution_id_num_1
      
   AND aph.invoice_id = apl.invoice_id
   AND aph.invoice_id = apd.invoice_id
   AND apl.line_number = apd.invoice_line_number
   AND xah.application_id = 200
   AND xal.application_id = 200
   AND xte.application_id = 200
   AND xdl.application_id = 200
   AND xte.entity_code = 'AP_INVOICES'
   AND xdl.source_distribution_type = 'AP_INV_DIST' --improve the efficient
   AND aph.invoice_num = '10005873';

SELECT *
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah
 WHERE 1 = 1
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xte.creation_date >= to_date('20180713', 'yyyymmdd')
   AND xte.application_id = 707
   AND xte.entity_code = 'MTL_ACCOUNTING_EVENTS';

--AR by Hakim   
SELECT *
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah
 WHERE xte.application_id = xah.application_id
   AND xte.entity_id = xah.entity_id
   AND xte.source_id_int_1 = 4206255 --ct.customer_trx_id
   AND xah.accounting_entry_status_code = 'F'
   AND xte.application_id = 222
   AND xte.entity_code = 'TRANSACTIONS';

SELECT DISTINCT xte.entity_code
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND xte.creation_date > SYSDATE - 360;

--start
/*
 source_distribution_type         description
1 'R'                              PA Expenditure 
2 AP_INV_DIST                      AP Invoice
3 RA_CUST_TRX_LINE_GL_DIST_ALL     AR Transaction
4 MTL_TRANSACTION_ACCOUNTS         Material Transaction
5 RCV_RECEIVING_SUB_LEDGER         RCV Transaction
6 WIP_TRANSACTION_ACCOUNTS         WIP Transaction
*/

-- PA Expenditure
SELECT xdl.application_id,
       xdl.ae_header_id,
       xdl.ae_line_num,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       xte.entity_code,
       pei.project_id,
       ppa.segment1 project_number,
       pei.task_id,
       pt.task_number
  FROM xla.xla_distribution_links   xdl,
       xla.xla_ae_headers           xah,
       xla.xla_transaction_entities xte,
       pa_expenditure_items_all     pei,
       pa_projects_all              ppa,
       pa_tasks                     pt
 WHERE 1 = 1
   AND xdl.ae_header_id = 2383042
      --AND xdl.ae_line_num = 1
   AND xdl.application_id = 275
   AND xdl.source_distribution_type = 'R'
   AND xdl.application_id = xah.application_id
   AND xdl.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xte.entity_code = 'EXPENDITURES'
   AND xdl.source_distribution_id_num_1 = pei.expenditure_item_id
   AND pei.project_id = ppa.project_id
   AND pei.task_id = pt.task_id
--AND xdl.source_distribution_id_num_1 = 1813247
;

-- AP Invoice
SELECT xte.entity_code,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       aid.distribution_line_number,
       aid.invoice_line_number,
       ail.line_number,
       aia.invoice_num,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla.xla_ae_headers           xah,
       xla.xla_ae_lines             xal,
       xla.xla_distribution_links   xdl,
       ap_invoice_distributions_all aid,
       ap_invoice_lines_all         ail,
       ap_invoices_all              aia
 WHERE 1 = 1
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xal.ae_header_id = xah.ae_header_id
   AND xdl.ae_header_id = xal.ae_header_id
   AND xdl.ae_line_num = xal.ae_line_num
   AND xdl.application_id = 200
   AND xdl.source_distribution_type = 'AP_INV_DIST'
   AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
   AND aid.invoice_id = ail.invoice_id
   AND aid.invoice_line_number = ail.line_number
   AND ail.invoice_id = aia.invoice_id
   AND aia.invoice_num = '10005873';

-- AR Transaction
SELECT xdl.ae_header_id,
       xdl.ae_line_num,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       xte.entity_code,
       rctd.*
  FROM xla.xla_distribution_links   xdl,
       xla.xla_ae_headers           xah,
       xla.xla_transaction_entities xte,
       ra_cust_trx_line_gl_dist_all rctd
 WHERE 1 = 1
   AND xdl.application_id = 222
   AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND xdl.application_id = xah.application_id
   AND xdl.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
   AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xdl.source_distribution_id_num_1 = rctd.cust_trx_line_gl_dist_id
   AND rctd.creation_date > SYSDATE - 100;

-- Material Transaction
SELECT mmt.transaction_id,
       mmt.creation_date,
       xte.entity_code,
       mmt.transaction_date,
       mmt.transaction_type_id,
       mmt.transaction_cost,
       --xah.accounting_entry_type_code,
       xah.event_type_code,
       xah.je_category_name,
       xah.description,
       xah.accounting_date,
       xe.event_status_code,
       xe.event_date,
       (SELECT fu.user_name
          FROM fnd_user fu
         WHERE 1 = 1
           AND fu.user_id = xte.created_by) user_name,
       xte.created_by,
       xdl.application_id,
       xdl.ae_header_id,
       xdl.ae_line_num,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       xte.entity_code,
       mmt.project_id,
       mmt.source_project_id,
       ppa.segment1 project_number,
       mmt.task_id,
       mmt.source_task_id,
       pt.task_number,
       xah.*
  FROM xla.xla_distribution_links   xdl,
       xla.xla_ae_headers           xah,
       xla.xla_transaction_entities xte,
       mtl_transaction_accounts     mta,
       mtl_material_transactions    mmt,
       pa_projects_all              ppa,
       pa_tasks                     pt,
       xla_events                   xe
 WHERE 1 = 1
   AND xe.event_id = xah.event_id
   AND xe.application_id = xte.application_id
   AND xe.entity_id = xte.entity_id
      --AND xdl.ae_header_id = 5687680
      -- AND xdl.ae_line_num = 1
   AND xdl.application_id = 707
   AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
   AND xdl.application_id = xah.application_id
   AND xdl.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
      --AND xah.ledger_id = xte.ledger_id
   AND xah.entity_id = xte.entity_id
   AND xdl.source_distribution_id_num_1 --= 54869415 --9378860 mmt trx id
       IN (54869415, 54869414, 54869413, 54869412, 54869411, 54869410, 54869409, 54869408, 54869407)
   AND xdl.source_distribution_id_num_1 = mta.inv_sub_ledger_id
   AND xte.source_id_int_1 = mta.transaction_id
      --AND mmt.transaction_id IN (54869415, 54869414, 54869413, 54869412, 54869411, 54869410, 54869409, 54869408, 54869407)
   AND mta.transaction_id = mmt.transaction_id
   AND nvl(mmt.project_id, mmt.source_project_id) = ppa.project_id(+)
   AND nvl(mmt.task_id, mmt.source_task_id) = pt.task_id(+)
 ORDER BY mmt.transaction_id,
          xah.ae_header_id ASC;

SELECT *
  FROM mtl_transaction_accounts mta
 WHERE 1 = 1
   AND mta.inv_sub_ledger_id IN
       (54869415, 54869414, 54869413, 54869412, 54869411, 54869410, 54869409, 54869408, 54869407);

SELECT lookup_code,
       meaning,
       description
  FROM mfg_lookups
 WHERE lookup_type = 'CST_ACCOUNTING_LINE_TYPE'
 ORDER BY 1;

SELECT *
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl
 WHERE 1 = 1
   AND xte.entity_id = xah.entity_id
   AND xte.ledger_id = xah.ledger_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xte.application_id = 707
--AND xte.entity_code = 'AP_INVOICES'
/*AND xah.application_id = 200
AND xal.application_id = 200
AND xte.application_id = 200
AND xdl.application_id = 200*/
;

-- RCV Transaction
SELECT xdl.application_id,
       xdl.ae_header_id,
       xdl.ae_line_num,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       xte.entity_code,
       rt.project_id,
       ppa.segment1 project_number,
       rt.task_id,
       pt.task_number
  FROM xla.xla_distribution_links   xdl,
       xla.xla_ae_headers           xah,
       xla.xla_transaction_entities xte,
       rcv_receiving_sub_ledger     rrs,
       rcv_transactions             rt,
       pa_projects_all              ppa,
       pa_tasks                     pt
 WHERE 1 = 1
   AND xdl.ae_header_id = 5626280
      -- AND xdl.ae_line_num = 1
   AND xdl.application_id = 707
   AND xdl.source_distribution_type = 'RCV_RECEIVING_SUB_LEDGER'
   AND xdl.application_id = xah.application_id
   AND xdl.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xdl.source_distribution_id_num_1 = rrs.rcv_sub_ledger_id
   AND rrs.rcv_transaction_id = rt.transaction_id
   AND rt.project_id = ppa.project_id(+)
   AND rt.task_id = pt.task_id(+);

-- WIP Transaction
SELECT xdl.application_id,
       xdl.ae_header_id,
       xdl.ae_line_num,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       xte.entity_code,
       wt.project_id,
       ppa.segment1 project_number,
       wt.task_id,
       pt.task_number
  FROM xla.xla_distribution_links   xdl,
       xla.xla_ae_headers           xah,
       xla.xla_transaction_entities xte,
       wip_transaction_accounts     wta,
       wip_transactions             wt,
       pa_projects_all              ppa,
       pa_tasks                     pt
 WHERE 1 = 1
      --AND xdl.ae_header_id = 5651636
      -- AND xdl.ae_line_num = 1
   AND xdl.application_id = 707
   AND xdl.source_distribution_type = 'WIP_TRANSACTION_ACCOUNTS'
   AND xdl.application_id = xah.application_id
   AND xdl.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xdl.source_distribution_id_num_1 = wta.wip_sub_ledger_id
   AND xte.source_id_int_1 = wta.transaction_id
   AND wta.transaction_id = wt.transaction_id
   AND wt.project_id = ppa.project_id(+)
   AND wt.task_id = pt.task_id(+);

--by Hakim 25-May-2018
SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND xte.application_id = 707
   AND xte.source_id_int_1 = 54834283;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id = 602 --707 --222
;

SELECT DISTINCT xdl.source_distribution_type,
                xdl.application_id
--,xdl.*
  FROM xla_distribution_links xdl
 WHERE 1 = 1;
