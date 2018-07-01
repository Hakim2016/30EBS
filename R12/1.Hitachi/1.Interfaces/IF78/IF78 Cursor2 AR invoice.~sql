--IF78 Cursor AR invoice
SELECT CT.CUSTOMER_TRX_ID,
             CT.TRX_NUMBER,
             ct.previous_customer_trx_id,
             '' Reference_Invoice_Number,
             CT.TRX_DATE,
             CT.INVOICE_CURRENCY_CODE,
             ROUND(APS.AMOUNT_DUE_ORIGINAL, 2) amount_due_original,
             APS.DUE_DATE,
             CT.BILL_TO_CUSTOMER_ID,
             party.Duns_Number_c CUSTOMER_code,
             PARTY.PARTY_NAME CUSTOMER_name,
             oh.order_number so_number,
             xih.CUST_PO_NUMBER,
             xih.LC_NUMBER,
             ct.org_id,
             hou.set_of_books_id ledger_id,
             ct.attribute1 project_id,
             aps.*
        FROM RA_CUSTOMER_TRX_ALL          CT,
             AR_PAYMENT_SCHEDULES_ALL     APS,
             hz_cust_accounts             CUST_ACCT,
             hz_parties                   party,
             xxar_tax_invoice_headers_all xih,
             oe_order_headers_all         oh,
             hr_operating_units           hou
       WHERE 1=1
       AND CT.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID(+)
         AND ct.BILL_TO_CUSTOMER_ID = cust_acct.cust_account_id(+)
         AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID(+)
         and ct.org_id = xih.org_id(+)
         and ct.TRX_NUMBER = xih.invoice_number(+)
         and xih.oe_header_id = oh.header_id(+)
         and ct.org_id = hou.organization_id
         AND CT.TRX_NUMBER IN ('JPE-17000461', 'JPE-17000451', 'JPE-17000463', 'JPE-17000466')
         
         and not exists
       (select 1
                from XXAR_Billing_TO_G4_DATA_INT v
               where v.source_id = ct.CUSTOMER_TRX_ID
                 and v.source_code = 'AR')
         --and ct.last_update_date >= nvl(P_START_DATE, ct.last_update_date)
         and hou.set_of_books_id = nvl(hou.set_of_books_id, 2041/*g_ledger_id*/)
         and exists
       (select 1 
                from xla.xla_transaction_entities xte, xla_ae_headers xah
               where xte.application_id = xah.application_id
                 and xte.entity_id = xah.entity_id
                 and xte.source_id_int_1 = CT.customer_trx_id
                 and xah.accounting_entry_status_code = 'F'
                 and xte.application_id = 222
                 AND xte.entity_code = 'TRANSACTIONS')
         and (ROUND(APS.AMOUNT_DUE_ORIGINAL, 2) > 0 or
             ROUND(APS.AMOUNT_DUE_ORIGINAL, 2) = 0)
         AND HOU.set_of_books_id = 2041/*g_ledger_id*/
       order by CT.CUSTOMER_TRX_ID;
       
SELECT * FROM oe_order_headers_all ooh
WHERE 1=1
AND ooh.order_number = '53020220';
