/*
refer to 
https://www.cnblogs.com/toowang/p/3873172.html
在此记录一下自己学习过程。新手，请多多指教，谢谢。     
     最近客户有需求，找出供应商对应的银行信息，查看了下网上帖子，发现都是从供应商及供应商地点层发起，去查找对应的银行信息，但是，供应商维护银行界面共有四个层级，依次为：供应商，
地址，地址-业务实体，地点  四个层级分别可以关联银行账户，且结合发票工作台和付款工作台界面， 其在录入供应商、业务实体、地点之后，会自动带出对应的银行账户，且以此从四个层级中查找。
，有结合IBY_EXTERNAL_PAYEES_ALL 这个表，个人觉得这个表才是真正四个层级关联银行的 关键点，从这个表入手，找出供应商四个层级关联的所有银行信息。
*/
/*
-- EMPLOYEE
SELECT ASP.VENDOR_ID                   AS 供应商ID,
       ASP.VENDOR_NAME                 AS 供应商名称,
       ASP.SEGMENT1                    AS 供应商编号,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS 供应商类型,
       ASP.START_DATE_ACTIVE           AS 供应商起始日期,
       ASP.ENABLED_FLAG                AS 供应商启用标识,
       ASP.END_DATE_ACTIVE             AS 供应商终止日期,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS 银行,
       IEB.BANK_BRANCH_NAME            AS 分行,
       IEB.BRANCH_PARTY_ID             AS 分行ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS 银行账户,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS 账户主要责任人ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS 账户主要责任人,
       
       IAO.END_DATE     AS 账户责任人终止日期,
       IAO.PRIMARY_FLAG AS 账户主要责任人标识,
       
       IEB.START_DATE AS 银行起始日期,
       IEB.END_DATE AS 银行终止日期,
       (SELECT T.START_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行起始日期,
       (SELECT T.END_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行终止日期,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       
       IEP.PARTY_SITE_ID,
       NULL              AS 地址名称,
       NULL              AS 地址是否有效,
       
       ASS.ORG_ID AS 业务实体ID,
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
           AND SYSDATE < NVL(T.END_DATE_ACTIVE, SYSDATE + 1)) AS 业务实体名称,
       (SELECT HOU.DATE_FROM
          FROM apps.HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = ASS.ORG_ID) AS 业务实体生效日期,
       (SELECT HOU.DATE_TO
          FROM apps.HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = ASS.ORG_ID) AS 业务实体失效日期,
       
       ASS.VENDOR_SITE_ID,
       ASS.VENDOR_SITE_CODE AS 地点名称,
       ASS.INACTIVE_DATE    AS 地点失效日期,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS 银行账户起始日期,
       USES.END_DATE                  AS 银行账户终止日期

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
   --AND ASP.VENDOR_NAME LIKE '%宁波国际投资咨询有限公司%'--= '&VENDOR_NAME'
   AND ASP.SEGMENT1 = 'MDM_106271088'

UNION ALL*/
--VENDOR
--第一层（供应商关联银行）
SELECT ASP.VENDOR_ID                   AS 供应商ID,
       ASP.VENDOR_NAME                 AS 供应商名称,
       ASP.SEGMENT1                    AS 供应商编号,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS 供应商类型,
       ASP.START_DATE_ACTIVE           AS 供应商起始日期,
       ASP.ENABLED_FLAG                AS 供应商启用标识,
       ASP.END_DATE_ACTIVE             AS 供应商终止日期,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS 银行,
       IEB.BANK_BRANCH_NAME            AS 分行,
       IEB.BRANCH_PARTY_ID             AS 分行ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS 银行账户,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS 账户主要责任人ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS 账户主要责任人,
       
       IAO.END_DATE     AS 账户责任人终止日期,
       IAO.PRIMARY_FLAG AS 账户主要责任人标识,
       
       IEB.START_DATE AS 银行起始日期,
       IEB.END_DATE AS 银行终止日期,
       (SELECT T.START_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行起始日期,
       (SELECT T.END_DATE
          FROM apps.IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行终止日期,
       
       IEP.PAYEE_PARTY_ID,
       IEP.PAYMENT_FUNCTION,
       
       IEP.PARTY_SITE_ID,
       NULL              AS 地址名称,
       NULL              AS 地址是否有效,
       
       IEP.ORG_ID AS 业务实体ID,
       NULL       AS 业务实体名称,
       NULL       AS 业务实体生效日期,
       NULL       AS 业务实体失效日期,
       
       IEP.SUPPLIER_SITE_ID,
       NULL,
       NULL,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS 银行账户起始日期,
       USES.END_DATE                  AS 银行账户终止日期

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

--第二层（地址关联银行）
SELECT ASP.VENDOR_ID   AS 供应商ID,
       ASP.VENDOR_NAME AS 供应商名称,
       
       ASP.SEGMENT1                    AS 供应商编号,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS 供应商类型,
       ASP.START_DATE_ACTIVE           AS 供应商起始日期,
       ASP.ENABLED_FLAG                AS 供应商启用标识,
       ASP.END_DATE_ACTIVE             AS 供应商终止日期,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS 银行,
       IEB.BANK_BRANCH_NAME            AS 分行,
       IEB.BRANCH_PARTY_ID             AS 分行ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS 银行账户,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS 账户主要责任人ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS 账户主要责任人,
       
       IAO.END_DATE     AS 账户责任人终止日期,
       IAO.PRIMARY_FLAG AS 账户主要责任人标识,
       
       IEB.START_DATE AS 银行起始日期,
       IEB.END_DATE AS 银行终止日期,
       (SELECT T.START_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行起始日期,
       (SELECT T.END_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行终止日期,
       
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
                   AND PAY.SITE_USE_TYPE = 'PAY')) AS 地址名称,
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
              '有效',
              '无效') AS 地址是否有效,
       
       IEP.ORG_ID,
       NULL       AS 业务实体,
       NULL       AS 业务实体生效日期,
       NULL       AS 业务实体失效日期,
       
       IEP.SUPPLIER_SITE_ID,
       NULL,
       NULL,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS 银行账户起始日期,
       USES.END_DATE                  AS 银行账户终止日期

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

--第三层（地址-业务实体关联银行）
SELECT ASP.VENDOR_ID   AS 供应商ID,
       ASP.VENDOR_NAME AS 供应商名称,
       
       ASP.SEGMENT1                    AS 供应商编号,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS 供应商类型,
       ASP.START_DATE_ACTIVE           AS 供应商起始日期,
       ASP.ENABLED_FLAG                AS 供应商启用标识,
       ASP.END_DATE_ACTIVE             AS 供应商终止日期,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS 银行,
       IEB.BANK_BRANCH_NAME            AS 分行,
       IEB.BRANCH_PARTY_ID             AS 分行ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS 银行账户,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS 账户主要责任人ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS 账户主要责任人,
       
       IAO.END_DATE     AS 账户责任人终止日期,
       IAO.PRIMARY_FLAG AS 账户主要责任人标识,
       
       IEB.START_DATE AS 银行起始日期,
       IEB.END_DATE AS 银行终止日期,
       (SELECT T.START_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行起始日期,
       (SELECT T.END_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行终止日期,
       
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
                   AND PAY.SITE_USE_TYPE = 'PAY')) AS 地址名称,
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
              '有效',
              '无效') AS 地址是否有效,
       
       IEP.ORG_ID,
       (SELECT TRIM(SUBSTR(HOU.NAME, 4))
           FROM HR_ORGANIZATION_UNITS HOU
          WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID)
       --AND SYSDATE BETWEEN NVL(HOU.DATE_FROM,SYSDATE-1) AND NVL(HOU.DATE_TO,SYSDATE+1)
        AS 业务实体,
       (SELECT HOU.DATE_FROM
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS 业务实体生效日期,
       (SELECT HOU.DATE_TO
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS 业务实体失效日期,
       
       IEP.SUPPLIER_SITE_ID,
       NULL                 AS 地点,
       NULL                 AS 地点失效日期,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS 银行账户起始日期,
       USES.END_DATE                  AS 银行账户终止日期

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

--第四层（地点关联银行）
SELECT ASP.VENDOR_ID   AS 供应商ID,
       ASP.VENDOR_NAME AS 供应商名称,
       
       ASP.SEGMENT1                    AS 供应商编号,
       ASP.VENDOR_TYPE_LOOKUP_CODE     AS 供应商类型,
       ASP.START_DATE_ACTIVE           AS 供应商起始日期,
       ASP.ENABLED_FLAG                AS 供应商启用标识,
       ASP.END_DATE_ACTIVE             AS 供应商终止日期,
       ASP.PARTY_ID,
       IEB.EXT_BANK_ACCOUNT_ID,
       IEB.BANK_PARTY_ID,
       IEB.BANK_NAME                   AS 银行,
       IEB.BANK_BRANCH_NAME            AS 分行,
       IEB.BRANCH_PARTY_ID             AS 分行ID,
       IEB.BANK_ACCOUNT_ID,
       IEB.BANK_ACCOUNT_NUMBER         AS 银行账户,
       IEB.PRIMARY_ACCT_OWNER_PARTY_ID AS 账户主要责任人ID,
       IEB.PRIMARY_ACCT_OWNER_NAME     AS 账户主要责任人,
       
       IAO.END_DATE     AS 账户责任人终止日期,
       IAO.PRIMARY_FLAG AS 账户主要责任人标识,
       
       IEB.START_DATE AS 银行起始日期,
       IEB.END_DATE AS 银行终止日期,
       (SELECT T.START_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行起始日期,
       (SELECT T.END_DATE
          FROM IBY_EXT_BANK_BRANCHES_V T
         WHERE T.BRANCH_PARTY_ID = IEB.BRANCH_PARTY_ID) AS 分行终止日期,
       
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
                   AND PAY.SITE_USE_TYPE = 'PAY')) AS 地址名称,
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
              '有效',
              '无效') AS 地址是否有效,
       
       IEP.ORG_ID,
       (SELECT TRIM(SUBSTR(HOU.NAME, 4))
           FROM HR_ORGANIZATION_UNITS HOU
          WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID)
       --AND SYSDATE BETWEEN NVL(HOU.DATE_FROM,SYSDATE-1) AND NVL(HOU.DATE_TO,SYSDATE+1)
        AS 业务实体,
       (SELECT HOU.DATE_FROM
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS 业务实体生效日期,
       (SELECT HOU.DATE_TO
          FROM HR_ORGANIZATION_UNITS HOU
         WHERE HOU.ORGANIZATION_ID = IEP.ORG_ID) AS 业务实体失效日期,
       
       IEP.SUPPLIER_SITE_ID,
       (SELECT ASS.VENDOR_SITE_CODE
          FROM AP_SUPPLIER_SITES_ALL ASS
         WHERE ASS.VENDOR_SITE_ID = IEP.SUPPLIER_SITE_ID
           AND ASS.PURCHASING_SITE_FLAG = 'Y'
           AND ASS.PAY_SITE_FLAG = 'Y') AS 地点,
       (SELECT ASS.INACTIVE_DATE
          FROM AP_SUPPLIER_SITES_ALL ASS
         WHERE ASS.VENDOR_SITE_ID = IEP.SUPPLIER_SITE_ID
           AND ASS.PURCHASING_SITE_FLAG = 'Y'
           AND ASS.PAY_SITE_FLAG = 'Y') AS 地点失效日期,
       
       USES.INSTRUMENT_PAYMENT_USE_ID,
       USES.EXT_PMT_PARTY_ID,
       USES.INSTRUMENT_ID,
       USES.PAYMENT_FUNCTION,
       USES.START_DATE                AS 银行账户起始日期,
       USES.END_DATE                  AS 银行账户终止日期

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
