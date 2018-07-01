SELECT /*SUM((RCTL.EXTENDED_AMOUNT +
           (SELECT ZL2.TAX_AMT
               FROM ZX_LINES ZL2
              WHERE ZL2.TRX_LINE_ID = RCTL.CUSTOMER_TRX_LINE_ID
                AND ROWNUM = 1)) * NVL(RCT.EXCHANGE_RATE, 1)) ALL_AMT*/
                ooh.order_number,
                ool.ordered_item,
 (RCTL.EXTENDED_AMOUNT + (SELECT ZL2.TAX_AMT
                            FROM ZX_LINES ZL2
                           WHERE ZL2.TRX_LINE_ID = RCTL.CUSTOMER_TRX_LINE_ID
                             AND ROWNUM = 1)) * NVL(RCT.EXCHANGE_RATE, 1) amount,
 rct.trx_number,
 (
 SELECT dih.last_invoice_flag FROM 
       xxom_do_invoice_headers_all dih
       WHERE 1=1
       AND dih.document_number = rct.trx_number
 ) last_invoice,
 RCT.TRX_DATE,
 rct.creation_date,
 rct.previous_customer_trx_id ref_cst_id,
 (
 SELECT rct1.trx_number FROM RA_CUSTOMER_TRX_ALL rct1
 WHERE 1=1
 AND rct1.customer_trx_id = rct.previous_customer_trx_id
 ) ref_trx_num,
 rct.ct_reference

  FROM RA_CUSTOMER_TRX_LINES_ALL RCTL,
       OE_ORDER_LINES_ALL        OOL,
       OE_ORDER_HEADERS_ALL      OOH,
       RA_CUSTOMER_TRX_ALL       RCT
 WHERE 1 = 1
   AND OOH.HEADER_ID = OOL.HEADER_ID
   AND OOH.ORDER_NUMBER = RCTL.SALES_ORDER
   AND RCT.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
   AND OOL.LINE_NUMBER || '.' || OOL.SHIPMENT_NUMBER =
       RCTL.SALES_ORDER_LINE
   AND OOL.TASK_ID = /*P_TASK_ID*/
       4360903--4119176
   AND RCT.TRX_DATE < /*P_END_DATE*/
       --to_date('2016/12/31 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
       to_date('2017/3/31 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
 --GROUP BY OOL.TASK_ID
 ORDER BY rct.creation_date
 ;
