--hejingjing v1.0 ap
/*
�㽭apͷ״̬


�㽭ap��״̬


*/

/*
Ӧ����Ʊ
ͷ����״̬��
APPROVAL
VALIDATED_FAILED
ERROR

�д���״̬��
VALIDATED
PENDING
VALIDATED_FAILED
ERROR

*/
SELECT
--DISTINCT CAI.PROCESS_STATUS_LOOKUP_CODE
--DISTINCT CAIL.PROCESS_STATUS_LOOKUP_CODE
 cai.pri_key,
 --cai.invoice_header_id,
 --cail.invoice_line_id,
 cai.source_document_number       ��Դ���ݱ�ű��˵���,
 cail.source_document_line_number �к�,
 cail.creation_date,
 --CAI.SOURCE_DOCUMENT_ID         ��Դ����ͷID,
 --CAI.SOURCE_DOCUMENT_LINE_ID    ��Դ������ID,
 --CAI.COMPANY_CODE                ��˾����,
 hou.operating_unit              ҵ��ʵ��,
 cai.batch_name                  ��Ʊ��,
 cai.invoice_num                 ��Ʊ���,
 cai.process_date                ͷ��������,
 cai.process_status_lookup_code  ͷ����״̬,
 cai.process_message             ͷ������Ϣ,
 cail.process_status_lookup_code AS �д���״̬,
 cail.process_message            AS �д�����Ϣ,
 cai.vendor_number               ��Ӧ�̱��,
 cai.vendor_name                 ��Ӧ������,
 cai.employee_number             AS �Ƶ��˱��,
 cai.attribute7                  AS �����,
 cai.emp_number                  Ա������,
 cai.emp_name                    Ա����,
 cai.invoice_date                ��Ʊ����,
 cai.invoice_amount              ��Ʊ���,
 cai.description                 ͷժҪ,
 cail.process_message            �д�����Ϣ,
 --9999999                         AS �н��,
 --9999999                         AS ��Ʊ��ժҪ,
 cail.process_date               AS ����ʱ��,
 --999999                          AS ��ͬ��,
 cail.dist_code_combination      AS ��Ʊ��Ĭ���˻�,
 cai.*,
 cail.*

  FROM cux.cux_ap_ws_invoices_itf     cai,
       apps.cux_fnd_operating_units_v hou,
       cux.cux_ap_ws_invoice_line_itf cail
 WHERE 1 = 1
   AND hou.company_code = cai.company_code
   AND cai.invoice_header_id = cail.invoice_header_id --INVOICE_LINE_ID
      --AND CAI.CREATION_DATE > TRUNC(SYSDATE) - 180 --+0.5--���ƽ���
      --AND CAI.PROCESS_STATUS_LOOKUP_CODE <> 'APPROVAL'
   AND hou.operating_unit LIKE '%ZJ%'
      --and cai.pri_key = 373449
   AND cail.process_status_lookup_code IN (
                                           --'VALIDATED',
                                           'PENDING',
                                           'VALIDATED_FAILED',
                                           'ERROR',
                                           'VALIDATED_FAILED')
      
   AND cai.pri_key IN
       (SELECT cai.pri_key
          FROM cux.cux_ap_ws_invoices_itf     cai,
               apps.cux_fnd_operating_units_v hou /*,
               CUX.CUX_AP_WS_INVOICE_LINE_ITF CAIL*/
         WHERE 1 = 1
           AND hou.company_code = cai.company_code
           AND hou.operating_unit LIKE '%ZJ%'
           AND cai.process_status_lookup_code IN ('VALIDATED_FAILED', 'ERROR')
              
           AND NOT EXISTS
         (SELECT 1 from cux.cux_ap_ws_invoices_itf cai2 WHERE 1 = 1 AND cai2.pri_key = cai.pri_key AND cai2.process_status_lookup_code IN('VALIDATED',
                                                                                                                                               'APPROVAL')))

 ORDER BY cai.last_update_date DESC;
