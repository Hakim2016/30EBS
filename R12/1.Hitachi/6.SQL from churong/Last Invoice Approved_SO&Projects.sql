
SELECT distinct xha.so_number,
                ott.NAME,
                ppa.attribute1,
                ppa.segment1,
                ppa.creation_date,
                ppa.start_date,
                ppa.completion_date,
                xha.approved_date,
                xha.last_invoice_flag,
                xha.status_code,
                xha.*
  FROM XXOM_DO_INVOICE_HEADERS_ALL xha,
       oe_order_lines_all          ool,
       pa_projects_all             ppa,
       oe_order_headers_all        ooh,
       oe_transaction_types        ott
 WHERE 1 = 1
   --AND xha.approved_date >= to_date('2017-01-01', 'yyyy-mm-dd')
   --AND xha.approved_date <= to_date('2017-01-31', 'yyyy-mm-dd')
   AND xha.last_invoice_flag = 'Y'
   AND xha.status_code in ('APPROVED','INVOICE')
   and xha.org_id in ('141','84')
   and ool.header_id = xha.oe_header_id
   and ool.project_id = ppa.project_id(+)
   and xha.so_number = ooh.order_number
   and ooh.order_type_id = ott.TRANSACTION_TYPE_ID
   and ppa.segment1 is not null
