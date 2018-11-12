/*
refer to 
https://www.cnblogs.com/toowang/p/3873172.html
�ڴ˼�¼һ���Լ�ѧϰ���̡����֣�����ָ�̣�лл��     
     ����ͻ��������ҳ���Ӧ�̶�Ӧ��������Ϣ���鿴�����������ӣ����ֶ��Ǵӹ�Ӧ�̼���Ӧ�̵ص�㷢��ȥ���Ҷ�Ӧ��������Ϣ�����ǣ���Ӧ��ά�����н��湲���ĸ��㼶������Ϊ����Ӧ�̣�
��ַ����ַ-ҵ��ʵ�壬�ص�  �ĸ��㼶�ֱ���Թ��������˻����ҽ�Ϸ�Ʊ����̨�͸����̨���棬 ����¼�빩Ӧ�̡�ҵ��ʵ�塢�ص�֮�󣬻��Զ�������Ӧ�������˻������Դ˴��ĸ��㼶�в��ҡ�
���н��IBY_EXTERNAL_PAYEES_ALL ��������˾����������������ĸ��㼶�������е� �ؼ��㣬����������֣��ҳ���Ӧ���ĸ��㼶����������������Ϣ��
*/
/*
-- EMPLOYEE
SELECT ASP.VENDOR_ID                   AS ��Ӧ��ID,
       ASP.VENDOR_NAME                 AS ��Ӧ������,
       ASP.SEGMENT1                    AS ��Ӧ�̱��,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS ��Ӧ������,
       ASP.START_DATE_ACTIVE           AS ��Ӧ����ʼ����,
       ASP.ENABLED_FLAG                AS ��Ӧ�����ñ�ʶ,
       ASP.END_DATE_ACTIVE             AS ��Ӧ����ֹ����,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS ����,
       IEB.BANK_BRANCH_NAME            AS ����,
       IEB.BRANCH_PARTY_ID             AS ����ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS �����˻�,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS �˻���Ҫ������ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS �˻���Ҫ������,
       
       IAO.END_DATE     AS �˻���������ֹ����,
       IAO.PRIMARY_FLAG AS �˻���Ҫ�����˱�ʶ,
       
       IEB.START_DATE AS ������ʼ����,
       IEB.END_DATE AS ������ֹ����,
       (SELECT T.START_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ʼ����,
       (SELECT T.END_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ֹ����,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       
       IEP.PARTY_SITE_ID,
       NULL              AS ��ַ����,
       NULL              AS ��ַ�Ƿ���Ч,
       
       ASS.ORG_ID AS ҵ��ʵ��ID,
       (SELECT T.DESCRIPTION
          FROM apps.FND_FLEX_VALUES_VL T, apps.FND_FLEX_VALUE_SETS S
         WHERE 1 = 1
           AND T.FLEX_VALUE_SET_ID = S.FLEX_VALUE_SET_ID
           AND S.FLEX_VALUE_SET_NAME = 'XXX-COMPANY'
           AND T.FLEX_VALUE =
               (SELECT SUBSTR(HOU.SHORT_CODE, 4)
                  FROM apps.HR_OPERATING_UNITS HOU
                 WHERE HOU.ORGANIZATION_ID = ASS.ORG_ID)
           AND T.ENABLED_FLAG = 'Y'
           AND SYSDATE < NVL(T.END_DATE_ACTIVE, SYSDATE + 1)) AS ҵ��ʵ������,
       (SELECT HOU.DATE_FROM
          FROM apps.HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = ASS.ORG_ID) AS ҵ��ʵ����Ч����,
       (SELECT HOU.DATE_TO
          FROM apps.HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = ASS.ORG_ID) AS ҵ��ʵ��ʧЧ����,
       
       ASS.VENDOR_SITE_ID,
       ASS.VENDOR_SITE_CODE AS �ص�����,
       ASS.INACTIVE_DATE    AS �ص�ʧЧ����,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS �����˻���ʼ����,
       USES.END_DATE                  AS �����˻���ֹ����

  FROM apps.AP_SUPPLIERS            ASP,
       apps.IBY_EXT_BANK_ACCOUNTS_V IEB,
       apps.IBY_EXTERNAL_PAYEES_ALL IEP,
       apps.IBY_PMT_INSTR_USES_ALL  USES,
       apps.IBY_ACCOUNT_OWNERS      IAO,
       apps.AP_SUPPLIER_SITES_ALL   ASS
 WHERE 1 = 1
   AND IEP.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
   AND IEP.PAYMENT_FUNCTION = 'PAYABLES_DISB'
   AND USES.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID
   AND IEP.PAYEE_PARTY_ID = ASP.PARTY_ID
   AND IEP.PARTY_SITE_ID IS NULL
   AND IEP.SUPPLIER_SITE_ID IS NULL
   AND IEP.ORG_ID IS NULL
   --AND ASP.VENDOR_TYPE_LOOKUP_CODE = 'EMPLOYEE'
   AND ASS.VENDOR_ID = ASP.VENDOR_ID
   AND USES.INSTRUMENT_TYPE = 'BANKACCOUNT'
   AND IAO.ACCOUNT_OWNER_PARTY_ID = ASP.PARTY_ID
   AND IAO.EXT_BANK_ACCOUNT_ID(+) = IEB.EXT_BANK_ACCOUNT_ID
   --AND ASP.VENDOR_NAME LIKE '%��������Ͷ����ѯ���޹�˾%'--= '&VENDOR_NAME'
   AND ASP.SEGMENT1 = 'MDM_106271088'

UNION ALL*/
--VENDOR
--��һ�㣨��Ӧ�̹������У�
SELECT ASP.VENDOR_ID                   AS ��Ӧ��ID,
       ASP.VENDOR_NAME                 AS ��Ӧ������,
       ASP.SEGMENT1                    AS ��Ӧ�̱��,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS ��Ӧ������,
       ASP.START_DATE_ACTIVE           AS ��Ӧ����ʼ����,
       ASP.ENABLED_FLAG                AS ��Ӧ�����ñ�ʶ,
       ASP.END_DATE_ACTIVE             AS ��Ӧ����ֹ����,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS ����,
       IEB.BANK_BRANCH_NAME            AS ����,
       IEB.BRANCH_PARTY_ID             AS ����ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS �����˻�,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS �˻���Ҫ������ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS �˻���Ҫ������,
       
       IAO.END_DATE     AS �˻���������ֹ����,
       IAO.PRIMARY_FLAG AS �˻���Ҫ�����˱�ʶ,
       
       IEB.START_DATE AS ������ʼ����,
       IEB.END_DATE AS ������ֹ����,
       (SELECT T.START_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ʼ����,
       (SELECT T.END_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ֹ����,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       
       IEP.PARTY_SITE_ID,
       NULL              AS ��ַ����,
       NULL              AS ��ַ�Ƿ���Ч,
       
       IEP.ORG_ID AS ҵ��ʵ��ID,
       NULL       AS ҵ��ʵ������,
       NULL       AS ҵ��ʵ����Ч����,
       NULL       AS ҵ��ʵ��ʧЧ����,
       
       IEP.SUPPLIER_SITE_ID,
       NULL,
       NULL,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS �����˻���ʼ����,
       USES.END_DATE                  AS �����˻���ֹ����

  FROM apps.AP_SUPPLIERS            ASP,
       apps.IBY_EXT_BANK_ACCOUNTS_V IEB,
       apps.IBY_EXTERNAL_PAYEES_ALL IEP,
       apps.IBY_ACCOUNT_OWNERS      IAO,
       apps.IBY_PMT_INSTR_USES_ALL  USES
 WHERE 1 = 1
   AND IEP.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
   AND IEP.PAYMENT_FUNCTION = 'PAYABLES_DISB'
   AND USES.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID
   AND IEP.PAYEE_PARTY_ID = ASP.PARTY_ID
   AND IEP.PARTY_SITE_ID IS NULL
   AND IEP.SUPPLIER_SITE_ID IS NULL
   AND IEP.ORG_ID IS NULL
   AND ASP.VENDOR_TYPE_LOOKUP_CODE = 'VENDOR'
   AND USES.INSTRUMENT_TYPE = 'BANKACCOUNT'
   AND IAO.ACCOUNT_OWNER_PARTY_ID = ASP.PARTY_ID
   AND IAO.EXT_BANK_ACCOUNT_ID(+) = IEB.EXT_BANK_ACCOUNT_ID
      
   --AND ASP.VENDOR_NAME = '&VENDOR_NAME'
   AND asp.segment1 = 'MDM_106271088'
/*
UNION ALL

--�ڶ��㣨��ַ�������У�
SELECT ASP.VENDOR_ID   AS ��Ӧ��ID,
       ASP.VENDOR_NAME AS ��Ӧ������,
       
       ASP.SEGMENT1                    AS ��Ӧ�̱��,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS ��Ӧ������,
       ASP.START_DATE_ACTIVE           AS ��Ӧ����ʼ����,
       ASP.ENABLED_FLAG                AS ��Ӧ�����ñ�ʶ,
       ASP.END_DATE_ACTIVE             AS ��Ӧ����ֹ����,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS ����,
       IEB.BANK_BRANCH_NAME            AS ����,
       IEB.BRANCH_PARTY_ID             AS ����ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS �����˻�,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS �˻���Ҫ������ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS �˻���Ҫ������,
       
       IAO.END_DATE     AS �˻���������ֹ����,
       IAO.PRIMARY_FLAG AS �˻���Ҫ�����˱�ʶ,
       
       IEB.START_DATE AS ������ʼ����,
       IEB.END_DATE AS ������ֹ����,
       (SELECT T.START_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ʼ����,
       (SELECT T.END_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ֹ����,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       
       IEP.PARTY_SITE_ID,
       (SELECT HPS.PARTY_SITE_NAME
          FROM HZ_PARTY_SITES HPS
         WHERE IEP.PARTY_SITE_ID = HPS.PARTY_SITE_ID
              --AND HPS.STATUS='A'
           AND EXISTS
         (SELECT 1
                  FROM HZ_PARTY_SITES     HPS,
                       HZ_PARTY_SITE_USES PURCHASE,
                       HZ_PARTY_SITE_USES PAY
                 WHERE HPS.PARTY_SITE_ID = PURCHASE.PARTY_SITE_ID
                   AND HPS.PARTY_SITE_ID = PAY.PARTY_SITE_ID
                   AND PURCHASE.SITE_USE_TYPE = 'PURCHASING'
                   AND PAY.SITE_USE_TYPE = 'PAY')) AS ��ַ����,
       DECODE((SELECT HPS.STATUS
                FROM HZ_PARTY_SITES HPS
               WHERE IEP.PARTY_SITE_ID = HPS.PARTY_SITE_ID
                    --AND HPS.STATUS='A'
                 AND EXISTS
               (SELECT 1
                        FROM HZ_PARTY_SITES     HPS,
                             HZ_PARTY_SITE_USES PURCHASE,
                             HZ_PARTY_SITE_USES PAY
                       WHERE HPS.PARTY_SITE_ID = PURCHASE.PARTY_SITE_ID
                         AND HPS.PARTY_SITE_ID = PAY.PARTY_SITE_ID
                         AND PURCHASE.SITE_USE_TYPE = 'PURCHASING'
                         AND PAY.SITE_USE_TYPE = 'PAY')),
              'A',
              '��Ч',
              '��Ч') AS ��ַ�Ƿ���Ч,
       
       IEP.ORG_ID,
       NULL       AS ҵ��ʵ��,
       NULL       AS ҵ��ʵ����Ч����,
       NULL       AS ҵ��ʵ��ʧЧ����,
       
       IEP.SUPPLIER_SITE_ID,
       NULL,
       NULL,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS �����˻���ʼ����,
       USES.END_DATE                  AS �����˻���ֹ����

  FROM AP_SUPPLIERS            ASP,
       IBY_EXT_BANK_ACCOUNTS_V IEB,
       IBY_EXTERNAL_PAYEES_ALL IEP,
       IBY_ACCOUNT_OWNERS      IAO,
       IBY_PMT_INSTR_USES_ALL  USES

 WHERE 1 = 1
   AND IEP.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
   AND IEP.PAYMENT_FUNCTION = 'PAYABLES_DISB'
   AND USES.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID
   AND IEP.PAYEE_PARTY_ID = ASP.PARTY_ID
   AND IEP.PARTY_SITE_ID IS NOT NULL
   AND IEP.SUPPLIER_SITE_ID IS NULL
   AND IEP.ORG_ID IS NULL
   AND ASP.VENDOR_TYPE_LOOKUP_CODE = 'VENDOR'
   AND USES.INSTRUMENT_TYPE = 'BANKACCOUNT'
   AND IAO.ACCOUNT_OWNER_PARTY_ID = ASP.PARTY_ID
   AND IAO.EXT_BANK_ACCOUNT_ID(+) = IEB.EXT_BANK_ACCOUNT_ID
   AND ASP.VENDOR_NAME = '&VENDOR_NAME'

UNION ALL

--�����㣨��ַ-ҵ��ʵ��������У�
SELECT ASP.VENDOR_ID   AS ��Ӧ��ID,
       ASP.VENDOR_NAME AS ��Ӧ������,
       
       ASP.SEGMENT1                    AS ��Ӧ�̱��,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS ��Ӧ������,
       ASP.START_DATE_ACTIVE           AS ��Ӧ����ʼ����,
       ASP.ENABLED_FLAG                AS ��Ӧ�����ñ�ʶ,
       ASP.END_DATE_ACTIVE             AS ��Ӧ����ֹ����,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS ����,
       IEB.BANK_BRANCH_NAME            AS ����,
       IEB.BRANCH_PARTY_ID             AS ����ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS �����˻�,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS �˻���Ҫ������ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS �˻���Ҫ������,
       
       IAO.END_DATE     AS �˻���������ֹ����,
       IAO.PRIMARY_FLAG AS �˻���Ҫ�����˱�ʶ,
       
       IEB.START_DATE AS ������ʼ����,
       IEB.END_DATE AS ������ֹ����,
       (SELECT T.START_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ʼ����,
       (SELECT T.END_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ֹ����,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       
       IEP.PARTY_SITE_ID,
       (SELECT HPS.PARTY_SITE_NAME
          FROM HZ_PARTY_SITES HPS
         WHERE IEP.PARTY_SITE_ID = HPS.PARTY_SITE_ID
              --AND HPS.STATUS='A'
           AND EXISTS
         (SELECT 1
                  FROM HZ_PARTY_SITES     HPS,
                       HZ_PARTY_SITE_USES PURCHASE,
                       HZ_PARTY_SITE_USES PAY
                 WHERE HPS.PARTY_SITE_ID = PURCHASE.PARTY_SITE_ID
                   AND HPS.PARTY_SITE_ID = PAY.PARTY_SITE_ID
                   AND PURCHASE.SITE_USE_TYPE = 'PURCHASING'
                   AND PAY.SITE_USE_TYPE = 'PAY')) AS ��ַ����,
       DECODE((SELECT HPS.STATUS
                FROM HZ_PARTY_SITES HPS
               WHERE IEP.PARTY_SITE_ID = HPS.PARTY_SITE_ID
                    --AND HPS.STATUS='A'
                 AND EXISTS
               (SELECT 1
                        FROM HZ_PARTY_SITES     HPS,
                             HZ_PARTY_SITE_USES PURCHASE,
                             HZ_PARTY_SITE_USES PAY
                       WHERE HPS.PARTY_SITE_ID = PURCHASE.PARTY_SITE_ID
                         AND HPS.PARTY_SITE_ID = PAY.PARTY_SITE_ID
                         AND PURCHASE.SITE_USE_TYPE = 'PURCHASING'
                         AND PAY.SITE_USE_TYPE = 'PAY')),
              'A',
              '��Ч',
              '��Ч') AS ��ַ�Ƿ���Ч,
       
       IEP.ORG_ID,
       (SELECT TRIM(SUBSTR(HOU.NAME, 4))
           FROM HR_ORGANIZATION_UNITS HOU
          WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID)
       --AND SYSDATE BETWEEN NVL(HOU.DATE_FROM,SYSDATE-1) AND NVL(HOU.DATE_TO,SYSDATE+1)
        AS ҵ��ʵ��,
       (SELECT HOU.DATE_FROM
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS ҵ��ʵ����Ч����,
       (SELECT HOU.DATE_TO
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS ҵ��ʵ��ʧЧ����,
       
       IEP.SUPPLIER_SITE_ID,
       NULL                 AS �ص�,
       NULL                 AS �ص�ʧЧ����,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS �����˻���ʼ����,
       USES.END_DATE                  AS �����˻���ֹ����

  FROM AP_SUPPLIERS            ASP,
       IBY_EXT_BANK_ACCOUNTS_V IEB,
       IBY_EXTERNAL_PAYEES_ALL IEP,
       IBY_ACCOUNT_OWNERS      IAO,
       IBY_PMT_INSTR_USES_ALL  USES

 WHERE 1 = 1
   AND IEP.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
   AND IEP.PAYMENT_FUNCTION = 'PAYABLES_DISB'
   AND USES.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID
   AND IEP.PAYEE_PARTY_ID = ASP.PARTY_ID
   AND IEP.PARTY_SITE_ID IS NOT NULL
   AND IEP.SUPPLIER_SITE_ID IS NULL
   AND IEP.ORG_ID IS NOT NULL
   AND USES.INSTRUMENT_TYPE = 'BANKACCOUNT'
   AND ASP.VENDOR_TYPE_LOOKUP_CODE = 'VENDOR'
   AND IAO.ACCOUNT_OWNER_PARTY_ID = ASP.PARTY_ID
   AND IAO.EXT_BANK_ACCOUNT_ID(+) = IEB.EXT_BANK_ACCOUNT_ID
      
   AND ASP.VENDOR_NAME = '&VENDOR_NAME'

UNION ALL

--���Ĳ㣨�ص�������У�
SELECT ASP.VENDOR_ID   AS ��Ӧ��ID,
       ASP.VENDOR_NAME AS ��Ӧ������,
       
       ASP.SEGMENT1                    AS ��Ӧ�̱��,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS ��Ӧ������,
       ASP.START_DATE_ACTIVE           AS ��Ӧ����ʼ����,
       ASP.ENABLED_FLAG                AS ��Ӧ�����ñ�ʶ,
       ASP.END_DATE_ACTIVE             AS ��Ӧ����ֹ����,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS ����,
       IEB.BANK_BRANCH_NAME            AS ����,
       IEB.BRANCH_PARTY_ID             AS ����ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS �����˻�,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS �˻���Ҫ������ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS �˻���Ҫ������,
       
       IAO.END_DATE     AS �˻���������ֹ����,
       IAO.PRIMARY_FLAG AS �˻���Ҫ�����˱�ʶ,
       
       IEB.START_DATE AS ������ʼ����,
       IEB.END_DATE AS ������ֹ����,
       (SELECT T.START_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ʼ����,
       (SELECT T.END_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS ������ֹ����,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       IEP.PARTY_SITE_ID,
       (SELECT HPS.PARTY_SITE_NAME
          FROM HZ_PARTY_SITES HPS
         WHERE IEP.PARTY_SITE_ID = HPS.PARTY_SITE_ID
              --AND HPS.STATUS='A'
           AND EXISTS
         (SELECT 1
                  FROM HZ_PARTY_SITES     HPS,
                       HZ_PARTY_SITE_USES PURCHASE,
                       HZ_PARTY_SITE_USES PAY
                 WHERE HPS.PARTY_SITE_ID = PURCHASE.PARTY_SITE_ID
                   AND HPS.PARTY_SITE_ID = PAY.PARTY_SITE_ID
                   AND PURCHASE.SITE_USE_TYPE = 'PURCHASING'
                   AND PAY.SITE_USE_TYPE = 'PAY')) AS ��ַ����,
       DECODE((SELECT HPS.STATUS
                FROM HZ_PARTY_SITES HPS
               WHERE IEP.PARTY_SITE_ID = HPS.PARTY_SITE_ID
                    --AND HPS.STATUS='A'
                 AND EXISTS
               (SELECT 1
                        FROM HZ_PARTY_SITES     HPS,
                             HZ_PARTY_SITE_USES PURCHASE,
                             HZ_PARTY_SITE_USES PAY
                       WHERE HPS.PARTY_SITE_ID = PURCHASE.PARTY_SITE_ID
                         AND HPS.PARTY_SITE_ID = PAY.PARTY_SITE_ID
                         AND PURCHASE.SITE_USE_TYPE = 'PURCHASING'
                         AND PAY.SITE_USE_TYPE = 'PAY')),
              'A',
              '��Ч',
              '��Ч') AS ��ַ�Ƿ���Ч,
       
       IEP.ORG_ID,
       (SELECT TRIM(SUBSTR(HOU.NAME, 4))
           FROM HR_ORGANIZATION_UNITS HOU
          WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID)
       --AND SYSDATE BETWEEN NVL(HOU.DATE_FROM,SYSDATE-1) AND NVL(HOU.DATE_TO,SYSDATE+1)
        AS ҵ��ʵ��,
       (SELECT HOU.DATE_FROM
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS ҵ��ʵ����Ч����,
       (SELECT HOU.DATE_TO
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS ҵ��ʵ��ʧЧ����,
       
       IEP.SUPPLIER_SITE_ID,
       (SELECT ASS.VENDOR_SITE_CODE
          FROM AP_SUPPLIER_SITES_ALL ASS
         WHERE ASS.VENDOR_SITE_ID = IEP.SUPPLIER_SITE_ID
           AND ASS.PURCHASING_SITE_FLAG = 'Y'
           AND ASS.PAY_SITE_FLAG = 'Y') AS �ص�,
       (SELECT ASS.INACTIVE_DATE
          FROM AP_SUPPLIER_SITES_ALL ASS
         WHERE ASS.VENDOR_SITE_ID = IEP.SUPPLIER_SITE_ID
           AND ASS.PURCHASING_SITE_FLAG = 'Y'
           AND ASS.PAY_SITE_FLAG = 'Y') AS �ص�ʧЧ����,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS �����˻���ʼ����,
       USES.END_DATE                  AS �����˻���ֹ����

  FROM AP_SUPPLIERS            ASP,
       IBY_EXT_BANK_ACCOUNTS_V IEB,
       IBY_EXTERNAL_PAYEES_ALL IEP,
       IBY_ACCOUNT_OWNERS      IAO,
       IBY_PMT_INSTR_USES_ALL  USES

 WHERE 1 = 1
   AND ASP.VENDOR_TYPE_LOOKUP_CODE = 'VENDOR'
      
   AND IEP.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
   AND IEP.PAYMENT_FUNCTION = 'PAYABLES_DISB'
   AND USES.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID
   AND IEP.PAYEE_PARTY_ID = ASP.PARTY_ID
   AND IEP.PARTY_SITE_ID IS NOT NULL
   AND IEP.SUPPLIER_SITE_ID IS NOT NULL
   AND IEP.ORG_ID IS NOT NULL
   AND USES.INSTRUMENT_TYPE = 'BANKACCOUNT'
   AND IAO.ACCOUNT_OWNER_PARTY_ID = ASP.PARTY_ID
   AND IAO.EXT_BANK_ACCOUNT_ID(+) = IEB.EXT_BANK_ACCOUNT_ID
      
   AND ASP.VENDOR_NAME = '&VENDOR_NAME';
*/
