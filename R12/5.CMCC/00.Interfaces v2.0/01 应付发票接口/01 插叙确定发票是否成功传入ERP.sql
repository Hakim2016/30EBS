--hejingjing v1.0 ap
/*
先查头状态
再头行状态
*/


SELECT
--DISTINCT CAI.PROCESS_STATUS_LOOKUP_CODE
--DISTINCT CAIL.PROCESS_STATUS_LOOKUP_CODE
 cai.pri_key,
 --cai.invoice_header_id,
 --cail.invoice_line_id,
 cai.source_document_number       来源单据编号报账单号,
 --CAI.SOURCE_DOCUMENT_ID         来源单据头ID,
 --CAI.SOURCE_DOCUMENT_LINE_ID    来源单据行ID,
 --CAI.COMPANY_CODE                公司代码,
 --hou.operating_unit              业务实体,
 cai.batch_name                  发票批,
 cai.invoice_num                 发票编号,
 cai.process_date                头处理日期,
 cai.process_status_lookup_code  头处理状态,
 cai.process_message             头处理信息,
 --cail.process_status_lookup_code AS 行处理状态,
 --cail.process_message            AS 行处理消息,
 cai.vendor_number               供应商编号,
 cai.vendor_name                 供应商名称,
 cai.employee_number             AS 制单人编号,
 cai.attribute7                  AS 审核人,
 cai.emp_number                  员工工号,
 cai.emp_name                    员工名,
 cai.invoice_date                发票日期,
 cai.invoice_amount              发票金额,
 cai.description                 头摘要,
 cai.*

  FROM cux.cux_ap_ws_invoices_itf     cai
  where 1=1
  and cai.source_document_number in (
  '302222C25181029003'

  );
/*
应付发票
头处理状态：
APPROVAL
VALIDATED_FAILED
ERROR

行处理状态：
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
 cai.source_document_number       来源单据编号报账单号,
 cail.source_document_line_number 行号,
 cail.creation_date,
 --CAI.SOURCE_DOCUMENT_ID         来源单据头ID,
 --CAI.SOURCE_DOCUMENT_LINE_ID    来源单据行ID,
 --CAI.COMPANY_CODE                公司代码,
 hou.operating_unit              业务实体,
 cai.batch_name                  发票批,
 cai.invoice_num                 发票编号,
 cai.process_date                头处理日期,
 cai.process_status_lookup_code  头处理状态,
 cai.process_message             头处理信息,
 cail.process_status_lookup_code AS 行处理状态,
 cail.process_message            AS 行处理消息,
 cai.vendor_number               供应商编号,
 cai.vendor_name                 供应商名称,
 cai.employee_number             AS 制单人编号,
 cai.attribute7                  AS 审核人,
 cai.emp_number                  员工工号,
 cai.emp_name                    员工名,
 cai.invoice_date                发票日期,
 cai.invoice_amount              发票金额,
 cai.description                 头摘要,
 cail.process_message            行处理信息,
 --9999999                         AS 行金额,
 --9999999                         AS 发票行摘要,
 cail.process_date               AS 处理时间,
 --999999                          AS 合同号,
 cail.dist_code_combination      AS 发票行默认账户,
 cai.*,
 cail.*

  FROM cux.cux_ap_ws_invoices_itf     cai,
       apps.cux_fnd_operating_units_v hou,
       cux.cux_ap_ws_invoice_line_itf cail
 WHERE 1 = 1
   AND hou.company_code = cai.company_code
   AND cai.invoice_header_id = cail.invoice_header_id --INVOICE_LINE_ID
      --AND CAI.CREATION_DATE > TRUNC(SYSDATE) - 180 --+0.5--限制今天
      --AND CAI.PROCESS_STATUS_LOOKUP_CODE <> 'APPROVAL'
   AND hou.operating_unit LIKE '%ZJ%'
   and cai.source_document_number in 
   (
   '302226C20181102004',
'302226C20181101010',
'302226C20181101011',
'302226C20181102001',
'302226C20181102003',
'302224C20181102007',
'302224C20181102002',
'302224C20181102003',
'302224C20181102005',
'302224C20181102006',
'302224R02181102006'
   )
      --and cai.pri_key = 373449
 ORDER BY cai.last_update_date DESC;
