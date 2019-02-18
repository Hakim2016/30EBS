SELECT rt.transaction_id,
       rt.transaction_type,
       poh.segment1,
       rt.destination_type_code,
       rt.quantity,
       --rt.amount,
       rt.subinventory,
       rt.locator_id,
       ppa.segment1,
       pt.task_number,
       rt.project_id,
       rt.task_id,
       rt.*
  FROM rcv_transactions rt,
       po_headers_all   poh,
       pa_projects_all  ppa,
       pa_tasks         pt

 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
   AND rt.project_id = ppa.project_id(+)
   AND rt.task_id = pt.task_id(+)
      --AND rt.organization_id = 121
   AND rt.po_header_id = poh.po_header_id
      --AND rt.transaction_id IN (4654211, 4654212)
   AND poh.segment1 = '10070815' --'10070815'--'10000415'
--AND pt.task_number = 'JBL0262-IN.EQ'
;

SELECT rt.transaction_id,
       --rt.creation_date,
       rt.transaction_type trx_type,
       rt.transaction_date,
       rt.po_unit_price rt_po_price,
       pol.unit_price pol_price,
      /*rt.po_unit_price* (SELECT gdr.conversion_rate --gdr.conversion_rate
  FROM gl_daily_rates gdr
 WHERE gdr.from_currency = 'JPY'--'USD' --p_from_currency
   AND gdr.to_currency = 'SGD' --p_to_currency
   AND gdr.status_code != 'D'
      AND gdr.conversion_type = 'Corporate'--p_conversion_type
   AND gdr.conversion_date = trunc(rt.transaction_date)
   --to_date('30-SEP-2018', 'DD-MM-YYYY') --trunc(p_conversion_date);
) gsd_price,*/
      /* (SELECT gdr.conversion_rate --gdr.conversion_rate
  FROM gl_daily_rates gdr
 WHERE gdr.from_currency = 'JPY'--'USD' --p_from_currency
   AND gdr.to_currency = 'SGD' --p_to_currency
   AND gdr.status_code != 'D'
      AND gdr.conversion_type = 'Corporate'--p_conversion_type
   AND gdr.conversion_date = trunc(rt.transaction_date)
   --to_date('30-SEP-2018', 'DD-MM-YYYY') --trunc(p_conversion_date);
) exchange_rate,*/
       poh.segment1,
       rt.destination_type_code,
       rt.quantity,
       rt.quantity_billed,
       rt.amount_billed,
       pol.line_num,
       --rt.amount,
       rt.subinventory,
       rt.locator_id,
       /*ppa.segment1,
       pt.task_number,*/
       rt.project_id,
       rt.task_id,
       rt.*
  FROM rcv_transactions rt,
       po_headers_all   poh,
       po_lines_all     pol
 WHERE 1 = 1
      --AND rt.organization_id = 83--121
   AND rt.po_header_id = poh.po_header_id
      --AND rt.transaction_id IN (4654211, 4654212)
   AND poh.segment1 = '10070207'--'10071699'--'10070815'--'10073394'--'10070815' --'10073394'----'10070815'--'10070231'--'10000415'
   AND rt.po_line_id = pol.po_line_id
   AND poh.org_id = 82
   --AND pol.line_num = 39
--AND pt.task_number = 'JBL0262-IN.EQ'
 ORDER BY rt.transaction_id;
SELECT *
  FROM rcv_vrc_txs_v v
 WHERE 1 = 1
   AND v.transaction_id IN (4654211, 4654212);

SELECT *
  FROM rcv_vrc_hds_v v
 WHERE 1 = 1
   AND v.receipt_num = '85822'
--AND v.organization_id = 83--SG1
;
