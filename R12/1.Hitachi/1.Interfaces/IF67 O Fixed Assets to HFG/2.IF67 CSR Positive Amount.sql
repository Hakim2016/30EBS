--IF67 CSR Positive Amount
/*CURSOR cur_hfg IS*/
      SELECT xte.entity_id,
             xhs.company_code,
             prl.attribute1 main_asset_number,
             nvl(prl.attribute2, 0) asset_subnumber,
             to_char(rt.creation_date, 'YYYYMMDD') document_date,
             to_char(xah.accounting_date, 'YYYYMMDD') posting_date,
             prl.item_description,
             pv.segment1 reference,
             pha.segment1 allocation,
             pha.currency_code,
             rt.quantity * rt.po_unit_price * rt.currency_conversion_rate amount,
             prl.org_id,
             rt.transaction_id,
             rt.creation_date,
             xe.process_status_code
        FROM rcv_transactions             rt,
             rcv_shipment_headers         rsh,
             po_lines_all                 pl,
             po_requisition_lines_all     prl,
             po_distributions_all         pod,
             po_req_distributions_all     pord,
             xla.xla_transaction_entities xte,
             xxgl_hfs_system_options      xhs,
             po_vendors                   pv,
             po_headers_all               pha,
             xla_ae_headers               xah,
             xla_events                   xe
       WHERE rt.po_line_id = pl.po_line_id(+)
         AND pl.po_line_id = pod.po_line_id(+)
         AND pod.req_distribution_id = pord.distribution_id(+)
         AND pord.requisition_line_id = prl.requisition_line_id(+)
         AND rt.transaction_id = xte.source_id_int_1
         AND xhs.ledger_id = xte.ledger_id
         AND rt.shipment_header_id = rsh.shipment_header_id
         AND pha.vendor_id = pv.vendor_id
         AND pha.po_header_id = pl.po_header_id
         AND xte.entity_id = xah.entity_id
         AND xah.event_id = xe.event_id
         AND xe.process_status_code = 'P'
         AND xte.application_id = xah.application_id
         AND xte.application_id = 707
         AND xte.entity_code = 'RCV_ACCOUNTING_EVENTS'
         AND rt.transaction_type = 'DELIVER'
         AND prl.attribute1 IS NOT NULL
         AND length(prl.attribute1) > 10
         /*AND EXISTS (SELECT 1
                FROM gl_ledgers gl
               WHERE gl.name = 'HEA_Ledger'--p_ledger
                 AND gl.ledger_id = xte.ledger_id)*/
         AND nvl(xhs.inactive_date, SYSDATE + 1) >= SYSDATE
         AND xah.completed_date >= to_date('2018-05-24','yyyy-mm-dd')--trunc(p_date_from)
         /*AND NOT EXISTS
       (SELECT 1
                FROM xxgl_assets_to_hfg_int xathi
               WHERE xathi.main_asset_number || xathi.asset_subnumber = prl.attribute1 || nvl(prl.attribute2, 0)
                 AND transaction_id = rt.transaction_id)*/
         /*AND EXISTS (SELECT 1
                FROM gl_period_statuses gls
               WHERE gls.closing_status IN ('O')
                 AND gls.ledger_id = (SELECT ledger_id
                                        FROM gl_ledgers gl
                                       WHERE gl.name = 'HEA_Ledger'\*p_ledger*\))*/
;

SELECT * FROM fnd_application fa
WHERE 1=1
AND fa.application_id = 702;
