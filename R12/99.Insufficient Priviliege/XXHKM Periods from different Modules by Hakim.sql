SELECT * FROM APPS.GL_SETS_OF_BOOKS SOB WHERE 1 = 1;

--Doc ID 552244.1
--------GL���ɹ������ʻ����),Ӧ�գ�Ӧ�����ʲ�
SELECT P.APPLICATION_NAME       APPL_NAME,
       P.APPLICATION_ID         APP_ID,
       P.APPLICATION_SHORT_NAME APP_SHORT,
       SOB.DESCRIPTION,
       P.BASEPATH,
       T.SET_OF_BOOKS_ID,
       T.PERIOD_NAME,
       T.CLOSING_STATUS,
       GLPS.SHOW_STATUS,
       T.START_DATE,
       T.END_DATE,
       T.LAST_UPDATE_DATE,
       T.LAST_UPDATED_BY /*,
       99999999999,
       p.**/
--glps.*
  FROM GL.GL_PERIOD_STATUSES             T,
       APPS.FND_APPLICATION_VL           P,
       APPS.GL_LOOKUPS_PERIOD_STATUSES_V GLPS,
       APPS.GL_SETS_OF_BOOKS             SOB
 WHERE T.APPLICATION_ID = P.APPLICATION_ID
   AND T.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
   AND GLPS.STATUS_FLAG = T.CLOSING_STATUS
      --AND p.application_id = 222
      and t.set_of_books_id=2035--'2026'
      --AND t.period_name = 'APR-18'
   AND T.START_DATE = TO_DATE('2018-09-01', 'yyyy-mm-dd')
      --AND t.set_of_books_id = 2023--2021--2041--2021
   --AND P.APPLICATION_SHORT_NAME IN ('AR')
 ORDER BY T.APPLICATION_ID ASC, T.START_DATE ASC;

SELECT SET_OF_BOOKS_ID,
       PERIOD_NAME,
       DECODE(CLOSING_STATUS,
              'O',
              'Open',
              'C',
              'Closed',
              'F',
              'Future',
              'N',
              'Never',
              CLOSING_STATUS) GL_STATUS,
       START_DATE,
       END_DATE
  FROM GL_PERIOD_STATUSES
 WHERE TRUNC(START_DATE) > SYSDATE - 40 --adjust date as needed
   AND TRUNC(START_DATE) < SYSDATE + 1
   AND APPLICATION_ID = 101
 ORDER BY APPLICATION_ID, START_DATE DESC;

SELECT * FROM APPS.FND_APPLICATION FA WHERE FA.APPLICATION_ID = 101;

--PO Period
SELECT SET_OF_BOOKS_ID,
       APPLICATION_ID,
       PERIOD_NAME,
       DECODE(CLOSING_STATUS,
              'O',
              'Open',
              'C',
              'Closed',
              'F',
              'Future',
              'N',
              'Never',
              CLOSING_STATUS) PO_STATUS,
       START_DATE,
       END_DATE
  FROM APPS.GL_PERIOD_STATUSES
 WHERE 1 = 1
   --AND TRUNC(START_DATE) > SYSDATE - 40 --adjust date as needed
   --AND TRUNC(START_DATE) < SYSDATE + 1
   AND start_date = to_date('2018-11-01','yyyy-mm-dd')
   AND APPLICATION_ID = 201
 ORDER BY APPLICATION_ID, START_DATE DESC;

--INV
SELECT OAP.ORGANIZATION_ID "Organization ID",
       MP.ORGANIZATION_CODE "Organization Code",
       OAP.PERIOD_NAME "Period Name",
       OAP.PERIOD_START_DATE "Start Date",
       OAP.PERIOD_CLOSE_DATE "Closed Date",
       DECODE(OAP.OPEN_FLAG,
              'P',
              'P - Period Close is processing',
              'N',
              'N - Period Close process is completed',
              'Y',
              'Y - Period is open if Closed Date is NULL',
              'Unknown') "Period Status"
  FROM APPS.ORG_ACCT_PERIODS OAP, APPS.MTL_PARAMETERS MP
 WHERE OAP.ORGANIZATION_ID = MP.ORGANIZATION_ID
      --AND trunc(period_start_date) > SYSDATE - 40 --adjust date as needed
      --AND trunc(period_start_date) < SYSDATE + 1
   AND OAP.PERIOD_START_DATE = TO_DATE('2018-10-01', 'yyyy-mm-dd')
 ORDER BY OAP.ORGANIZATION_ID, OAP.PERIOD_START_DATE;

----------������ڼ䣭����������

SELECT OAP.ORGANIZATION_ID,
       OAP.PERIOD_NAME,
       OAP.PERIOD_SET_NAME,
       OAP.ACCT_PERIOD_ID,
       OAP.STATUS
  FROM ORG_ACCT_PERIODS_V OAP
 WHERE OAP.ORGANIZATION_ID != 0
   AND OAP.ORGANIZATION_ID = 86 --83
   AND OAP.START_DATE = TO_DATE('2018-09-01', 'yyyy-mm-dd')
--and oap.period_name=--'MAR-18'
 ORDER BY OAP.ORGANIZATION_ID, OAP.START_DATE;

--------------����--------

SELECT * FROM GL_PERIOD_SETS;

---------�ɱ��ڼ䣭������������������

