
/*
IF67
XXGLB005
XXGLAD3
XXGL:Fixed Assets Outbound to HFG
XXGL_ASSETS_TO_HFG_INT
*/
--xxgl_assets_to_hfg_pkg;--.hfg_main

SELECT intf.request_id,
       intf.transaction_id,
       intf.company_code,
       intf.main_asset_number,
       intf.asset_subnumber,
       intf.document_date,
       intf.posting_date,
       intf.text,
       intf.reference,
       intf.allocation,
       intf.currency_key1,
       intf.amt_posted_txn_currency,
       intf.amt_posted_local_currency_1,
       intf.amt_posted_local_currency_2,
       intf.currency_key2,
       intf.manual_revenue_txn_currency,
       intf.revenue_local_currency_1,
       intf.revenue_local_currency_2,
       intf.company_code_to,
       intf.main_asset_number_to_1,
       intf.asset_subnumber_to_1,
       intf.amt_posted_local_currency_3,
       intf.amt_posted_local_currency_4,
       intf.main_asset_number_to_2,
       intf.asset_subnumber_to_2,
       intf.amt_posted_local_currency_5,
       intf.percentage_rate,
       intf.quantity,
       intf.* /*,
       
       
       intf.request_id,
       intf.interface_file_name,
       intf.ledger_name,
       intf.creation_date,
       intf.main_asset_number,
       intf.text,
       intf.**/
  FROM xxgl_assets_to_hfg_int intf
 WHERE 1 = 1
--AND intf.creation_date > SYSDATE - 360
--AND INTF.MAIN_ASSET_NUMBER IN ('101601200038','101601100193')
--AND intf.
/*AND intf.main_asset_number IN (SELECT t.main_asset_number
  FROM xxgl_assets_to_hfg_int t
 WHERE 1 = 1
 GROUP BY t.main_asset_number
HAVING COUNT(*) >= 2)*/
 ORDER BY intf.request_id DESC;

SELECT rt.transaction_id,
       rt.transaction_type,
       rt.creation_date,
       xte.entity_code,
       xte.entity_id,
       xah.event_id,
       xe.process_status_code,
       xah.completed_date
  FROM rcv_transactions             rt,
       po_lines_all                 pl,
       po_requisition_lines_all     prl,
       po_distributions_all         pod,
       po_req_distributions_all     pord,
       po_headers_all               pha,
       xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_events                   xe
 WHERE 1 = 1
   AND rt.po_line_id = pl.po_line_id(+)
   AND pl.po_line_id = pod.po_line_id(+)
   AND pod.req_distribution_id = pord.distribution_id(+)
   AND pord.requisition_line_id = prl.requisition_line_id(+)
   AND pha.po_header_id = pl.po_header_id
   AND rt.transaction_id = xte.source_id_int_1(+)
   AND xte.entity_id = xah.entity_id
   AND xah.event_id = xe.event_id
   AND xte.application_id = xah.application_id
   AND xte.application_id = 707
   AND xte.ledger_id = '2021'
   AND pha.segment1 = '10048319';

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id IN (702, 707);

SELECT *
  FROM fnd_user fu
 WHERE 1 = 1
   AND fu.user_id = 1133;
