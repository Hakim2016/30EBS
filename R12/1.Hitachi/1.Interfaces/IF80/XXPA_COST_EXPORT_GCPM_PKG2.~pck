CREATE OR REPLACE PACKAGE XXPA_COST_EXPORT_GCPM_PKG2 IS

  -- Sections
  G_DOMESTIC_SEC NUMBER := 1;
  G_OVERSEAS_SEC NUMBER := 2;
  G_PARTS_SEC    NUMBER := 3;
  G_OTHERS_SEC   NUMBER := 4;
  G_ADD_COST_SEC NUMBER := 5;

  -- TypesG_ADD_COST_SEC
  G_DOMESTIC VARCHAR2(30) := 'DOMESTIC';
  G_OVERSEAS VARCHAR2(30) := 'OVERSEAS';
  G_PARTS    VARCHAR2(30) := 'PARTS';

  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPA_COST_EXPORT_GCPM_PKG2
  Description:
      This program provide concurrent main procedure to perform:
      XXFND:Test Interface Export
  History:
      1.00  2017-03-01 14:10:00  Hand  Creation
  ==================================================*/

  --main
  PROCEDURE MAIN(ERRBUF     OUT VARCHAR2,
                 RETCODE    OUT VARCHAR2,
                 P_GROUP_ID IN VARCHAR2,
                 P_DATE     IN VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_sale_amount
  *
  *   DESCRIPTION:
  *       Get Sale Amount
  *   ARGUMENT: p_task_id         task id
  *             p_period_name     period name
  *             p_sale_amout      sale amount
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_SALE_AMOUNT(P_TASK_ID IN NUMBER) RETURN NUMBER;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_so_rate
  *
  *   DESCRIPTION:
  *       Get So Amount Rate
  *   ARGUMENT: p_mfg_no        Mfg NO
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_SO_RATE(P_TRANSACTIONAL_CURR_CODE IN VARCHAR2,
                       P_ORDERED_DATE            DATE) RETURN NUMBER;

  FUNCTION GET_SECTION(P_TOP_TASK_ID NUMBER, P_PERIOD VARCHAR2) RETURN NUMBER;
  FUNCTION GET_PERIOD_NAME(P_DATE DATE) RETURN VARCHAR2;
  FUNCTION GET_EQ_ER(P_TASK_ID IN NUMBER) RETURN VARCHAR2;
  PROCEDURE IS_IN_TAX_INVOICE(P_TASK_ID           IN NUMBER,
                              P_START_DATE        IN DATE,
                              P_END_DATE          IN DATE,
                              X_LAST_INVOICE_FLAG OUT VARCHAR2,
                              X_EXIST             OUT VARCHAR2,
                              X_ISOVERSEA         OUT VARCHAR2);
  PROCEDURE GENERATE_FILE;

END XXPA_COST_EXPORT_GCPM_PKG2;
/
CREATE OR REPLACE PACKAGE BODY XXPA_COST_EXPORT_GCPM_PKG2 IS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPA_COST_EXPORT_GCPM_PKG2
  Description:
      This program provide concurrent main procedure to perform:
      XXPA:Project Cost Data Outbound
  History:
      1.00  2017-03-01  14:10:00  Hand  Creation
      2.00  2017-06-08  Jingjing.He Modify
      3.00  2017-07-03  Jingjing.He New CR
      4.00  2017-09-06  Jingjing.He Modify
      5.00  2018-02-26  jingjing.he Modify
      6.00  2018-05-31L jingjing.he Modify
  ==================================================*/
  G_SEPERATOR  VARCHAR2(1) := CHR(9);
  G_PA_APPL_ID NUMBER := XXFND_CONST.APPL_ID_PA;
  -- Global variable
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'XXPA_COST_EXPORT_GCPM_PKG2';

  G_GROUP_ID NUMBER;
  -- Debug Enabled
  L_DEBUG VARCHAR2(1) :=  /*nvl(fnd_profile.value('AFLOG_ENABLED'), 'N')*/
   'Y';

  G_LAST_UPDATED_BY   NUMBER := FND_GLOBAL.USER_ID;
  G_CREATED_BY        NUMBER := FND_GLOBAL.USER_ID;
  G_LAST_UPDATE_LOGIN NUMBER := FND_GLOBAL.LOGIN_ID;

  G_REQUEST_ID      NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  G_CONC_PROGRAM_ID NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  G_PROG_APPL_ID    NUMBER := FND_GLOBAL.PROG_APPL_ID;
  G_TO_SYSTEM       VARCHAR2(10) := 'SCM';
  G_PERIOD_NAME     VARCHAR2(25);
  G_PRE_PERIOD_DATE DATE;
  G_CURRENCY_CODE   VARCHAR2(25);
  G_HBS_OU          NUMBER := 101;
  G_SHE_OU          NUMBER := 84;
  G_HET_OU          NUMBER := 141;
  G_HEA_OU          NUMBER := 82;
  G_LEDGER_ID       NUMBER;
  --g_ledger_id       NUMBER := fnd_profile.value('GL_SET_OF_BKS_ID');

  TYPE TASK_TBL IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  G_TASK_TBL TASK_TBL;

  CURSOR EXP_TYPES_C IS
    SELECT EXPENDITURE_TYPE FROM XXPA_EXP_REPORT_TITLES_V;

  --g_time_format     VARCHAR2(25) := 'yyyymmdd';
  --output
  PROCEDURE OUTPUT_FILE(P_CONTENT IN VARCHAR2) IS
  BEGIN
    FND_FILE.PUT(FND_FILE.OUTPUT, P_CONTENT);
  END OUTPUT_FILE;
  PROCEDURE OUTPUT(P_CONTENT IN VARCHAR2) IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, P_CONTENT);
  END OUTPUT;

  --log
  PROCEDURE LOG(P_CONTENT IN VARCHAR2) IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, P_CONTENT);
  END LOG;

  PROCEDURE DEBUG(P IN VARCHAR2) IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, P);
  END DEBUG;

  FUNCTION REPLACE_DELIMITED(P_STR IN VARCHAR2) RETURN VARCHAR2 IS
    L_RESULT VARCHAR2(1000);
  BEGIN
    SELECT REPLACE(REPLACE(REPLACE(P_STR, G_SEPERATOR, ' '), CHR(10), ' '),
                   CHR(13),
                   ' ')
      INTO L_RESULT
      FROM DUAL;
    RETURN L_RESULT;
  END REPLACE_DELIMITED;

  PROCEDURE PROC_COGS_DATA(P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                           X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                           X_MSG_COUNT     OUT NOCOPY NUMBER,
                           X_MSG_DATA      OUT NOCOPY VARCHAR2,
                           P_START_DATE    IN DATE,
                           P_END_DATE      IN DATE,
                           P_ORG_ID        IN NUMBER) IS
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
    DELETE FROM XXPA_COST_GCPM_TASK_T2;
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'COGS', NVL(SUM(PEI.PROJECT_BURDENED_COST), 0), PEI.TASK_ID
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
  
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'COGS',
             NVL(SUM(MMT.ACTUAL_COST * MMT.PRIMARY_QUANTITY), 0),
             MMT.SOURCE_TASK_ID
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
  
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'COGS',
             NVL(SUM(MMT.ACTUAL_COST * MMT.PRIMARY_QUANTITY), 0),
             NVL(MMT.SOURCE_TASK_ID, MMT.TASK_ID)
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
  
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'COGS', NVL(SUM(CDL.PROJECT_BURDENED_COST), 0), PEI.TASK_ID
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
    INSERT INTO XXPA_COST_GCPM_TASK_T2
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
             
             ER.TASK_ID
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
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'COGS',
             SUM(NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0)),
             EQ.TASK_ID AS TASK_ID
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
  
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT EQ_ER_CATEGORY, SALE_AMOUNT /*- pre_amount*/, TASK_ID
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
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'ER', SALE_AMOUNT, TASK_ID
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
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT 'ER', SALE_AMOUNT, TASK_ID
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
    INSERT INTO XXPA_COST_GCPM_TASK_T2
      SELECT EQ_ER_CATEGORY, SALE_AMOUNT /*- pre_amount*/, TASK_ID
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

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_country_desc
  *
  *   DESCRIPTION:
  *       Get Country Desc 
  *   ARGUMENT: p_country_desc        Country Desc
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_COUNTRY_DESC(P_COUNTRY IN VARCHAR2) RETURN VARCHAR2 IS
    L_COUNTRY_DESC VARCHAR2(30);
    CURSOR CUR_COUNTRY_DESC IS
      SELECT FT.TERRITORY_SHORT_NAME
        FROM FND_TERRITORIES_VL FT
       WHERE FT.TERRITORY_CODE = P_COUNTRY;
  
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get Country Desc' || P_COUNTRY);
    END IF;
    L_COUNTRY_DESC := NULL;
    OPEN CUR_COUNTRY_DESC;
    FETCH CUR_COUNTRY_DESC
      INTO L_COUNTRY_DESC;
    CLOSE CUR_COUNTRY_DESC;
    RETURN L_COUNTRY_DESC;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GET_COUNTRY_DESC;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_so_rate
  *
  *   DESCRIPTION:
  *       Get So Amount Rate
  *   ARGUMENT: p_mfg_no        Mfg NO
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_SO_RATE(P_TRANSACTIONAL_CURR_CODE IN VARCHAR2,
                       P_ORDERED_DATE            DATE) RETURN NUMBER IS
    L_SO_RATE NUMBER;
    CURSOR CUR_SO_RATE IS
      SELECT GD2.CONVERSION_RATE
        FROM GL_DAILY_RATES GD2
       WHERE GD2.CONVERSION_TYPE = '1002' --SHEAR
         AND GD2.FROM_CURRENCY = P_TRANSACTIONAL_CURR_CODE
         AND GD2.TO_CURRENCY = G_CURRENCY_CODE
         AND GD2.CONVERSION_DATE =
             (SELECT MAX(GD3.CONVERSION_DATE)
                FROM GL_DAILY_RATES GD3
               WHERE GD3.CONVERSION_TYPE = GD2.CONVERSION_TYPE
                 AND GD3.FROM_CURRENCY = GD2.FROM_CURRENCY
                 AND GD3.TO_CURRENCY = GD2.TO_CURRENCY
                 AND GD3.CONVERSION_DATE <= TRUNC(P_ORDERED_DATE));
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get So rate' || P_TRANSACTIONAL_CURR_CODE ||
            'p_ordered_date:' || TO_CHAR(P_ORDERED_DATE, 'yyyy-mm-dd'));
    END IF;
    L_SO_RATE := NULL;
    OPEN CUR_SO_RATE;
    FETCH CUR_SO_RATE
      INTO L_SO_RATE;
    CLOSE CUR_SO_RATE;
  
    RETURN NVL(L_SO_RATE, 1);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END GET_SO_RATE;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_subcon
  *
  *   DESCRIPTION:
  *       Get subcon
  *   ARGUMENT: p_task_id        Task
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_SUBCON(P_TASK_ID  IN NUMBER,
                      P_ORG_ID   NUMBER,
                      P_END_DATE IN DATE) RETURN NUMBER IS
    CURSOR CUR_SUBCON IS
      SELECT SUM(0 - XCFD.EXPENDITURE_AMOUNT) AMT
        FROM XXPA_COST_FLOW_DTLS_ALL XCFD /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               pa_projects_all         pa,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               pa_tasks                pt,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               pa_expenditure_types    pet*/
       WHERE /*xcfd.project_id = pa.project_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           AND xcfd.org_id = pa.org_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           AND xcfd.task_id = pt.task_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           AND xcfd.expenditure_type = pet.expenditure_type
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           AND*/
       SUBSTR(XCFD.EXPENDITURE_REFERENCE, 1, 7) = 'ACCRUAL'
       AND NVL(XCFD.TRANSFERED_PA_FLAG, 'N') = 'Y'
       AND XCFD.TASK_ID = P_TASK_ID
       AND XCFD.ORG_ID = P_ORG_ID
       AND XCFD.EXPENDITURE_ITEM_DATE <= P_END_DATE
       AND DECODE(COST_TYPE,
              'FAC_FG',
              'SHE_FAC_ORG',
              'FAC_TO_HO_FG',
              'SHE_HQ_ORG',
              'FINAL_FG', /*
                                                                                                  'SHE_HQ_ORG',*/
              DECODE(XCFD.ORG_ID, 141, 'HET_HQ_ORG', 'SHE_HQ_ORG'), --Modify by jingjing 20180226 v5.00
              NULL) IN
       (SELECT OOD.ORGANIZATION_NAME
          FROM ORG_ORGANIZATION_DEFINITIONS OOD
         WHERE OOD.OPERATING_UNIT = P_ORG_ID);
    L_SUBCON NUMBER;
  BEGIN
    OPEN CUR_SUBCON;
    FETCH CUR_SUBCON
      INTO L_SUBCON;
    CLOSE CUR_SUBCON;
  
    RETURN NVL(L_SUBCON, 0);
  END GET_SUBCON;

  FUNCTION GET_FUNC_COST(P_PROJECT_ID       NUMBER,
                         P_TASK_ID          NUMBER,
                         P_EXPENDITURE_TYPE VARCHAR2) RETURN NUMBER IS
    CURSOR COST_C(P_PROJECT_ID       NUMBER,
                  P_TASK_ID          NUMBER,
                  P_EXPENDITURE_TYPE VARCHAR2) IS
      SELECT SUM(DECODE(PEI.SYSTEM_LINKAGE_FUNCTION,
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
                        PEI.BURDEN_COST))
        FROM XXPA_COST_GCPM_COGS_T2      T, --XXPA_PROJ_REV_COGS_TMP      T,
             XXPA_PROJ_COST_TRANSFER_HTY H,
             PA_EXPENDITURE_ITEMS_ALL    FG,
             XXPA_FG_COMPLETION_RELATION R,
             PA_EXPENDITURE_ITEMS_ALL    PEI,
             PA_EXPENDITURE_TYPES        PET
       WHERE T.AE_HEADER_ID = H.AE_HEADER_ID
         AND H.EXPENDITURE_ITEM_ID = FG.EXPENDITURE_ITEM_ID
         AND R.TRANSACTION_SOURCE = FG.TRANSACTION_SOURCE
         AND R.ORIG_TRANSACTION_REFERENCE = FG.ORIG_TRANSACTION_REFERENCE
         AND R.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
         AND PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
         AND PEI.ORG_ID = G_HEA_OU --add by jingjing
            -- 2.00  2014-11-06  hand       Update begin
            -- AND pei.expenditure_type != 'Material'
         AND PEI.EXPENDITURE_TYPE NOT IN
             ('Material',
              'Material Overhead',
              'Resource',
              'Outsourcing',
              'Overhead')
            -- 2.00  2014-11-06  hand       Update End
         AND PEI.PROJECT_ID = P_PROJECT_ID
         AND PEI.TASK_ID = P_TASK_ID
         AND DECODE(PET.ATTRIBUTE_CATEGORY,
                    'HEA_OU',
                    NVL(PET.ATTRIBUTE15, PEI.EXPENDITURE_TYPE),
                    PEI.EXPENDITURE_TYPE) = P_EXPENDITURE_TYPE;
  
    CURSOR COST2_C(P_PROJECT_ID NUMBER,
                   P_TASK_ID    NUMBER,
                   P_CATEGORY   VARCHAR2) IS
      SELECT SUM(DECODE(PEI.SYSTEM_LINKAGE_FUNCTION,
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
                        PEI.BURDEN_COST))
        FROM XXPA_COST_GCPM_COGS_T2      T, --XXPA_PROJ_REV_COGS_TMP      T,
             XXPA_PROJ_COST_TRANSFER_HTY H,
             PA_EXPENDITURE_ITEMS_ALL    FG,
             XXPA_FG_COMPLETION_RELATION R,
             PA_EXPENDITURE_ITEMS_ALL    PEI
       WHERE T.AE_HEADER_ID = H.AE_HEADER_ID
         AND H.EXPENDITURE_ITEM_ID = FG.EXPENDITURE_ITEM_ID
         AND R.TRANSACTION_SOURCE = FG.TRANSACTION_SOURCE
         AND R.ORIG_TRANSACTION_REFERENCE = FG.ORIG_TRANSACTION_REFERENCE
         AND R.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
            -- 2.00  2014-11-06  hand       Update begin
            --AND pei.expenditure_type = 'Material'
         AND PEI.EXPENDITURE_TYPE IN ('Material',
                                      'Material Overhead',
                                      'Resource',
                                      'Outsourcing',
                                      'Overhead')
            -- 2.00  2014-11-06  hand       Update End
         AND PEI.PROJECT_ID = P_PROJECT_ID
         AND PEI.TASK_ID = P_TASK_ID
            -- 2.00  2014-11-06  hand       Update begin
            -- AND xxpa_reports_utils.get_item_category(pei.org_id, pei.inventory_item_id) = p_category
         AND XXPA_REPORTS_UTILS.GET_MATERIAL_CATEGORY(XXPA_REPORTS_UTILS.FUN_GET_REPORT_EXP_TYPE(PEI.EXPENDITURE_ITEM_ID)) =
             P_CATEGORY
      -- 2.00  2014-11-06  hand       Update End
      ;
  
    CURSOR COST3_C(P_PROJECT_ID NUMBER, P_TASK_ID NUMBER) IS
      SELECT SUM(XPM.BURDEN_COST)
        FROM XXPA_COST_GCPM_COGS_T2      T, --XXPA_PROJ_REV_COGS_TMP      T,
             XXPA_PROJ_COST_TRANSFER_HTY H,
             PA_EXPENDITURE_ITEMS_ALL    FG,
             XXPA_FG_COMPLETION_RELATION R,
             XXPA_PROJ_MATERIAL_V        XPM
       WHERE T.AE_HEADER_ID = H.AE_HEADER_ID
         AND H.EXPENDITURE_ITEM_ID = FG.EXPENDITURE_ITEM_ID
         AND R.TRANSACTION_SOURCE = FG.TRANSACTION_SOURCE
         AND R.ORIG_TRANSACTION_REFERENCE = FG.ORIG_TRANSACTION_REFERENCE
         AND R.EXPENDITURE_ITEM_ID = XPM.EXPENDITURE_ITEM_ID
         AND XPM.PROJECT_ID = P_PROJECT_ID
         AND XPM.TASK_ID = P_TASK_ID
         AND XPM.CATEGORY_NAME NOT IN ('SOS', 'PPO');
  
    L_FUNC_COST     NUMBER;
    L_ADDL_COST     NUMBER;
    L_ITEM_CATEGORY MTL_CATEGORIES_B_KFV.CONCATENATED_SEGMENTS%TYPE;
  BEGIN
  
    OPEN COST_C(P_PROJECT_ID, P_TASK_ID, P_EXPENDITURE_TYPE);
    FETCH COST_C
      INTO L_FUNC_COST;
    IF COST_C%NOTFOUND THEN
      L_FUNC_COST := NULL;
    END IF;
    CLOSE COST_C;
  
    L_FUNC_COST := NVL(L_FUNC_COST, 0);
  
    L_ITEM_CATEGORY := XXPA_REPORTS_UTILS.GET_MATERIAL_CATEGORY(P_EXPENDITURE_TYPE);
    IF L_ITEM_CATEGORY IS NOT NULL THEN
    
      OPEN COST2_C(P_PROJECT_ID, P_TASK_ID, L_ITEM_CATEGORY);
      FETCH COST2_C
        INTO L_ADDL_COST;
      CLOSE COST2_C;
    
      L_FUNC_COST := L_FUNC_COST + NVL(L_ADDL_COST, 0);
    
      /*    ELSIF p_expenditure_type = 'Material' THEN
      
      OPEN  cost3_c(p_project_id,
                    p_task_id);
      FETCH cost3_c
       INTO l_func_cost;
      IF cost3_c%NOTFOUND THEN
        l_func_cost := NULL;
      END IF;
      CLOSE cost3_c;
      
      l_func_cost := NVL(l_func_cost, 0);*/
    
    END IF;
  
    RETURN L_FUNC_COST;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END GET_FUNC_COST;
  --add by jingjing.he start
  FUNCTION GET_FUNC_COST2(P_START_DATE       DATE,
                          P_END_DATE         DATE,
                          P_PROJECT_ID       NUMBER,
                          P_TASK_ID          NUMBER,
                          P_EXPENDITURE_TYPE VARCHAR2) RETURN NUMBER IS
    CURSOR COST_C(P_START_DATE       DATE,
                  P_END_DATE         DATE,
                  P_PROJECT_ID       NUMBER,
                  P_TASK_ID          NUMBER,
                  P_EXPENDITURE_TYPE VARCHAR2) IS
      SELECT SUM(DECODE(PEI.SYSTEM_LINKAGE_FUNCTION,
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
                        PEI.BURDEN_COST))
        FROM PA_EXPENDITURE_ITEMS_ALL       PEI,
             PA_TASKS                       PT,
             XXPA_PROJ_MILESTONE_MANAGE_ALL XPMM,
             PA_EXPENDITURE_TYPES           PET
       WHERE PEI.EXPENDITURE_TYPE != 'Cost of Sales for ER'
            -- 2.00  2014-11-06  hand       Update begin
            -- AND pei.expenditure_type != 'Material'
         AND PEI.EXPENDITURE_TYPE NOT IN
             ('Material',
              'Material Overhead',
              'Resource',
              'Outsourcing',
              'Overhead')
            -- 2.00  2014-11-06  hand       Update End
         AND PEI.ORG_ID = G_HEA_OU
         AND PEI.TASK_ID = PT.TASK_ID
         AND PT.TOP_TASK_ID = XPMM.TASK_ID
         AND PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
         AND (XPMM.HAND_OVER_DATE BETWEEN P_START_DATE AND P_END_DATE AND
             PEI.EXPENDITURE_ITEM_DATE <= P_END_DATE OR
             XPMM.HAND_OVER_DATE < P_START_DATE AND
             PEI.EXPENDITURE_ITEM_DATE BETWEEN P_START_DATE AND P_END_DATE)
         AND PEI.PROJECT_ID = P_PROJECT_ID
         AND PEI.TASK_ID = P_TASK_ID
         AND DECODE(PET.ATTRIBUTE_CATEGORY,
                    'HEA_OU',
                    NVL(PET.ATTRIBUTE15, PEI.EXPENDITURE_TYPE),
                    PEI.EXPENDITURE_TYPE) = P_EXPENDITURE_TYPE;
  
    CURSOR COST2_C(P_START_DATE DATE,
                   P_END_DATE   DATE,
                   P_PROJECT_ID NUMBER,
                   P_TASK_ID    NUMBER,
                   P_CATEGORY   VARCHAR2) IS
      SELECT SUM(DECODE(PEI.SYSTEM_LINKAGE_FUNCTION,
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
                        PEI.BURDEN_COST))
        FROM PA_EXPENDITURE_ITEMS_ALL       PEI,
             PA_TASKS                       PT,
             XXPA_PROJ_MILESTONE_MANAGE_ALL XPMM,
             PA_EXPENDITURE_TYPES           PET
       WHERE PEI.TASK_ID = PT.TASK_ID
         AND PT.TOP_TASK_ID = XPMM.TASK_ID
         AND PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
            -- 2.00  2014-11-06  hand       Update begin
            -- AND pei.expenditure_type = 'Material'
         AND PEI.EXPENDITURE_TYPE IN ('Material',
                                      'Material Overhead',
                                      'Resource',
                                      'Outsourcing',
                                      'Overhead')
            -- 2.00  2014-11-06  hand       Update End
         AND (XPMM.HAND_OVER_DATE BETWEEN P_START_DATE AND P_END_DATE AND
             PEI.EXPENDITURE_ITEM_DATE <= P_END_DATE OR
             XPMM.HAND_OVER_DATE < P_START_DATE AND
             PEI.EXPENDITURE_ITEM_DATE BETWEEN P_START_DATE AND P_END_DATE)
         AND PEI.PROJECT_ID = P_PROJECT_ID
         AND PEI.TASK_ID = P_TASK_ID
            -- 2.00  2014-11-06  hand       Update begin
            -- AND xxpa_reports_utils.get_item_category(pei.org_id, pei.inventory_item_id) = p_category
         AND XXPA_REPORTS_UTILS.GET_MATERIAL_CATEGORY(XXPA_REPORTS_UTILS.FUN_GET_REPORT_EXP_TYPE(PEI.EXPENDITURE_ITEM_ID)) =
             P_CATEGORY
      -- 2.00  2014-11-06  hand       Update End
      
      ;
  
    CURSOR COST3_C(P_START_DATE DATE,
                   P_END_DATE   DATE,
                   P_PROJECT_ID NUMBER,
                   P_TASK_ID    NUMBER) IS
      SELECT SUM(PEI.BURDEN_COST)
        FROM XXPA_PROJ_MATERIAL_V           PEI,
             PA_TASKS                       PT,
             XXPA_PROJ_MILESTONE_MANAGE_ALL XPMM,
             PA_EXPENDITURE_TYPES           PET
       WHERE PEI.TASK_ID = PT.TASK_ID
         AND PT.TOP_TASK_ID = XPMM.TASK_ID
         AND PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
         AND (XPMM.HAND_OVER_DATE BETWEEN P_START_DATE AND P_END_DATE AND
             PEI.EXPENDITURE_ITEM_DATE <= P_END_DATE OR
             XPMM.HAND_OVER_DATE < P_START_DATE AND
             PEI.EXPENDITURE_ITEM_DATE BETWEEN P_START_DATE AND P_END_DATE)
         AND PEI.PROJECT_ID = P_PROJECT_ID
         AND PEI.TASK_ID = P_TASK_ID
         AND PEI.CATEGORY_NAME NOT IN ('SOS', 'PPO');
  
    L_FUNC_COST     NUMBER;
    L_ADDL_COST     NUMBER;
    L_ITEM_CATEGORY MTL_CATEGORIES_B_KFV.CONCATENATED_SEGMENTS%TYPE;
  BEGIN
  
    OPEN COST_C(P_START_DATE,
                P_END_DATE,
                P_PROJECT_ID,
                P_TASK_ID,
                P_EXPENDITURE_TYPE);
    FETCH COST_C
      INTO L_FUNC_COST;
    IF COST_C%NOTFOUND THEN
      L_FUNC_COST := NULL;
    END IF;
    CLOSE COST_C;
  
    L_FUNC_COST     := NVL(L_FUNC_COST, 0);
    L_ITEM_CATEGORY := XXPA_REPORTS_UTILS.GET_MATERIAL_CATEGORY(P_EXPENDITURE_TYPE);
    IF L_ITEM_CATEGORY IS NOT NULL THEN
    
      OPEN COST2_C(P_START_DATE,
                   P_END_DATE,
                   P_PROJECT_ID,
                   P_TASK_ID,
                   L_ITEM_CATEGORY);
      FETCH COST2_C
        INTO L_ADDL_COST;
      CLOSE COST2_C;
    
      L_FUNC_COST := L_FUNC_COST + NVL(L_ADDL_COST, 0);
    
      /*ELSIF p_expenditure_type = 'Material' THEN
      
      OPEN  cost3_c(p_start_date,
                    p_end_date,
                    p_project_id,
                    p_task_id);
      FETCH cost3_c
       INTO l_func_cost;
      IF cost3_c%NOTFOUND THEN
        l_func_cost := NULL;
      END IF;
      CLOSE cost3_c;
      
      l_func_cost := NVL(l_func_cost, 0);*/
    
    END IF;
  
    RETURN L_FUNC_COST;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --add by jingjing.he end

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_Goe_Number
  *
  *   DESCRIPTION:
  *       Get Goe Number
  *   ARGUMENT: p_mfg_no        Mfg NO
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_GOE_NUMBER(P_MFG_NO IN VARCHAR2, P_ORG_ID NUMBER)
    RETURN VARCHAR2 IS
    L_GOE_NUMBER VARCHAR2(30);
    CURSOR CUR_GOE_NUMBER IS
      SELECT XXQ.QUOTATION_NUMBER
        FROM XXPJM_MFG_NUMBERS            XXP,
             XXPJM_MFG_RELATIONSHIPS      XXR,
             XXPJM_QUOTATIONS             XXQ,
             ORG_ORGANIZATION_DEFINITIONS OOD
       WHERE NVL(XXR.SOURCE_TABLE, 'XXPJM_QUOTATIONS') = 'XXPJM_QUOTATIONS'
         AND XXR.SOURCE_TABLE_ID = XXQ.QUOTATION_ID(+)
         AND XXP.MFG_ID = XXR.MFG_ID
         AND XXP.MFG_NUMBER = P_MFG_NO
         AND XXP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
       ORDER BY DECODE(OOD.OPERATING_UNIT, P_ORG_ID, 1, 0);
  
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get Goe Number' || P_MFG_NO || 'p_org_id:' || P_ORG_ID);
    END IF;
    L_GOE_NUMBER := NULL;
    OPEN CUR_GOE_NUMBER;
    FETCH CUR_GOE_NUMBER
      INTO L_GOE_NUMBER;
    CLOSE CUR_GOE_NUMBER;
  
    RETURN L_GOE_NUMBER;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GET_GOE_NUMBER;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_Model
  *
  *   DESCRIPTION:
  *       Get Model
  *   ARGUMENT: p_task_id        Task ID
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_MODEL(P_TASK_ID      IN NUMBER,
                     P_SO_HEADER_ID IN NUMBER,
                     P_MFG_NO       IN VARCHAR2,
                     P_ORG_ID       NUMBER) RETURN VARCHAR2 IS
    L_MODEL VARCHAR2(30);
    CURSOR CUR_MODEL IS
      SELECT XSL.MODEL
        FROM XXPJM_SO_ADDTN_LINES_ALL XSL, OE_ORDER_LINES_ALL OOLA
       WHERE XSL.SO_LINE_ID = OOLA.LINE_ID
         AND OOLA.HEADER_ID = P_SO_HEADER_ID
         AND OOLA.TASK_ID = P_TASK_ID
         AND XSL.MODEL IS NOT NULL
       ORDER BY XSL.MODEL DESC;
    CURSOR CUR_MFG_MODEL IS
      SELECT MFG.MODEL
        FROM XXPJM_MFG_NUMBERS MFG, ORG_ORGANIZATION_DEFINITIONS OOD
       WHERE MFG.MFG_NUMBER = P_MFG_NO
         AND MFG.MODEL IS NOT NULL
         AND MFG.ORGANIZATION_ID = OOD.ORGANIZATION_ID
       ORDER BY DECODE(OOD.OPERATING_UNIT, P_ORG_ID, 1, 0);
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get Model' || P_TASK_ID || 'p_so_header_id:' ||
            P_SO_HEADER_ID);
    END IF;
    L_MODEL := NULL;
    OPEN CUR_MODEL;
    FETCH CUR_MODEL
      INTO L_MODEL;
    CLOSE CUR_MODEL;
    IF L_MODEL IS NULL THEN
      OPEN CUR_MFG_MODEL;
      FETCH CUR_MFG_MODEL
        INTO L_MODEL;
      CLOSE CUR_MFG_MODEL;
    END IF;
  
    RETURN L_MODEL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Others';
  END GET_MODEL;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_delivery_date
  *
  *   DESCRIPTION:
  *       Get Delivery Date
  *   ARGUMENT: p_task_id        Task ID
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_DELIVERY_DATE(P_TOP_TASK_ID  IN NUMBER,
                             P_ORG_ID       IN NUMBER,
                             P_PROJECT_TYPE IN VARCHAR2) RETURN DATE IS
    L_FULLY_DELIVERY_DATE DATE;
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get Delivery Date' || P_TOP_TASK_ID);
    END IF;
    IF P_ORG_ID = G_HET_OU THEN
      RETURN NULL;
    END IF;
    IF P_ORG_ID = G_SHE_OU AND P_PROJECT_TYPE = 'Oversea' THEN
      RETURN NULL;
    END IF;
    IF P_ORG_ID = G_SHE_OU THEN
      BEGIN
        SELECT FND_CONC_DATE.STRING_TO_DATE(PPE.ATTRIBUTE1)
          INTO L_FULLY_DELIVERY_DATE
          FROM PA_PROJ_ELEMENT_VERSIONS PPEV,
               PA_PROJECTS_ALL          PA,
               PA_PROJ_ELEMENTS         PPE
         WHERE PPEV.OBJECT_TYPE = 'PA_TASKS'
           AND PPEV.WBS_LEVEL = 1
           AND PPEV.PROJECT_ID = PA.PROJECT_ID
           AND PPEV.PROJ_ELEMENT_ID = PPE.PROJ_ELEMENT_ID
           AND PA.TEMPLATE_FLAG = 'N'
           AND PPEV.PARENT_STRUCTURE_VERSION_ID =
               NVL(PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(PPEV.PROJECT_ID),
                   PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID(PPEV.PROJECT_ID))
           AND (PA.ORG_ID = P_ORG_ID)
           AND PPEV.PROJ_ELEMENT_ID = P_TOP_TASK_ID;
      EXCEPTION
        WHEN OTHERS THEN
          L_FULLY_DELIVERY_DATE := NULL;
      END;
    END IF;
    IF P_ORG_ID IN (G_HEA_OU, G_HBS_OU) THEN
      BEGIN
        SELECT HAND_OVER_DATE
          INTO L_FULLY_DELIVERY_DATE
          FROM XXPA_PROJ_MILESTONE_MANAGE_ALL XPM
         WHERE P_TOP_TASK_ID = XPM.TASK_ID;
      EXCEPTION
        WHEN OTHERS THEN
          L_FULLY_DELIVERY_DATE := NULL;
      END;
    END IF;
    RETURN L_FULLY_DELIVERY_DATE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GET_DELIVERY_DATE;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_country_map
  *
  *   DESCRIPTION:
  *       Get Country Map
  *   ARGUMENT: p_gscm_country         country
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_COUNTRY_MAP(P_GSCM_COUNTRY IN VARCHAR2) RETURN VARCHAR2 IS
    L_GCPM_COUNTRY VARCHAR2(30);
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('Get Country Map :' || P_GSCM_COUNTRY);
    END IF;
    SELECT FLV.TAG
      INTO L_GCPM_COUNTRY
      FROM FND_LOOKUP_VALUES_VL FLV
     WHERE FLV.LOOKUP_TYPE = 'XXPA_PROJ_COUNTRY'
       AND FLV.MEANING = P_GSCM_COUNTRY
       AND FLV.ENABLED_FLAG = 'Y'
       AND SYSDATE BETWEEN NVL(FLV.START_DATE_ACTIVE, SYSDATE) AND
           NVL(FLV.END_DATE_ACTIVE, SYSDATE);
    RETURN L_GCPM_COUNTRY;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Other';
    WHEN OTHERS THEN
      RETURN NULL;
  END GET_COUNTRY_MAP;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_model_map
  *
  *   DESCRIPTION:
  *       Get Model Map
  *   ARGUMENT: p_gscm_country         country
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_MODEL_MAP(P_GSCM_MODEL IN VARCHAR2) RETURN VARCHAR2 IS
    L_GCPM_MODEL VARCHAR2(30);
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('Get Model Map :' || P_GSCM_MODEL);
    END IF;
    IF P_GSCM_MODEL IS NULL THEN
      RETURN 'Others';
    END IF;
    SELECT FLV.TAG
      INTO L_GCPM_MODEL
      FROM FND_LOOKUP_VALUES_VL FLV
     WHERE FLV.LOOKUP_TYPE = 'XXPA_PROJ_MODEL_TYPE'
       AND FLV.MEANING = P_GSCM_MODEL
       AND FLV.ENABLED_FLAG = 'Y'
       AND SYSDATE BETWEEN NVL(FLV.START_DATE_ACTIVE, SYSDATE) AND
           NVL(FLV.END_DATE_ACTIVE, SYSDATE);
  
    RETURN L_GCPM_MODEL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Others';
  END GET_MODEL_MAP;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_currency_map
  *
  *   DESCRIPTION:
  *       Get Currency Map
  *   ARGUMENT: p_currency_code         country
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_CURRENCY_MAP(P_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    L_CURRENCY_CODE VARCHAR2(30);
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('Get Currency Map :' || P_CURRENCY_CODE);
    END IF;
    SELECT FLV.TAG
      INTO L_CURRENCY_CODE
      FROM FND_LOOKUP_VALUES_VL FLV
     WHERE FLV.LOOKUP_TYPE = 'XXPA_PROJ_CURR'
       AND FLV.MEANING = P_CURRENCY_CODE
       AND FLV.ENABLED_FLAG = 'Y'
       AND SYSDATE BETWEEN NVL(FLV.START_DATE_ACTIVE, SYSDATE) AND
           NVL(FLV.END_DATE_ACTIVE, SYSDATE);
  
    RETURN L_CURRENCY_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END GET_CURRENCY_MAP;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_main_contractor_map
  *
  *   DESCRIPTION:
  *       Get Main Contractor Map
  *   ARGUMENT: p_main_contractor_code         main contractor
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE IN VARCHAR2)
    RETURN VARCHAR2 IS
    L_MAIN_CONTRACTOR VARCHAR2(30);
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('Get Main Contractor Map :' || P_MAIN_CONTRACTOR_CODE);
    END IF;
    SELECT FLV.TAG
      INTO L_MAIN_CONTRACTOR
      FROM FND_LOOKUP_VALUES_VL FLV
     WHERE FLV.LOOKUP_TYPE = 'XXPA_PROJ_MAIN_CONTR'
       AND FLV.MEANING = P_MAIN_CONTRACTOR_CODE
       AND FLV.ENABLED_FLAG = 'Y'
       AND SYSDATE BETWEEN NVL(FLV.START_DATE_ACTIVE, SYSDATE) AND
           NVL(FLV.END_DATE_ACTIVE, SYSDATE);
    RETURN L_MAIN_CONTRACTOR;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END GET_MAIN_CONTRACTOR_MAP;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_wip_amount
  *
  *   DESCRIPTION:
  *       Get Sale Amount
  *   ARGUMENT: p_task_id         task id
  *             p_period_name     period name
  *             p_sale_amout      sale amount
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  PROCEDURE GET_WIP_AMOUNT(P_TASK_ID             IN NUMBER,
                           X_MATERIAL_YTD        OUT NUMBER,
                           X_EXPENSE_YTD         OUT NUMBER,
                           X_LABOUR_YTD          OUT NUMBER,
                           X_SUBCON_YTD          OUT NUMBER,
                           X_PACKING_FREIGHT_YTD OUT NUMBER) IS
    CURSOR CUR_WIP_AMOUNT IS
      SELECT /*+index(xcg xxpa_cost_gcpm_int_n4)*/
       NVL(XCG.MATERIAL_YTD, 0),
       NVL(XCG.EXPENSE_YTD, 0),
       NVL(XCG.LABOUR_YTD, 0),
       NVL(XCG.SUBCON_YTD, 0),
       NVL(XCG.PACKING_FREIGHT_YTD, 0)
        FROM XXPA_COST_GCPM_INT XCG
       WHERE XCG.PERIOD_START_DATE =
             (SELECT MAX(XCG.PERIOD_START_DATE)
                FROM XXPA_COST_GCPM_INT XCG
               WHERE XCG.PERIOD_START_DATE < G_PRE_PERIOD_DATE
                 AND XCG.TASK_ID = P_TASK_ID)
         AND XCG.TASK_ID = P_TASK_ID
       ORDER BY XCG.UNIQUE_ID DESC;
  
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get actual sale amount :' || P_TASK_ID);
    END IF;
    X_MATERIAL_YTD        := 0;
    X_EXPENSE_YTD         := 0;
    X_LABOUR_YTD          := 0;
    X_SUBCON_YTD          := 0;
    X_PACKING_FREIGHT_YTD := 0;
    OPEN CUR_WIP_AMOUNT;
    FETCH CUR_WIP_AMOUNT
      INTO X_MATERIAL_YTD,
           X_EXPENSE_YTD,
           X_LABOUR_YTD,
           X_SUBCON_YTD,
           X_PACKING_FREIGHT_YTD;
    CLOSE CUR_WIP_AMOUNT;
  
  EXCEPTION
    WHEN OTHERS THEN
      X_MATERIAL_YTD        := 0;
      X_EXPENSE_YTD         := 0;
      X_LABOUR_YTD          := 0;
      X_SUBCON_YTD          := 0;
      X_PACKING_FREIGHT_YTD := 0;
  END GET_WIP_AMOUNT;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_additional_flag
  *
  *   DESCRIPTION:
  *       Get Sale Amount
  *   ARGUMENT: p_task_id         task id
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_ADDITIONAL_FLAG(P_TASK_ID IN NUMBER) RETURN VARCHAR2 IS
    CURSOR CUR_ADDITIONAL_FLAG IS
      SELECT /*+index(xcg xxpa_cost_gcpm_int_n4)*/
       '1'
        FROM XXPA_COST_GCPM_INT XCG
       WHERE XCG.PERIOD_START_DATE < G_PRE_PERIOD_DATE
         AND XCG.TASK_ID = P_TASK_ID
         AND ROWNUM = 1;
    L_CUR_ADDITIONAL_FLAG VARCHAR2(10);
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get actual sale amount :' || P_TASK_ID);
    END IF;
    OPEN CUR_ADDITIONAL_FLAG;
    FETCH CUR_ADDITIONAL_FLAG
      INTO L_CUR_ADDITIONAL_FLAG;
    CLOSE CUR_ADDITIONAL_FLAG;
    RETURN NVL(L_CUR_ADDITIONAL_FLAG, '0');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '0';
  END GET_ADDITIONAL_FLAG;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_sale_amount
  *
  *   DESCRIPTION:
  *       Get Sale Amount
  *   ARGUMENT: p_task_id         task id
  *             p_period_name     period name
  *             p_sale_amout      sale amount
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_SALE_AMOUNT(P_TASK_ID IN NUMBER) RETURN NUMBER IS
    CURSOR CUR_SALE_AMOUNT IS
      SELECT /*+index(xcg xxpa_cost_gcpm_int_n4)*/
       NVL(XCG.PREPERIOD_SALE_AMOUNT, 0)
        FROM XXPA_COST_GCPM_INT XCG
       WHERE XCG.PERIOD_START_DATE =
             (SELECT MAX(XCG.PERIOD_START_DATE)
                FROM XXPA_COST_GCPM_INT XCG
               WHERE XCG.PERIOD_START_DATE < G_PRE_PERIOD_DATE
                 AND XCG.TASK_ID = P_TASK_ID)
         AND XCG.TASK_ID = P_TASK_ID
       ORDER BY XCG.UNIQUE_ID DESC;
    L_SALE_AMOUNT_PERIOD NUMBER;
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get actual sale amount :' || P_TASK_ID);
    END IF;
    OPEN CUR_SALE_AMOUNT;
    FETCH CUR_SALE_AMOUNT
      INTO L_SALE_AMOUNT_PERIOD;
    CLOSE CUR_SALE_AMOUNT;
    RETURN NVL(L_SALE_AMOUNT_PERIOD, 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END GET_SALE_AMOUNT;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  GET_PERIOD_DATE
  *
  *   DESCRIPTION:
  *       Get Sale Amount
  *   ARGUMENT: P_PERIOD_NAME 
  *             X_START_DATE
  *             X_END_DATE
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  PROCEDURE GET_PERIOD_DATE(P_PERIOD_NAME IN VARCHAR2,
                            X_START_DATE  OUT DATE,
                            X_END_DATE    OUT DATE) IS
    CURSOR DATE_C(P_PERIOD_NAME VARCHAR2) IS
      SELECT GPS.START_DATE, GPS.END_DATE + 0.99999
        FROM GL_PERIOD_STATUSES GPS
       WHERE GPS.APPLICATION_ID = 101
         AND GPS.SET_OF_BOOKS_ID = G_LEDGER_ID
            --AND gps.closing_status         =  'O'
         AND GPS.ADJUSTMENT_PERIOD_FLAG = 'N'
         AND GPS.PERIOD_NAME = P_PERIOD_NAME;
  
  BEGIN
  
    OPEN DATE_C(P_PERIOD_NAME);
    FETCH DATE_C
      INTO X_START_DATE, X_END_DATE;
    IF DATE_C%NOTFOUND THEN
      X_START_DATE := NULL;
      X_END_DATE   := NULL;
    END IF;
    CLOSE DATE_C;
  
  END;
  --add by jingjing.he end
  --add by jingjing.he start
  PROCEDURE GET_MODEL_STOPS(P_TOP_TASK_ID IN NUMBER,
                            X_MODEL       OUT VARCHAR2,
                            X_STOPS       OUT VARCHAR2) IS
    CURSOR LINE_C(P_TOP_TASK_ID NUMBER) IS
      SELECT XSOL.MODEL, XSOL.STOPS
        FROM XXPJM_SO_ADDTN_LINES_ALL XSOL,
             OE_ORDER_LINES_ALL       OOL,
             PA_TASKS                 TOP
       WHERE XSOL.SO_LINE_ID = OOL.LINE_ID
         AND XSOL.MFG_NO = TOP.TASK_NUMBER
         AND OOL.PROJECT_ID = TOP.PROJECT_ID
         AND TOP.TASK_ID = P_TOP_TASK_ID;
  
  BEGIN
  
    OPEN LINE_C(P_TOP_TASK_ID);
    FETCH LINE_C
      INTO X_MODEL, X_STOPS;
    IF LINE_C%NOTFOUND THEN
      X_MODEL := NULL;
      X_STOPS := NULL;
    END IF;
    CLOSE LINE_C;
  
  EXCEPTION
    WHEN OTHERS THEN
      X_MODEL := NULL;
      X_STOPS := NULL;
  END;
  --add by jingjing.he end

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  GET_HEA_ER_FIRST_AMOUNT
  *
  *   DESCRIPTION:
  *       Get first COGS & Sales amnt of HEA ER from XXPA_COST_GCPM_INT
  *   ARGUMENT: p_task_id         task id
  *   HISTORY:
  *     1.00 2017-07-03 jingjing.He Creation
  * =============================================*/
  PROCEDURE GET_HEA_ER_FIRST_AMOUNT(P_TASK_ID         IN NUMBER,
                                    P_START_DATE      IN DATE,
                                    X_SALES_AMOUNT    OUT NUMBER,
                                    X_COGS            OUT NUMBER,
                                    X_MATERIAL        OUT NUMBER,
                                    X_EXPENSE         OUT NUMBER,
                                    X_LABOUR          OUT NUMBER,
                                    X_SUBCON          OUT NUMBER,
                                    X_PACKING_FREIGHT OUT NUMBER) IS
    CURSOR GET_AMNT_FR_INT(P_TASK_ID IN NUMBER, P_START_DATE IN DATE) IS
      SELECT SUM(T.SALE_AMOUNT),
             SUM(T.COGS),
             SUM(T.MATERIAL),
             SUM(T.EXPENSE),
             SUM(T.LABOUR),
             SUM(T.SUBCON),
             SUM(T.PACKING_FREIGHT)
        FROM (SELECT DISTINCT CGI.TASK_ID,
                              --CGI.ADDITIONAL_FLAG,
                              CGI.SALE_AMOUNT,
                              CGI.COGS,
                              CGI.MATERIAL,
                              CGI.EXPENSE,
                              CGI.LABOUR,
                              CGI.SUBCON,
                              CGI.PACKING_FREIGHT,
                              CGI.ACTUAL_MONTH
                FROM XXPA_COST_GCPM_INT CGI
               WHERE 1 = 1
                 AND CGI.TASK_ID = P_TASK_ID
                 AND CGI.ADDITIONAL_FLAG = 'N'
                 AND CGI.ACTUAL_MONTH < P_START_DATE) T
       GROUP BY T.TASK_ID;
  
  BEGIN
    OPEN GET_AMNT_FR_INT(P_TASK_ID, P_START_DATE);
    FETCH GET_AMNT_FR_INT
      INTO X_SALES_AMOUNT,
           X_COGS,
           X_MATERIAL,
           X_EXPENSE,
           X_LABOUR,
           X_SUBCON,
           X_PACKING_FREIGHT;
    IF GET_AMNT_FR_INT%NOTFOUND THEN
      X_SALES_AMOUNT    := 0;
      X_COGS            := 0;
      X_MATERIAL        := 0;
      X_EXPENSE         := 0;
      X_LABOUR          := 0;
      X_SUBCON          := 0;
      X_PACKING_FREIGHT := 0;
      RETURN;
    END IF;
    CLOSE GET_AMNT_FR_INT;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE get_hea_er_first_amount : ' || SQLERRM);
  END GET_HEA_ER_FIRST_AMOUNT;

  PROCEDURE GET_FIRST_SALE_AMOUNT(P_TASK_ID      IN NUMBER,
                                  P_START_DATE   IN DATE,
                                  P_END_DATE     IN DATE,
                                  X_SALES_AMOUNT OUT NUMBER) IS
  
    CURSOR CUR_SALE_AMOUNT(P_TASK_ID    IN NUMBER,
                           P_START_DATE IN DATE,
                           P_END_DATE   IN DATE) IS
    
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
         AND OOL.TASK_ID = P_TASK_ID
         AND RCT.TRX_DATE < P_END_DATE
       GROUP BY OOL.TASK_ID;
  
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('GET_FIRST_SALE_AMOUNT : TASK ID = ' || P_TASK_ID);
    END IF;
    OPEN CUR_SALE_AMOUNT(P_TASK_ID, P_START_DATE, P_END_DATE);
    FETCH CUR_SALE_AMOUNT
      INTO X_SALES_AMOUNT;
    CLOSE CUR_SALE_AMOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE GET_FIRST_SALE_AMOUNT : ' || SQLERRM);
  END GET_FIRST_SALE_AMOUNT;

  PROCEDURE GET_ADD_SALE_AMOUNT(P_TASK_ID      IN NUMBER,
                                P_START_DATE   IN DATE,
                                P_END_DATE     IN DATE,
                                P_ISOVERSEA    IN VARCHAR2,
                                X_SALES_AMOUNT OUT NUMBER) IS
    L_LAST_DATE DATE;
    CURSOR CUR_LAST_DATE(P_TASK_ID IN NUMBER, p_start_date DATE) IS
      SELECT trunc(LAST_DAY(MAX(LIT.DIH_CREATION_DATE))) + 0.99999 --the first day of next month
        FROM XXOM_LAST_INVOICE_TMP LIT
       WHERE LIT.TASK_ID = P_TASK_ID
         AND 'DOMESTIC' = P_ISOVERSEA
         AND lit.dih_creation_date < p_start_date
      UNION ALL
      SELECT trunc(LAST_DAY(MAX(OIT.DIH_CREATION_DATE))) + 0.99999
        FROM XXOM_OVERSEA_INVOICE_TMP OIT
       WHERE OIT.TASK_ID = P_TASK_ID
         AND 'OVERSEA' = P_ISOVERSEA
         AND oit.dih_creation_date < p_start_date
       ORDER BY 1; --add by hakim @ 2018/05/31L V6.00
  
    CURSOR CUR_SALE_AMOUNT(P_TASK_ID    IN NUMBER,
                           P_START_DATE IN DATE,
                           P_END_DATE   IN DATE) IS
    
      SELECT SUM((RCTL.EXTENDED_AMOUNT +
                 (SELECT ZL2.TAX_AMT
                     FROM ZX_LINES ZL2
                    WHERE ZL2.TRX_LINE_ID = RCTL.CUSTOMER_TRX_LINE_ID)) *
                 NVL(RCT.EXCHANGE_RATE, 1)) ALL_AMT
        FROM RA_CUSTOMER_TRX_LINES_ALL RCTL,
             OE_ORDER_LINES_ALL        OOL,
             RA_CUSTOMER_TRX_ALL       RCT
      
       WHERE 1 = 1
         AND RCT.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
         AND OOL.LINE_ID = TO_CHAR(RCTL.INTERFACE_LINE_ATTRIBUTE6)
         AND OOL.TASK_ID = P_TASK_ID
         AND RCT.TRX_DATE BETWEEN P_START_DATE AND P_END_DATE
       GROUP BY OOL.TASK_ID;
  
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('CUR_SALE_AMOUNT : TASK ID = ' || P_TASK_ID);
    END IF;
    OPEN CUR_LAST_DATE(P_TASK_ID, p_start_date);
    FETCH CUR_LAST_DATE
      INTO L_LAST_DATE;
    CLOSE CUR_LAST_DATE;
  
    OPEN CUR_SALE_AMOUNT(P_TASK_ID, L_LAST_DATE, P_END_DATE);
    FETCH CUR_SALE_AMOUNT
      INTO X_SALES_AMOUNT;
    CLOSE CUR_SALE_AMOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE GET_ADD_SALE_AMOUNT : ' || SQLERRM);
  END GET_ADD_SALE_AMOUNT;

  FUNCTION GET_EQ_ER(P_TASK_ID IN NUMBER) RETURN VARCHAR2 IS
    CURSOR ISER(P_TASK_ID IN VARCHAR2) IS
      SELECT PT.TASK_NUMBER FROM PA_TASKS PT WHERE PT.TASK_ID = P_TASK_ID;
  
    CURSOR EQ_ER(P_TASK_ID IN NUMBER) IS
      SELECT PPA.PROJECT_TYPE, NVL(OTT.ATTRIBUTE5, 'EQ')
        FROM PA_TASKS                 PT,
             PA_PROJECTS_ALL          PPA,
             OE_ORDER_LINES_ALL       OOL,
             OE_TRANSACTION_TYPES_ALL OTT
       WHERE 1 = 1
         AND OOL.TASK_ID = PT.TASK_ID
         AND OOL.LINE_TYPE_ID = OTT.TRANSACTION_TYPE_ID
         AND PT.PROJECT_ID = PPA.PROJECT_ID
         AND PT.TASK_ID = P_TASK_ID;
    L_END_ER   VARCHAR2(20);
    L_PRJ_TYPE VARCHAR2(20);
    L_ATTR5    VARCHAR2(20);
  BEGIN
    OPEN ISER(P_TASK_ID);
    FETCH ISER
      INTO L_END_ER;
    CLOSE ISER;
    IF L_END_ER LIKE '%.ER' THEN
      RETURN 'ER';
    END IF;
  
    OPEN EQ_ER(P_TASK_ID);
    FETCH EQ_ER
      INTO L_PRJ_TYPE, L_ATTR5;
    CLOSE EQ_ER;
    IF L_PRJ_TYPE IN ('SHE FAC_Assy Parts', 'SHE FAC_Elevator') THEN
      RETURN 'EQ';
    ELSIF L_ATTR5 = 'PART' THEN
      RETURN 'PARTS';
    ELSE
      RETURN 'EQ';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE GET_EQ_ER : ' || SQLERRM);
  END GET_EQ_ER;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_actual_sale_month
  *
  *   DESCRIPTION:
  *       Get Actual Sale Month
  *   ARGUMENT: p_task_id         task id
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_ACTUAL_SALE_MONTH(P_TASK_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('get actual sale month :' || P_TASK_ID);
    END IF;
    RETURN P_TASK_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '0';
  END GET_ACTUAL_SALE_MONTH;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  insert_int_err
  *
  *   DESCRIPTION:
  *       Insert Interface Error info
  *   ARGUMENT: p_int_err         error record
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  PROCEDURE INSERT_INT_ERR(P_INT_ERR IN XXPA_COST_GCPM_ERROR2%ROWTYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM XXPA_COST_GCPM_ERROR2 T
     WHERE T.ORG_ID = P_INT_ERR.ORG_ID
       AND T.SOURCE_HEADER_ID = P_INT_ERR.SOURCE_HEADER_ID
       AND T.SOURCE_LINE_ID = P_INT_ERR.SOURCE_LINE_ID;
    INSERT INTO XXPA_COST_GCPM_ERROR2 VALUES P_INT_ERR;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE insert_int_err : ' || SQLERRM);
  END INSERT_INT_ERR;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_separator_length
  *
  *   DESCRIPTION:
  *       Generate File 
  *   ARGUMENT: 
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  FUNCTION GET_SEPARATOR_LENGTH(P_SEPARATOR IN VARCHAR2) RETURN NUMBER IS
    CURSOR CUR_SEPARATOR IS
      SELECT LENGTH('|| chr(' || XL.LOOKUP_CODE || ') || ''')
        FROM XXFND_LOOKUPS XL
       WHERE XL.LOOKUP_TYPE = 'XXFND_COLUMN_SEPARATOR'
         AND XL.ENABLED_FLAG = 'Y'
         AND SYSDATE BETWEEN NVL(XL.START_DATE_ACTIVE, SYSDATE) AND
             NVL(XL.END_DATE_ACTIVE, SYSDATE)
         AND XL.LOOKUP_CODE = P_SEPARATOR;
    L_SEPARATOR NUMBER;
  BEGIN
    OPEN CUR_SEPARATOR;
    FETCH CUR_SEPARATOR
      INTO L_SEPARATOR;
    IF CUR_SEPARATOR%NOTFOUND THEN
      L_SEPARATOR := LENGTH('|| chr() || ''');
    END IF;
    CLOSE CUR_SEPARATOR;
    RETURN L_SEPARATOR;
  END;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  generate_file
  *
  *   DESCRIPTION:
  *       Generate File 
  *   ARGUMENT: 
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  PROCEDURE GENERATE_FILE IS
    CURSOR CUR_PARAM IS
      SELECT *
        FROM XXFND_INTERFACE_CONFIG XIC
       WHERE XIC.INTERFACE_CODE = 'IF80';
    L_PARAM_REC      CUR_PARAM%ROWTYPE;
    L_PROCESS_STATUS VARCHAR2(1);
    L_PREFIX         VARCHAR2(10);
    CURSOR CUR_COLUMN(P_INTERFACE_ID IN NUMBER) IS
      SELECT XICC.COLUMN_NAME
        FROM XXFND_INTERFACE_COL_CONFIG XICC
       WHERE XICC.INTERFACE_ID = P_INTERFACE_ID
         AND XICC.ENABLED_FLAG = 'Y'
       ORDER BY XICC.DISPLAY_SEQ ASC;
    TYPE L_DATA_TYPE IS TABLE OF VARCHAR2(20000) INDEX BY PLS_INTEGER;
    L_DATA_REC         L_DATA_TYPE;
    CUR_DATA           SYS_REFCURSOR;
    L_PHASE            VARCHAR2(30);
    L_TITLE_SQL        VARCHAR2(20000);
    L_TITLE            VARCHAR2(20000);
    L_SEPARATOR_LENGTH NUMBER;
  BEGIN
  
    OPEN CUR_PARAM;
    FETCH CUR_PARAM
      INTO L_PARAM_REC;
  
    IF CUR_PARAM%NOTFOUND THEN
      DEBUG('Error:no interface config found.');
    END IF;
    CLOSE CUR_PARAM;
  
    L_DATA_REC.DELETE;
  
    OPEN CUR_DATA FOR L_PARAM_REC.DATA_FETCH_SQL
      USING IN G_GROUP_ID, IN L_PROCESS_STATUS;
    FETCH CUR_DATA BULK COLLECT
      INTO L_DATA_REC;
  
    IF L_DATA_REC.COUNT > 0 THEN
    
      L_PHASE := '20.Construct data file.';
    
      IF L_PARAM_REC.TITLE_ROWS > 0 THEN
        L_PHASE     := '21.Construct title sql.';
        L_PREFIX    := NULL;
        L_TITLE_SQL := 'select ''' || L_PREFIX;
      
        FOR REC IN CUR_COLUMN(L_PARAM_REC.INTERFACE_ID) LOOP
        
          L_TITLE_SQL := L_TITLE_SQL || REC.COLUMN_NAME || ''' || chr(' ||
                         L_PARAM_REC.COLUMN_SEPARATOR || ') || ''';
        END LOOP;
      
        IF L_TITLE_SQL <> 'select ''' THEN
          L_SEPARATOR_LENGTH := GET_SEPARATOR_LENGTH(L_PARAM_REC.COLUMN_SEPARATOR);
          L_TITLE_SQL        := SUBSTR(L_TITLE_SQL,
                                       1,
                                       (LENGTH(L_TITLE_SQL) -
                                       L_SEPARATOR_LENGTH));
          L_TITLE_SQL        := L_TITLE_SQL ||
                                ' || chr(13) || chr(10) from dual';
        
          LOG('Generate file l_title_sql:' || L_TITLE_SQL);
          EXECUTE IMMEDIATE L_TITLE_SQL
            INTO L_TITLE;
          OUTPUT_FILE(L_TITLE);
        END IF;
      END IF;
    
      FOR I IN 1 .. L_DATA_REC.COUNT LOOP
        OUTPUT_FILE(L_DATA_REC(I) || CHR(13) || CHR(10));
      END LOOP;
      CLOSE CUR_DATA;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Generate file error:' || SQLERRM || L_PHASE);
      RAISE FND_API.G_EXC_ERROR;
  END GENERATE_FILE;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  BACKUP_DOM_TAX_INVOICE
  *
  *   DESCRIPTION:
  *       backup last invoice of domestic task to temp table
  *   ARGUMENT: 
  *
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  PROCEDURE BACKUP_DOM_TAX_INVOICE(P_TASK_ID    IN NUMBER,
                                   P_START_DATE IN DATE,
                                   P_END_DATE   IN DATE) IS
    L_COUNT NUMBER;
    CURSOR ISEXIST(P_START_DATE IN DATE, P_END_DATE IN DATE) IS
      SELECT COUNT(*)
        FROM XXOM_LAST_INVOICE_TMP LIT
       WHERE LIT.TASK_ID = P_TASK_ID
         AND LIT.DIH_CREATION_DATE BETWEEN P_START_DATE AND P_END_DATE;
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('BACKUP_DOM_TAX_INVOICE : TASK ID = ' || P_TASK_ID);
    END IF;
    OPEN ISEXIST(P_START_DATE, P_END_DATE);
    FETCH ISEXIST
      INTO L_COUNT;
    CLOSE ISEXIST;
    IF L_COUNT > 0 THEN
      RETURN;
    END IF;
  
    INSERT INTO XXOM_LAST_INVOICE_TMP
      (TASK_ID,
       DIH_HEADER_ID,
       ORG_ID,
       DIH_CREATION_DATE, --It is the transaction date
       LAST_INVOICE_FLAG)
      SELECT OOL.TASK_ID,
             DIL.HEADER_ID,
             DIL.ORG_ID,
             DIH.TRANSACTION_DATE,
             nvl(DIH.LAST_INVOICE_FLAG, 'N')
        FROM XXOM_DO_INVOICE_LINES_ALL   DIL,
             OE_ORDER_LINES_ALL          OOL,
             XXOM_DO_INVOICE_HEADERS_ALL DIH,
             PA_PROJECTS_ALL             PPA,
             PA_PROJECT_TYPES_ALL        PPT
       WHERE 1 = 1
         AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
         AND OOL.PROJECT_ID = PPA.PROJECT_ID
         AND DIH.HEADER_ID = DIL.HEADER_ID
         AND DIL.OE_LINE_ID = OOL.LINE_ID
         AND OOL.TASK_ID = P_TASK_ID
            --AND DIH.LAST_INVOICE_FLAG = 'Y'--todo170620 
         AND NVL(PPT.ATTRIBUTE7, 'DOMESTIC') <> 'OVERSEA'
         AND DIH.TRANSACTION_DATE BETWEEN P_START_DATE AND P_END_DATE;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE backup_dom_tax_invoice : ' || SQLERRM);
  END BACKUP_DOM_TAX_INVOICE;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  BACKUP_OVERSEA_TAX_INVOICE
  *
  *   DESCRIPTION:
  *       insert first invoice info into template table
  *   ARGUMENT: P_TASK_ID         task id
  *   P_START_DATE                start date
  *   P_END_DATE                  end date
  *
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  PROCEDURE BACKUP_OVERSEA_TAX_INVOICE(P_TASK_ID    IN NUMBER,
                                       P_START_DATE IN DATE,
                                       P_END_DATE   IN DATE) IS
    L_COUNT NUMBER;
    CURSOR ISEXIST(P_TASK_ID    IN NUMBER,
                   P_START_DATE IN DATE,
                   P_END_DATE   IN DATE) IS
      SELECT COUNT(*)
        FROM XXOM_OVERSEA_INVOICE_TMP OIT
       WHERE OIT.TASK_ID = P_TASK_ID
         AND OIT.DIH_CREATION_DATE BETWEEN P_START_DATE AND P_END_DATE;
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('BACKUP_OVERSEA_TAX_INVOICE : TASK ID = ' || P_TASK_ID);
    END IF;
    OPEN ISEXIST(P_TASK_ID, P_START_DATE, P_END_DATE);
    FETCH ISEXIST
      INTO L_COUNT;
    CLOSE ISEXIST;
    IF L_COUNT > 0 THEN
      RETURN;
    END IF;
    INSERT INTO XXOM_OVERSEA_INVOICE_TMP
      (TASK_ID, DIH_HEADER_ID, ORG_ID, DIH_CREATION_DATE)
      SELECT DISTINCT OOL.TASK_ID,
                      DIL.HEADER_ID,
                      DIL.ORG_ID,
                      DIH.TRANSACTION_DATE
        FROM XXOM_DO_INVOICE_LINES_ALL   DIL,
             XXOM_DO_INVOICE_HEADERS_ALL DIH,
             OE_ORDER_LINES_ALL          OOL,
             PA_PROJECTS_ALL             PPA,
             PA_PROJECT_TYPES_ALL        PPT
       WHERE 1 = 1
         AND DIH.HEADER_ID = DIL.HEADER_ID
         AND PPA.PROJECT_ID = OOL.PROJECT_ID
         AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
         AND PPT.ATTRIBUTE7 = 'OVERSEA'
         AND OOL.PROJECT_ID = PPA.PROJECT_ID
         AND DIL.OE_LINE_ID = OOL.LINE_ID
         AND OOL.TASK_ID = P_TASK_ID
         AND DIH.TRANSACTION_DATE BETWEEN P_START_DATE AND P_END_DATE;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE BACKUP_OVERSEA_tax_INVOICE : ' || SQLERRM);
  END BACKUP_OVERSEA_TAX_INVOICE;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  EXIST_DOMESTIC_LAST_INVOICE
  *
  *   DESCRIPTION:
  *        Does the last invoice happen before with the same task_id
  *   ARGUMENT: p_task_id         task id
  *             p_start_date      the start of inputed month
  *
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  FUNCTION EXIST_DOMESTIC_LAST_INVOICE(P_TASK_ID    IN NUMBER,
                                       P_START_DATE IN DATE) RETURN VARCHAR2 IS
    L_COUNT NUMBER := 0;
    L_FLAG  VARCHAR2(20);
  
    CURSOR COUNTS(P_TASK_ID IN NUMBER, P_START_DATE IN DATE) IS
      SELECT COUNT(*)
        FROM XXOM_LAST_INVOICE_TMP LIT
       WHERE LIT.TASK_ID = P_TASK_ID
         AND LIT.LAST_INVOICE_FLAG = 'Y' --exist last invoice
         AND LIT.DIH_CREATION_DATE < P_START_DATE;
  BEGIN
    OPEN COUNTS(P_TASK_ID, P_START_DATE);
    FETCH COUNTS
      INTO L_COUNT;
    CLOSE COUNTS;
  
    IF L_COUNT > 0 THEN
      L_FLAG := 'Y';
    ELSE
      L_FLAG := 'N';
    END IF;
  
    RETURN L_FLAG;
  
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE EXIST_DOMESTIC_LAST_INVOICE : ' || SQLERRM);
  END EXIST_DOMESTIC_LAST_INVOICE;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  EXIST_OVERSEA_INVOICE
  *
  *   DESCRIPTION:
  *        Does the tax invoice happen before with the same task_id
  *   ARGUMENT: p_task_id         task id
  *             p_start_date      the start of inputed month
  *
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  FUNCTION EXIST_OVERSEA_INVOICE(P_TASK_ID IN NUMBER, P_START_DATE IN DATE)
    RETURN VARCHAR2 IS
    L_COUNT NUMBER := 0;
    L_FLAG  VARCHAR2(20);
  
    CURSOR COUNTS(P_TASK_ID IN NUMBER, P_START_DATE IN DATE) IS
      SELECT COUNT(*)
        FROM XXOM_OVERSEA_INVOICE_TMP OIT
       WHERE OIT.TASK_ID = P_TASK_ID
         AND OIT.DIH_CREATION_DATE < P_START_DATE;
  BEGIN
    OPEN COUNTS(P_TASK_ID, P_START_DATE);
    FETCH COUNTS
      INTO L_COUNT;
    CLOSE COUNTS;
  
    IF L_COUNT > 0 THEN
      L_FLAG := 'Y';
    ELSE
      L_FLAG := 'N';
    END IF;
  
    RETURN L_FLAG;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE EXIST_OVERSEA_INVOICE : ' || SQLERRM);
  END EXIST_OVERSEA_INVOICE;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  EXIST_SHE_NO_SO
  *
  *   DESCRIPTION:
  *        Does the task exist in tax invoice
  *   ARGUMENT: p_task_id         task id
  *             p_start_date      the start of inputed month
  *             p_end_date        the end of inputed month
  *
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  FUNCTION EXIST_SHE_NO_SO(P_TASK_ID    IN NUMBER,
                           P_ORG_ID     IN NUMBER,
                           P_START_DATE IN DATE,
                           P_END_DATE   IN DATE) RETURN VARCHAR2 IS
    L_COUNT NUMBER := 0;
    L_FLAG  VARCHAR2(20);
  
    CURSOR COUNTS(P_TASK_ID    IN NUMBER,
                  P_ORG_ID     IN NUMBER,
                  P_START_DATE IN DATE,
                  P_END_DATE   IN DATE) IS
      SELECT COUNT(*)
        FROM (SELECT MMT.SOURCE_TASK_ID TASK_ID
                FROM APPS.MTL_MATERIAL_TRANSACTIONS MMT,
                     APPS.PA_PROJECTS_ALL           PA,
                     APPS.PA_PROJECT_TYPES_ALL      PPT
               WHERE 1 = 1
                 AND PPT.PROJECT_TYPE = 'SHE FAC_MTE Parts' --1
                 AND MMT.TRANSACTION_SOURCE_ID = 180 --2
                 AND MMT.SOURCE_PROJECT_ID = PA.PROJECT_ID
                 AND PA.PROJECT_TYPE = PPT.PROJECT_TYPE
                 AND PA.ORG_ID = P_ORG_ID
                 AND MMT.SOURCE_TASK_ID = P_TASK_ID
                 AND MMT.TRANSACTION_DATE BETWEEN P_START_DATE AND
                     P_END_DATE
              
              UNION ALL
              
              SELECT NVL(MMT.SOURCE_TASK_ID, MMT.TASK_ID) TASK_ID
                FROM APPS.MTL_MATERIAL_TRANSACTIONS MMT,
                     APPS.PA_PROJECTS_ALL           PA,
                     APPS.PA_PROJECT_TYPES_ALL      PPT
               WHERE 1 = 1
                 AND PPT.PROJECT_TYPE = 'SHE FAC_MTE Parts' --1
                 AND MMT.TRANSACTION_TYPE_ID = 33 --
                 AND NVL(MMT.SOURCE_PROJECT_ID, MMT.PROJECT_ID) =
                     PA.PROJECT_ID
                 AND PA.PROJECT_TYPE = PPT.PROJECT_TYPE
                 AND PA.ORG_ID = P_ORG_ID
                 AND NVL(MMT.SOURCE_TASK_ID, MMT.TASK_ID) = P_TASK_ID
                 AND MMT.TRANSACTION_DATE BETWEEN P_START_DATE AND
                     P_END_DATE
              
              UNION ALL
              
              SELECT DISTINCT PEI.TASK_ID
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
                 AND PEI.EXPENDITURE_TYPE IN
                     ('FG Completion',
                      'FAC FG-MTE-TO SHE HO',
                      'FAC FG-MTE-TO HET')
                 AND PEI.EXPENDITURE_ITEM_ID = CDL.EXPENDITURE_ITEM_ID
                 AND PEI.TASK_ID = P_TASK_ID
                 AND CDL.GL_DATE BETWEEN P_START_DATE AND P_END_DATE) T;
  
  BEGIN
    OPEN COUNTS(P_TASK_ID, P_ORG_ID, P_START_DATE, P_END_DATE);
    FETCH COUNTS
      INTO L_COUNT;
    CLOSE COUNTS;
  
    IF L_COUNT > 0 THEN
      L_FLAG := 'Y';
    ELSE
      L_FLAG := 'N';
    END IF;
  
    RETURN L_FLAG;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE EXIST_SHE_NO_SO : ' || SQLERRM);
  END EXIST_SHE_NO_SO;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  IS_IN_TAX_INVOICE
  *
  *   DESCRIPTION:
  *        Does the task exist in tax invoice
  *   ARGUMENT: p_task_id         task id
  *             p_start_date      the start of inputed month
  *             p_end_date        the end of inputed month
  *
  *   HISTORY:
  *     1.00 2017-06-02 Jingjing.He Creation
  * =============================================*/
  PROCEDURE IS_IN_TAX_INVOICE(P_TASK_ID           IN NUMBER,
                              P_START_DATE        IN DATE,
                              P_END_DATE          IN DATE,
                              X_LAST_INVOICE_FLAG OUT VARCHAR2,
                              X_EXIST             OUT VARCHAR2,
                              X_ISOVERSEA         OUT VARCHAR2) IS
  
    CURSOR COUNTS(P_TASK_ID    IN NUMBER,
                  P_START_DATE IN DATE,
                  P_END_DATE   IN DATE) IS
    --modified by jingjing.he start 20170906
    --one mfg could happen several tax invoices for a month
      SELECT *
        FROM (SELECT DECODE(PPT.ATTRIBUTE7, 'OVERSEA', 'OVERSEA', 'DOMESTIC') ISOVERSEA,
                     NVL(DIH.LAST_INVOICE_FLAG, 'N') LAST_INVOICE_FLAG
                FROM XXOM_DO_INVOICE_LINES_ALL   DIL,
                     OE_ORDER_LINES_ALL          OOL, --task_id   project_id
                     PA_PROJECTS_ALL             PPA,
                     PA_PROJECT_TYPES_ALL        PPT,
                     XXOM_DO_INVOICE_HEADERS_ALL DIH
               WHERE 1 = 1
                 AND DIH.HEADER_ID = DIL.HEADER_ID
                 AND DIL.OE_LINE_ID = OOL.LINE_ID
                 AND OOL.TASK_ID = P_TASK_ID
                 AND OOL.PROJECT_ID = PPA.PROJECT_ID
                 AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
                 AND DIH.TRANSACTION_DATE BETWEEN P_START_DATE AND
                     P_END_DATE
               ORDER BY nvl(DIH.Last_Invoice_Flag, 'N') DESC) T
       WHERE ROWNUM = 1;
    --modified by jingjing.he end 20170906
    /*SELECT DECODE(PPT.ATTRIBUTE7, 'OVERSEA', 'OVERSEA', 'DOMESTIC') ISOVERSEA,
          DIH.LAST_INVOICE_FLAG
     FROM XXOM_DO_INVOICE_LINES_ALL   DIL,
          OE_ORDER_LINES_ALL          OOL, --task_id   project_id
          PA_PROJECTS_ALL             PPA,
          PA_PROJECT_TYPES_ALL        PPT,
          XXOM_DO_INVOICE_HEADERS_ALL DIH
    WHERE 1 = 1
      AND DIH.HEADER_ID = DIL.HEADER_ID
      AND DIL.OE_LINE_ID = OOL.LINE_ID
      AND OOL.TASK_ID = P_TASK_ID
      AND OOL.PROJECT_ID = PPA.PROJECT_ID
      AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
      AND DIH.TRANSACTION_DATE BETWEEN P_START_DATE AND P_END_DATE;*/
  
  BEGIN
    IF L_DEBUG = 'Y' THEN
      DEBUG('IS_IN_TAX_INVOICE : TASK ID = ' || P_TASK_ID);
    END IF;
    X_EXIST := 'Y';
    OPEN COUNTS(P_TASK_ID, P_START_DATE, P_END_DATE);
    FETCH COUNTS
      INTO X_ISOVERSEA, X_LAST_INVOICE_FLAG;
    IF counts%NOTFOUND THEN
      X_EXIST := 'N';
    END IF;
    CLOSE COUNTS;
  EXCEPTION
    WHEN OTHERS THEN
      LOG('Error in PROCEDURE IS_IN_TAX_INVOICE : ' || SQLERRM);
  END IS_IN_TAX_INVOICE;

  FUNCTION GET_PERIOD_NAME(P_DATE DATE) RETURN VARCHAR2 IS
    CURSOR PERIOD_C(P_DATE DATE) IS
      SELECT GPS.PERIOD_NAME
        FROM GL_PERIOD_STATUSES GPS
       WHERE GPS.APPLICATION_ID = 101
         AND GPS.SET_OF_BOOKS_ID = G_LEDGER_ID
            --AND gps.closing_status         =  'O'
         AND GPS.ADJUSTMENT_PERIOD_FLAG = 'N'
         AND P_DATE BETWEEN GPS.START_DATE AND GPS.END_DATE;
  
    L_PERIOD_NAME VARCHAR2(15);
  BEGIN
  
    OPEN PERIOD_C(P_DATE);
    FETCH PERIOD_C
      INTO L_PERIOD_NAME;
    IF PERIOD_C%NOTFOUND THEN
      L_PERIOD_NAME := NULL;
    END IF;
    CLOSE PERIOD_C;
  
    RETURN L_PERIOD_NAME;
  
  END;

  --add by jingjing
  FUNCTION GET_SECTION(P_TOP_TASK_ID NUMBER, P_PERIOD VARCHAR2) RETURN NUMBER IS
    CURSOR MIN_PERIOD_C(P_TOP_TASK_ID NUMBER) IS
      SELECT GET_PERIOD_NAME(MIN(PEI.EXPENDITURE_ITEM_DATE))
        FROM PA_EXPENDITURE_ITEMS_ALL PEI, PA_TASKS PT
       WHERE EXISTS (SELECT NULL
                FROM XXPA_FG_COMPLETION_RELATION R
               WHERE R.TRANSACTION_SOURCE = PEI.TRANSACTION_SOURCE
                 AND R.ORIG_TRANSACTION_REFERENCE =
                     PEI.ORIG_TRANSACTION_REFERENCE)
         AND PEI.TASK_ID = PT.TASK_ID
         AND PT.TOP_TASK_ID = P_TOP_TASK_ID;
  
    CURSOR TYPE_C(P_TOP_TASK_ID NUMBER) IS
      SELECT XL.DESCRIPTION
        FROM OE_ORDER_LINES_ALL       OOL,
             OE_ORDER_HEADERS_ALL     OOH,
             OE_TRANSACTION_TYPES_ALL OTT, --oe_transaction_types_vl ott,
             OE_TRANSACTION_TYPES_TL  OTP,
             PA_TASKS                 PT,
             XXPA_LOOKUPS             XL
       WHERE OOL.HEADER_ID = OOH.HEADER_ID
         AND OOL.TASK_ID = PT.TASK_ID
         AND OOH.ORDER_TYPE_ID = OTT.TRANSACTION_TYPE_ID
         AND XL.LOOKUP_TYPE = 'XXPA_REPORT_ORDER_TYPE'
         AND XL.ENABLED_FLAG = 'Y'
         AND TRUNC(SYSDATE) >= NVL(XL.START_DATE_ACTIVE, TRUNC(SYSDATE))
         AND TRUNC(SYSDATE) <= NVL(XL.END_DATE_ACTIVE, TRUNC(SYSDATE))
         AND OTT.TRANSACTION_TYPE_ID = OTP.TRANSACTION_TYPE_ID
         AND OTP.LANGUAGE = 'US'
         AND XL.MEANING = OTP.NAME
         AND OTT.ORG_ID = G_HEA_OU --add by jingjing he
         AND PT.TOP_TASK_ID = P_TOP_TASK_ID;
  
    CURSOR OTHERS_C(P_TOP_TASK_ID NUMBER) IS
      SELECT 'Y'
        FROM PA_TASKS PT, PA_PROJECTS_ALL PA, XXPA_LOOKUPS XL
       WHERE PT.PROJECT_ID = PA.PROJECT_ID
         AND XL.LOOKUP_TYPE = 'XXPA_EQ_REV_SPEC_PROJ_TYPES'
         AND XL.ENABLED_FLAG = 'Y'
         AND TRUNC(SYSDATE) >= NVL(XL.START_DATE_ACTIVE, TRUNC(SYSDATE))
         AND TRUNC(SYSDATE) <= NVL(XL.END_DATE_ACTIVE, TRUNC(SYSDATE))
         AND XL.MEANING = PA.PROJECT_TYPE
         AND PT.TASK_ID = P_TOP_TASK_ID;
  
    CURSOR PROJ_TYPE_C(P_TOP_TASK_ID NUMBER) IS
      SELECT PA.PROJECT_TYPE
        FROM PA_TASKS PT, PA_PROJECTS_ALL PA
       WHERE PT.PROJECT_ID = PA.PROJECT_ID
         AND PT.TASK_ID = P_TOP_TASK_ID;
  
    L_MIN_PERIOD   GL_PERIOD_STATUSES.PERIOD_NAME%TYPE;
    L_TYPE         XXPA_LOOKUPS.DESCRIPTION%TYPE;
    L_SECTION      NUMBER;
    L_OTHERS_FLAG  VARCHAR2(1);
    L_PROJECT_TYPE PA_PROJECTS_ALL.PROJECT_TYPE%TYPE;
  BEGIN
  
    IF G_TASK_TBL.EXISTS(P_TOP_TASK_ID) THEN
      L_SECTION := G_TASK_TBL(P_TOP_TASK_ID);
    ELSE
    
      OPEN MIN_PERIOD_C(P_TOP_TASK_ID);
      FETCH MIN_PERIOD_C
        INTO L_MIN_PERIOD;
      CLOSE MIN_PERIOD_C;
    
      OPEN PROJ_TYPE_C(P_TOP_TASK_ID);
      FETCH PROJ_TYPE_C
        INTO L_PROJECT_TYPE;
      CLOSE PROJ_TYPE_C;
    
      IF TO_DATE(L_MIN_PERIOD, 'MON-YY') < TO_DATE(P_PERIOD, 'MON-YY') OR
         L_PROJECT_TYPE = 'Z' AND
         'N' = XXPA_UTILS.GET_EXCLUDE_FLAG(P_TOP_TASK_ID) THEN
        G_TASK_TBL(P_TOP_TASK_ID) := G_ADD_COST_SEC;
        RETURN G_ADD_COST_SEC;
      END IF;
    
      OPEN TYPE_C(P_TOP_TASK_ID);
      FETCH TYPE_C
        INTO L_TYPE;
      IF TYPE_C%NOTFOUND THEN
        L_TYPE := NULL;
      END IF;
      CLOSE TYPE_C;
    
      IF L_TYPE IS NOT NULL THEN
      
        IF L_TYPE = G_DOMESTIC THEN
          L_SECTION := G_DOMESTIC_SEC;
        ELSIF L_TYPE = G_OVERSEAS THEN
          L_SECTION := G_OVERSEAS_SEC;
        ELSIF L_TYPE = G_PARTS THEN
          L_SECTION := G_PARTS_SEC;
        ELSE
          L_SECTION := G_ADD_COST_SEC;
        END IF;
      
      ELSE
      
        OPEN OTHERS_C(P_TOP_TASK_ID);
        FETCH OTHERS_C
          INTO L_OTHERS_FLAG;
        IF OTHERS_C%NOTFOUND THEN
          L_OTHERS_FLAG := 'N';
        END IF;
        CLOSE OTHERS_C;
      
        IF L_OTHERS_FLAG = 'Y' THEN
          L_SECTION := G_OTHERS_SEC;
        ELSE
          L_SECTION := G_ADD_COST_SEC;
        END IF;
      
      END IF;
    
      G_TASK_TBL(P_TOP_TASK_ID) := L_SECTION;
    
    END IF;
  
    RETURN L_SECTION;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --add by jingjing.he start
  PROCEDURE GENERATE_COGS_DATA(P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                               X_MSG_COUNT     OUT NOCOPY NUMBER,
                               X_MSG_DATA      OUT NOCOPY VARCHAR2,
                               P_START_DATE    IN DATE,
                               P_END_DATE      IN DATE,
                               P_TYPE          IN VARCHAR2,
                               P_PROJECT_ID    IN NUMBER,
                               P_TOP_TASK_ID   IN NUMBER) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'GENERATE_COGS_DATA';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := 'sp_GENERATE_COGS_DATA01';
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
  
    IF L_DEBUG = 'Y' THEN
      LOG('P_TYPE = ' || P_TYPE);
    END IF;
    --参考报表创建的表 XXPA_COST_GCPM_COGS_T2
    DELETE FROM XXPA_COST_GCPM_COGS_T2; --xxpa_proj_rev_cogs_tmp;
  
    IF P_TYPE = 'EQ' THEN
    
      INSERT INTO XXPA_COST_GCPM_COGS_T2 --xxpa_proj_rev_cogs_tmp
        (PROJECT_ID,
         TOP_TASK_ID,
         AE_HEADER_ID,
         ENTERED_AMOUNT,
         ACCOUNTED_AMOUNT,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN)
        SELECT PA.PROJECT_ID,
               TOP.TASK_ID,
               XAH.AE_HEADER_ID,
               SUM(NVL(XAL.ENTERED_DR, 0) - NVL(XAL.ENTERED_CR, 0)),
               SUM(NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0)),
               SYSDATE,
               G_CREATED_BY,
               SYSDATE,
               G_LAST_UPDATED_BY,
               G_LAST_UPDATE_LOGIN
          FROM XLA_AE_HEADERS       XAH,
               XLA_AE_LINES         XAL,
               GL_CODE_COMBINATIONS GCC,
               PA_TASKS             TOP,
               PA_PROJECTS_ALL      PA --todo 20170605
         WHERE XAH.APPLICATION_ID = G_PA_APPL_ID
           AND XAH.JE_CATEGORY_NAME IN ('1', '2')
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND TOP.TASK_ID = TOP.TOP_TASK_ID
           AND TOP.PROJECT_ID = PA.PROJECT_ID
           AND XAL.DESCRIPTION =
               PA.SEGMENT1 || '.' || TOP.TASK_NUMBER || '.EQ'
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
              -- v6.0  2015-04-24          jinlong.pan   Update Begin
              -- AND gcc.segment3 != '6111010000'
           AND GCC.SEGMENT3 NOT IN ('6111010000', '6111009899')
              -- v6.0  2015-04-24          jinlong.pan   Update End
           AND (XAH.JE_CATEGORY_NAME = '2' AND
               XAL.ACCOUNTING_CLASS_CODE = 'REVENUE' OR
               XAH.JE_CATEGORY_NAME = '1' AND
               XAL.ACCOUNTING_CLASS_CODE = 'COST_OF_GOODS_SOLD')
              --AND xal.ae_line_num        =   1
           AND XAH.ACCOUNTING_DATE >= P_START_DATE
           AND XAH.ACCOUNTING_DATE <= P_END_DATE
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND PA.PROJECT_ID = NVL(P_PROJECT_ID, PA.PROJECT_ID)
           AND PA.ORG_ID = G_HEA_OU --todo20170605
           AND TOP.TASK_ID = NVL(P_TOP_TASK_ID, TOP.TASK_ID)
         GROUP BY PA.PROJECT_ID, TOP.TASK_ID, XAH.AE_HEADER_ID;
    
    ELSIF P_TYPE = 'ER' THEN
    
      INSERT INTO XXPA_COST_GCPM_COGS_T2 --xxpa_proj_rev_cogs_tmp
        (PROJECT_ID,
         TOP_TASK_ID,
         AE_HEADER_ID,
         ENTERED_AMOUNT,
         ACCOUNTED_AMOUNT,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN)
        SELECT PA.PROJECT_ID,
               TOP.TASK_ID,
               XAH.AE_HEADER_ID,
               SUM(NVL(XAL.ENTERED_DR, 0) - NVL(XAL.ENTERED_CR, 0)),
               SUM(NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0)),
               SYSDATE,
               G_CREATED_BY,
               SYSDATE,
               G_LAST_UPDATED_BY,
               G_LAST_UPDATE_LOGIN
          FROM XLA_AE_HEADERS  XAH,
               XLA_AE_LINES    XAL,
               PA_TASKS        TOP,
               PA_PROJECTS_ALL PA
        
         WHERE XAH.APPLICATION_ID = G_PA_APPL_ID
           AND XAH.JE_CATEGORY_NAME IN ('4')
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND TOP.TASK_ID = TOP.TOP_TASK_ID
           AND TOP.PROJECT_ID = PA.PROJECT_ID
           AND XAL.DESCRIPTION =
               PA.SEGMENT1 || '.' || TOP.TASK_NUMBER || '.ER'
           AND XAL.ACCOUNTING_CLASS_CODE = 'REVENUE'
              --AND xal.ae_line_num        =   1
           AND XAH.ACCOUNTING_DATE >= P_START_DATE
           AND XAH.ACCOUNTING_DATE <= P_END_DATE
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND PA.PROJECT_ID = NVL(P_PROJECT_ID, PA.PROJECT_ID)
           AND PA.ORG_ID = G_HEA_OU --todo20170605
           AND TOP.TASK_ID = NVL(P_TOP_TASK_ID, TOP.TASK_ID)
         GROUP BY PA.PROJECT_ID, TOP.TASK_ID, XAH.AE_HEADER_ID;
    
    END IF;
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
  END;
  --add by jingjing.he end

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  process_request6
  *
  *   DESCRIPTION:
  *       Process Request 
  *   ARGUMENT: P_LAYOUT_TYPE      
  *             P_GL_PERIOD  
  *             P_OTHER_WORKS_ONLY
  *             P_OU_NAME 
  *             P_ORG_ID
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  *     2.00 2017-06-08 Jingjing.He Modify
  * =============================================*/
  PROCEDURE PROCESS_REQUEST6(P_INIT_MSG_LIST    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             X_RETURN_STATUS    OUT NOCOPY VARCHAR2,
                             X_MSG_COUNT        OUT NOCOPY NUMBER,
                             X_MSG_DATA         OUT NOCOPY VARCHAR2,
                             P_LAYOUT_TYPE      IN VARCHAR2,
                             P_GL_PERIOD        IN VARCHAR2,
                             P_OTHER_WORKS_ONLY IN VARCHAR2,
                             P_OU_NAME          IN VARCHAR2,
                             P_ORG_ID           IN VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'process_request6';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := 'sp_process_request06';
    L_INTERFACE_REC   XXPA_COST_GCPM_INT%ROWTYPE;
    L_INT_ERR         XXPA_COST_GCPM_ERROR2%ROWTYPE;
    L_SO_COUNT        NUMBER;
    L_COUNTRY_DESC    VARCHAR2(80);
    L_PRE_SALE_AMOUNT NUMBER;
  
    TYPE COST_TAB IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    L_INDEX             NUMBER;
    L_FUNC_COST         NUMBER;
    L_FUNC_COST_TAB     COST_TAB;
    L_START_DATE        DATE;
    L_END_DATE          DATE;
    L_SEQ_NUM           NUMBER;
    L_RETURN_STATUS     VARCHAR2(1);
    L_ERROR_MESSAGE     VARCHAR2(2000);
    L_COMPLETION_STATUS BOOLEAN;
    L_MODEL             XXPJM_SO_ADDTN_LINES_ALL.MODEL%TYPE;
    L_STOPS             XXPJM_SO_ADDTN_LINES_ALL.STOPS%TYPE;
    L_OTHERS            NUMBER;
    L_QTY               NUMBER;
    L_START_INDEX       NUMBER;
    L_END_INDEX         NUMBER;
    L_LAYOUT_TYPE       VARCHAR2(240);
    L_EXIST             VARCHAR2(20);
    L_ISOVERSEA         VARCHAR2(20);
    L_EXIST_TAX_INVOICE VARCHAR2(20);
    L_EXIST_NO_SO       VARCHAR2(20);
    L_SALES_AMOUNT      NUMBER;
    L_COGS              NUMBER; --add by jingjing.He 20170703
    L_MATERIAL          NUMBER; --add by jingjing.He 20170703
    L_EXPENSE           NUMBER; --add by jingjing.He 20170703
    L_LABOUR            NUMBER; --add by jingjing.He 20170703
    L_SUBCON            NUMBER; --add by jingjing.He 20170703
    L_PACKING_FREIGHT   NUMBER; --add by jingjing.He 20170703
    L_LAST_INVOICE_FLAG VARCHAR2(20);
    I                   NUMBER;
    L_PROJECT_TYPE7     VARCHAR2(240);
  
    CURSOR CUR_TASK IS
      SELECT PT.PROJECT_ID,
             PTOP.TOP_TASK_ID,
             T.TASK_ID,
             T.COGS,
             T.SALE_AMOUNT,
             PTOP.TASK_NUMBER MFG_NO,
             P_ORG_ID,
             G_PERIOD_NAME,
             DECODE(SUBSTR(PPA.LONG_NAME, 1, LENGTH(PPA.SEGMENT1)),
                    PPA.SEGMENT1,
                    NVL(SUBSTR(PPA.LONG_NAME, LENGTH(PPA.SEGMENT1) + 2),
                        PPA.LONG_NAME),
                    PPA.LONG_NAME) SITE,
             PTT.ATTRIBUTE7 PROJECT_TYPE,
             PTT.PROJECT_TYPE ORG_PROJECT_TYPE
        FROM (SELECT TASK_ID,
                     SUM(DECODE(XGT.TYPE, 'COGS', XGT.AMOUNT, 0)) COGS,
                     SUM(DECODE(XGT.TYPE, 'COGS', 0, XGT.AMOUNT)) SALE_AMOUNT
                FROM XXPA_COST_GCPM_TASK_T2 XGT
               GROUP BY TASK_ID) T,
             PA_TASKS PT,
             PA_TASKS PTOP,
             PA_PROJECTS_ALL PPA,
             PA_PROJECT_TYPES_ALL PTT
       WHERE T.TASK_ID = PT.TASK_ID
         AND PT.TOP_TASK_ID = PTOP.TASK_ID
         AND PT.PROJECT_ID = PPA.PROJECT_ID
         AND PPA.PROJECT_TYPE = PTT.PROJECT_TYPE
         AND PPA.ORG_ID = PTT.ORG_ID;
    CURSOR CUR_MFG(P_TASK_ID IN NUMBER) IS
      SELECT NVL(SUM(DECODE(PET.EXPENDITURE_CATEGORY,
                            'Material',
                            PEI.BURDEN_COST,
                            0)),
                 0) + NVL(SUM(DECODE(PET.EXPENDITURE_CATEGORY,
                                     'Material Overhead',
                                     PEI.BURDEN_COST,
                                     0)),
                          0) MATERIAL,
             NVL(SUM(DECODE(PET.EXPENDITURE_CATEGORY,
                            'Expense',
                            PEI.BURDEN_COST,
                            0)),
                 0) EXPENSE,
             NVL(SUM(DECODE(PET.EXPENDITURE_CATEGORY,
                            'Labour',
                            PEI.BURDEN_COST,
                            0)),
                 0) LABOUR,
             NVL(SUM(DECODE(PET.EXPENDITURE_CATEGORY,
                            'Labour',
                            DECODE(PET.EXPENDITURE_TYPE,
                                   'Prod. Subcon',
                                   PEI.BURDEN_COST,
                                   'Prod. Subcon Accrual',
                                   PEI.BURDEN_COST,
                                   'Prod. Subcon Offset',
                                   PEI.BURDEN_COST,
                                   'Prod. Subcon Transfer',
                                   PEI.BURDEN_COST,
                                   'FAC - Prod. Subcon',
                                   PEI.BURDEN_COST,
                                   'FAC - Store. Subcon',
                                   PEI.BURDEN_COST,
                                   'Subcon-Variation',
                                   PEI.BURDEN_COST,
                                   0),
                            0)),
                 0) SUBCON,
             NVL(SUM(DECODE(PET.EXPENDITURE_CATEGORY,
                            'Expense',
                            DECODE(PET.EXPENDITURE_TYPE,
                                   'Transport',
                                   PEI.BURDEN_COST,
                                   'Transport Accrual',
                                   PEI.BURDEN_COST,
                                   'Transport Offset',
                                   PEI.BURDEN_COST,
                                   'Transport Transfer',
                                   PEI.BURDEN_COST,
                                   'Direct Packing',
                                   PEI.BURDEN_COST,
                                   'Direct Packing Accrual',
                                   PEI.BURDEN_COST,
                                   'Direct Packing Offset',
                                   PEI.BURDEN_COST,
                                   'Direct Packing Transfer',
                                   PEI.BURDEN_COST,
                                   0),
                            0)),
                 0) PACKING_FREIGHT
        FROM PA_EXPENDITURE_ITEMS_ALL PEI, PA_EXPENDITURE_TYPES PET
       WHERE PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
         AND PEI.EXPENDITURE_ITEM_DATE <= L_END_DATE
            --TO_DATE('2017-02-28 23:59:59', 'yyyy-mm-dd hh24:mi:ss') --L_END_DATE
         AND PEI.TASK_ID = P_TASK_ID
         AND PET.EXPENDITURE_CATEGORY IN
             ('Material', 'Material Overhead', 'Labour', 'Expense')
         AND PEI.ORG_ID = P_ORG_ID;
  
    -- new ER
    CURSOR LINES_C(P_START_DATE       DATE,
                   P_END_DATE         DATE,
                   P_OTHER_WORKS_ONLY VARCHAR2) IS
      SELECT M.DATA_TYPE,
             M.TASK_ID,
             M.TOP_TASK_ID,
             M.PROJECT_ID,
             M.ER_TASK_NUMBER, --MFG_NO,
             M.TASK_NUMBER MFG_NO, --to_task_number
             M.PROJECT_NUMBER,
             M.PROJECT_NAME,
             M.PROJECT_TYPE,
             M.SITE,
             --add by jingjing.he start 20170703
             XPMM.HAND_OVER_DATE,
             xpmm.installation_progress_rate,
             --add by jingjing.he end 20170703
             DECODE(SIGN(P_START_DATE -
                         NVL(XPMM.HAND_OVER_DATE,
                             TO_DATE('9999-12-31', 'YYYY-MM-DD'))),
                    1,
                    'Y',
                    'N') ADDITIONAL_FLAG,
             NVL(SUM(M.SALES_AMOUNT), 0) SALES_AMOUNT,
             NVL(SUM(M.COGS_AMOUNT), 0) COGS_AMOUNT
        FROM (SELECT 'ER' AS DATA_TYPE,
                     DECODE(SUBSTR(PA.LONG_NAME, 1, LENGTH(PA.SEGMENT1)),
                            PA.SEGMENT1,
                            NVL(SUBSTR(PA.LONG_NAME, LENGTH(PA.SEGMENT1) + 2),
                                PA.LONG_NAME),
                            PA.LONG_NAME) SITE,
                     ER.TASK_ID AS TASK_ID,
                     T.TOP_TASK_ID AS TOP_TASK_ID,
                     PA.PROJECT_ID AS PROJECT_ID,
                     ER.TASK_NUMBER AS ER_TASK_NUMBER,
                     TOP.TASK_NUMBER AS TASK_NUMBER,
                     PA.SEGMENT1 AS PROJECT_NUMBER,
                     PA.LONG_NAME AS PROJECT_NAME,
                     PA.PROJECT_TYPE AS PROJECT_TYPE,
                     NVL(- (SUM(T.ACCOUNTED_AMOUNT)), 0) AS SALES_AMOUNT,
                     NULL AS COGS_AMOUNT
              
                FROM XXPA_COST_GCPM_COGS_T2 T,
                     PA_PROJECTS_ALL        PA,
                     PA_TASKS               TOP,
                     PA_TASKS               ER,
                     PA_PROJ_ELEMENTS       PPE,
                     PA_TASK_TYPES          PTT
              
               WHERE T.PROJECT_ID = PA.PROJECT_ID
                 AND T.TOP_TASK_ID = TOP.TASK_ID
                 AND ER.TOP_TASK_ID = TOP.TASK_ID
                 AND ER.TASK_ID = PPE.PROJ_ELEMENT_ID
                 AND PPE.TYPE_ID = PTT.TASK_TYPE_ID
                 AND PTT.TASK_TYPE = 'ER COST'
               GROUP BY ER.TASK_ID,
                        T.TOP_TASK_ID,
                        TOP.TASK_NUMBER,
                        PA.PROJECT_ID,
                        ER.TASK_NUMBER,
                        TOP.TASK_NUMBER,
                        PA.SEGMENT1,
                        PA.LONG_NAME,
                        PA.PROJECT_TYPE
              HAVING NVL(- (SUM(T.ACCOUNTED_AMOUNT)), 0) != 0
              
              UNION ALL
              
              SELECT 'ER' AS DATA_TYPE,
                     DECODE(SUBSTR(PA.LONG_NAME, 1, LENGTH(PA.SEGMENT1)),
                            PA.SEGMENT1,
                            NVL(SUBSTR(PA.LONG_NAME, LENGTH(PA.SEGMENT1) + 2),
                                PA.LONG_NAME),
                            PA.LONG_NAME) SITE,
                     ER.TASK_ID AS TASK_ID,
                     TOP.TOP_TASK_ID AS TOP_TASK_ID,
                     PA.PROJECT_ID AS PROJECT_ID,
                     ER.TASK_NUMBER AS ER_TASK_NUMBER,
                     TOP.TASK_NUMBER AS　TASK_NUMBER,
                     PA.SEGMENT1 AS PROJECT_NUMBER,
                     PA.LONG_NAME AS PROJECT_NAME,
                     PA.PROJECT_TYPE AS PROJECT_TYPE,
                     NULL AS SALES_AMOUNT,
                     -- Updated by hand on 24-NOV-2012 BEGIN
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
                                  PEI.BURDEN_COST))) AS COGS_AMOUNT
              
              -- Updated by hand on 24-NOV-2012 END
                FROM PA_EXPENDITURE_ITEMS_ALL PEI, --项目支出子表
                     PA_TASKS                 ER,
                     PA_TASKS                 TOP,
                     PA_PROJECTS_ALL          PA
               WHERE PEI.EXPENDITURE_TYPE = 'Cost of Sales for ER'
                 AND PEI.TASK_ID = ER.TASK_ID
                 AND ER.TOP_TASK_ID = TOP.TASK_ID
                 AND PEI.PROJECT_ID = PA.PROJECT_ID
                    --AND PEI.ORG_ID = G_HEA_OU --removed by jingjing.he
                    -- Updated by hand on 24-NOV-2012 BEGIN
                 AND PEI.EXPENDITURE_ITEM_DATE BETWEEN P_START_DATE AND
                     P_END_DATE
              -- Updated by hand on 24-NOV-2012 END
               GROUP BY ER.TASK_ID,
                        TOP.TOP_TASK_ID,
                        TOP.TASK_NUMBER,
                        PA.PROJECT_ID,
                        ER.TASK_NUMBER,
                        TOP.TASK_NUMBER,
                        PA.SEGMENT1,
                        PA.LONG_NAME,
                        PA.PROJECT_TYPE) M,
             XXPA_PROJ_MILESTONE_MANAGE_ALL XPMM
       WHERE M.TOP_TASK_ID = XPMM.TASK_ID(+)
         AND (P_OTHER_WORKS_ONLY = 'N' OR
             P_OTHER_WORKS_ONLY = 'Y' AND
             XXPA_UTILS.GET_SPECIAL_FLAG(M.PROJECT_ID) = 'Y')
       GROUP BY M.DATA_TYPE,
                M.TASK_ID,
                M.TOP_TASK_ID,
                M.PROJECT_ID,
                M.TASK_NUMBER,
                M.ER_TASK_NUMBER,
                M.PROJECT_NUMBER,
                M.PROJECT_NAME,
                M.PROJECT_TYPE,
                M.SITE,
                XPMM.HAND_OVER_DATE,
                xpmm.installation_progress_rate
       ORDER BY M.PROJECT_NUMBER, M.ER_TASK_NUMBER;
  
    CURSOR EQ_LINES_C(P_START_DATE DATE,
                      P_END_DATE   DATE,
                      P_PERIOD     VARCHAR2,
                      P_SECTION    NUMBER) IS
      SELECT 'EQ' AS DATA_TYPE,
             EQ.TASK_ID AS TASK_ID,
             T.TOP_TASK_ID AS TOP_TASK_ID,
             PA.PROJECT_ID AS PROJECT_ID,
             TOP.TASK_NUMBER AS TASK_NUMBER,
             PA.SEGMENT1 AS PROJECT_NUMBER,
             PA.LONG_NAME AS PROJECT_NAME,
             PA.PROJECT_TYPE AS PROJECT_TYPE,
             DECODE(SUBSTR(PA.LONG_NAME, 1, LENGTH(PA.SEGMENT1)),
                    PA.SEGMENT1,
                    NVL(SUBSTR(PA.LONG_NAME, LENGTH(PA.SEGMENT1) + 2),
                        PA.LONG_NAME),
                    PA.LONG_NAME) SITE,
             XXPA_REPORTS_UTILS.GET_COUNTRY(T.TOP_TASK_ID) AS COUNTRY,
             /*get_additional_flag(   pa.segment1     || '.'
             || top.task_number || '.EQ',
             p_start_date)              AS  additional_flag,*/
             NVL(- (SUM(DECODE(XAH.JE_CATEGORY_NAME, '2', T.ACCOUNTED_AMOUNT))),
                 0) AS SALES_AMOUNT,
             NVL(SUM(DECODE(XAH.JE_CATEGORY_NAME, '1', T.ACCOUNTED_AMOUNT)),
                 0) AS COGS_AMOUNT
        FROM XXPA_COST_GCPM_COGS_T2 T, --xxpa_proj_rev_cogs_tmp t,
             PA_PROJECTS_ALL        PA,
             PA_TASKS               TOP,
             XLA_AE_HEADERS         XAH,
             PA_TASKS               EQ,
             PA_PROJ_ELEMENTS       PPE,
             PA_TASK_TYPES          PTT
      
       WHERE T.PROJECT_ID = PA.PROJECT_ID
         AND T.TOP_TASK_ID = TOP.TASK_ID
         AND T.AE_HEADER_ID = XAH.AE_HEADER_ID
         AND EQ.TOP_TASK_ID = TOP.TASK_ID
         AND EQ.TASK_ID = PPE.PROJ_ELEMENT_ID
         AND PPE.TYPE_ID = PTT.TASK_TYPE_ID
         AND PTT.TASK_TYPE = 'EQ COST'
         AND P_SECTION = GET_SECTION(T.TOP_TASK_ID, P_PERIOD)
       GROUP BY EQ.TASK_ID,
                T.TOP_TASK_ID,
                TOP.TASK_NUMBER,
                PA.PROJECT_ID,
                EQ.TASK_NUMBER,
                PA.SEGMENT1,
                PA.LONG_NAME,
                PA.PROJECT_TYPE
      HAVING NVL(- (SUM(DECODE(XAH.JE_CATEGORY_NAME, '2', T.ACCOUNTED_AMOUNT))), 0) != 0 OR NVL(SUM(DECODE(XAH.JE_CATEGORY_NAME, '1', T.ACCOUNTED_AMOUNT)), 0) != 0
       ORDER BY PA.SEGMENT1, TOP.TASK_NUMBER;
  
    CURSOR CUR_ORDER(P_PROJECT_ID IN NUMBER, P_TASK_ID IN NUMBER) IS
    
      SELECT DECODE(P_ORG_ID,
                    G_HBS_OU,
                    HP.DUNS_NUMBER_C,
                    G_HET_OU,
                    HP.DUNS_NUMBER_C,
                    HP.DUNS_NUMBER) GG_CODE,
             P_TASK_ID TASK_ID,
             HP.PARTY_NAME CUSTOMER_NAME,
             OOH.ORDER_NUMBER ORDER_NUMBER,
             OOH.CREATION_DATE ORDER_RECEIVED_DATE,
             OOH.ORDERED_DATE,
             OOH.TRANSACTIONAL_CURR_CODE CURRENCY_CODE,
             (SELECT NVL(XSH.PROJECT_COUNTRY, HP.COUNTRY)
                FROM XXPJM_SO_ADDTN_HEADERS_ALL XSH
               WHERE OOH.HEADER_ID = XSH.SO_HEADER_ID) COUNTRY,
             NVL(OTT.ATTRIBUTE5, 'ER') EQ_ER_CATEGORY,
             NULL SALE_AMOUNT,
             OOH.HEADER_ID,
             OOL.LINE_NUMBER LINE_NUMBER
        FROM OE_ORDER_HEADERS_ALL OOH,
             (SELECT OOL2.LINE_NUMBER, LINE_TYPE_ID, HEADER_ID
                FROM OE_ORDER_LINES_ALL OOL2
               WHERE OOL2.TASK_ID = P_TASK_ID
                 AND OOL2.PROJECT_ID = P_PROJECT_ID
                 AND OOL2.ORG_ID = P_ORG_ID
              UNION ALL
              SELECT OOL2.LINE_NUMBER, LINE_TYPE_ID, HEADER_ID
                FROM OE_ORDER_LINES_ALL OOL2
               WHERE OOL2.TASK_ID IN
                     (SELECT PTEQ.TASK_ID
                        FROM PA_TASKS PTER, PA_TASKS PTEQ, PA_TASKS PTOP
                       WHERE PTEQ.TOP_TASK_ID = PTER.TOP_TASK_ID
                         AND PTOP.TASK_ID = PTER.TOP_TASK_ID
                         AND PTEQ.TASK_NUMBER = PTOP.TASK_NUMBER || '.EQ'
                         AND PTER.TASK_ID = P_TASK_ID)
                 AND OOL2.PROJECT_ID = P_PROJECT_ID
                 AND OOL2.ORG_ID = P_ORG_ID
                 AND NOT EXISTS (SELECT 1
                        FROM OE_ORDER_LINES_ALL OOL3
                       WHERE OOL3.TASK_ID = P_TASK_ID
                         AND OOL3.PROJECT_ID = P_PROJECT_ID
                         AND OOL3.ORG_ID = P_ORG_ID)) OOL,
             HZ_CUST_ACCOUNTS HCA,
             HZ_PARTIES HP,
             OE_TRANSACTION_TYPES_ALL OTT
      
       WHERE 1 = 1
         AND ROWNUM = 1
            /*AND PT.TASK_ID =
            (SELECT PT2.TASK_ID
               FROM PA_TASKS TOP, PA_TASKS PT2
              WHERE TOP.TASK_ID = PT.TOP_TASK_ID
                AND PT2.TASK_NUMBER = TOP.TASK_NUMBER || '.EQ'
                AND PT2.PROJECT_ID = P_PROJECT_ID)*/
         AND OOL.LINE_TYPE_ID = OTT.TRANSACTION_TYPE_ID
         AND OOL.HEADER_ID = OOH.HEADER_ID
         AND OOH.SOLD_TO_ORG_ID = HCA.CUST_ACCOUNT_ID
         AND HCA.PARTY_ID = HP.PARTY_ID;
  
    CURSOR CUR_PDO(P_TASK_ID IN NUMBER) IS
      SELECT T.ORDER_NUMBER,
             T.UNITS,
             T.AMOUNT,
             T.DELIVERY_DATE,
             XPL2.ITEM_DESC MODEL
        FROM (SELECT XPH.PROD_HEADER_ID,
                     TO_NUMBER(XPH.PRODUCTION_NUMBER) ORDER_NUMBER,
                     SUM(XPL.QUANTITY) UNITS,
                     SUM(XPL.AMOUNT) AMOUNT,
                     XPH.DELIVERY_DATE
                FROM XXINV_DELY_NOTE_HEADERS_ALL XDNH,
                     XXOM_PROD_HEADERS_V         XPH,
                     XXOM_PROD_LINES_V           XPL
               WHERE 1 = 1
                 AND XDNH.PROD_HEADER_ID = XPH.PROD_HEADER_ID
                 AND XPL.PROD_HEADER_ID = XPH.PROD_HEADER_ID
                 AND XDNH.TASK_ID = P_TASK_ID
               GROUP BY XPH.PROD_HEADER_ID,
                        XPH.PRODUCTION_NUMBER,
                        XPH.DELIVERY_DATE) T,
             XXOM_PROD_LINES_V XPL2
       WHERE 1 = 1
         AND XPL2.PROD_HEADER_ID = T.PROD_HEADER_ID
         AND ROWNUM = 1;
  
    L_MATERIAL_YTD        NUMBER;
    L_EXPENSE_YTD         NUMBER;
    L_LABOUR_YTD          NUMBER;
    L_SUBCON_YTD          NUMBER;
    L_PACKING_FREIGHT_YTD NUMBER;
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
  
    GET_PERIOD_DATE(P_GL_PERIOD, L_START_DATE, L_END_DATE);
    --inti record 
    --l_interface_rec.interface_file_name    := get_file_name;
    L_INTERFACE_REC.GROUP_ID               := G_GROUP_ID;
    L_INTERFACE_REC.ORG_ID                 := P_ORG_ID;
    L_INTERFACE_REC.SOURCE_TABLE           := 'SO';
    L_INTERFACE_REC.PROCESS_STATUS         := 'P';
    L_INTERFACE_REC.PROCESS_DATE           := SYSDATE;
    L_INTERFACE_REC.REFERENCE1             := NULL;
    L_INTERFACE_REC.REFERENCE2             := NULL;
    L_INTERFACE_REC.REFERENCE3             := NULL;
    L_INTERFACE_REC.REFERENCE4             := NULL;
    L_INTERFACE_REC.REFERENCE5             := NULL;
    L_INTERFACE_REC.OBJECT_VERSION_NUMBER  := 1;
    L_INTERFACE_REC.CREATION_DATE          := SYSDATE;
    L_INTERFACE_REC.CREATED_BY             := G_CREATED_BY;
    L_INTERFACE_REC.LAST_UPDATED_BY        := G_LAST_UPDATED_BY;
    L_INTERFACE_REC.LAST_UPDATE_DATE       := SYSDATE;
    L_INTERFACE_REC.LAST_UPDATE_LOGIN      := G_LAST_UPDATE_LOGIN;
    L_INTERFACE_REC.PROGRAM_APPLICATION_ID := G_PROG_APPL_ID;
    L_INTERFACE_REC.PROGRAM_ID             := G_CONC_PROGRAM_ID;
    L_INTERFACE_REC.PROGRAM_UPDATE_DATE    := SYSDATE;
    L_INTERFACE_REC.REQUEST_ID             := G_REQUEST_ID;
    L_INTERFACE_REC.SYSTEM                 := G_TO_SYSTEM;
    L_INTERFACE_REC.DATA_TYPE              := 'ACTUAL';
    L_INTERFACE_REC.PERIOD_START_DATE      := G_PRE_PERIOD_DATE;
    L_INTERFACE_REC.CURRENCY_CODE          := GET_CURRENCY_MAP(P_CURRENCY_CODE => G_CURRENCY_CODE);
    L_INTERFACE_REC.CANCELATION_FLAG       := '0';
    L_INTERFACE_REC.COMPANY_NAME           := SUBSTR(P_OU_NAME, 1, 3);
    L_INTERFACE_REC.GOE_NUMBER             := '';
    L_INTERFACE_REC.UNITS                  := 1;
    --
    LOG('p_org_id = ' || P_ORG_ID);
    IF P_ORG_ID = G_HEA_OU THEN
      --HAKIM01
      L_LAYOUT_TYPE := 'ER';
      IF L_LAYOUT_TYPE = 'ER' THEN
        GENERATE_COGS_DATA(P_INIT_MSG_LIST => FND_API.G_TRUE,
                           X_RETURN_STATUS => X_RETURN_STATUS,
                           X_MSG_COUNT     => X_MSG_COUNT,
                           X_MSG_DATA      => X_MSG_DATA,
                           P_START_DATE    => L_START_DATE,
                           P_END_DATE      => L_END_DATE,
                           P_TYPE          => L_LAYOUT_TYPE,
                           P_PROJECT_ID    => NULL,
                           P_TOP_TASK_ID   => NULL);
        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      
        L_SEQ_NUM := 0;
      
        FOR ONE_LINE IN LINES_C(L_START_DATE,
                                L_END_DATE,
                                P_OTHER_WORKS_ONLY) LOOP
          /*IF ONE_LINE.ADDITIONAL_FLAG = 'Y' THEN
            L_INTERFACE_REC.ADDITIONAL_FLAG := '1';
          ELSIF ONE_LINE.ADDITIONAL_FLAG = 'N' THEN
            L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
          END IF;*/
        
          --add by jingjing.he start 20170703
          --deal with additional flag
          IF ONE_LINE.HAND_OVER_DATE IS NULL THEN
            GOTO NEXT_ONE_LINE;
            /*IF ONE_LINE.ADDITIONAL_FLAG = 'Y' THEN
              L_INTERFACE_REC.ADDITIONAL_FLAG := '1';
            ELSIF ONE_LINE.ADDITIONAL_FLAG = 'N' THEN
              L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
            END IF;*/
          ELSIF ONE_LINE.HAND_OVER_DATE < L_START_DATE THEN
          
            L_INTERFACE_REC.ADDITIONAL_FLAG := '1';
          ELSIF to_char(ONE_LINE.HAND_OVER_DATE, 'yyyy-mm') =
                to_char(L_START_DATE, 'yyyy-mm') THEN
          
            L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
          ELSE
            --do not output this data
            L_INTERFACE_REC.ADDITIONAL_FLAG := 'N';
          END IF;
          --add by jingjing.he end 20170703
        
          BEGIN
            SELECT PPT.ATTRIBUTE7
              INTO L_PROJECT_TYPE7
              FROM PA_PROJECT_TYPES_ALL PPT
             WHERE PPT.PROJECT_TYPE = ONE_LINE.PROJECT_TYPE;
          END;
        
          --todo
          L_INTERFACE_REC.MFG_NUM     := ONE_LINE.MFG_NO;
          L_INTERFACE_REC.SITE        := ONE_LINE.SITE;
          L_INTERFACE_REC.TASK_ID     := ONE_LINE.TASK_ID;
          L_INTERFACE_REC.PROJECT_ID  := ONE_LINE.PROJECT_ID;
          L_INTERFACE_REC.TOP_TASK_ID := ONE_LINE.TOP_TASK_ID;
          L_INTERFACE_REC.SALE_AMOUNT := ONE_LINE.SALES_AMOUNT;
          L_INTERFACE_REC.COGS        := ONE_LINE.COGS_AMOUNT;
          --L_INTERFACE_REC.ADDITIONAL_FLAG := GET_ADDITIONAL_FLAG(ONE_LINE.TASK_ID);
        
          --todo2
          GET_MODEL_STOPS(ONE_LINE.TOP_TASK_ID, L_MODEL, L_STOPS);
          L_INDEX := 0;
        
          FOR ONE_TYPE IN EXP_TYPES_C LOOP
            L_INDEX := L_INDEX + 1;
            L_FUNC_COST := GET_FUNC_COST2(L_START_DATE,
                                          L_END_DATE,
                                          ONE_LINE.PROJECT_ID,
                                          ONE_LINE.TASK_ID,
                                          ONE_TYPE.EXPENDITURE_TYPE);
            L_FUNC_COST_TAB(L_INDEX) := L_FUNC_COST;
          END LOOP;
        
          --deal with costs
          L_INTERFACE_REC.MATERIAL        := L_FUNC_COST_TAB(18) +
                                             L_FUNC_COST_TAB(19) +
                                             L_FUNC_COST_TAB(20) +
                                             L_FUNC_COST_TAB(21) +
                                             L_FUNC_COST_TAB(22);
          L_INTERFACE_REC.EXPENSE         := L_FUNC_COST_TAB(27) +
                                             L_FUNC_COST_TAB(28) +
                                             L_FUNC_COST_TAB(29) +
                                             L_FUNC_COST_TAB(30);
          L_INTERFACE_REC.LABOUR          := L_FUNC_COST_TAB(1) +
                                             L_FUNC_COST_TAB(2) +
                                             L_FUNC_COST_TAB(3) +
                                             L_FUNC_COST_TAB(4) +
                                             L_FUNC_COST_TAB(5) +
                                             L_FUNC_COST_TAB(6) +
                                             L_FUNC_COST_TAB(7);
          L_INTERFACE_REC.SUBCON          := L_FUNC_COST_TAB(23) +
                                             L_FUNC_COST_TAB(24);
          L_INTERFACE_REC.PACKING_FREIGHT := L_FUNC_COST_TAB(25) +
                                             L_FUNC_COST_TAB(26);
        
          --add by jingjing.he start 20170703
          IF L_INTERFACE_REC.ADDITIONAL_FLAG = '0' THEN
            GET_HEA_ER_FIRST_AMOUNT(P_TASK_ID         => ONE_LINE.TASK_ID,
                                    P_START_DATE      => L_START_DATE,
                                    X_SALES_AMOUNT    => L_SALES_AMOUNT,
                                    X_COGS            => L_COGS,
                                    X_MATERIAL        => L_MATERIAL,
                                    X_EXPENSE         => L_EXPENSE,
                                    X_LABOUR          => L_LABOUR,
                                    X_SUBCON          => L_SUBCON,
                                    X_PACKING_FREIGHT => L_PACKING_FREIGHT);
          
            L_INTERFACE_REC.SALE_AMOUNT     := ONE_LINE.SALES_AMOUNT +
                                               L_SALES_AMOUNT;
            L_INTERFACE_REC.COGS            := L_INTERFACE_REC.COGS +
                                               L_COGS;
            L_INTERFACE_REC.MATERIAL        := L_INTERFACE_REC.MATERIAL +
                                               L_MATERIAL;
            L_INTERFACE_REC.EXPENSE         := L_INTERFACE_REC.EXPENSE +
                                               L_EXPENSE;
            L_INTERFACE_REC.LABOUR          := L_INTERFACE_REC.LABOUR +
                                               L_LABOUR;
            L_INTERFACE_REC.SUBCON          := L_INTERFACE_REC.SUBCON +
                                               L_SUBCON;
            L_INTERFACE_REC.PACKING_FREIGHT := L_INTERFACE_REC.PACKING_FREIGHT +
                                               L_PACKING_FREIGHT;
            NULL;
          END IF;
        
          --add by jingjing.he end 20170703
        
          L_INTERFACE_REC.GOE_NUMBER    := GET_GOE_NUMBER(P_MFG_NO => ONE_LINE.MFG_NO,
                                                          P_ORG_ID => P_ORG_ID);
          L_INTERFACE_REC.DELIVERY_DATE := GET_DELIVERY_DATE(P_TOP_TASK_ID  => ONE_LINE.TOP_TASK_ID,
                                                             P_ORG_ID       => P_ORG_ID,
                                                             P_PROJECT_TYPE => L_PROJECT_TYPE7);
          IF L_DEBUG = 'Y' THEN
            DEBUG('Loop Sale Order Info ' || ONE_LINE.MFG_NO);
          END IF;
        
          FOR REC_ORDER IN CUR_ORDER(P_PROJECT_ID => ONE_LINE.PROJECT_ID,
                                     P_TASK_ID    => ONE_LINE.TASK_ID) LOOP
            L_INT_ERR.PROCESS_MESSAGE := NULL;
            L_SO_COUNT                := L_SO_COUNT + 1;
          
            L_INTERFACE_REC.SOURCE_HEADER_ID := REC_ORDER.HEADER_ID;
            L_INTERFACE_REC.LINE_NUMBER      := REC_ORDER.LINE_NUMBER;
            L_INTERFACE_REC.GG_CODE          := REC_ORDER.GG_CODE;
            L_INTERFACE_REC.CUSTOMER_NAME    := REC_ORDER.CUSTOMER_NAME;
            L_COUNTRY_DESC                   := GET_COUNTRY_DESC(REC_ORDER.COUNTRY);
            L_INTERFACE_REC.MAIN_CONTRACTOR  := GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE => L_COUNTRY_DESC || '.' ||
                                                                                                  REC_ORDER.EQ_ER_CATEGORY);
            IF L_INTERFACE_REC.MAIN_CONTRACTOR IS NULL THEN
              L_INTERFACE_REC.MAIN_CONTRACTOR := GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE => 'Other.' ||
                                                                                                   REC_ORDER.EQ_ER_CATEGORY);
            END IF;
            L_INTERFACE_REC.DELIVERED_COUNTRY := GET_COUNTRY_MAP(L_COUNTRY_DESC);
            L_INTERFACE_REC.ORDER_NUMBER      := REC_ORDER.ORDER_NUMBER;
          
            L_INTERFACE_REC.ORDER_RECEIVED_DATE := REC_ORDER.ORDER_RECEIVED_DATE;
          
            L_INTERFACE_REC.EQ_ER_CATEGORY := GET_EQ_ER(REC_ORDER.TASK_ID);
            L_INTERFACE_REC.MODEL          := NVL(GET_MODEL(P_TASK_ID      => REC_ORDER.TASK_ID,
                                                            P_SO_HEADER_ID => REC_ORDER.HEADER_ID,
                                                            P_MFG_NO       => ONE_LINE.MFG_NO,
                                                            P_ORG_ID       => P_ORG_ID),
                                                  'Others');
            L_INTERFACE_REC.MODEL_TYPE     := NVL(GET_MODEL_MAP(P_GSCM_MODEL => L_INTERFACE_REC.MODEL),
                                                  'Others');
            L_PRE_SALE_AMOUNT              := GET_SALE_AMOUNT(P_TASK_ID => ONE_LINE.TASK_ID);
            L_INTERFACE_REC.SALE_AMOUNT    := ROUND(NVL(L_INTERFACE_REC.SALE_AMOUNT,
                                                        0),
                                                    2);
            /* l_interface_rec.preperiod_sale_amount := rec_order.sale_amount *
            get_so_rate(rec_order.currency_code,
                        rec_order.ordered_date);*/
            IF L_DEBUG = 'Y' THEN
              DEBUG('Inser into  xxpa_cost_gcpm_int');
            END IF;
          
            IF L_INTERFACE_REC.SALE_AMOUNT <> 0 OR
               (L_INTERFACE_REC.COGS <> 0 AND
               (L_INTERFACE_REC.MATERIAL <> 0 OR
               L_INTERFACE_REC.EXPENSE <> 0 OR
               L_INTERFACE_REC.LABOUR <> 0 OR L_INTERFACE_REC.SUBCON <> 0 OR
               L_INTERFACE_REC.PACKING_FREIGHT <> 0)) THEN
              --L_INTERFACE_REC.ADDITIONAL_FLAG := GET_ADDITIONAL_FLAG(L_INTERFACE_REC.TASK_ID);
              L_INTERFACE_REC.ACTUAL_MONTH := L_START_DATE;
            
              SELECT XXPA_COST_GCPM_INT_ROW_S.NEXTVAL
                INTO L_INTERFACE_REC.UNIQUE_ID
                FROM DUAL;
              INSERT INTO XXPA_COST_GCPM_INT VALUES L_INTERFACE_REC;
            
            ELSE
              --L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
              L_INTERFACE_REC.ACTUAL_MONTH := NULL;
            END IF;
          END LOOP;
          <<NEXT_ONE_LINE>>
          NULL;
        END LOOP;
      END IF; --L_LAYOUT_TYPE := 'ER';
    
      L_LAYOUT_TYPE := 'EQ';
      IF L_LAYOUT_TYPE = 'EQ' THEN
        GENERATE_COGS_DATA(P_INIT_MSG_LIST => FND_API.G_TRUE,
                           X_RETURN_STATUS => X_RETURN_STATUS,
                           X_MSG_COUNT     => X_MSG_COUNT,
                           X_MSG_DATA      => X_MSG_DATA,
                           P_START_DATE    => L_START_DATE,
                           P_END_DATE      => L_END_DATE,
                           P_TYPE          => L_LAYOUT_TYPE,
                           P_PROJECT_ID    => NULL,
                           P_TOP_TASK_ID   => NULL);
        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      
        IF L_ERROR_MESSAGE != FND_API.G_RET_STS_SUCCESS THEN
          L_COMPLETION_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                                                                      NULL);
          RETURN;
        END IF;
      
        FOR I IN 1 .. 5 LOOP
          IF I = 4 THEN
            GOTO NEXT_LOOP;
          END IF;
        
          /*IF I = 5 THEN
            L_INTERFACE_REC.ADDITIONAL_FLAG := '1';
          ELSE
            L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
          END IF;*/
        
          FOR ONE_LINE IN EQ_LINES_C(L_START_DATE,
                                     L_END_DATE,
                                     P_GL_PERIOD,
                                     I) LOOP
            BEGIN
            
              SELECT PPT.ATTRIBUTE7
                INTO L_PROJECT_TYPE7
                FROM PA_PROJECT_TYPES_ALL PPT
               WHERE PPT.PROJECT_TYPE = ONE_LINE.PROJECT_TYPE;
            END;
            --todo
            L_INTERFACE_REC.MFG_NUM         := ONE_LINE.TASK_NUMBER;
            L_INTERFACE_REC.SITE            := ONE_LINE.SITE;
            L_INTERFACE_REC.TASK_ID         := ONE_LINE.TASK_ID;
            L_INTERFACE_REC.PROJECT_ID      := ONE_LINE.PROJECT_ID;
            L_INTERFACE_REC.TOP_TASK_ID     := ONE_LINE.TOP_TASK_ID;
            L_INTERFACE_REC.COGS            := ONE_LINE.COGS_AMOUNT;
            L_INTERFACE_REC.ADDITIONAL_FLAG := GET_ADDITIONAL_FLAG(ONE_LINE.TASK_ID);
          
            L_INDEX := 0;
            FOR ONE_TYPE IN EXP_TYPES_C LOOP
              L_INDEX := L_INDEX + 1;
              L_FUNC_COST := GET_FUNC_COST(ONE_LINE.PROJECT_ID,
                                           ONE_LINE.TASK_ID,
                                           ONE_TYPE.EXPENDITURE_TYPE);
              L_FUNC_COST_TAB(L_INDEX) := L_FUNC_COST;
            END LOOP;
          
            --deal with the costs
            L_INTERFACE_REC.MATERIAL        := L_FUNC_COST_TAB(18) +
                                               L_FUNC_COST_TAB(19) +
                                               L_FUNC_COST_TAB(20) +
                                               L_FUNC_COST_TAB(21) +
                                               L_FUNC_COST_TAB(22);
            L_INTERFACE_REC.EXPENSE         := L_FUNC_COST_TAB(27) +
                                               L_FUNC_COST_TAB(28) +
                                               L_FUNC_COST_TAB(29) +
                                               L_FUNC_COST_TAB(30);
            L_INTERFACE_REC.LABOUR          := L_FUNC_COST_TAB(1) +
                                               L_FUNC_COST_TAB(2) +
                                               L_FUNC_COST_TAB(3) +
                                               L_FUNC_COST_TAB(4) +
                                               L_FUNC_COST_TAB(5) +
                                               L_FUNC_COST_TAB(6) +
                                               L_FUNC_COST_TAB(7);
            L_INTERFACE_REC.SUBCON          := L_FUNC_COST_TAB(23) +
                                               L_FUNC_COST_TAB(24);
            L_INTERFACE_REC.PACKING_FREIGHT := L_FUNC_COST_TAB(25) +
                                               L_FUNC_COST_TAB(26);
          
            L_INTERFACE_REC.GOE_NUMBER    := GET_GOE_NUMBER(P_MFG_NO => ONE_LINE.TASK_NUMBER,
                                                            P_ORG_ID => P_ORG_ID);
            L_INTERFACE_REC.DELIVERY_DATE := GET_DELIVERY_DATE(P_TOP_TASK_ID  => ONE_LINE.TOP_TASK_ID,
                                                               P_ORG_ID       => P_ORG_ID,
                                                               P_PROJECT_TYPE => L_PROJECT_TYPE7);
            IF L_DEBUG = 'Y' THEN
              DEBUG('Loop Sale Order Info ' || ONE_LINE.TASK_NUMBER);
            END IF;
          
            FOR REC_ORDER IN CUR_ORDER(P_PROJECT_ID => ONE_LINE.PROJECT_ID,
                                       P_TASK_ID    => ONE_LINE.TASK_ID) LOOP
            
              L_INTERFACE_REC.SOURCE_HEADER_ID := REC_ORDER.HEADER_ID;
              L_INTERFACE_REC.LINE_NUMBER      := REC_ORDER.LINE_NUMBER;
              L_INTERFACE_REC.GG_CODE          := REC_ORDER.GG_CODE;
              L_INTERFACE_REC.CUSTOMER_NAME    := REC_ORDER.CUSTOMER_NAME;
              L_COUNTRY_DESC                   := GET_COUNTRY_DESC(REC_ORDER.COUNTRY);
              L_INTERFACE_REC.MAIN_CONTRACTOR  := GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE => L_COUNTRY_DESC || '.' ||
                                                                                                    REC_ORDER.EQ_ER_CATEGORY);
              IF L_INTERFACE_REC.MAIN_CONTRACTOR IS NULL THEN
                L_INTERFACE_REC.MAIN_CONTRACTOR := GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE => 'Other.' ||
                                                                                                     REC_ORDER.EQ_ER_CATEGORY);
              END IF;
              L_INTERFACE_REC.DELIVERED_COUNTRY := GET_COUNTRY_MAP(L_COUNTRY_DESC);
              L_INTERFACE_REC.ORDER_NUMBER      := REC_ORDER.ORDER_NUMBER;
            
              L_INTERFACE_REC.ORDER_RECEIVED_DATE := REC_ORDER.ORDER_RECEIVED_DATE;
            
              L_INTERFACE_REC.EQ_ER_CATEGORY := GET_EQ_ER(ONE_LINE.TASK_ID);
              L_INTERFACE_REC.MODEL          := NVL(GET_MODEL(P_TASK_ID      => ONE_LINE.TASK_ID, --rec_mfg.task_id,
                                                              P_SO_HEADER_ID => REC_ORDER.HEADER_ID,
                                                              P_MFG_NO       => ONE_LINE.TASK_NUMBER, --rec_mfg.mfg_no,
                                                              P_ORG_ID       => P_ORG_ID),
                                                    'Others');
              L_INTERFACE_REC.MODEL_TYPE     := NVL(GET_MODEL_MAP(P_GSCM_MODEL => L_INTERFACE_REC.MODEL),
                                                    'Others');
            
              /*l_pre_sale_amount                     := get_sale_amount(p_task_id => rec_mfg.task_id);*/
              L_INTERFACE_REC.SALE_AMOUNT := ROUND(NVL(ONE_LINE.SALES_AMOUNT,
                                                       0),
                                                   2);
            
              IF L_DEBUG = 'Y' THEN
                DEBUG('Inser into  xxpa_cost_gcpm_int');
              END IF;
            
              IF L_INTERFACE_REC.SALE_AMOUNT <> 0 OR
                 (L_INTERFACE_REC.COGS <> 0 AND
                 (L_INTERFACE_REC.MATERIAL <> 0 OR
                 L_INTERFACE_REC.EXPENSE <> 0 OR
                 L_INTERFACE_REC.LABOUR <> 0 OR
                 L_INTERFACE_REC.SUBCON <> 0 OR
                 L_INTERFACE_REC.PACKING_FREIGHT <> 0)) THEN
                --L_INTERFACE_REC.ADDITIONAL_FLAG := GET_ADDITIONAL_FLAG(L_INTERFACE_REC.TASK_ID);
                L_INTERFACE_REC.ACTUAL_MONTH := L_START_DATE;
              
                SELECT XXPA_COST_GCPM_INT_ROW_S.NEXTVAL
                  INTO L_INTERFACE_REC.UNIQUE_ID
                  FROM DUAL;
                INSERT INTO XXPA_COST_GCPM_INT VALUES L_INTERFACE_REC;
              
              ELSE
                --L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
                L_INTERFACE_REC.ACTUAL_MONTH := NULL;
              END IF;
            
            END LOOP;
          
          END LOOP;
          <<NEXT_LOOP>>
          NULL;
        END LOOP;
      END IF; --L_LAYOUT_TYPE := 'EQ';      
    END IF;
    IF P_ORG_ID = G_SHE_OU OR P_ORG_ID = G_HET_OU THEN
      ---prepare task wip data 
      --these prepared data need to be connected with tax invoice
      --if data matched according to task_id
      --there is no need to collect the so data and the following steps will be skipped.
      PROC_COGS_DATA(P_INIT_MSG_LIST => FND_API.G_TRUE,
                     X_RETURN_STATUS => X_RETURN_STATUS,
                     X_MSG_COUNT     => X_MSG_COUNT,
                     X_MSG_DATA      => X_MSG_DATA,
                     P_START_DATE    => L_START_DATE,
                     P_END_DATE      => L_END_DATE,
                     P_ORG_ID        => P_ORG_ID);
    
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    
      IF L_DEBUG = 'Y' THEN
        DEBUG('Loop Mfg ');
      END IF;
    
      FOR REC_MFG IN CUR_TASK LOOP
        L_INTERFACE_REC.ADDITIONAL_FLAG := NULL;
        L_INTERFACE_REC.MFG_NUM         := REC_MFG.MFG_NO;
        L_INTERFACE_REC.SITE            := REC_MFG.SITE;
        L_INTERFACE_REC.TASK_ID         := REC_MFG.TASK_ID;
        L_INTERFACE_REC.PROJECT_ID      := REC_MFG.PROJECT_ID;
        L_INTERFACE_REC.TOP_TASK_ID     := REC_MFG.TOP_TASK_ID;
        L_INTERFACE_REC.COGS            := REC_MFG.COGS;
        L_MATERIAL_YTD                  := 0;
        L_EXPENSE_YTD                   := 0;
        L_LABOUR_YTD                    := 0;
        L_SUBCON_YTD                    := 0;
        L_PACKING_FREIGHT_YTD           := 0;
        L_PRE_SALE_AMOUNT               := 0;
      
        --todo now
        FOR REC_WIP IN CUR_MFG(REC_MFG.TASK_ID) LOOP
          GET_WIP_AMOUNT(P_TASK_ID             => REC_MFG.TASK_ID,
                         X_MATERIAL_YTD        => L_MATERIAL_YTD,
                         X_EXPENSE_YTD         => L_EXPENSE_YTD,
                         X_LABOUR_YTD          => L_LABOUR_YTD,
                         X_SUBCON_YTD          => L_SUBCON_YTD,
                         X_PACKING_FREIGHT_YTD => L_PACKING_FREIGHT_YTD);
        
          L_INTERFACE_REC.MATERIAL_YTD := REC_WIP.MATERIAL;
          L_INTERFACE_REC.EXPENSE_YTD  := REC_WIP.EXPENSE -
                                          REC_WIP.PACKING_FREIGHT;
          L_INTERFACE_REC.LABOUR_YTD   := REC_WIP.LABOUR - REC_WIP.SUBCON;
        
          L_INTERFACE_REC.SUBCON_YTD          := GET_SUBCON(REC_MFG.TASK_ID,
                                                            P_ORG_ID,
                                                            L_END_DATE);
          L_INTERFACE_REC.PACKING_FREIGHT_YTD := REC_WIP.PACKING_FREIGHT;
          --
          L_INTERFACE_REC.MATERIAL := REC_WIP.MATERIAL - L_MATERIAL_YTD;
          L_INTERFACE_REC.EXPENSE  := REC_WIP.EXPENSE -
                                      REC_WIP.PACKING_FREIGHT -
                                      L_EXPENSE_YTD;
          L_INTERFACE_REC.LABOUR   := REC_WIP.LABOUR - REC_WIP.SUBCON -
                                      L_LABOUR_YTD;
        
          L_INTERFACE_REC.SUBCON          := L_INTERFACE_REC.SUBCON_YTD -
                                             L_SUBCON_YTD;
          L_INTERFACE_REC.PACKING_FREIGHT := REC_WIP.PACKING_FREIGHT -
                                             L_PACKING_FREIGHT_YTD;
        END LOOP;
      
        L_INTERFACE_REC.GOE_NUMBER    := GET_GOE_NUMBER(P_MFG_NO => REC_MFG.MFG_NO,
                                                        P_ORG_ID => P_ORG_ID);
        L_INTERFACE_REC.DELIVERY_DATE := GET_DELIVERY_DATE(P_TOP_TASK_ID  => REC_MFG.TOP_TASK_ID,
                                                           P_ORG_ID       => P_ORG_ID,
                                                           P_PROJECT_TYPE => REC_MFG.PROJECT_TYPE);
      
        IF L_DEBUG = 'Y' THEN
          DEBUG('Loop Sale Order Info ' || REC_MFG.MFG_NO);
          DEBUG('task id ' || REC_MFG.TASK_ID);
        END IF;
        L_SO_COUNT := 0;
        --if the task has no so associated with it
        FOR REC_ORDER IN CUR_ORDER(P_PROJECT_ID => REC_MFG.PROJECT_ID,
                                   P_TASK_ID    => REC_MFG.TASK_ID) LOOP
          --the loop only execute once
          --during this loop, the main reason is to get the data
          L_SO_COUNT                       := L_SO_COUNT + 1;
          L_INT_ERR.PROCESS_MESSAGE        := NULL;
          L_INTERFACE_REC.SOURCE_HEADER_ID := REC_ORDER.HEADER_ID;
          L_INTERFACE_REC.LINE_NUMBER      := REC_ORDER.LINE_NUMBER;
          L_INTERFACE_REC.GG_CODE          := REC_ORDER.GG_CODE;
          L_INTERFACE_REC.CUSTOMER_NAME    := REC_ORDER.CUSTOMER_NAME;
          L_COUNTRY_DESC                   := GET_COUNTRY_DESC(REC_ORDER.COUNTRY);
          L_INTERFACE_REC.MAIN_CONTRACTOR  := GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE => L_COUNTRY_DESC || '.' ||
                                                                                                REC_ORDER.EQ_ER_CATEGORY);
          IF L_INTERFACE_REC.MAIN_CONTRACTOR IS NULL THEN
            L_INTERFACE_REC.MAIN_CONTRACTOR := GET_MAIN_CONTRACTOR_MAP(P_MAIN_CONTRACTOR_CODE => 'Other.' ||
                                                                                                 REC_ORDER.EQ_ER_CATEGORY);
          END IF;
          L_INTERFACE_REC.DELIVERED_COUNTRY := GET_COUNTRY_MAP(L_COUNTRY_DESC);
          L_INTERFACE_REC.ORDER_NUMBER      := REC_ORDER.ORDER_NUMBER;
        
          L_INTERFACE_REC.ORDER_RECEIVED_DATE := REC_ORDER.ORDER_RECEIVED_DATE;
        
          L_INTERFACE_REC.EQ_ER_CATEGORY := GET_EQ_ER(REC_MFG.TASK_ID);
          L_INTERFACE_REC.MODEL          := NVL(GET_MODEL(P_TASK_ID      => REC_MFG.TASK_ID,
                                                          P_SO_HEADER_ID => REC_ORDER.HEADER_ID,
                                                          P_MFG_NO       => REC_MFG.MFG_NO,
                                                          P_ORG_ID       => P_ORG_ID),
                                                'Others');
          L_INTERFACE_REC.MODEL_TYPE     := NVL(GET_MODEL_MAP(P_GSCM_MODEL => L_INTERFACE_REC.MODEL),
                                                'Others');
        
          --in the loop of so, the sale_amount is always the same
          L_INTERFACE_REC.SALE_AMOUNT := ROUND(NVL(REC_MFG.SALE_AMOUNT, 0),
                                               2);
        
          --where does the task_id come from? OVERSEA or DOMESTIC
          IS_IN_TAX_INVOICE(P_TASK_ID           => REC_MFG.TASK_ID,
                            P_START_DATE        => L_START_DATE,
                            P_END_DATE          => L_END_DATE,
                            X_LAST_INVOICE_FLAG => L_LAST_INVOICE_FLAG,
                            X_EXIST             => L_EXIST_TAX_INVOICE,
                            X_ISOVERSEA         => L_ISOVERSEA);
          --step1 wether or not exist in tax invoice
          IF L_EXIST_TAX_INVOICE = 'Y' THEN
            IF L_ISOVERSEA <> 'OVERSEA' THEN
              --backup data with time which will be used later
              BACKUP_DOM_TAX_INVOICE(REC_MFG.TASK_ID,
                                     L_START_DATE,
                                     L_END_DATE);
              --If it is last invoice
              IF L_LAST_INVOICE_FLAG = 'Y' THEN
                L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
                GET_FIRST_SALE_AMOUNT(P_TASK_ID      => REC_MFG.TASK_ID,
                                      P_START_DATE   => L_START_DATE,
                                      P_END_DATE     => L_END_DATE,
                                      X_SALES_AMOUNT => L_SALES_AMOUNT);
                L_INTERFACE_REC.SALE_AMOUNT := ROUND(NVL(L_SALES_AMOUNT, 0),
                                                     2);
              ELSE
                -- <> last invoice
                L_EXIST := NULL;
                L_EXIST := EXIST_DOMESTIC_LAST_INVOICE(P_TASK_ID    => REC_MFG.TASK_ID,
                                                       P_START_DATE => L_START_DATE);
                IF L_EXIST = 'Y' THEN
                  --ADDITIONAL FLAG = 1
                  L_INTERFACE_REC.ADDITIONAL_FLAG := '1';
                  GET_ADD_SALE_AMOUNT(P_TASK_ID      => REC_MFG.TASK_ID,
                                      P_START_DATE   => L_START_DATE,
                                      P_END_DATE     => L_END_DATE,
                                      P_ISOVERSEA    => 'DOMESTIC',
                                      X_SALES_AMOUNT => L_SALES_AMOUNT);
                  L_INTERFACE_REC.SALE_AMOUNT := ROUND(NVL(L_SALES_AMOUNT,
                                                           0),
                                                       2);
                ELSIF L_EXIST = 'N' THEN
                  GOTO NEXT_LOOP_TASK;
                END IF;
              
                NULL;
              END IF;
            ELSE
              BACKUP_OVERSEA_TAX_INVOICE(P_TASK_ID    => REC_MFG.TASK_ID,
                                         P_START_DATE => L_START_DATE,
                                         P_END_DATE   => L_END_DATE);
              --OVRSEA
              L_EXIST := NULL;
              L_EXIST := EXIST_OVERSEA_INVOICE(P_TASK_ID    => REC_MFG.TASK_ID,
                                               P_START_DATE => L_START_DATE);
              IF L_EXIST = 'Y' THEN
                L_INTERFACE_REC.ADDITIONAL_FLAG := '1';
                GET_ADD_SALE_AMOUNT(P_TASK_ID      => REC_MFG.TASK_ID,
                                    P_START_DATE   => L_START_DATE,
                                    P_END_DATE     => L_END_DATE,
                                    P_ISOVERSEA    => 'OVERSEA',
                                    X_SALES_AMOUNT => L_SALES_AMOUNT);
              
                L_INTERFACE_REC.SALE_AMOUNT := ROUND(NVL(L_SALES_AMOUNT, 0),
                                                     2);
              ELSIF L_EXIST = 'N' THEN
                L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
                GET_FIRST_SALE_AMOUNT(P_TASK_ID      => REC_MFG.TASK_ID,
                                      P_START_DATE   => L_START_DATE,
                                      P_END_DATE     => L_END_DATE,
                                      X_SALES_AMOUNT => L_SALES_AMOUNT);
              
                L_INTERFACE_REC.SALE_AMOUNT := ROUND(NVL(L_SALES_AMOUNT, 0),
                                                     2);
              END IF;
            END IF;
          END IF;
        
          IF L_DEBUG = 'Y' THEN
            DEBUG('Inser into  xxpa_cost_gcpm_int');
          END IF;
          /* IF l_interface_rec.order_received_date BETWEEN p_start_date AND
             p_end_date THEN
            l_interface_rec.additional_flag := '0';
            l_interface_rec.actual_month    := p_start_date;
            SELECT xxpa_cost_gcpm_int_row_s.nextval
              INTO l_interface_rec.unique_id
              FROM dual;
            INSERT INTO xxpa_cost_gcpm_int VALUES l_interface_rec;
          
          ELS*/
          --todo4
        
          IF L_INTERFACE_REC.SALE_AMOUNT <> 0 OR
             (L_INTERFACE_REC.COGS <> 0 AND
             (L_INTERFACE_REC.MATERIAL <> 0 OR
             L_INTERFACE_REC.EXPENSE <> 0 OR L_INTERFACE_REC.LABOUR <> 0 OR
             L_INTERFACE_REC.SUBCON <> 0 OR
             L_INTERFACE_REC.PACKING_FREIGHT <> 0)) THEN
            IF L_INTERFACE_REC.ADDITIONAL_FLAG IS NULL THEN
              L_INTERFACE_REC.ADDITIONAL_FLAG := GET_ADDITIONAL_FLAG(L_INTERFACE_REC.TASK_ID);
            END IF;
            L_INTERFACE_REC.ACTUAL_MONTH := L_START_DATE;
            SELECT XXPA_COST_GCPM_INT_ROW_S.NEXTVAL
              INTO L_INTERFACE_REC.UNIQUE_ID
              FROM DUAL;
            INSERT INTO XXPA_COST_GCPM_INT VALUES L_INTERFACE_REC;
          ELSE
            L_INTERFACE_REC.ADDITIONAL_FLAG := '0';
            L_INTERFACE_REC.ACTUAL_MONTH    := NULL;
          END IF;
        
        END LOOP;
      
        IF L_SO_COUNT = 0 THEN
          --The task without so, there exists special situation needed to consider.
          L_EXIST_NO_SO := EXIST_SHE_NO_SO(P_TASK_ID    => REC_MFG.TASK_ID,
                                           P_ORG_ID     => P_ORG_ID,
                                           P_START_DATE => L_START_DATE,
                                           P_END_DATE   => L_END_DATE);
          --EXIST_SHE_NO_SO(REC_MFG.TASK_ID, P_ORG_ID, p_start_date, p_end_date);
          IF L_EXIST_NO_SO = 'Y' THEN
            IF L_DEBUG = 'Y' THEN
              DEBUG('Inser into  xxpa_cost_gcpm_int with no so');
            END IF;
            --==================================
            L_INT_ERR.PROCESS_MESSAGE           := NULL;
            L_INTERFACE_REC.SOURCE_HEADER_ID    := NULL;
            L_INTERFACE_REC.LINE_NUMBER         := '1'; --todo      varchar2(40)
            L_INTERFACE_REC.GG_CODE             := NULL; --null
            L_INTERFACE_REC.CUSTOMER_NAME       := NULL; --null
            L_INTERFACE_REC.MAIN_CONTRACTOR     := NULL; --null
            L_INTERFACE_REC.DELIVERED_COUNTRY   := NULL; --null
            L_INTERFACE_REC.ORDER_NUMBER        := NULL; --todo
            L_INTERFACE_REC.UNITS               := NULL; --todo
            L_INTERFACE_REC.ORDER_RECEIVED_DATE := NULL; --null
            L_INTERFACE_REC.DELIVERY_DATE       := NULL; --todo20170704
            L_INTERFACE_REC.EQ_ER_CATEGORY      := 'PARTS'; --'PARTS'
            L_INTERFACE_REC.MODEL               := NULL; --todo
            L_INTERFACE_REC.MODEL_TYPE          := 'PARTS'; --'PARTS'
            L_INTERFACE_REC.SALE_AMOUNT         := NULL;
            L_INTERFACE_REC.ADDITIONAL_FLAG     := GET_ADDITIONAL_FLAG(P_TASK_ID => REC_MFG.TASK_ID);
            --===================================
          
            --add by jingjing.He start 20170703
            OPEN CUR_PDO(P_TASK_ID => REC_MFG.TASK_ID);
          
            /*T.ORDER_NUMBER,
            T.UNITS,
            T.AMOUNT,
            T.DELIVERY_DATE,
            XPL2.ITEM_DESC MODEL*/
            FETCH CUR_PDO
              INTO L_INTERFACE_REC.ORDER_NUMBER, --number
                   L_INTERFACE_REC.UNITS, --number
                   L_INTERFACE_REC.SALE_AMOUNT,
                   L_INTERFACE_REC.DELIVERY_DATE,
                   L_INTERFACE_REC.MODEL; --varchar2(150) --number
            CLOSE CUR_PDO;
          
            IF L_INTERFACE_REC.ORDER_NUMBER IS NULL THEN
              GOTO NEXT_LOOP_TASK;
            END IF;
            --add by jingjing.He end 20170703
            L_INTERFACE_REC.ACTUAL_MONTH := L_START_DATE;
            SELECT XXPA_COST_GCPM_INT_ROW_S.NEXTVAL
              INTO L_INTERFACE_REC.UNIQUE_ID
              FROM DUAL;
            INSERT INTO XXPA_COST_GCPM_INT VALUES L_INTERFACE_REC;
          END IF;
          NULL;
        END IF;
        <<NEXT_LOOP_TASK>>
        NULL;
      END LOOP;
    END IF; --84 141
  
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
  END PROCESS_REQUEST6;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  main
  *
  *   DESCRIPTION:
  *       main
  *   ARGUMENT: p_group_id         group id
  *             p_date             now date
  *             p_ledger_name      ledger name
  *   HISTORY:
  *     1.00 2017-03-03 Steven.Wang Creation
  * =============================================*/
  PROCEDURE MAIN(ERRBUF     OUT VARCHAR2,
                 RETCODE    OUT VARCHAR2,
                 P_GROUP_ID IN VARCHAR2,
                 P_DATE     IN VARCHAR2) IS
    L_ERROR_MESSAGE VARCHAR2(2000);
    L_RETURN_STATUS VARCHAR2(30);
    L_MSG_COUNT     NUMBER;
    L_MSG_DATA      VARCHAR2(2000);
    L_RUNING_NUMBER NUMBER;
    L_DATE          DATE;
    L_START_DATE    DATE;
    L_END_DATE      DATE;
    CURSOR CUR_PERIOD(P_START_DATE IN DATE, P_SET_OF_BOOKS_ID IN NUMBER) IS
      SELECT GPS.START_DATE, TRUNC(GPS.END_DATE) + 0.99999, GPS.PERIOD_NAME
        FROM GL_PERIOD_STATUSES GPS
       WHERE GPS.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
         AND GPS.APPLICATION_ID = 101
         AND GPS.ADJUSTMENT_PERIOD_FLAG = 'N'
         AND GPS.END_DATE < P_START_DATE
       ORDER BY GPS.START_DATE DESC;
    CURSOR CUR_PERIOD2(P_START_DATE IN DATE, P_SET_OF_BOOKS_ID IN NUMBER) IS
      SELECT GPS.START_DATE
        FROM GL_PERIOD_STATUSES GPS
       WHERE GPS.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
         AND GPS.APPLICATION_ID = 101
         AND GPS.ADJUSTMENT_PERIOD_FLAG = 'N'
         AND GPS.END_DATE < P_START_DATE
       ORDER BY GPS.START_DATE DESC;
  BEGIN
    RETCODE := '0';
    -- concurrent header log
    XXFND_CONC_UTL.LOG_HEADER;
    L_DATE := FND_CONC_DATE.STRING_TO_DATE(P_DATE);
    -- conc body
  
    XXFND_DEBUG2.START_PROFILER(RUN_COMMENT1 => 'Test',
                                RUN_NUMBER   => L_RUNING_NUMBER);
    LOG('l_runing_number : ' || L_RUNING_NUMBER);
    IF P_GROUP_ID IS NOT NULL THEN
      G_GROUP_ID := P_GROUP_ID;
    ELSE
      SELECT XXPA_COST_GCPM_INT_S.NEXTVAL INTO G_GROUP_ID FROM DUAL;
    END IF;
    FOR REC IN (SELECT HOU.ORGANIZATION_ID,
                       GSB.SET_OF_BOOKS_ID,
                       HOU.NAME,
                       GSB.CURRENCY_CODE
                  FROM GL_SETS_OF_BOOKS GSB, HR_OPERATING_UNITS HOU
                 WHERE GSB.SET_OF_BOOKS_ID = HOU.SET_OF_BOOKS_ID
                      AND HOU.ORGANIZATION_ID NOT IN (101)) LOOP
                      --AND HOU.ORGANIZATION_ID IN (G_HEA_OU)) LOOP
                   --AND HOU.ORGANIZATION_ID IN (G_she_OU)) LOOP
      G_PERIOD_NAME     := NULL;
      G_PRE_PERIOD_DATE := NULL;
      G_LEDGER_ID       := REC.SET_OF_BOOKS_ID;
      G_CURRENCY_CODE   := REC.CURRENCY_CODE;
    
      OPEN CUR_PERIOD(L_DATE, REC.SET_OF_BOOKS_ID);
      FETCH CUR_PERIOD
        INTO L_START_DATE, L_END_DATE, G_PERIOD_NAME;
      CLOSE CUR_PERIOD;
    
      IF G_PERIOD_NAME IS NULL THEN
        LOG('Can not get period date');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OPEN CUR_PERIOD2(L_START_DATE, REC.SET_OF_BOOKS_ID);
      FETCH CUR_PERIOD2
        INTO G_PRE_PERIOD_DATE;
      CLOSE CUR_PERIOD2;
      IF G_PERIOD_NAME IS NULL THEN
        LOG('Can not get pre period data');
      END IF;
    
      PROCESS_REQUEST6(P_INIT_MSG_LIST    => FND_API.G_TRUE,
                       X_RETURN_STATUS    => L_RETURN_STATUS,
                       X_MSG_COUNT        => L_MSG_COUNT,
                       X_MSG_DATA         => L_MSG_DATA,
                       P_LAYOUT_TYPE      => NULL,
                       P_GL_PERIOD        => G_PERIOD_NAME,
                       P_OTHER_WORKS_ONLY => 'N',
                       P_OU_NAME          => REC.NAME, --ou_name
                       P_ORG_ID           => REC.ORGANIZATION_ID);
    
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  
    GENERATE_FILE;
  
    -- conc end body
    -- concurrent footer log
    XXFND_DEBUG2.STOP_PROFILER;
    XXFND_CONC_UTL.LOG_FOOTER;
  
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      XXFND_CONC_UTL.LOG_MESSAGE_LIST;
      RETCODE := '1';
      FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => FND_API.G_FALSE,
                                P_COUNT   => L_MSG_COUNT,
                                P_DATA    => L_MSG_DATA);
      IF L_MSG_COUNT > 1 THEN
        L_MSG_DATA := FND_MSG_PUB.GET_DETAIL(P_MSG_INDEX => FND_MSG_PUB.G_FIRST,
                                             P_ENCODED   => FND_API.G_FALSE);
      END IF;
      ERRBUF := L_MSG_DATA;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      XXFND_CONC_UTL.LOG_MESSAGE_LIST;
      RETCODE := '2';
      FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => FND_API.G_FALSE,
                                P_COUNT   => L_MSG_COUNT,
                                P_DATA    => L_MSG_DATA);
      IF L_MSG_COUNT > 1 THEN
        L_MSG_DATA := FND_MSG_PUB.GET_DETAIL(P_MSG_INDEX => FND_MSG_PUB.G_FIRST,
                                             P_ENCODED   => FND_API.G_FALSE);
      END IF;
      ERRBUF := L_MSG_DATA;
    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG(P_PKG_NAME       => G_PKG_NAME,
                              P_PROCEDURE_NAME => 'MAIN',
                              P_ERROR_TEXT     => SUBSTRB(SQLERRM, 1, 240));
      XXFND_CONC_UTL.LOG_MESSAGE_LIST;
      RETCODE := '2';
      ERRBUF  := SQLERRM;
  END MAIN;

END XXPA_COST_EXPORT_GCPM_PKG2;
/