SELECT * FROM GMF_CALENDAR_ASSIGNMENTS; ---�ڼ����

SELECT * FROM CM_CLDR_DTL; ---�ڼ���ϸ

SELECT * FROM GL.GL_LEDGER_CONFIG_DETAILS; ---- ����ʵ��

SELECT * FROM apps.GMF_PERIOD_STATUSES P WHERE P.PERIOD_CODE = '04-10'; ---�ڼ�״̬

SELECT * FROM ORG_ORGANIZATION_DEFINITIONS OOD;
SELECT *
  FROM FND_APPLICATION FA
 WHERE 1 = 1
   AND FA.APPLICATION_ID = 201;

--GL & PO
SELECT SOB.NAME "Set of Books",
       FND.PRODUCT_CODE "Porduct Code",
       PS.PERIOD_NAME "Period Name",
       PS.START_DATE "Period Start Date",
       PS.END_DATE "Period End Date",
       DECODE(PS.CLOSING_STATUS,
              'O',
              'O - Open',
              'N',
              'N - Never Opened',
              'F',
              'F - Future Enterable',
              'C',
              'C - Closed',
              'Unknown') "Period Status"
  FROM GL_PERIOD_STATUSES PS, GL_SETS_OF_BOOKS SOB, FND_APPLICATION_VL FND
 WHERE PS.APPLICATION_ID IN (101, 201) -- GL & PO
   AND SOB.SET_OF_BOOKS_ID = PS.SET_OF_BOOKS_ID
   AND FND.APPLICATION_ID = PS.APPLICATION_ID
   AND PS.ADJUSTMENT_PERIOD_FLAG = 'N'
   AND (TRUNC(SYSDATE - 30) -- Comment line if a a date other than SYSDATE is being tested.
       --AND ('01-APR-2011' -- Uncomment line if a date other than SYSDATE is being tested.
       BETWEEN TRUNC(PS.START_DATE) AND TRUNC(PS.END_DATE))
 ORDER BY PS.SET_OF_BOOKS_ID, FND.PRODUCT_CODE, PS.START_DATE;

--INV
SELECT MP.ORGANIZATION_ID "Organization ID",
       MP.ORGANIZATION_CODE "Organization Code",
       OOD.ORGANIZATION_NAME "Organization Name",
       OAP.PERIOD_NAME "Period Name",
       OAP.PERIOD_START_DATE "Start Date",
       OAP.PERIOD_CLOSE_DATE "Closed Date",
       OAP.SCHEDULE_CLOSE_DATE "Scheduled Close",
       DECODE(OAP.OPEN_FLAG,
              'P',
              'P - Period Close is processing',
              'N',
              'N - Period Close process is completed',
              'Y',
              'Y - Period is open if Closed Date is NULL',
              'Unknown') "Period Status"
  FROM ORG_ACCT_PERIODS             OAP,
       ORG_ORGANIZATION_DEFINITIONS OOD,
       MTL_PARAMETERS               MP
 WHERE OAP.ORGANIZATION_ID = MP.ORGANIZATION_ID
   AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID(+)
   AND (TRUNC(SYSDATE - 30) -- Comment line if a a date other than SYSDATE is being tested.
       --AND ('01-APR-2011' -- Uncomment line if a date other than SYSDATE is being tested.
       BETWEEN TRUNC(OAP.PERIOD_START_DATE) AND
       TRUNC(OAP.SCHEDULE_CLOSE_DATE))
 ORDER BY MP.ORGANIZATION_ID, OAP.PERIOD_START_DATE;

--The reason Organization Name may return NULL is that ORG_ORGANIZATION_DEFINITIONS (OOD) is a View which uses the View HR_ORGANIZATION_UNITS whose HR Security settings may prevent ODD from returning data.

/*���ڼ��ģ�飺GL��AP��AR��FA��INV��PO��PA��AGIS
��Ӧ��׼·��
GL��    ����-����-��/�ر�
AP��    Ӧ��-��ƿ�Ŀ-����Ӧ�����ڼ�
AR��    Ӧ��-����-��ƿ�Ŀ-��/�ر��ڼ�
FA��    �ʲ�-�۾�-�����۾�
INV��  ���-��ƹر�����-�������
       Inventory->Accounting Close Cycle
PO��   �ɹ�����->����->����ϵͳ->���->�򿪺͹ر��ڼ�
PA��    PA->Setup->System->PA Periods/GL Periods
AGIS������-�ڼ�-��/�ر�

TIPS
   PA��PO��INV��AP��AR���ڼ���GL��������PA���Զ�ͬ��
   ap�ڼ�򿪱���gl��po�ڼ��
   inv��fa�ڼ�رպ������ٴ�
  agis�ڼ�����������أ�ÿ���������������ڼ�Ŀ���

20150617 ����
    ���ڼ��ģ�飺AGIS
    ��Ӧ�ı�׼·����AGIS������-�ڼ�-��/�ر�
    ע��AGIS�ڼ�����������أ�ÿ���������������ڼ�Ŀ���
20151124 ����
    һ����ڼ�˳�򣺲ɹ�-���-��Ŀ-�ʲ�-Ӧ��-Ӧ��-����
                             AP��PO��FA��AR/INV��GL
    ʹ��PACһ����ڼ�˳��AP��PO��FA/AR��INV��PAC��GL*/
