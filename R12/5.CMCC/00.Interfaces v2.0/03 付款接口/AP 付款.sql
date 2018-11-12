/*
付款
头所有处理状态
ORDER_SEND
SEND_DUPLICATED
CHECK_FAILED
ORDER_FAILED
FINAL
INVOKE_FAILED

行所有处理状态
ORDER_SEND
BANK_PAID
CHECK_APPROVED
SEND_DUPLICATED
REFUND
ORDER_FAILED
CHECK_FAILED
NEW
BANK_FAILED
INVOKE_FAILED

*/
SELECT
--distinct tl.process_status_lookup_code
--T.PROCESS_GROUP_ID            分组ID,
 HOU.OPERATING_UNIT            业务实体,
 T.SOURCE_DOCUMENT_NUM         单据编号,
 T.PROCESS_STATUS_LOOKUP_CODE  头表处理状态,
 T.PROCESS_MESSAGE             头表错误消息,
 TL.PROCESS_STATUS_LOOKUP_CODE 行状态,
 TL.PROCESS_MESSAGE            行处理信息,
 PV.SEGMENT1                   供应商编码,--
 PV.VENDOR_NAME                供应商名称,--
 TL.R_BANK_ACCOUNT_NAME        收款银行账户,
 TL.R_BANK_ACCOUNT_NUM         收款银行账号,
 T.APPLYER_CODE                报账人工号,
 T.APPLYER_NAME                报账人名称,
 t.department_name AS 报账部门名称,
 t.BANK_ACCOUNT_NAME AS 付款银行账户名称,
 t.BANK_ACCOUNT_NUM AS 付款银行账号,
 t.ACCOUNTANT_CODE AS 复核会计编号,
 t.ACCOUNTANT_NAME AS 复核会计名称,
 t.REVIEW_ACCOUNTANT_CODE AS 省复核会计编号,
 t.REVIEW_ACCOUNTANT_NAME AS 省复核会计名称,
 t.COMMAND_SENT_TIME AS 指令发送时间,
 t.RBS_SUMMARY AS 报账头摘要,
 T.PAYMENT_METHOD_CODE         付款方法代码,
 --T.PROCESS_STATUS_LOOKUP_CODE  接口表处理状态,
 --T.PROCESS_MESSAGE             头表错误消息,
 TL.R_CNAPS_NUMBER             分行编号,
 TL.R_CNAPS_NAME               分行名称,
 TL.AP_STATUS_LOOKUP_CODE      付款状态,
 --TL.PROCESS_STATUS_LOOKUP_CODE 行状态,
 --TL.PROCESS_MESSAGE            行处理信息,
 TL.BANK_DESC                  银行摘要,
 TL.CMS_DESC,
 TL.CASHIER_DESC               出纳摘要,
 T.LAST_UPDATE_DATE            最后更新时间,
 FU.USER_NAME                  最后更新人,
 T.*,
 TL.*
  FROM APPS.PO_VENDORS                PV,
       APPS.CUX_FND_OPERATING_UNITS_V HOU,
       CUX.CUX_AP_WS_PAY_DETAIL_ITF   TL,
       APPS.CUX_AP_WS_CHECKS_ITF      T,
       APPS.FND_USER                  FU
 WHERE 1 = 1
   AND HOU.COMPANY_CODE = T.COMPANY_CODE
   AND T.CHECK_ID = TL.CHECK_ID
   AND T.VENDOR_NUMBER = PV.SEGMENT1
   AND T.LAST_UPDATED_BY = FU.USER_ID
      --AND t.creation_date > trunc(SYSDATE)
   AND T.PROCESS_STATUS_LOOKUP_CODE --'PENDING'--头处理状态
       IN (--'ORDER_SEND',
           'SEND_DUPLICATED',
           'CHECK_FAILED',
           'ORDER_FAILED',
           --'FINAL',
           'INVOKE_FAILED')
   AND TL.PROCESS_STATUS_LOOKUP_CODE IN      
       ('ORDER_SEND',
        'BANK_PAID',
        'CHECK_APPROVED',
        'SEND_DUPLICATED',
        'REFUND',
        'ORDER_FAILED',
        'CHECK_FAILED',
        'NEW',
        'BANK_FAILED',
        'INVOKE_FAILED')
      /*and t.PROCESS_STATUS_LOOKUP_CODE in 
      ('CHECK_FAILED','ORDER_FAILED','INVOKE_FAILED','SEND_DUPLICATED', 'CHECK_APPROVED')--错误状态
      */
      --AND (hou.operating_unit LIKE 'OU_ZJ%')--浙江省
   AND T.SOURCE_DOCUMENT_NUM = '302310E02180922001'--'303889C13180929841'
 ORDER BY T.LAST_UPDATE_DATE DESC;
