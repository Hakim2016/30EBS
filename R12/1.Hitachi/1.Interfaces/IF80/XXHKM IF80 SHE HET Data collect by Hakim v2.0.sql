/*PROCEDURE PROC_COGS_DATA(P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                           X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                           X_MSG_COUNT     OUT NOCOPY NUMBER,
                           X_MSG_DATA      OUT NOCOPY VARCHAR2,
                           P_START_DATE    IN DATE,
                           P_END_DATE      IN DATE,
                           P_ORG_ID        IN NUMBER) IS*/
                           
                           
                           --------------
DECLARE

---------
P_INIT_MSG_LIST VARCHAR2(240); --DEFAULT FND_API.G_FALSE
X_RETURN_STATUS  VARCHAR2(240);
X_MSG_COUNT      NUMBER;
X_MSG_DATA       VARCHAR2(240);
P_START_DATE     DATE:=to_date('2017-08-01','yyyy-mm-dd');
P_END_DATE       DATE:= to_date('2017-08-31', 'yyyy-mm-dd')+0.99999;
P_ORG_ID         NUMBER:=84;--SHE
G_PKG_NAME VARCHAR2(240):='for testing';
G_LEDGER_ID NUMBER:=2023; --SHE
G_PA_APPL_ID NUMBER:=275;--PA
---------



    L_API_NAME       CONSTANT VARCHAR2(30) := 'proc_cogs_data';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := 'sp_proc_cogs_data01';
  
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    X_RETURN_STATUS := XXFND_API.START_ACTIVITY(P_PKG_NAME       => G_PKG_NAME,
                                                P_API_NAME       => L_API_NAME,
                                                P_SAVEPOINT_NAME => L_SAVEPOINT_NAME,
                                                P_INIT_MSG_LIST  => P_INIT_MSG_LIST);
    IF (X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (X_RETURN_STATUS = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    DELETE FROM XXPA_COST_GCPM_TASK_T5;
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'COGS', NVL(SUM(PEI.PROJECT_BURDENED_COST), 0), PEI.TASK_ID, P_START_DATE,1
        FROM APPS.PA_EXPENDITURE_ITEMS_ALL PEI,
             XLA.XLA_TRANSACTION_ENTITIES  XTE,
             APPS.XLA_AE_HEADERS           XAH
       WHERE 1 = 1
         AND XTE.ENTITY_CODE = 'MANUAL'
         AND XTE.APPLICATION_ID = 275
         AND XTE.ENTITY_ID = XAH.ENTITY_ID
         AND XAH.APPLICATION_ID = 275
         AND XTE.TRANSACTION_NUMBER LIKE 'C%'
         AND SUBSTR(XTE.TRANSACTION_NUMBER, 2) = PEI.EXPENDITURE_ITEM_ID
         AND XAH.LEDGER_ID = G_LEDGER_ID
         AND PEI.ORG_ID = P_ORG_ID
         AND XAH.ACCOUNTING_DATE <= P_END_DATE
         AND XAH.ACCOUNTING_DATE >= P_START_DATE
       GROUP BY PEI.TASK_ID;
  
    /*    INSERT INTO XXPA_COST_GCPM_TASK_T2
    SELECT 'COGS',
           nvl(SUM(0 - cdl.project_burdened_cost), 0),
           pei.task_id
      FROM apps.pa_expenditure_items_all  pei,
           pa_expenditure_types           pet,
           pa_cost_distribution_lines_all cdl
     WHERE pei.expenditure_type = pet.expenditure_type
       AND pei.Org_Id = p_org_id
       AND pet.expenditure_category = 'FG Transfer'
       AND pei.expenditure_item_id = cdl.expenditure_item_id
       AND cdl.gl_date BETWEEN p_start_date AND p_end_date
     GROUP BY pei.task_id;*/
  
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'COGS',
             NVL(SUM(MMT.ACTUAL_COST * MMT.PRIMARY_QUANTITY), 0),
             MMT.SOURCE_TASK_ID,P_START_DATE,2 
        FROM APPS.MTL_MATERIAL_TRANSACTIONS MMT,
             APPS.PA_PROJECTS_ALL           PA,
             APPS.PA_PROJECT_TYPES_ALL      PPT
       WHERE MMT.TRANSACTION_SOURCE_ID = 180 --DN OUT, --2
         AND MMT.SOURCE_PROJECT_ID = PA.PROJECT_ID
         AND PA.PROJECT_TYPE = PPT.PROJECT_TYPE
         AND PPT.PROJECT_TYPE = 'SHE FAC_MTE Parts' --1
         AND PA.ORG_ID = P_ORG_ID
         AND MMT.TRANSACTION_DATE <= P_END_DATE
         AND MMT.TRANSACTION_DATE >= P_START_DATE
       GROUP BY MMT.SOURCE_TASK_ID;
  
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'COGS',
             NVL(SUM(MMT.ACTUAL_COST * MMT.PRIMARY_QUANTITY), 0),
             NVL(MMT.SOURCE_TASK_ID, MMT.TASK_ID),P_START_DATE,3
        FROM APPS.MTL_MATERIAL_TRANSACTIONS MMT,
             APPS.PA_PROJECTS_ALL           PA,
             APPS.PA_PROJECT_TYPES_ALL      PPT
       WHERE 1 = 1
         AND PPT.PROJECT_TYPE = 'SHE FAC_MTE Parts' --1
         AND MMT.TRANSACTION_TYPE_ID = 33 --2
         AND NVL(MMT.SOURCE_PROJECT_ID, MMT.PROJECT_ID) = PA.PROJECT_ID
         AND PA.PROJECT_TYPE = PPT.PROJECT_TYPE
         AND PA.ORG_ID = P_ORG_ID
         AND MMT.TRANSACTION_DATE <= P_END_DATE
         AND MMT.TRANSACTION_DATE >= P_START_DATE
       GROUP BY NVL(MMT.SOURCE_TASK_ID, MMT.TASK_ID);
  
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'COGS', NVL(SUM(CDL.PROJECT_BURDENED_COST), 0), PEI.TASK_ID,P_START_DATE,4
        FROM APPS.PA_EXPENDITURE_ITEMS_ALL  PEI,
             PA_PROJECTS_ALL                PPA,
             APPS.PA_EXPENDITURE_TYPES      PET,
             APPS.PA_PROJECT_TYPES_ALL      PPT,
             PA_COST_DISTRIBUTION_LINES_ALL CDL
       WHERE PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
         AND PEI.ORG_ID = P_ORG_ID
         AND PEI.PROJECT_ID = PPA.PROJECT_ID
         AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
         AND PPA.ORG_ID = PPT.ORG_ID
         AND PPT.PROJECT_TYPE = 'SHE FAC_MTE Parts'
            --AND PET.EXPENDITURE_CATEGORY = 'FG Completion'
         AND PEI.EXPENDITURE_TYPE IN
             ('FG Completion', 'FAC FG-MTE-TO SHE HO', 'FAC FG-MTE-TO HET')
         AND PEI.EXPENDITURE_ITEM_ID = CDL.EXPENDITURE_ITEM_ID
         AND CDL.GL_DATE BETWEEN P_START_DATE AND P_END_DATE
       GROUP BY PEI.TASK_ID;
  
    --HEA/HBS XXPA:EQ and ER Sales Profit and Cost of Sales for the month
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'COGS',
             - (SUM(DECODE(PEI.SYSTEM_LINKAGE_FUNCTION,
                          'ST',
                          DECODE(PA_SECURITY.VIEW_LABOR_COSTS(PEI.PROJECT_ID),
                                 'Y',
                                 PEI.BURDEN_COST,
                                 NULL),
                          'OT',
                          DECODE(PA_SECURITY.VIEW_LABOR_COSTS(PEI.PROJECT_ID),
                                 'Y',
                                 PEI.BURDEN_COST,
                                 NULL),
                          PEI.BURDEN_COST))),
             
             ER.TASK_ID,P_START_DATE,5
        FROM PA_EXPENDITURE_ITEMS_ALL PEI,
             PA_TASKS                 ER,
             PA_TASKS                 TOP,
             PA_PROJECTS_ALL          PA
       WHERE PEI.EXPENDITURE_TYPE = 'Cost of Sales for ER'
         AND PEI.TASK_ID = ER.TASK_ID
         AND ER.TOP_TASK_ID = TOP.TASK_ID
         AND PEI.PROJECT_ID = PA.PROJECT_ID
         AND PEI.ORG_ID = P_ORG_ID
         AND ER.TASK_NUMBER = TOP.TASK_NUMBER || '.ER'
         AND PEI.EXPENDITURE_ITEM_DATE BETWEEN P_START_DATE AND P_END_DATE
       GROUP BY ER.TASK_ID;
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'COGS',
             SUM(NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0)),
             EQ.TASK_ID AS TASK_ID,P_START_DATE,6 
        FROM XLA_AE_HEADERS       XAH,
             XLA_AE_LINES         XAL,
             GL_CODE_COMBINATIONS GCC,
             PA_TASKS             TOP,
             PA_TASKS             EQ,
             PA_PROJ_ELEMENTS     PPE,
             PA_TASK_TYPES        PTT,
             PA_PROJECTS_ALL      PA
       WHERE XAH.APPLICATION_ID = G_PA_APPL_ID
         AND XAH.JE_CATEGORY_NAME IN ('1', '2')
         AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
         AND TOP.TASK_ID = TOP.TOP_TASK_ID
         AND TOP.PROJECT_ID = PA.PROJECT_ID
         AND XAL.DESCRIPTION LIKE '%.EQ'
         AND SUBSTR(XAL.DESCRIPTION, 1, INSTR(XAL.DESCRIPTION, '.') - 1) =
             PA.SEGMENT1
         AND SUBSTR(XAL.DESCRIPTION,
                    INSTR(XAL.DESCRIPTION, '.') + 1,
                    INSTR(XAL.DESCRIPTION, '.', 1, 2) -
                    INSTR(XAL.DESCRIPTION, '.') - 1) = TOP.TASK_NUMBER
            /* AND xal.description =
            pa.segment1 || '.' || top.task_number || '.EQ'*/
         AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
         AND GCC.SEGMENT3 NOT IN ('6111010000', '6111009899')
         AND (XAH.JE_CATEGORY_NAME = '2' AND
             XAL.ACCOUNTING_CLASS_CODE = 'REVENUE' OR
             XAH.JE_CATEGORY_NAME = '1' AND
             XAL.ACCOUNTING_CLASS_CODE = 'COST_OF_GOODS_SOLD')
         AND XAH.ACCOUNTING_DATE >= P_START_DATE
         AND XAH.ACCOUNTING_DATE <= P_END_DATE
         AND XAH.LEDGER_ID = G_LEDGER_ID
         AND EQ.TOP_TASK_ID = TOP.TASK_ID
         AND EQ.TASK_ID = PPE.PROJ_ELEMENT_ID
         AND PPE.TYPE_ID = PTT.TASK_TYPE_ID
         AND PA.ORG_ID = P_ORG_ID
         AND PTT.TASK_TYPE = 'EQ COST'
       GROUP BY EQ.TASK_ID;
  
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT EQ_ER_CATEGORY, SALE_AMOUNT /*- pre_amount*/, TASK_ID,P_START_DATE,7
        FROM (SELECT NVL(SUM(RCTL.EXTENDED_AMOUNT *
                             NVL(RCTA.EXCHANGE_RATE, 1)),
                         0) SALE_AMOUNT,
                     OOL.TASK_ID,
                     NVL(OTT.ATTRIBUTE5, 'ER') EQ_ER_CATEGORY
                FROM OE_ORDER_LINES_ALL        OOL,
                     RA_CUSTOMER_TRX_LINES_ALL RCTL,
                     RA_CUSTOMER_TRX_ALL       RCTA,
                     OE_TRANSACTION_TYPES_ALL  OTT,
                     OE_ORDER_HEADERS_ALL      OOH,
                     XXPJM_SO_ADDTN_LINES_ALL  XSL
               WHERE OOL.LINE_TYPE_ID = OTT.TRANSACTION_TYPE_ID
                 AND OOL.LINE_ID = XSL.SO_LINE_ID(+)
                 AND OOL.HEADER_ID = OOH.HEADER_ID
                 AND OOL.ORG_ID = P_ORG_ID
                 AND OOL.LINE_ID = RCTL.INTERFACE_LINE_ATTRIBUTE6
                 AND RCTL.INTERFACE_LINE_CONTEXT IN
                     ('SHE TAX INVOICE',
                      'HEA TAX INVOICE',
                      'HET TAX INVOICE')
                 AND RCTL.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                 AND RCTA.TRX_DATE BETWEEN P_START_DATE AND P_END_DATE
               GROUP BY OOL.TASK_ID, NVL(OTT.ATTRIBUTE5, 'ER')) SO_CHANGE;
    --   
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'ER', SALE_AMOUNT, TASK_ID,P_START_DATE,8
        FROM (SELECT NVL(SUM(RCTL.EXTENDED_AMOUNT *
                             DECODE(OOL.UNIT_SELLING_PRICE,
                                    0,
                                    1,
                                    NVL(XSL.PRICE_ER, 0) /
                                    OOL.UNIT_SELLING_PRICE) *
                             NVL(RCTA.EXCHANGE_RATE, 1)),
                         0) SALE_AMOUNT,
                     PTER.TASK_ID
                FROM OE_ORDER_LINES_ALL        OOL,
                     RA_CUSTOMER_TRX_LINES_ALL RCTL,
                     RA_CUSTOMER_TRX_ALL       RCTA,
                     PA_TASKS                  PTEQ,
                     PA_TASKS                  PTER,
                     OE_TRANSACTION_TYPES_ALL  OTT,
                     OE_ORDER_HEADERS_ALL      OOH,
                     XXPJM_SO_ADDTN_LINES_ALL  XSL
               WHERE OOL.LINE_TYPE_ID = OTT.TRANSACTION_TYPE_ID
                 AND OOL.HEADER_ID = OOH.HEADER_ID
                 AND OOL.LINE_ID = XSL.SO_LINE_ID(+)
                 AND OOL.TASK_ID = PTEQ.TASK_ID
                 AND PTEQ.TASK_NUMBER LIKE '%EQ'
                 AND PTER.PROJECT_ID = PTEQ.PROJECT_ID
                 AND PTER.TASK_NUMBER =
                     REPLACE(PTEQ.TASK_NUMBER, '.EQ', '') || '.ER'
                 AND OOL.ORG_ID = P_ORG_ID
                 AND NOT EXISTS
               (SELECT 1
                        FROM OE_ORDER_LINES_ALL OOLA
                       WHERE OOLA.TASK_ID = PTER.TASK_ID)
                 AND OOL.LINE_ID = RCTL.INTERFACE_LINE_ATTRIBUTE6
                 AND RCTL.INTERFACE_LINE_CONTEXT IN
                     ('SHE TAX INVOICE',
                      'HEA TAX INVOICE',
                      'HET TAX INVOICE')
                 AND RCTL.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                 AND RCTA.TRX_DATE BETWEEN P_START_DATE AND P_END_DATE
               GROUP BY PTER.TASK_ID) SO_CHANGE;
  
    -- AR No SO LINE_ID
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT 'ER', SALE_AMOUNT, TASK_ID,P_START_DATE,9
        FROM (SELECT NVL(SUM(RCTL.EXTENDED_AMOUNT * OOL.ORDERED_QUANTITY *
                             NVL(XSL.PRICE_ER, 0) /
                             (SELECT SUM(OOL_SUM.ORDERED_QUANTITY *
                                         OOL_SUM.UNIT_SELLING_PRICE)
                                FROM OE_ORDER_LINES_ALL OOL_SUM
                               WHERE OOL_SUM.HEADER_ID = OOL.HEADER_ID) *
                             NVL(RCTA.EXCHANGE_RATE, 1)),
                         0) SALE_AMOUNT,
                     PTER.TASK_ID
                FROM OE_ORDER_LINES_ALL        OOL,
                     RA_CUSTOMER_TRX_LINES_ALL RCTL,
                     RA_CUSTOMER_TRX_ALL       RCTA,
                     PA_TASKS                  PTEQ,
                     PA_TASKS                  PTER,
                     OE_TRANSACTION_TYPES_ALL  OTT,
                     OE_ORDER_HEADERS_ALL      OOH,
                     XXPJM_SO_ADDTN_LINES_ALL  XSL
               WHERE OOL.LINE_TYPE_ID = OTT.TRANSACTION_TYPE_ID
                 AND OOL.HEADER_ID = OOH.HEADER_ID
                 AND OOL.LINE_ID = XSL.SO_LINE_ID(+)
                 AND OOL.TASK_ID = PTEQ.TASK_ID
                 AND PTEQ.TASK_NUMBER LIKE '%EQ'
                 AND PTER.PROJECT_ID = PTEQ.PROJECT_ID
                 AND RCTL.INTERFACE_LINE_ATTRIBUTE6 IS NULL
                 AND PTER.TASK_NUMBER =
                     REPLACE(PTEQ.TASK_NUMBER, '.EQ', '') || '.ER'
                 AND OOL.ORG_ID = P_ORG_ID
                 AND NOT EXISTS
               (SELECT 1
                        FROM OE_ORDER_LINES_ALL OOLA
                       WHERE OOLA.TASK_ID = PTER.TASK_ID)
                 AND OOL.HEADER_ID = RCTL.INTERFACE_LINE_ATTRIBUTE3
                 AND RCTL.INTERFACE_LINE_CONTEXT IN
                     ('SHE TAX INVOICE',
                      'HEA TAX INVOICE',
                      'HET TAX INVOICE')
                 AND RCTL.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                 AND RCTA.TRX_DATE BETWEEN P_START_DATE AND P_END_DATE
               GROUP BY PTER.TASK_ID) SO_CHANGE;
    INSERT INTO XXPA_COST_GCPM_TASK_T5
      SELECT EQ_ER_CATEGORY, SALE_AMOUNT /*- pre_amount*/, TASK_ID,P_START_DATE, 10
        FROM (SELECT NVL(SUM(RCTL.EXTENDED_AMOUNT * OOL.ORDERED_QUANTITY *
                             DECODE(OTT.ATTRIBUTE5,
                                    'EQ',
                                    NVL(XSL.PRICE_EQ, OOL.UNIT_SELLING_PRICE),
                                    OOL.UNIT_SELLING_PRICE) /
                             (SELECT SUM(OOL_SUM.ORDERED_QUANTITY *
                                         OOL_SUM.UNIT_SELLING_PRICE)
                                FROM OE_ORDER_LINES_ALL OOL_SUM
                               WHERE OOL_SUM.HEADER_ID = OOL.HEADER_ID) *
                             NVL(RCTA.EXCHANGE_RATE, 1)),
                         0) SALE_AMOUNT,
                     OOL.TASK_ID,
                     NVL(OTT.ATTRIBUTE5, 'ER') EQ_ER_CATEGORY
                FROM OE_ORDER_LINES_ALL        OOL,
                     RA_CUSTOMER_TRX_LINES_ALL RCTL,
                     RA_CUSTOMER_TRX_ALL       RCTA,
                     OE_TRANSACTION_TYPES_ALL  OTT,
                     OE_ORDER_HEADERS_ALL      OOH,
                     XXPJM_SO_ADDTN_LINES_ALL  XSL
               WHERE OOL.LINE_TYPE_ID = OTT.TRANSACTION_TYPE_ID
                 AND OOL.LINE_ID = XSL.SO_LINE_ID(+)
                 AND OOL.HEADER_ID = OOH.HEADER_ID
                 AND OOL.ORG_ID = P_ORG_ID
                 AND OOL.HEADER_ID = RCTL.INTERFACE_LINE_ATTRIBUTE3
                 AND RCTL.INTERFACE_LINE_ATTRIBUTE6 IS NULL
                 AND RCTL.INTERFACE_LINE_CONTEXT IN
                     ('SHE TAX INVOICE',
                      'HEA TAX INVOICE',
                      'HET TAX INVOICE')
                 AND RCTL.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                 AND RCTA.TRX_DATE BETWEEN P_START_DATE AND P_END_DATE
               GROUP BY OOL.TASK_ID, NVL(OTT.ATTRIBUTE5, 'ER')) SO_CHANGE;
    -- API end body
    -- end activity, include debug message hint to exit api
    XXFND_API.END_ACTIVITY(P_PKG_NAME  => G_PKG_NAME,
                           P_API_NAME  => L_API_NAME,
                           X_MSG_COUNT => X_MSG_COUNT,
                           X_MSG_DATA  => X_MSG_DATA);
  
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_RETURN_STATUS := XXFND_API.HANDLE_EXCEPTIONS(P_PKG_NAME       => G_PKG_NAME,
                                                     P_API_NAME       => L_API_NAME,
                                                     P_SAVEPOINT_NAME => L_SAVEPOINT_NAME,
                                                     P_EXC_NAME       => XXFND_API.G_EXC_NAME_ERROR,
                                                     X_MSG_COUNT      => X_MSG_COUNT,
                                                     X_MSG_DATA       => X_MSG_DATA);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    
      X_RETURN_STATUS := XXFND_API.HANDLE_EXCEPTIONS(P_PKG_NAME       => G_PKG_NAME,
                                                     P_API_NAME       => L_API_NAME,
                                                     P_SAVEPOINT_NAME => L_SAVEPOINT_NAME,
                                                     P_EXC_NAME       => XXFND_API.G_EXC_NAME_UNEXP,
                                                     X_MSG_COUNT      => X_MSG_COUNT,
                                                     X_MSG_DATA       => X_MSG_DATA);
    WHEN OTHERS THEN
      X_RETURN_STATUS := XXFND_API.HANDLE_EXCEPTIONS(P_PKG_NAME       => G_PKG_NAME,
                                                     P_API_NAME       => L_API_NAME,
                                                     P_SAVEPOINT_NAME => L_SAVEPOINT_NAME,
                                                     P_EXC_NAME       => XXFND_API.G_EXC_NAME_OTHERS,
                                                     X_MSG_COUNT      => X_MSG_COUNT,
                                                     X_MSG_DATA       => X_MSG_DATA);
  END PROC_COGS_DATA;
  
  
  SELECT * FROM XXPA_COST_GCPM_TASK_T5
