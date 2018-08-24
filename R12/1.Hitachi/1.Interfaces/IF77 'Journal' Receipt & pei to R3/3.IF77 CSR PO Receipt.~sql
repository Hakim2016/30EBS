/*cursor cur_po_receipt is*/
    ---po receipt
      select pa.segment1 SO_number,
             PD.EXPENDITURE_TYPE cost_element,
             party.Duns_Number_c CUSTOMER_code,
             PARTY.PARTY_NAME CUSTOMER_name,
             RT.TRANSACTION_DATE record_date,
             1 PRICE_identification_code,
             decode(RT.TRANSACTION_TYPE,
                    'RETURN TO RECEIVING',
                    -1 * ROUND(RT.QUANTITY * RT.PO_UNIT_PRICE, 2),
                    ROUND(RT.QUANTITY * RT.PO_UNIT_PRICE, 2)) PRICE,
             RT.CURRENCY_CODE,
             PH.SEGMENT1 PO_NUMBER,
             HP.Duns_Number_c supplier_code,
             PAV.VENDOR_NAME SUPPLIER_name,
             PT2.TASK_NUMBER HBS_SG_MFG_NUMBER,
             '' REMARK,
             RT.TRANSACTION_ID SOURCE_ID,
             nvl(RT.PROJECT_ID,(select v.project_id
                    from rcv_transactions v
                   where v.transaction_id = rt.parent_transaction_id)) project_id,
             nvl(rt.task_id,
                 (select v.task_id
                    from rcv_transactions v
                   where v.transaction_id = rt.parent_transaction_id)) task_id,
             PH.PO_HEADER_ID,
             OH.HEADER_ID SO_HEADER_ID,
             ODD.OPERATING_UNIT ORG_ID,
             ODD.SET_OF_BOOKS_ID LEDGER_ID

        from rcv_transactions             rt,
             PO_HEADERS_ALL               PH,
             PO_DISTRIBUTIONS             PD,
             AP_SUPPLIERS                 PAV,
             HZ_PARTIES                   HP,
             pa_projects_all              pa,
             PA_TASKS                     PT,
             PA_TASKS                     PT2,
             OE_ORDER_HEADERS_ALL         OH,
             hz_cust_accounts             CUST_ACCT,
             hz_parties                   party,
             ORG_ORGANIZATION_DEFINITIONS ODD
       where RT.PO_HEADER_ID = PH.PO_HEADER_ID
         and rt.po_distribution_id = pd.po_distribution_id
         and rt.VENDOR_ID = pav.vendor_id(+)
         and PAV.PARTY_ID = HP.PARTY_ID(+)
         and nvl(rt.project_id,
                 (select v.project_id
                    from rcv_transactions v
                   where v.transaction_id = rt.parent_transaction_id)) =
             pa.project_id
         AND nvl(rt.task_id,
                 (select v.task_id
                    from rcv_transactions v
                   where v.transaction_id = rt.parent_transaction_id)) =
             PT.TASK_ID
         AND PT.TOP_TASK_ID = PT2.TASK_ID
         AND PA.ORG_ID = OH.ORG_ID(+)
         AND PA.SEGMENT1 = OH.ORDER_NUMBER(+)
         AND Oh.sold_to_org_id = cust_acct.cust_account_id(+)
         AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID(+)
         AND RT.ORGANIZATION_ID = ODD.ORGANIZATION_ID
         AND RT.TRANSACTION_TYPE IN ('DELIVER', 'RETURN TO RECEIVING')
         AND NOT EXISTS
       (SELECT 'Y'
                FROM XXAP_JOURNAL_TO_R3_DATA_INT J
               WHERE J.SOURCE_CODE = 'PO RECIPT'
                 AND J.SOURCE_ID = RT.TRANSACTION_ID)

         AND RT.CREATION_DATE >= NVL(P_START_DATE, RT.CREATION_DATE)
         AND ODD.set_of_books_id = NVL(g_ledger_id, ODD.set_of_books_id)
         order by RT.TRANSACTION_ID;
