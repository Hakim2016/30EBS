--IF79 Cursor

--org_id      Resp_id     Resp_app_id
--HBS 101     51249       660        
--HEA 82      50676       660
--HET 141     51272       20005
--SHE 84      50778       20005

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 51249,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;*/
--CURSOR cur_DATA IS
      SELECT oel.org_id,
             tt.task_number HBS_SG_MFG_Number,
             pt.top_task_id,
             oel.attribute1 delivery_status_flag,
             decode(oel.attribute1,
                    'N',
                    'Awaiting Delivered',
                    'Y',
                    'Fully Delivered') delivery_status,
             fnd_conc_date.string_to_date(oel.attribute4) delivery_date,
             oh.order_number SO_Number,
             OEL.LINE_NUMBER,
             party.Duns_Number_c CUSTOMER_code,
             PARTY.PARTY_NAME CUSTOMER_name,
             XH.SALES_COMMISSION_PERCENT Sales_Commission,
             oel.project_id,
             oel.task_id,
             oel.LINE_ID SOURCE_ID,
             HOU.set_of_books_id LEDGER_ID

        FROM oe_order_headers_all     OH,
             oe_order_lines_all       oel,
             oe_transaction_types_all ott,
             XXPJM_SO_ADDTN_HEADERS   XH,
             HR_OPERATING_UNITS       HOU,
             pa_tasks                 pt,
             pa_tasks                 tt,
             hz_cust_accounts         CUST_ACCT,
             hz_parties               party

       WHERE oh.header_id = oel.header_id
         AND oel.line_type_id = ott.transaction_type_id
         AND OH.HEADER_ID = XH.SO_HEADER_ID
         AND OH.ORG_ID = HOU.organization_id
         AND OEL.PROJECT_ID = PT.PROJECT_ID
         AND OEL.TASK_ID = PT.TASK_ID
         AND pt.top_task_id = tt.task_id
         AND Oh.sold_to_org_id = cust_acct.cust_account_id(+)
         AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID(+)
         AND oel.flow_status_code NOT IN ('CLOSED', 'CANCELLED', 'ENTERED')
         and ott.attribute5 IN ('EQ', 'PART')
         AND OEL.ATTRIBUTE1 IS NOT NULL
/*         AND NOT EXISTS
         --cond1
         --not exists in interface table
           --delivery status stay unchanged
           --delivery date stay unchanged
       (SELECT 1
                FROM XXAR_DELIVERY_TO_R3_INT V
               WHERE V.SOURCE_ID = OEL.LINE_ID
                 AND V.DELIVERY_STATUS_FLAG = OEL.ATTRIBUTE1
                 AND nvl(V.BACKUP_DELIVERY_DATES,sysdate) =
                     nvl(fnd_conc_date.string_to_date(oel.attribute4) ,sysdate)
                 and v.version =
                     (select max(di.version)
                        from XXAR_DELIVERY_TO_R3_INT di
                       where di.SOURCE_ID = OEL.LINE_ID))--end of cond1
*/                       
         --cond2
         --delivery status in interface table(Fully Delivered) <> 
         --                which in so line(Awaiting Delivered)
         --or
         --delivery status in so line(Fully Delivered)
         AND ((OEL.ATTRIBUTE1 = 'N' AND EXISTS
              (SELECT 1
                  FROM XXAR_DELIVERY_TO_R3_INT V
                 WHERE V.SOURCE_ID = OEL.LINE_ID
                   AND V.DELIVERY_STATUS_FLAG = 'Y')) OR
             OEL.ATTRIBUTE1 = 'Y')

         AND HOU.set_of_books_id = 2041--g_ledger_id
    --AND OEL.LAST_UPDATE_DATE > NVL(P_START_DATE,OEL.LAST_UPDATE_DATE)
    AND oh.order_number = '53020044'--'53020400'
    order by  OEL.LAST_UPDATE_DATE ;
