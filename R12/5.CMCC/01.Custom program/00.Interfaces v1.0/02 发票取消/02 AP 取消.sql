
--AP ��Ʊȡ��
--CUX:���뷢Ʊȡ����Ϣ�����ѯ(CUX_AP_WS_INV_CANCEL_ITF_V)

SELECT APC.PRI_KEY,
       HOU.OPERATING_UNIT,
       APC.CREATION_DATE,
       apc.last_update_date,
       APC.SOURCE_DOCUMENT_NUMBER ��Դϵͳ���ݺ�,
       apc.invoice_num ��Ʊ���,
       apc.process_status_lookup_code ����״̬,
       apc.process_message
       ,
       APC.*
  FROM APPS.CUX_AP_WS_INV_CANCEL_ITF  APC,
       APPS.CUX_FND_OPERATING_UNITS_V HOU

 WHERE 1 = 1
   AND APC.COMPANY_CODE = HOU.COMPANY_CODE
--AND HOU.OPERATING_UNIT LIKE 'OU_ZJ%'
