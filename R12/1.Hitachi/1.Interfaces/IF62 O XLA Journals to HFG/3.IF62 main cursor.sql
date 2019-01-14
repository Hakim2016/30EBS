/*CURSOR cur_public_data(p_data_start_date DATE) IS*/
SELECT xah.ae_header_id,
       to_char(xah.accounting_date, /*g_time_format*/ 'yyyymmdd') gl_date,
       xet.event_class_code,
       xal.accounting_class_code,
       xah.event_id,
       gcc.segment2,
       gcc.segment3,
       gcc.segment4,
       xal.ae_line_num,
       xal.code_combination_id,
       to_char(xal.accounting_date, 'MM') period_name,
       to_char(xal.accounting_date, /*g_time_format*/ 'yyyymmdd') posting_date,
       xal.currency_code currency_key,
       abs(decode(nvl(xal.entered_dr, 0), 0, nvl(xal.entered_cr, 0), nvl(xal.entered_dr, 0))) entered,
       abs(decode(nvl(xal.accounted_dr, 0), 0, nvl(xal.accounted_cr, 0), nvl(xal.accounted_dr, 0))) accounted,
       decode(sign(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)), 1, 'dr', 'cr') cr_dr_flag,
       xte.source_id_int_1,
       xte.source_id_int_2,
       xte.entity_code,
       xte.source_application_id,
       xah.application_id,
       xah.ledger_id,
       xal.currency_conversion_rate,
       xte.transaction_number,
       xte.security_id_int_1,
       xah.event_type_code,
       xah.accounting_date,
       xxgl_accounting_export_hfg_pkg.get_document_type(xte.source_application_id, xah.ledger_id, xet.event_class_code) document_type,
       ceil((COUNT(xah.ae_header_id) over(PARTITION BY xah.ae_header_id)) / 249) page_num,
       xah.description,
       xal.description line_desc
  FROM xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla.xla_transaction_entities xte,
       gl_code_combinations         gcc,
       xla_event_types_b            xet,
       xla_events                   xe
 WHERE xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
   AND xal.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xal.code_combination_id = gcc.code_combination_id
   AND xet.application_id = xah.application_id
   AND xet.event_type_code = xah.event_type_code
   AND xah.event_id = xe.event_id
   AND xe.process_status_code = 'P'
   AND xah.ledger_id = 2041 --g_ledger_id
   AND xte.entity_id = 28080659--27219514
   --AND xah.ae_header_id = 24601670
   AND xte.entity_code <> 'RECEIPTS' ---exclude receipt. --how to indentify cost transaction
   /*AND NOT EXISTS (SELECT 1 -- added by Jaron.li@2014-12-18 begin
          FROM rcv_transactions         rt,
               po_lines_all             pl,
               po_requisition_lines_all prl,
               po_distributions_all     pod,
               po_req_distributions_all pord
         WHERE rt.po_line_id = pl.po_line_id(+)
           AND pl.po_line_id = pod.po_line_id(+)
           AND pod.req_distribution_id = pord.distribution_id(+)
           AND pord.requisition_line_id = prl.requisition_line_id(+)
           AND rt.transaction_id = xte.source_id_int_1
           AND xte.entity_code = 'RCV_ACCOUNTING_EVENTS'
           AND prl.attribute1 IS NOT NULL
           AND length(prl.attribute1) > 10
           AND EXISTS (SELECT 1
                  FROM gl_ledgers gl
                 WHERE upper(gl.name) = 'HEA LEDGER' \*g_hea_ledger*\
                   AND gl.ledger_id = xte.ledger_id))*/
   AND (nvl(xal.accounted_dr, 0) <> 0 OR nvl(xal.accounted_cr, 0) <> 0)
      /*AND (l_budat_limit IS NULL AND --
      xah.completed_date >= l_start_date OR --
      l_budat_limit IS NOT NULL AND --
      to_char(xah.accounting_date, \*g_time_format*\'yyyymmdd') = l_budat_limit)*/
      --
      --AND xal.accounting_date >= SYSDATE-5--p_data_start_date
      /*         AND NOT EXISTS (SELECT xad.unique_id
       FROM xxgl_acct_details_lines_hfg xad
      WHERE xad.source_table = 'XLA_AE_LINES'--l_source_table
        AND xad.source_header_id = xal.ae_header_id
        AND xad.source_line_id = xal.ae_line_num)*/
   /*AND NOT EXISTS (SELECT 1
          FROM xla_distribution_links xdl,
               xla_acct_line_types_tl jlt
         WHERE xdl.ae_header_id = xal.ae_header_id
           AND xdl.ae_line_num = xal.ae_line_num
           AND xdl.application_id = xah.application_id
           AND jlt.accounting_line_code = xdl.accounting_line_code
           AND jlt.application_id = xdl.application_id
           AND jlt.accounting_line_type_code = xdl.accounting_line_type_code
           AND jlt.event_class_code = xdl.event_class_code
           AND jlt.language = userenv('LANG')
           AND jlt.name = 'Credit Memo Default Application'
           AND xal.accounting_class_code = 'RECEIVABLE')
   AND NOT EXISTS (SELECT 1
          FROM xla_ae_lines xal2
         WHERE xal2.ae_header_id = xah.ae_header_id
           AND (nvl(xal2.entered_dr, 0) + nvl(xal2.entered_cr, 0)) = 0
           AND (nvl(xal2.accounted_dr, 0) + nvl(xal2.accounted_cr, 0)) <> 0)*/
      
   --AND xte.application_id = 200 --AP
   --AND xte.source_id_int_1 = 1988890 --1950254--ap invoice id
   AND (xte.source_id_int_1 NOT IN (1011559) OR xte.source_id_int_1 IS NULL)
 ORDER BY xah.application_id,
          xah.ae_header_id,
          xal.ae_line_num;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id = 200;
