SELECT T.PRI_KEY,
       HOU.OPERATING_UNIT            业务实体,
       T.SOURCE_DOCUMENT_NUM         单据编号,
       T.PROCESS_STATUS_LOOKUP_CODE  头表处理状态,
       T.PROCESS_MESSAGE             头表错误消息,
       TL.PROCESS_STATUS_LOOKUP_CODE 行状态,
       TL.PROCESS_MESSAGE            行处理信息,
       PV.SEGMENT1                   供应商编码, --
       PV.VENDOR_NAME                供应商名称, --
       TL.R_BANK_ACCOUNT_NAME        收款银行账户,
       TL.R_BANK_ACCOUNT_NUM         收款银行账号,
       T.APPLYER_CODE                报账人工号,
       T.APPLYER_NAME                报账人名称,
       T.DEPARTMENT_NAME             AS 报账部门名称,
       T.BANK_ACCOUNT_NAME           AS 付款银行账户名称,
       T.BANK_ACCOUNT_NUM            AS 付款银行账号,
       T.ACCOUNTANT_CODE             AS 复核会计编号,
       T.ACCOUNTANT_NAME             AS 复核会计名称,
       T.REVIEW_ACCOUNTANT_CODE      AS 省复核会计编号,
       T.REVIEW_ACCOUNTANT_NAME      AS 省复核会计名称,
       T.COMMAND_SENT_TIME           AS 指令发送时间,
       T.RBS_SUMMARY                 AS 报账头摘要,
       T.PAYMENT_METHOD_CODE         付款方法代码,
       TL.R_CNAPS_NUMBER             分行编号,
       TL.R_CNAPS_NAME               分行名称,
       TL.AP_STATUS_LOOKUP_CODE      付款状态,
       TL.BANK_DESC                  银行摘要,
       TL.CMS_DESC,
       TL.CASHIER_DESC               出纳摘要,
       T.LAST_UPDATE_DATE            最后更新时间,
       FU.USER_NAME                  最后更新人,
       T.*,
       TL.*
  FROM APPS.PO_VENDORS                PV,
       APPS.CUX_FND_OPERATING_UNITS_V HOU,
       APPS.CUX_AP_WS_CHECKS_ITF      T,
       CUX.CUX_AP_WS_PAY_DETAIL_ITF   TL,
       APPS.FND_USER                  FU
 WHERE 1 = 1
   AND HOU.COMPANY_CODE = T.COMPANY_CODE
   AND T.CHECK_ID = TL.CHECK_ID
   AND T.VENDOR_NUMBER = PV.SEGMENT1
   AND T.LAST_UPDATED_BY = FU.USER_ID
   AND T.PRI_KEY IN (SELECT T.PRI_KEY --, T.SOURCE_DOCUMENT_NUM, T.*
                       FROM APPS.CUX_AP_WS_CHECKS_ITF      T,
                            APPS.CUX_FND_OPERATING_UNITS_V HOU
                      WHERE 1 = 1
                        AND HOU.COMPANY_CODE = T.COMPANY_CODE
                        AND HOU.OPERATING_UNIT LIKE 'OU_ZJ%'
                        AND T.PROCESS_STATUS_LOOKUP_CODE IN (
                                                             --'ORDER_SEND',
                                                             'SEND_DUPLICATED',
                                                             'CHECK_FAILED',
                                                             'ORDER_FAILED',
                                                             --'FINAL',
                                                             'INVOKE_FAILED')
                           
                        AND NOT EXISTS (SELECT 1
                               FROM APPS.CUX_AP_WS_CHECKS_ITF T2
                              WHERE 1 = 1
                                AND T2.PRI_KEY = T.PRI_KEY
                                AND T2.PROCESS_STATUS_LOOKUP_CODE IN
                                    ('ORDER_SEND',
                                     --'SEND_DUPLICATED',
                                     --'CHECK_FAILED',
                                     --'ORDER_FAILED',
                                     'FINAL'
                                     --'INVOKE_FAILED'
                                     )));
