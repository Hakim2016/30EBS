
--AP 发票取消
--CUX:导入发票取消信息服务查询(CUX_AP_WS_INV_CANCEL_ITF_V)

SELECT APC.PRI_KEY,
       HOU.OPERATING_UNIT,
       APC.CREATION_DATE,
       apc.last_update_date,
       APC.SOURCE_DOCUMENT_NUMBER 来源系统单据号,
       apc.invoice_num 发票编号,
       apc.process_status_lookup_code 处理状态,
       apc.process_message
       ,
       APC.*
  FROM APPS.CUX_AP_WS_INV_CANCEL_ITF  APC,
       APPS.CUX_FND_OPERATING_UNITS_V HOU

 WHERE 1 = 1
   AND APC.COMPANY_CODE = HOU.COMPANY_CODE
--AND HOU.OPERATING_UNIT LIKE 'OU_ZJ%'
