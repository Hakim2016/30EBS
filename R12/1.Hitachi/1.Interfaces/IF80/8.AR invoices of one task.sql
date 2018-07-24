--get first sale amount
SELECT /*SUM((RCTL.EXTENDED_AMOUNT +
           (SELECT ZL2.TAX_AMT
               FROM ZX_LINES ZL2
              WHERE ZL2.TRX_LINE_ID = RCTL.CUSTOMER_TRX_LINE_ID
                AND ROWNUM = 1)) * NVL(RCT.EXCHANGE_RATE, 1)) ALL_AMT*/
 ooh.order_number,
 ool.ordered_item,
 (rctl.extended_amount + (SELECT zl2.tax_amt
                            FROM zx_lines zl2
                           WHERE zl2.trx_line_id = rctl.customer_trx_line_id
                             AND rownum = 1)) * nvl(rct.exchange_rate, 1) amount,
 rct.trx_number,
 (SELECT dih.last_invoice_flag
    FROM xxom_do_invoice_headers_all dih
   WHERE 1 = 1
     AND dih.document_number = rct.trx_number) last_invoice,
 rct.trx_date,
 rct.creation_date,
 rct.created_by,
 rct.previous_customer_trx_id ref_cst_id,
 (SELECT rct1.trx_number
    FROM ra_customer_trx_all rct1
   WHERE 1 = 1
     AND rct1.customer_trx_id = rct.previous_customer_trx_id) ref_trx_num,
 rct.ct_reference

  FROM ra_customer_trx_lines_all rctl,
       oe_order_lines_all        ool,
       oe_order_headers_all      ooh,
       ra_customer_trx_all       rct
 WHERE 1 = 1
   AND ooh.header_id = ool.header_id
   AND ooh.order_number = rctl.sales_order
   AND rct.customer_trx_id = rctl.customer_trx_id
   AND ool.line_number || '.' || ool.shipment_number = rctl.sales_order_line
   AND ool.task_id = /*P_TASK_ID*/
       --5770299--4360903 --4119176
       4360903--SBG0220-HK.EQ
   AND rct.trx_date < /*P_END_DATE*/
      --to_date('2016/12/31 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
       to_date('2018/3/31 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
--GROUP BY OOL.TASK_ID
 ORDER BY rct.creation_date;
