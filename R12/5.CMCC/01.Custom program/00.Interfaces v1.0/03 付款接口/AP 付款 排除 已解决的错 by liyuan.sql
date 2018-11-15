SELECT
--distinct tl.process_status_lookup_code
t.PRI_KEY,
--T.PROCESS_GROUP_ID            ����ID,
 HOU.OPERATING_UNIT            ҵ��ʵ��,
 T.SOURCE_DOCUMENT_NUM         ���ݱ��,
 T.PROCESS_STATUS_LOOKUP_CODE  ͷ����״̬,
 T.PROCESS_MESSAGE             ͷ�������Ϣ,
 TL.PROCESS_STATUS_LOOKUP_CODE ��״̬,
 TL.PROCESS_MESSAGE            �д�����Ϣ,
 PV.SEGMENT1                   ��Ӧ�̱���, --
 PV.VENDOR_NAME                ��Ӧ������, --
 TL.R_BANK_ACCOUNT_NAME        �տ������˻�,
 TL.R_BANK_ACCOUNT_NUM         �տ������˺�,
 T.APPLYER_CODE                �����˹���,
 T.APPLYER_NAME                ����������,
 T.DEPARTMENT_NAME             AS ���˲�������,
 T.BANK_ACCOUNT_NAME           AS ���������˻�����,
 T.BANK_ACCOUNT_NUM            AS ���������˺�,
 T.ACCOUNTANT_CODE             AS ���˻�Ʊ��,
 T.ACCOUNTANT_NAME             AS ���˻������,
 T.REVIEW_ACCOUNTANT_CODE      AS ʡ���˻�Ʊ��,
 T.REVIEW_ACCOUNTANT_NAME      AS ʡ���˻������,
 T.COMMAND_SENT_TIME           AS ָ���ʱ��,
 T.RBS_SUMMARY                 AS ����ͷժҪ,
 T.PAYMENT_METHOD_CODE         ���������,
 --T.PROCESS_STATUS_LOOKUP_CODE  �ӿڱ���״̬,
 --T.PROCESS_MESSAGE             ͷ�������Ϣ,
 TL.R_CNAPS_NUMBER        ���б��,
 TL.R_CNAPS_NAME          ��������,
 TL.AP_STATUS_LOOKUP_CODE ����״̬,
 --TL.PROCESS_STATUS_LOOKUP_CODE ��״̬,
 --TL.PROCESS_MESSAGE            �д�����Ϣ,
 TL.BANK_DESC       ����ժҪ,
 TL.CMS_DESC,
 TL.CASHIER_DESC    ����ժҪ,
 T.LAST_UPDATE_DATE ������ʱ��,
 FU.USER_NAME       ��������,
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
      --AND t.creation_date > trunc(SYSDATE) + 0.5
      /*AND t.creation_date >
      to_date('2018-10-29 18:00:00', 'YYYY-MM-DD HH24:MI:SS')*/
      /*AND t.creation_date between
          to_date('2018-10-31 18:00:00', 'YYYY-MM-DD HH24:MI:SS') and to_date('2018-11-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS') -- ����
      */
      --AND t.creation_date BETWEEN
      --    to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') AND to_date('2018-10-31 18:00:00', 'YYYY-MM-DD HH24:MI:SS') -- ҹ��
      --AND t.process_status_lookup_code = 'PENDING'--δ����״̬
   AND T.PROCESS_STATUS_LOOKUP_CODE IN
       ('CHECK_FAILED',
        'ORDER_FAILED',
        'INVOKE_FAILED',
        'SEND_DUPLICATED',
        'CHECK_APPROVED') --����״̬
   AND NOT EXISTS (SELECT 1
          FROM CUX.CUX_AP_WS_CHECKS_ITF WC
         WHERE WC.PRI_KEY = T.PRI_KEY
           AND WC.PROCESS_STATUS_LOOKUP_CODE = 'FINAL')
   AND (TL.AP_STATUS_LOOKUP_CODE = 'ERROR' OR
       TL.PROCESS_STATUS_LOOKUP_CODE IN
       ('CHECK_FAILED',
         'ORDER_FAILED',
         'INVOKE_FAILED',
         'BANK_FAILED',
         'SEND_DUPLICATED',
         'CHECK_APPROVED')) --����״̬
   AND (HOU.OPERATING_UNIT LIKE 'OU_ZJ%') --�㽭ʡ
 ORDER BY T.LAST_UPDATE_DATE DESC
