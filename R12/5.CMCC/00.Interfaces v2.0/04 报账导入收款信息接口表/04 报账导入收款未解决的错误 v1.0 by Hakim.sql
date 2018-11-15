--报账导入收款信息接口表

SELECT ARI.INTERFACE_ID intf_id,
       ARI.RESOURCE_ID pri_key,
       ari.last_update_date,
       --ARI.CREATION_DATE,
       ARI.PROCESS_STATUS_LOOKUP_CODE 处理状态,
       ARI.PROCESS_MESSAGE            处理信息,
       ari.amount,
       ARI.BATCH_NUMBER,
       ARI.RECEIPT_NUMBER,
       ARI.*
  FROM APPS.CUX_AR_BAT_RECEIPT_ITF_ALL ARI
 WHERE 1 = 1
      --AND ARI.ORG_NAME LIKE '%ZJ%'
      --AND ARI.PROCESS_STATUS_LOOKUP_CODE <> 'SUCCESS'
      --AND ARI.CREATION_DATE > TRUNC(SYSDATE)
   AND ARI.RESOURCE_ID IN
      
       (SELECT ARI.RESOURCE_ID
          FROM APPS.CUX_AR_BAT_RECEIPT_ITF_ALL ARI
         WHERE 1 = 1
           AND ARI.ORG_NAME LIKE '%ZJ%'
           AND ARI.PROCESS_STATUS_LOOKUP_CODE <> 'SUCCESS'
           AND NOT EXISTS
         (SELECT 1
                  FROM APPS.CUX_AR_BAT_RECEIPT_ITF_ALL ARI2
                 WHERE 1 = 1
                   AND ARI2.RESOURCE_ID = ARI.RESOURCE_ID
                   AND ARI2.PROCESS_STATUS_LOOKUP_CODE IN ('SUCCESS', 'ENTER'))
        )
order by ari.last_update_date desc
;
--收款导入的所有处理状态
/*
SUCCESS
ERROR
ENTER
*/
SELECT DISTINCT ARI.PROCESS_STATUS_LOOKUP_CODE
  FROM APPS.CUX_AR_BAT_RECEIPT_ITF_ALL ARI;

--
select * from apps.CUX_AR_BAT_RECEIPT_ITF_all;
select * from apps.CUX_AR_BAT_RECEIPT_ITF_all ARI
  where 1=1
  and ari.RECEIPT_NUMBER = '302229R12181101001';
