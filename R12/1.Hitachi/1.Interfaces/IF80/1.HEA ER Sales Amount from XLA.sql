/*INSERT INTO XXPA_COST_GCPM_COGS_T2 --xxpa_proj_rev_cogs_tmp
        (PROJECT_ID,
         TOP_TASK_ID,
         AE_HEADER_ID,
         ENTERED_AMOUNT,
         ACCOUNTED_AMOUNT,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN)*/
        SELECT PA.PROJECT_ID,
        XAH.Description,
               pa.segment1,
               TOP.TASK_ID,
               top.task_number,
               XAH.AE_HEADER_ID,
               XAH.ACCOUNTING_DATE,
               SUM(NVL(XAL.ENTERED_DR, 0) - NVL(XAL.ENTERED_CR, 0)),
               SUM(NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0)),
               SYSDATE/*,
               G_CREATED_BY,
               SYSDATE,
               G_LAST_UPDATED_BY,
               G_LAST_UPDATE_LOGIN*/
          FROM XLA_AE_HEADERS  XAH,
               XLA_AE_LINES    XAL,
               PA_TASKS        TOP,
               PA_PROJECTS_ALL PA
        
         WHERE XAH.APPLICATION_ID = 275--G_PA_APPL_ID
           AND XAH.JE_CATEGORY_NAME IN ('4')
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND TOP.TASK_ID = TOP.TOP_TASK_ID
           AND TOP.PROJECT_ID = PA.PROJECT_ID
           AND XAL.DESCRIPTION =
               PA.SEGMENT1 || '.' || TOP.TASK_NUMBER || '.ER'
           AND XAL.ACCOUNTING_CLASS_CODE = 'REVENUE'
              --AND xal.ae_line_num        =   1
           --AND XAH.ACCOUNTING_DATE >= to_date('2018-12-01','yyyy-mm-dd')--P_START_DATE
           AND XAH.ACCOUNTING_DATE <= to_date('2018-12-31','yyyy-mm-dd') + 0.99999--P_END_DATE
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND PA.PROJECT_ID = NVL(NULL/*P_PROJECT_ID*/, PA.PROJECT_ID)
           AND PA.ORG_ID = 82--G_HEA_OU --todo20170605
           AND TOP.TASK_ID = NVL(NULL/*P_TOP_TASK_ID*/, TOP.TASK_ID)
           AND top.task_number = 'SAG0495-SG'--'SBC0266-SG'
         GROUP BY 
               pa.segment1,XAH.Description,
               top.task_number,PA.PROJECT_ID, TOP.TASK_ID, XAH.AE_HEADER_ID,XAH.ACCOUNTING_DATE;
         
         SELECT * FROM fnd_application fa
         WHERE 1=1
         AND fa.application_short_name = 'PA';


SELECT SUM((RCTL.EXTENDED_AMOUNT +
                 (SELECT ZL2.TAX_AMT
                     FROM ZX_LINES ZL2
                    WHERE ZL2.TRX_LINE_ID = RCTL.CUSTOMER_TRX_LINE_ID
                      AND ROWNUM = 1)) * NVL(RCT.EXCHANGE_RATE, 1)) ALL_AMT
      
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
             AND ooh.order_number = '11001281'
         --AND OOL.TASK_ID = 4883768--4883767--P_TASK_ID
         --AND RCT.TRX_DATE < P_END_DATE
       GROUP BY OOL.TASK_ID;
       
SELECT * FROM pa_tasks pt WHERE 1=1 AND pt.task_id = 4883768;
       
